-- Only an already-installed Lua 5.1 runtime is approved for this standalone runner.
local namespace={}
for _,name in ipairs({"Core","Storage","Data","Knowledge","Collectors","KnowledgeCheck","Details","ViewModel","Dashboard","SelfTests","Commands"}) do
    local chunk,why=loadfile("CraftArmy/"..name..".lua")
    assert(chunk,why); chunk("CraftArmy",namespace)
end
local result=namespace.SelfTests.Run()
for _,line in ipairs(result.lines) do print(line) end
print(result.passed.." passed; "..result.failed.." failed (pure fixtures only)")
if result.failed>0 then os.exit(1) end

-- Standalone-only K6 supplement. No production namespace/runtime/DB is borrowed.
-- Each Core chunk sees its own math table; the host math/native field is untouched.
local hostMath, hostNative, hostPcall = math, rawget(math,"isfinite"), pcall
local supplementChecks=0
local function check(ok, why)
    assert(ok, "K6 supplement: "..why)
    supplementChecks=supplementChecks+1
end
local function ieee(n) return n==n and n>-hostMath.huge and n<hostMath.huge end
local function isolated()
    local counters={pcalls=0, args={}}
    local env=setmetatable({}, {__index=function(_,key)
        if key=="math" then return nil end
        return _G[key]
    end})
    local function reset()
        local library={}
        for k,v in pairs(hostMath) do library[k]=v end
        library.isfinite=nil
        env.math=library
        counters.pcalls=0; counters.args={}
    end
    env.pcall=function(...)
        counters.pcalls=counters.pcalls+1
        return hostPcall(...)
    end
    reset()
    local ns={}
    local chunk,why=loadfile("CraftArmy/Core.lua")
    assert(chunk,why); setfenv(chunk,env); chunk("CraftArmy",ns)
    return ns.Core,env,counters,reset
end

