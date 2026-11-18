-- Optional local runner; execute from repository root with lua5.1 tests/run.lua.
local namespace = {}
for _, file in ipairs({ "Core.lua", "Probes.lua", "SelfTests.lua" }) do
    local chunk, reason = loadfile("CraftArmy_Diagnostics/" .. file)
    assert(chunk, reason)
    chunk("CraftArmy_Diagnostics", namespace)
end
local result = namespace.RunSelfTests()
for _, failure in ipairs(result.failures) do io.stderr:write(failure, "\n") end
print(string.format("%d/%d pure fixture cases passed (not live-client evidence)", result.passed, result.total))
if result.passed ~= result.total then os.exit(1) end
