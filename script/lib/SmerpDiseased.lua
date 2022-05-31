#include "SmerpBase.lua"
#include "Types.lua"

function init()
	body = FindBody("SmerpBody")
    torso = FindShape("SmerpTorso")
	head = FindShape("SmerpHead")
	smerpType = smerpTypes.smerpDiseased
	screams = {
		LoadSound("MOD/snd/Scream1.ogg"),
		LoadSound("MOD/snd/Scream2.ogg"),
		LoadSound("MOD/snd/Scream3.ogg"),
		LoadSound("MOD/snd/Scream4.ogg"),
		LoadSound("MOD/snd/Scream5.ogg"),
		LoadSound("MOD/snd/Scream6.ogg"),
		LoadSound("MOD/snd/Scream7.ogg"),
		LoadSound("MOD/snd/Scream8.ogg"),
		LoadSound("MOD/snd/Scream9.ogg"),
		LoadSound("MOD/snd/Scream10.ogg"),
		LoadSound("MOD/snd/Scream11.ogg"),
		LoadSound("MOD/snd/Scream12.ogg")
	}

	initSmerp()
end

function tick(dt)
	smerpTick(dt)
end