-- Frozen pre-K6 boundedData BODY, using the SAME isolated Core's public guards.
-- Only its declaration/return wrapper and function environment are test plumbing.
local function oldWalker(Core,env)
    local function boundedData(value, makeCopy)
        local seen, count = {}, 0
        local function copy(v, depth)
            count = count + 1
            if count > 50000 or depth > 20 then error("data traversal limit") end
            local kind = type(v)
            if kind == "nil" or kind == "boolean" then return v end
            if kind == "number" and Core.Finite(v) then return v end
            if kind == "string" and #v <= 4096 then return v end
            if kind ~= "table" or getmetatable(v) or seen[v] then error("invalid/cyclic data") end
            seen[v] = true
            local out = makeCopy and {} or nil
            for k, x in pairs(v) do
                if not ((type(k) == "string" and #k <= 128) or Core.Integer(k, 0)) then
                    error("invalid key")
                end
                local child = copy(x, depth + 1)
                if makeCopy then out[k] = child end
            end
            seen[v] = nil
            return out
        end
        local ok, result = pcall(copy, value, 0)
        if ok then
            if makeCopy then return result end
            return true
        end
        return nil, tostring(result)
    end
    setfenv(boundedData,env)
    return function(value) return boundedData(value,true) end
end

local function class(why)
    if why==nil then return nil end
    for _,name in ipairs({"invalid/cyclic data","invalid key","data traversal limit"}) do
        if why:find(name,1,true) then return name end
    end
    error("unexpected rejection class: "..tostring(why))
end
local function equal(a,b)
    if type(a)~=type(b) then return false end
    if type(a)=="number" and a~=a and b~=b then return true end
    if type(a)~="table" then return a==b end
    for k,v in pairs(a) do if not equal(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
-- Identity-aware, cycle-safe input snapshot; assertions never copy via new Core.
local function unchanged(root)
    local records={}
    local function visit(v)
        if type(v)~="table" or records[v] then return end
        local record={meta=getmetatable(v), entries={}}; records[v]=record
        for k,x in pairs(v) do record.entries[k]=x; visit(k); visit(x) end
    end
    visit(root)
    return function()
        for t,r in pairs(records) do
            check(getmetatable(t)==r.meta,"input metatable unchanged")
            for k,v in pairs(r.entries) do
                check(t[k]==v or (type(v)=="number" and v~=v and t[k]~=t[k]),"input value/reference unchanged")
            end
            for k in pairs(t) do check(r.entries[k]~=nil,"no input key added") end
        end
    end
end
local PRIVATE="K6_PRIVATE_NATIVE_PAYLOAD"
local function install(env,counters,behavior)
    env.math.isfinite=function(n)
        local args=counters.args; args[#args+1]=n
        return behavior(n,#args)
    end
end
local function parity(name,input,setup,expected,expectedArgs)
    local Core,env,counters,reset=isolated()
    local oracle=oldWalker(Core,env)
    local verify=unchanged(input)
    local function run(copy)
        reset(); setup(Core,env,counters)
        local value,why=copy(input)
        local args={}; for i,n in ipairs(counters.args) do args[i]=n end
        local calls=counters.pcalls
        check(not why or not why:find(PRIVATE,1,true),name.." private payload omitted")
        verify()
        return value,class(why),args,calls
    end
    local value,why,args,calls=run(Core.Copy)
    local old,oldWhy,oldArgs,oldCalls=run(oracle)
    check(equal(value,old) and why==oldWhy,name.." frozen oracle value/error parity")
    check(why==expected,name.." expected rejection/acceptance")
    check(equal(args,oldArgs),name.." native argument order/count parity")
    if expectedArgs then check(equal(args,expectedArgs),name.." exact native arguments") end
    if why==nil then
        check(equal(value,input),name.." accepted values preserved")
        if type(input)=="table" then check(value~=input and old~=input,name.." fresh result") end
    else check(value==nil and old==nil,name.." no partial output") end
    return value,args,calls,oldCalls
end
local function standard(_,env,counters) install(env,counters,ieee) end
local function behavior(fn)
    return function(_,env,counters) install(env,counters,fn) end
end

local shared={answer=7}
local copied,args,newCalls,oldCalls=parity("normal true/aliases",{[2]=shared,again=shared,flag=false},standard,nil)
check(copied[2]~=copied.again and copied[2]~=shared and copied.again~=shared,"aliases expanded, not borrowed")
check(newCalls==1 and oldCalls==1+#args,"outer-only vs outer plus every native guard pcall")
parity("integer key/lower/value order",{[2]=7},standard,nil,{2,0,7})
parity("zero value",0,standard,nil,{0})
parity("false value",false,standard,nil,{})
parity("nil value",nil,standard,nil,{})
parity("native false",7,behavior(function() return false end),"invalid/cyclic data",{7})
parity("NaN",0/0,standard,"invalid/cyclic data")
parity("positive infinity",hostMath.huge,standard,"invalid/cyclic data",{hostMath.huge})
parity("negative infinity",-hostMath.huge,standard,"invalid/cyclic data",{-hostMath.huge})
-- Dispatch parity, not a valid classifier: a present native true is authoritative
-- even for IEEE host samples, proving no extra fallback comparison was inserted.
parity("native true authoritative NaN",0/0,behavior(function() return true end),nil)
parity("native true authoritative infinity",hostMath.huge,behavior(function() return true end),nil,{hostMath.huge})
parity("absent native",{[2]=7},function() end,nil,{})
parity("nonfunction native",7,function(_,env) env.math.isfinite=true end,"invalid/cyclic data",{})
for _,answer in ipairs({0,1,"true",{}}) do
    parity("nonboolean "..type(answer),7,behavior(function() return answer end),"invalid/cyclic data",{7})
end
parity("nil native result",7,behavior(function() return nil end),"invalid/cyclic data",{7})
for _,library in ipairs({false,42,"math"}) do
    parity("invalid math "..type(library),7,function(_,env) env.math=library end,"invalid/cyclic data",{})
end
parity("nil math",7,function(_,env) env.math=nil end,"invalid/cyclic data",{})
parity("native rawget not inherited",7,function(_,env)
    setmetatable(env.math,{__index={isfinite=function() error(PRIVATE) end}})
end,nil,{})
parity("reject literal zero",{[2]=7},behavior(function(n) return n~=0 end),"invalid key",{2,0})
parity("throw value",7,behavior(function() error(PRIVATE) end),"invalid/cyclic data",{7})
parity("throw key",{[2]=7},behavior(function() error(PRIVATE) end),"invalid key",{2})
parity("throw lower zero",{[2]=7},behavior(function(n) if n==0 then error(PRIVATE) end return true end),"invalid key",{2,0})
parity("negative key",{[-2]=7},standard,"invalid key",{-2,0})
parity("fractional key",{[2.5]=7},standard,"invalid key",{2.5,0})
parity("bad key type",{[false]=7},standard,"invalid key",{})
parity("bad value type",function() end,standard,"invalid/cyclic data",{})
parity("metatable",setmetatable({n=7},{}),standard,"invalid/cyclic data",{})
local cycle={}; cycle.self=cycle
parity("cycle",cycle,standard,"invalid/cyclic data",{})
parity("dynamic native replacement",{[2]=7},function(_,env,counters)
    install(env,counters,function()
        env.math.isfinite=function(n) counters.args[#counters.args+1]=n; return false end
        return true
    end)
end,"invalid key",{2,0})
parity("dynamic math replacement",{[2]=7},function(_,env,counters)
    install(env,counters,function()
        env.math={huge=hostMath.huge,isfinite=function(n) counters.args[#counters.args+1]=n; return false end}
        return true
    end)
end,"invalid key",{2,0})
parity("dynamic native absent",{[2]=7},function(_,env,counters)
    install(env,counters,function() env.math.isfinite=nil; return true end)
end,nil,{2})
parity("dynamic nonboolean normal return",{[2]=7},function(_,env,counters)
    install(env,counters,function(n,i) if i==2 then return "not boolean" end return true end)
end,"invalid key",{2,0})

-- One-shot reentry shares only the isolated env, never a walk's pending state.
-- Save/restore the fake function and counter fields even if the nested call fails.
for _,outerThrows in ipairs({false,true}) do
    parity("reentrant walk "..tostring(outerThrows),{[2]=7},function(Core,env,counters)
        local entered=false
        install(env,counters,function(n)
            if not entered then
                entered=true
                local savedNative=env.math.isfinite
                local savedArgs,savedCalls=counters.args,counters.pcalls
                local ok,why=hostPcall(function()
                    counters.args={}; counters.pcalls=0
                    env.math.isfinite=function() error(PRIVATE) end
                    local v,e=Core.Copy(9)
                    check(v==nil and class(e)=="invalid/cyclic data" and not e:find(PRIVATE,1,true),"nested Copy exception sanitized")
                    local db={schema=1,characters={},sentinel=9}
                    local opened,reason=Core.Open(db)
                    check(opened==nil and reason=="Invalid saved data; writes disabled (no reset).","nested Open fails closed")
                end)
                env.math.isfinite=savedNative
                counters.args=savedArgs; counters.pcalls=savedCalls
                assert(ok,why)
                if outerThrows then error(PRIVATE) end
            end
            return ieee(n)
        end)
    end,outerThrows and "invalid key" or nil,outerThrows and {2} or {2,0,7})
end

-- Successful native return must clear pending before an unrelated walk error.
local Core,env,counters=isolated()
install(env,counters,ieee)
local value,why=Core.Copy({[2]=function() end})
check(value==nil and class(why)=="invalid/cyclic data" and not why:find("invalid key",1,true),"pending key class cleared on normal return")

for _,site in ipairs({"value","key","lower"}) do
    local C,e,c=isolated()
    local db={schema=1,characters={}}
    if site=="value" then db.sentinel=987654321 else db[987654321]=false end
    local verify=unchanged(db)
    install(e,c,function(n)
        if (site~="lower" and n==987654321) or (site=="lower" and n==0) then error(PRIVATE) end
        return ieee(n)
    end)
    local opened,reason=C.Open(db)
    check(opened==nil and reason=="Invalid saved data; writes disabled (no reset).","Open "..site.." exception sanitized/no partial result")
    verify()
end

-- Root sentinel is unrelated to typed fields: visits 1/2/3 are the full Open,
-- alias-preserving mirror, and final expanded proposal respectively. No spies or
-- skipped passes; exercise real Apply and verify every original input reference.
for stage=1,3 do
    for _,throws in ipairs({false,true}) do
        local C,e,c=isolated()
        local character={guid="fixture",name="Fixture",realm="Test"}
        local identity={skillLineID=2913,parentID=773,profession=13,expansionID=11}
        local observations={unspent=C.Observation("observed",4,100,"fixture")}
        local db={schema=1,characters={},sentinel=987654321}
        local oldCharacters=db.characters
        local verify=unchanged({db,character,identity,observations})
        local visits=0
        install(e,c,function(n)
            if n==987654321 then
                visits=visits+1
                if visits==stage then if throws then error(PRIVATE) end return false end
            end
            return ieee(n)
        end)
        local applied,reason=C.Apply(db,character,identity,observations,100,"test")
        local reasons={"Invalid saved data; writes disabled (no reset).",
            "Bounded saved data mirror unavailable; scan not applied",
            "Assembled snapshot exceeds bounded saved data limits"}
        check(applied==nil and reason==reasons[stage],"Apply sentinel stage "..stage.." exact reason/throw="..tostring(throws))
        check(visits==stage,"Apply reached exact sentinel stage")
        check(db.characters==oldCharacters and db.characters.fixture==nil,"Apply no commit/reference change")
        check(not reason:find(PRIVATE,1,true),"Apply native payload omitted")
        verify()
    end
end

-- Mirror integer-key/lower-bound throw coverage: count a unique unrelated root
-- numeric key, then throw on that key or its immediately following literal zero.
for _,lower in ipairs({false,true}) do
    local C,e,c=isolated()
    local db={schema=1,characters={},[987654321]=false}
    local oldCharacters=db.characters
    local verify=unchanged(db)
    local visits,armed=0,false
    install(e,c,function(n)
        if n==987654321 then
            visits=visits+1
            if visits==2 then
                if not lower then error(PRIVATE) end
                armed=true
            end
        elseif n==0 and armed then error(PRIVATE) end
        return ieee(n)
    end)
    local applied,reason=C.Apply(db,{guid="fixture",name="Fixture",realm="Test"},
        {skillLineID=2913,parentID=773,profession=13,expansionID=11},{},100,"test")
    check(applied==nil and reason=="Bounded saved data mirror unavailable; scan not applied","mirror key/lower exception sanitized")
    check(visits==2 and db.characters==oldCharacters and next(oldCharacters)==nil,"mirror key/lower no commit")
    verify()
end
check(math==hostMath and rawget(math,"isfinite")==hostNative,"real host math/native never changed")
print("K6 isolated supplement: "..supplementChecks.." checks; 0 failed (standalone fake predicates, not native performance/API evidence)")

-- Standalone-only K7 supplement, appended AFTER the entire frozen K6 runner.
-- No addon namespace, host math, clock or public probe hook is modified.
do
    local checks=0
    local function test(ok,why)
        assert(ok,"K7 supplement: "..why); checks=checks+1
    end
    local function snapshot(root)
        local records={}
        local function visit(v)
            if type(v)~="table" or records[v] then return end
            local record={meta=getmetatable(v),entries={}}; records[v]=record
            for k,x in next,v do record.entries[k]=x; visit(k); visit(x) end
        end
        visit(root)
        return function()
            for t,r in pairs(records) do
                local same=getmetatable(t)==r.meta
                for k,v in next,r.entries do same=same and rawget(t,k)==v end
                for k in next,t do same=same and rawget(r.entries,k)~=nil end
                test(same,"all input entries/references/metatables unchanged")
            end
        end
    end
    local function array(n)
        local t={}; for i=1,n do t[i]=0 end; return t
    end
    local function own(t)
        local n=0; for _ in next,t do n=n+1 end; return n
    end
    local function chain(t,n)
        for _=1,n do t={t} end; return t
    end
    local function holey()
        local t=array(50000)
        for i=1,32000 do t[i]=nil end
        test(#t>=50000 and own(t)==18000,"sparse high border is only a hint, 18000 actual entries")
        return t
    end
    -- Trace ONLY fresh isolated Core's raw next calls. The old full walker uses
    -- pairs; no production predicate/clock or current149 namespace is replaced.
    local function fresh()
        local C,e,c,reset=isolated()
        local trace={calls=0,hinted=0,tables={}}
        e.next=function(t,k)
            trace.calls=trace.calls+1; trace.tables[t]=true
            if getmetatable(t)==nil and #t>=50000 then trace.hinted=trace.hinted+1 end
            return next(t,k)
        end
        return C,e,c,reset,trace
    end
    local function compare(name,input,expected,setup,traceCheck)
        local C,e,c,reset,trace=fresh()
        local oracle=oldWalker(C,e)
        local verify=snapshot(input)
        reset(); (setup or standard)(C,e,c)
        local value,why=C.Copy(input)
        local args=c.args
        test(c.pcalls==1,name.." one outer protected call")
        verify()
        if traceCheck then traceCheck(trace) end
        reset(); (setup or standard)(C,e,c)
        local old,oldWhy=oracle(input)
        test(equal(value,old) and class(why)==class(oldWhy),name.." frozen oracle values/error class")
        test(class(why)==expected,name.." expected acceptance/rejection")
        test(equal(args,c.args),name.." every native argument/order/count retained")
        test(not why or not why:find(PRIVATE,1,true),name.." private native payload omitted")
        if expected then test(value==nil and old==nil,name.." no partial output")
        elseif type(input)=="table" then test(value~=input and old~=input,name.." fresh owned output") end
        verify()
        return value
    end
    local function proof(name,input,oldClass)
        local C,e,c,_,trace=fresh(); install(e,c,ieee)
        local verify=snapshot(input)
        local value,why=C.Copy(input)
        test(value==nil and class(why)=="data traversal limit",name.." necessary reject/no partial output")
        test(#c.args==0 and c.pcalls==1,name.." proof needs no native calls, existing outer pcall only")
        test(trace.hinted==50000,name.." exactly 50000 confirmed own keys suffice")
        local old,oldWhy=oldWalker(C,e)(input)
        test(old==nil and class(oldWhy)==oldClass,name.." frozen old oracle also rejects")
        test(#c.args>0,name.." old oracle performed native prefix guards")
        test(not why:find(PRIVATE,1,true),name.." no native payload")
        verify()
    end

    local big=array(50001)
    test(own(big)==50001,"same full oversized payload constructed, not reduced")
    proof("50001 own children",big,"data traversal limit")
    proof("50000 own children",array(50000),"data traversal limit")
    compare("49999 children exact50000 visits",array(49999),nil)
    proof("reachable depth4",chain(big,4),"data traversal limit")
    compare("depth5 misses then full rejection",chain(big,5),"data traversal limit",nil,function(t)
        test(t.hinted==0,"depth5 not probed; depth4 checked before stopping descent")
    end)
    compare("sparse root high hint valid",holey(),nil,nil,function(t)
        test(t.hinted==18001+256,"sparse root counted to nil then bounded discovery")
    end)
    compare("two depth4 sparse hinted containers valid",chain({holey(),holey()},3),nil,nil,function(t)
        test(t.hinted==36002,"global probe count covers both hinted containers")
    end)
    compare("global50001 candidate cap falls back",chain({holey(),holey(),holey()},3),"data traversal limit",nil,function(t)
        test(t.hinted==50001,"global candidate probes capped across multiple holey containers")
        test(t.calls==50007,"candidate cap stops search immediately after six discovery entries")
    end)
    local sharedHoley=holey()
    compare("hinted alias search dedup still full expanded reject",chain({sharedHoley,sharedHoley,sharedHoley},3),"data traversal limit",nil,function(t)
        test(t.hinted==18001,"search counts aliased hinted container only once")
    end)
    compare("discovery256 valid fallback",array(300),nil,nil,function(t)
        test(t.calls==256,"exact256 raw discovery entries cap")
    end)
    local badEdges={}; for i=1,300 do badEdges[i]=string.rep("x",4097) end
    compare("discovery cap never accepts invalid",badEdges,"invalid/cyclic data")
    local tables={}; for i=1,70 do tables[i]={} end
    local function tableCap(t)
        test(own(t.tables)==64,"at most64 distinct tables searched")
        test(t.calls==127,"root64 discovery entries plus63 empty tables; then stop")
    end
    compare("table64 valid fallback",tables,nil,nil,tableCap)
    local badTables={}; for i=1,70 do badTables[i]={bad=function() end} end
    compare("table cap never accepts invalid",badTables,"invalid/cyclic data",nil,function(t)
        test(own(t.tables)==64,"invalid graph still stops search at64 tables")
    end)
    local shared=array(25000)
    local aliases=compare("alias expanded global limit",{shared,shared},"data traversal limit")
    test(aliases==nil,"search dedup is not validation dedup")
    local small={n=7}
    local expanded=compare("valid repeated aliases",{small,small},nil)
    test(expanded[1]~=expanded[2] and expanded[1]~=small,"full copy expands aliases independently")
    local cycle={7}; cycle[2]=cycle
    compare("cycle defers to ancestor guard",cycle,"invalid/cyclic data")
    local metamethods=0
    local function trap() metamethods=metamethods+1; error("K7_METAMETHOD_MUST_NOT_RUN") end
    for _,lock in ipairs({"locked",false}) do
        local t=setmetatable(array(50000),{__metatable=lock,__len=trap,__pairs=trap,__index=trap})
        -- The old guard treats a false lock as falsy (Lua5.1 pairs is raw).
        compare("metatable deferral "..tostring(lock),t,lock==false and "data traversal limit" or "invalid/cyclic data",nil,function(trace)
            test(trace.calls==0,"ANY metatable, including false, skips entire search")
        end)
    end
    compare("plain metatable deferral",setmetatable({7},{__len=trap,__pairs=trap,__index=trap}),"invalid/cyclic data")
    test(metamethods==0,"no user length/pairs/index metamethod calls")
    compare("unproven native throw",{7},"invalid key",behavior(function() error(PRIVATE) end))

    -- Deliberate error-priority difference: both paths reject multiply-invalid
    -- overbudget data. Do NOT assert false exact error/native-argument parity.
    local dual=array(50000)
    for i=1,50000 do dual[i]=function() end end
    proof("type-invalid and guaranteed overbudget",dual,"invalid/cyclic data")
    local dualCycle=array(50000)
    for i=1,50000 do dualCycle[i]=dualCycle end
    proof("cyclic and guaranteed overbudget",dualCycle,"invalid/cyclic data")
    do
        local C,e,c=fresh()
        install(e,c,function() error(PRIVATE) end)
        local value,why=C.Copy(big)
        test(value==nil and class(why)=="data traversal limit" and #c.args==0,"proof precedes otherwise-throwing native")
        local old,oldWhy=oldWalker(C,e)(big)
        test(old==nil and class(oldWhy)=="invalid key" and not oldWhy:find(PRIVATE,1,true),"native-fault old oracle also fails closed/sanitized")
    end

    do
        local C,e,c=fresh(); install(e,c,ieee)
        local character={guid="k7",name="Fixture",realm="Test"}
        local identity={skillLineID=2913,parentID=773,profession=13,expansionID=11}
        local balance={id=3261,quantity=4}
        local observations={unspent=C.Observation("observed",4,100,"fixture"),
            moxie=C.Observation("observed",balance,100,"fixture")}
        local db={schema=1,characters={}}
        local g=C.Apply(db,character,identity,observations,100,"test")
        test(g~=nil and C.Open(db)==db,"real valid Apply/Open still accepted")
        test(db.characters.k7~=character and g.identity~=identity and g.fields.unspent.last.value==4,"Apply owns identity/character/values")
        test(g.fields.moxie.last.value~=balance and g.fields.moxie.last.value.quantity==4,"Apply owns nested typed value")
        identity.name="caller changed"; observations.unspent.value=9
        balance.quantity=9
        test(g.identity.name==nil and g.fields.unspent.last.value==4 and g.fields.moxie.last.value.quantity==4,"caller mutation does not reach committed DB")
        local chars,oldCharacter,oldActive=db.characters,db.characters.k7,g
        local oversized={unspent=C.Observation("observed",big,101,"fixture")}
        local verify=snapshot({db,character,identity,oversized})
        c.args={}
        local applied,reason=C.Apply(db,character,identity,oversized,101,"test")
        test(applied==nil and reason=="Invalid scan data","real Apply same50001 payload fails incoming copy")
        test(#c.args>0,"Apply still fully validates existing DB before incoming proof")
        test(db.characters==chars and db.characters.k7==oldCharacter and oldCharacter.professions[2913].active==oldActive,"oversized Apply no commit/reference changes")
        verify()
        local malformed={schema=2,characters={}}
        local badChars=malformed.characters
        local verifyBad=snapshot(malformed)
        applied,reason=C.Apply(malformed,character,identity,oversized,101,"test")
        test(applied==nil and reason=="Unsupported or invalid CraftArmyDB; writes disabled. Back up saved data.","malformed DB reason precedes oversized incoming proof")
        test(malformed.characters==badChars and next(badChars)==nil,"malformed DB not committed")
        verifyBad()
        local nativeDB={schema=1,characters={},sentinel=123456789}
        local nativeChars=nativeDB.characters
        local verifyNative=snapshot(nativeDB)
        install(e,c,function(n) if n==123456789 then error(PRIVATE) end return ieee(n) end)
        applied,reason=C.Apply(nativeDB,character,identity,oversized,101,"test")
        test(applied==nil and reason=="Invalid saved data; writes disabled (no reset)." and not reason:find(PRIVATE,1,true),"DB native fault priority/sanitization precedes incoming proof")
        test(nativeDB.characters==nativeChars and next(nativeChars)==nil,"native DB fault no commit")
        verifyNative()
        local hugeDB={schema=1,characters={},extra=big}
        local hugeChars=hugeDB.characters
        local opened,openReason=C.Open(hugeDB)
        test(opened==nil and openReason=="Invalid saved data; writes disabled (no reset).","real Open oversized graph no partial output")
        test(hugeDB.characters==hugeChars and hugeDB.extra==big and own(big)==50001,"Open preserves oversized DB input")
    end
    test(supplementChecks==744,"entire K6 supplement count remains744")
    test(math==hostMath and rawget(math,"isfinite")==hostNative,"host math/native field untouched")
    print("K7 conservative proof supplement: "..checks.." checks; 0 failed (standalone soundness, not native performance/API evidence)")
end
