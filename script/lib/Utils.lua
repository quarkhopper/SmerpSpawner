#include "Defs.lua"

function randomInRange(low, high)
	return (math.random() * (high - low)) + low
end

function splitString(inputString, separator)
	if inputString == nil or inputString == "" then return {} end
	if separator == nil then
			separator = "%s"
	end
	local t={}
	for str in string.gmatch(inputString, "([^"..separator.."]+)") do
			table.insert(t, str)
	end
	return t
end

function joinStrings(inputTable, delimeter)
	if inputTable == nil or #inputTable == 0 then return "" end
	if #inputTable == 1 then return tostring(inputTable[1]) end
	
	local concatString = tostring(inputTable[1])
	for i=2, #inputTable do
		concatString = concatString..delimeter..tostring(inputTable[i])
	end
	
	return concatString
end

function vecToString(vec)
	return vec[1]..STRINGS.DELIM_VEC
	..vec[2]..STRINGS.DELIM_VEC
	..vec[3]
end

function stringToVec(vecString)
	local parts = splitString(vecString, STRINGS.DELIM_VEC)
	return Vec(parts[1], parts[2], parts[3])
end

function vecsEqual(vecA, vecB)
	return vecA[1] == vecB[1] and
	vecA[2] == vecB[2] and
	vecA[3] == vecB[3] 
end

function randomVec(magnitude)
	return Vec(randomVecComponent(magnitude), randomVecComponent(magnitude), randomVecComponent(magnitude))
end

function randomVecComponent(magnitude)
	return (math.random() * magnitude * 2) - magnitude
end 

function varyByPercentage(value, variation)
	return value + (value * randomVecComponent(variation))
end

function randomFloat(min, max)
	local range = max - min
	return (math.random() * range) + min
end

function fractionToRangeValue(fraction, min, max)
	local range = max - min
	return (range * fraction) + min
end

function rangeValueToFraction(value, min, max)
	frac = (value - min) / (max - min)
	return frac
end

function getKeysAndValues(t)
	keys = {}
	values = {}
	for k,v in pairs(t) do
		table.insert(keys, k)
		table.insert(values, v)
	end
	return keys, values
end

function bracketValue(value, max, min)
	return math.max(math.min(max, value), min)
end

function roundToPlace(value, place)
	multiplier = math.pow(10, place)
	rounded = math.floor(value * multiplier)
	return rounded / multiplier
end

function round(value)
	return math.floor(value + 0.5)
end

function isNumber(value)
	if tonumber(value) ~= nil then
		return true
	end
    return false
end

stringToBoolean={ ["true"]=true, ["false"]=false }

function getBodyCenter(body)
	local min, max = GetBodyBounds(body)
	return VecLerp(min, max, 0.5)
end

function getShapeCenter(shape)
	local min, max = GetShapeBounds(shape)
	return VecLerp(min, max, 0.5)
end
	