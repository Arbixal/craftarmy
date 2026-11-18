local _, D = ...
-- Pure Lua 5.1 core. No client APIs or SavedVariables are touched at load time.
D.SCHEMA = 1
D.LIMITS = { samples = 20, characters = 20, fields = 512, sampleBytes = 65536,
    stringBytes = 1024, tableEntries = 128, depth = 8 }
local statuses = { observed = true, empty = true, unknown = true,
    unsupported = true, error = true, not_applicable = true }
local roots = { environment = true, context = true, profession = true,
    equipment = true, concentration = true, knowledge = true, moxie = true,
    inventory = true, currency = true, auctionator = true, capabilities = true }

local function finite(v)
    return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end
D.Finite = finite

function D.Trim(text, limit)
    local cut = math.min(#text, limit)
    -- Client strings are UTF-8; do not split a multi-byte character at a bound.
    if cut < #text then
        local following = string.byte(text, cut + 1)
        while cut > 0 and following and following >= 128 and following < 192 do
            cut = cut - 1
            following = string.byte(text, cut + 1)
        end
    end
    return text:sub(1, cut)
end

local function keys(t)
    local out = {}
    for k in next, t do
        if type(k) == "string" or finite(k) then out[#out + 1] = k end
    end
    table.sort(out, function(a, b)
        if type(a) ~= type(b) then return type(a) < type(b) end
        return a < b
    end)
    return out
end

function D.Clean(value, depth, seen)
    depth, seen = depth or 0, seen or {}
    local kind = type(value)
    if kind == "string" then return D.Trim(value, D.LIMITS.stringBytes) end
    if kind == "boolean" or finite(value) then return value end
    if kind ~= "table" or depth >= D.LIMITS.depth or seen[value] then return nil end
    seen[value] = true
    local out, count = {}, 0
    for _, k in ipairs(keys(value)) do
        if count >= D.LIMITS.tableEntries then break end
        local v = D.Clean(rawget(value, k), depth + 1, seen)
        if v ~= nil and (type(k) ~= "string" or #k <= 128) then
            out[k], count = v, count + 1
        end
    end
    seen[value] = nil
    return out
end

-- Explicit projection: API tables are never copied wholesale.
function D.Pick(t, names)
    if type(t) ~= "table" then return nil end
    local out = {}
    for name in names:gmatch("%S+") do
        local v = rawget(t, name)
        if type(v) ~= "table" then out[name] = D.Clean(v) end
    end
    return out
end

local function quote(s)
    return '"' .. s:gsub('[%z\1-\31\\"|]', function(c)
        if c == '"' then return '\\"' end
        if c == '\\' then return '\\\\' end
        return string.format("\\u%04x", string.byte(c))
    end) .. '"'
end
local function encode(v)
    if type(v) == "string" then return quote(v) end
    if type(v) == "boolean" or finite(v) then return tostring(v) end
    if type(v) ~= "table" then return "null" end
    local parts = {}
    for _, k in ipairs(keys(v)) do
        parts[#parts + 1] = quote(tostring(k)) .. ":" .. encode(v[k])
    end
    return "{" .. table.concat(parts, ",") .. "}"
end
function D.Serialize(v) return encode(D.Clean(v)) end

function D.NewSample(label, now)
    return { schema = 1, label = type(label) == "string" and D.Trim(label, 80) or "scan",
        time = finite(now) and now or 0, timeKnown = finite(now),
        fields = {}, fieldCount = 0, bytes = 0 }
end

function D.Record(sample, key, status, source, value, reason, previous, budget)
    if type(key) ~= "string" or #key > 160 or not roots[key:match("^([%a]+)%.")]
        or not statuses[status] then return nil, "invalid" end
    -- A caller may tighten a section's write ceiling, never raise global limits.
    -- Knowledge alone uses this to leave room for its final coverage observation.
    local fieldLimit, byteLimit = D.LIMITS.fields, D.LIMITS.sampleBytes
    if type(budget) == "table" then
        if finite(budget.fields) then fieldLimit = math.min(fieldLimit, math.max(0, math.floor(budget.fields))) end
        if finite(budget.bytes) then byteLimit = math.min(byteLimit, math.max(0, math.floor(budget.bytes))) end
    end
    if sample.fieldCount >= fieldLimit and not sample.fields[key] then
        sample.truncated = true
        return nil, "field_limit"
    end
    local record = { status = status, time = sample.time, timeKnown = sample.timeKnown == true,
        source = type(source) == "string" and D.Trim(source, 160) or "diagnostic" }
    record.value = D.Clean(value)
    if reason then record.reason = D.Clean(reason) end
    if status == "observed" and record.value == nil then
        record.status, record.reason = "unknown", "nil or unsupported value type"
    end
    if record.status ~= "observed" and record.status ~= "empty" and previous then
        local old = previous.status == "observed" and
            { value = previous.value, time = previous.time, timeKnown = previous.timeKnown, source = previous.source }
            or previous.lastObserved
        record.lastObserved = D.Clean(old)
    end
    -- Values have already been cleaned; measure exactly what export will encode,
    -- not a second depth-limited copy that could undercount nested values.
    local bytes = #encode(record) + #quote(key) + 2
    local oldBytes = sample.fields[key] and (#encode(sample.fields[key]) + #quote(key) + 2) or 0
    if sample.bytes - oldBytes + bytes > byteLimit then
        sample.truncated = true
        return nil, "byte_limit"
    end
    if not sample.fields[key] then sample.fieldCount = sample.fieldCount + 1 end
    sample.fields[key], sample.bytes = record, sample.bytes - oldBytes + bytes
    return record
end

-- Missing/erroring calls never leak stack traces or arbitrary error objects.
function D.Attempt(fn, ...)
    if type(fn) ~= "function" then return "unsupported", nil, "API unavailable" end
    local ok, value = pcall(fn, ...)
    if not ok then return "error", nil, "API call failed (error payload omitted)" end
    if value == nil then return "unknown", nil, "API returned nil; readiness unverified" end
    return "observed", value
end

function D.Probe(sample, key, source, fn, previous, ...)
    local status, value, reason = D.Attempt(fn, ...)
    return D.Record(sample, key, status, source, value, reason, previous)
end

function D.OpenDB(db)
    if db == nil then return { schema = 1, characters = {} } end
    if type(db) ~= "table" or db.schema ~= 1 or type(db.characters) ~= "table" then
        return nil, "Existing diagnostic schema invalid/unsupported; left untouched"
    end
    return db
end

function D.AddSample(db, guid, sample)
    if type(guid) ~= "string" or #guid > 128 or guid == "" then return nil, "No player GUID" end
    local character = db.characters[guid]
    if character == nil then
        local count = 0
        for _ in next, db.characters do count = count + 1 end
        if count >= D.LIMITS.characters then return nil, "20-character storage limit; no data removed" end
        character = { samples = {} }
        db.characters[guid] = character
    end
    if type(character) ~= "table" or type(character.samples) ~= "table" then
        return nil, "Existing character data invalid; left untouched"
    end
    local samples = character.samples
    while #samples >= D.LIMITS.samples do table.remove(samples, 1) end
    samples[#samples + 1] = sample
    return true
end

function D.Previous(samples, key)
    for i = #samples, 1, -1 do
        local record = samples[i].fields and samples[i].fields[key]
        if record then return record end
    end
end

function D.Export(samples)
    -- Export only this addon's explicit schema, never the whole DB or globals.
    local rows = {}
    for i = math.max(1, #samples - 19), #samples do
        local s = samples[i]
        local fields = {}
        for _, key in ipairs(keys(s.fields or {})) do
            if type(key) == "string" and roots[key:match("^([%a]+)%.")] then
                local r = s.fields[key]
                if type(r) == "table" and statuses[r.status] then
                    local old = type(r.lastObserved) == "table" and r.lastObserved
                    fields[key] = { status = r.status, time = D.Clean(r.time), timeKnown = r.timeKnown == true,
                        source = D.Clean(r.source),
                        value = D.Clean(r.value), reason = D.Clean(r.reason),
                        lastObserved = old and { value = D.Clean(old.value),
                            time = D.Clean(old.time), timeKnown = old.timeKnown == true,
                            source = D.Clean(old.source) } or nil }
                end
            end
        end
        -- Serialize each field separately to avoid Clean's per-table entry cap
        -- truncating an otherwise valid 512-field sample.
        local coverageFlag = s.knowledgeCoverageFailed ~= nil and
            ',"knowledgeCoverageFailed":' .. tostring(s.knowledgeCoverageFailed == true) or ""
        rows[#rows + 1] = '{"schema":1,"label":' .. D.Serialize(s.label) ..
            ',"time":' .. D.Serialize(s.time) .. ',"timeKnown":' .. tostring(s.timeKnown == true) .. ',"truncated":' ..
            tostring(s.truncated == true) .. coverageFlag .. ',"fields":' .. encode(fields) .. '}'
    end
    return '{"schema":1,"samples":[' .. table.concat(rows, ",") .. ']}'
end
