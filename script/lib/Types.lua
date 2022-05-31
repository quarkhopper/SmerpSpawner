
-- executes frames at the appropriate times
function inst_smerpBehavior(frames)
	local inst = {}
	inst.clock = 0
	inst.frames = frames
	inst.frameIndex = 1
	inst.active = false
	
	return inst
end


function inst_behaviorFrame(goTime, args)
	local inst = {}
	inst.goTime = goTime
	inst.args = args or {}
	
	return inst
end

-------------------------------------------------
-- Enums
-------------------------------------------------

function enum(source)
	local enumTable = {}
    for i = 1, #source do
        local value = source[i]
        enumTable[value] = i
    end

    return enumTable
end

function enumToString(source)
	if source == nil then return "" end
	local keyTable = {}
	local valueTable = {}
	for k, v in pairs(source) do
		keyTable[#keyTable + 1] = k
		valueTable[#valueTable + 1] = v
	end

	return joinStrings(keyTable, STRINGS.DELIM_STRINGS).. 
		STRINGS.DELIM_ENUM_PAIR.. 
		joinStrings(valueTable, STRINGS.DELIM_STRINGS)
end

function stringToEnum(source)
	if source == nil or source == "" then return {} end
	local parts = splitString(source, STRINGS.DELIM_ENUM_PAIR)
	local keys = splitString(parts[1], STRINGS.DELIM_STRINGS)
	local values = splitString(parts[2], STRINGS.DELIM_STRINGS)
	
	local enumTable = {}
	for i = 1, #keys do
  		enumTable[keys[i]] = tonumber(values[i])
	end
	
	return enumTable
end

function getEnumKey(value, enumTable)
	for k, v in pairs(enumTable) do
		if v == value then
			return k
		end
	end
end

smerpTypes = enum {
	"smerp",
	"smerpContam",
	"smerpDiseased"
}

