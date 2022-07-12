#include "script/lib/Defs.lua"
#include "script/lib/Types.lua"
#include "script/lib/Utils.lua"
#include "script/lib/SmerpBase.lua"
#include "script/lib/Smerp.lua"
#include "script/lib/Mapping.lua"

------------------------------------------------
-- INIT
-------------------------------------------------



smerpNames = {
	[smerpTypes.smerp] = "smerp",
	[smerpTypes.smerpContam] = "robo smerp",
	[smerpTypes.smerpDiseased] = "diseased smerp"
}

prefabs = {
	[smerpTypes.smerp] = "MOD/prefab/Smerp.xml",
	[smerpTypes.smerpContam] = "MOD/prefab/SmerpContam.xml",
	[smerpTypes.smerpDiseased] = "MOD/prefab/SmerpDiseased.xml"
}

function init()
	RegisterTool(REG.TOOL_KEY, TOOL_NAME, nil, 6)
	SetBool("game.tool."..REG.TOOL_KEY..".enabled", true)
	SetFloat("game.tool."..REG.TOOL_KEY..".ammo", 1000)
	
	groupSpawnSound = LoadSound("MOD/snd/NinjaDead.ogg")

	smerps = {}
	selectedType = smerpTypes.smerp

	shootPause = 0.2
	shootTimer = shootPause

	set_spawn_area_parameters()

	death_toll = 0
	death_cam_mode = false
	death_cam_focus = nil
	death_cam_dist = 10
	death_cam_min_follow = 1.5
	death_cam_follow_timer = 0
	death_cam_max_follow = 6

	osd = false
end

-------------------------------------------------
-- Drawing
-------------------------------------------------

