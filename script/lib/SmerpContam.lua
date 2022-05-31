#include "SmerpBase.lua"
#include "Types.lua"
#include "Utils.lua"

function init()
	body = FindBody("SmerpBody")
    torso = FindShape("SmerpTorso")
	head = FindShape("SmerpHead")
	smerpType = smerpTypes.smerpContam
	fireSpread = 1
	screams = {
		LoadSound("MOD/snd/RoboScream1.ogg"),
		LoadSound("MOD/snd/RoboScream2.ogg"),
		LoadSound("MOD/snd/RoboScream3.ogg"),
		LoadSound("MOD/snd/RoboScream4.ogg"),
		LoadSound("MOD/snd/RoboScream5.ogg"),
		LoadSound("MOD/snd/RoboScream6.ogg"),
		LoadSound("MOD/snd/RoboScream7.ogg"),
		LoadSound("MOD/snd/RoboScream8.ogg"),
		LoadSound("MOD/snd/RoboScream9.ogg"),
		LoadSound("MOD/snd/RoboScream10.ogg"),
		LoadSound("MOD/snd/RoboScream11.ogg"),
		LoadSound("MOD/snd/RoboScream12.ogg")
	}

	initSmerp()

	numSparks = 200
	local deathFrames = {}
	local frameGoTime = 0
	for i=1, numSparks do
		local frame = inst_behaviorFrame(frameGoTime, {torso})
		frameGoTime = frameGoTime + (math.random(1, 10) * 0.001)
		table.insert(deathFrames, frame)
	end
	
	deathBehavior = inst_smerpBehavior(deathFrames)
end

function tick(dt)
	smerpTick(dt)
	if alive == false and deathBehavior.active == true then
		deathTick(dt) 
	end
end

function deathTick(dt)
	deathBehavior.clock = deathBehavior.clock + dt
	local nextFrame = deathBehavior.frames[deathBehavior.frameIndex]
	if nextFrame.goTime <= deathBehavior.clock then
		shootSpark(nextFrame.args)
		deathBehavior.frameIndex = deathBehavior.frameIndex + 1
		if deathBehavior.frameIndex > #deathBehavior.frames then
			deathBehavior.active = false
			deathBehavior.clock = 0
			deathBehavior.frameIndex = 1
			return false
		end
	end
	return true
end

-- define the shooting sparks and catching on fire behavior on death
function shootSpark(args)
	local torso = args[1]
	local position = getShapeCenter(torso)
	local firePosition = VecAdd(position, 
		Vec(math.random(0,fireSpread) - (fireSpread / 2), 
		math.random(0,fireSpread) - (fireSpread / 2), 
		math.random(0,fireSpread) - (fireSpread / 2)))
	SpawnFire(firePosition)
	ParticleReset()
	ParticleColor(1, 0.5, 0.2, 1, 0.2, 0.2)
	ParticleAlpha(1, 0, "easeout")
	ParticleRadius(0.02, 0.01)
	ParticleGravity(-5)
	ParticleDrag(0.5)
	ParticleEmissive(math.random(10, 15), 0, "easeout")
	ParticleTile(4)
	SpawnParticle(position, randomVec(8), math.random(1, 3))
end
