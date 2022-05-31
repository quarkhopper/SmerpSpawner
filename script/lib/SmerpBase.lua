#include "Types.lua"

smerpType = nil
screams = {}
body = nil
torso = nil
head = nil
alive = true
deathBehavior = nil

function initSmerp()
end

function smerpTick(dt)
	-- check if we're broken and therefor dead
	if alive then
		if IsShapeBroken(torso) or IsShapeBroken(head) then
			local trans = GetShapeWorldTransform(head)
			PlaySound(screams[math.random(#screams)],trans.pos,1.5)
			bump(Vec(0,200,-200))
			die(true)
		end
	end
end

function handleBehaviorTick(dt)
	-- tick any behvaviors that are active
	
	for i=1, #behaviors do
		local behavior = behaviors[i]
		if behavior.active then behavior.frameTick(dt) end
	end
end

function bump(impulse)
	local torso = FindBody("torso")
	ApplyBodyImpulse(torso, GetBodyCenterOfMass(torso), impulse)
end

function die(killed)
	alive = false
	if deathBehavior ~= nil then 
		deathBehavior.active = true
	end
end