function draw()
	if osd then 
		UiPush()
			UiTranslate(UiWidth(), 27)
			UiAlign("right")
			UiFont("bold.ttf", 25)
			UiTextOutline(0,0,0,1,0.5)
			UiColor(1,1,1)
			UiText("smerps (dead/alive): ("..death_toll.."/"..#smerps..")", true)
			if death_cam_mode and death_cam_focus == nil then
				UiText("Death cam mode on ("..KEY.DEATH_CAM_TOGGLE.key.." to turn off)")
			end
		UiPop()

		if death_cam_focus ~= nil then 
			UiPush()
				UiTranslate(UiCenter(), 25)
				UiAlign("center")
				UiFont("bold.ttf", 30)
				UiTextOutline(0,0,0,1,0.5)
				UiColor(1,1,1)
				UiText("Press enter to exit death cam")
			UiPop()
		end 
	end

	if GetString("game.player.tool") ~= REG.TOOL_KEY or
		GetPlayerVehicle() ~= 0 then return end

	UiPush()
		UiTranslate(0, UiHeight() - 18 * 5)
		UiAlign("left")
		UiFont("bold.ttf", 18)
		UiTextOutline(0,0,0,1,0.5)
		UiColor(1,1,1)
		UiText("LMB to spawn a "..smerpNames[selectedType], true)
		UiText("RMB to change smerp type", true)
		UiText(KEY.SPAWN_GROUP.key.." to spawn 50 smerps randomly around", true)
		UiText(KEY.DEATH_CAM_TOGGLE.key.." to activate smerp death cam", true)
		UiText(KEY.OSD.key.." to toggle information (upper right) on/off")
	UiPop()
end

-------------------------------------------------
-- TICK 
-------------------------------------------------

function tick(dt)
	handleInput(dt)

	local survivors = {}
	for i = 1, #smerps do
		local smerp = smerps[i]
		if IsShapeBroken(smerp.head) or IsShapeBroken(smerp.torso) then
			death_toll = death_toll + 1
			if death_cam_mode and death_cam_follow_timer < 0 then 
				death_cam_focus = smerp
				death_cam_follow_timer = death_cam_min_follow
			end
		else
			table.insert(survivors, smerp)
		end
	end
	smerps = survivors

	death_cam_tick(dt)
end

function death_cam_tick(dt)
	death_cam_follow_timer = math.max(-death_cam_max_follow, death_cam_follow_timer - dt)

	-- if we're not in the camera mode or there's no dead smerps to focus on
	-- then return now
	if not death_cam_mode or death_cam_focus == nil then return end

	-- followed for long enough. Return to player view
	if death_cam_follow_timer == -death_cam_max_follow then 
		death_cam_focus = nil
		return
	end

	local smerp = death_cam_focus
	local focus_shape = smerp.torso
	local smerp_pos = GetShapeWorldTransform(focus_shape).pos
	-- check that the camera view to the smerp isn't obstructed.
	if smerp.cam_trans ~= nil then 
		local diff = VecSub(smerp.cam_trans.pos, smerp_pos)
		local shot_dist = VecLength(diff)
		local shot_dir = VecNormalize(diff)
		-- outside_pos functionally is the min distance from the smerp shape
		-- to ensure we're not hitting smerp parts (most of the time). Sometimes 
		-- the shape ends up just being a bit of flying skull, which is ridiculous, 
		-- but there's only so much I'm willing to compensage for with my available 
		-- sanity. 
		local outside_pos = VecAdd(smerp_pos, VecScale(shot_dir, 1))
		local hit, dist = QueryRaycast(outside_pos, shot_dir, shot_dist) 
		if hit and dist > 1 and GetShapeVoxelCount(focus_shape) > 10 then
			-- put the camera in front of the obstacle
			local new_cam_pos = VecAdd(smerp_pos, VecScale(shot_dir, dist - 0.1))
			smerp.cam_trans = Transform(new_cam_pos, QuatLookAt(new_cam_pos, smerp_pos))
		else
			smerp.cam_trans = Transform(smerp.cam_trans.pos, QuatLookAt(smerp.cam_trans.pos, smerp_pos))
		end 
	else 
		local tries = 100
		local longest_dist = 0.1
		local longest_dir = nil
		-- find the longest angle or the angle that has no obstructions at the desired distance
		while tries > 0 do
			local dir = VecNormalize(Vec(randomVecComponent(1), 1, randomVecComponent(1)))
			local outside_pos = VecAdd(smerp_pos, VecScale(dir, 1))
			local hit, dist = QueryRaycast(outside_pos, dir, death_cam_dist)
			if not hit and dist > 1 and GetShapeVoxelCount(focus_shape) > 10 then
				local cam_pos = VecAdd(smerp_pos, VecScale(dir, death_cam_dist))
				local cam_rot = QuatLookAt(cam_pos, smerp_pos)
				smerp.cam_trans = Transform(cam_pos, cam_rot)
				break
			elseif dist > longest_dist then 
				longest_dist = dist
				longest_dir = dir
			end
			tries = tries - 1
		end
		if smerp.cam_trans == nil and longest_dir ~= nil then 
			-- best we could do is less than ideal
			local cam_pos = VecAdd(smerp_pos, VecScale(longest_dir, longest_dist - 0.1))
			local cam_rot = QuatLookAt(cam_pos, smerp_pos)
			smerp.cam_trans = Transform(cam_pos, cam_rot)
		end
	end

	if smerp.cam_trans ~= nil then 
		SetCameraFov(100)
		SetCameraTransform(smerp.cam_trans)
	end
end

-------------------------------------------------
-- Input handler
-------------------------------------------------

function handleInput(dt)
	shootTimer = math.max(shootTimer - dt, 0)

	-- because the death cam might be running with other tools equipped 
	-- we want the on screen display and controls available at all times. 
	-- For this reason we put them outside the control restriction if. 
	if InputPressed("return") and death_cam_focus ~= nil then 
		death_cam_focus = nil
	end

	if InputPressed(KEY.DEATH_CAM_TOGGLE.key) then
		if death_cam_focus == nil then 
			death_cam_mode = not death_cam_mode
		end
	end

	if GetString("game.player.tool") == REG.TOOL_KEY and
	GetPlayerVehicle() == 0 then 
		-- spawn smerp
		if not shootLock and
		shootTimer == 0 and 
		InputDown("LMB") and
		not InputDown("RMB") then
			local camera = GetPlayerCameraTransform()
			local shootDir = TransformToParentVec(camera, Vec(0, 0, -1))
			local rotx, roty, rotz = GetQuatEuler(camera.rot)
			local hit, dist = QueryRaycast(camera.pos, shootDir, 100, 0.025, true)
			if hit then
				local hitPoint = VecAdd(camera.pos, VecScale(shootDir, dist))
				local trans = Transform(hitPoint, QuatEuler(0, roty - 90,0))
				--trans.pos = VecAdd(trans.pos, Vec(0.5,0,0.5))
				local ents = Spawn(prefabs[selectedType], trans)
				register_smerp(ents)
			end
			shootTimer = shootPause
		end
		
		-- change smerp type
		if not shootLock and
		GetPlayerGrabShape() == 0 and
		InputDown("RMB") and
		not InputDown("LMB") then
			selectedType = math.fmod( selectedType, 3 ) + 1
			shootLock = true
		end
	
		-- spawn 50 smerps
		if shootTimer == 0 and
		InputPressed(KEY.SPAWN_GROUP.key) then
			local player_trans = GetPlayerTransform()
			PlaySound(groupSpawnSound, player_trans.pos, 50)
			for i = 1, 50 do
				local smerpType = math.random(3)
				local spawnPos = find_spawn_location()
				if spawnPos ~= nil then 
					local trans = Transform(spawnPos, QuatEuler(0,math.random(0,359),0))
					trans.pos = VecAdd(trans.pos, Vec(spawn_block_h_size/2,0.1,spawn_block_h_size/2))
					local ents = Spawn(prefabs[math.random(3)], trans)
					register_smerp(ents)
				end
			end
		end

		if InputPressed(KEY.OSD.key) then 
			osd = not osd
		end

		-- shoot lock for when the player is grabbing and 
		-- throwing things
		if GetPlayerGrabShape() ~= 0 then
			shootLock = true
		elseif shootLock == true and
		GetPlayerGrabShape() == 0 and
		not InputDown("RMB") and
		not InputDown("LMB") then
			shootLock = false
		end
	end
end

function register_smerp(ents)
	local smerp = {}
	for j = 1, #ents do
		local ent = ents[j]
		if HasTag(ent, "SmerpTorso") then
			smerp.torso = ent
		elseif HasTag(ent, "SmerpHead") then
			smerp.head = ent
		elseif HasTag(ent, "SmerpBody") then
			smerp.body = ent
		end
	end
	table.insert(smerps, smerp)
end