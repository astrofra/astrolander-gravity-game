-- game init

require('common')
require('game_globals')

function levelInit()
	while true do
		scn = plus:NewScene(true, true)

		while not scn:IsReady() do
			coroutine.yield()
		end

		--	physics
		scn:GetPhysicSystem():SetDebugVisuals(false)
		scn:GetPhysicSystem():SetForceRigidBodyAxisLockOnCreation(gs.LockZ + gs.LockRotX + gs.LockRotY)
		scn:GetPhysicSystem():SetGravity(g_gravity)

		-- load the player
		print('game_init.createPlayer()')

		scn:Load('assets/pod/pod.scn', gs.SceneLoadContext(plus:GetRenderSystem()))

		while not scn:IsReady() do
			coroutine.yield()
		end

		local player_body = scn:GetNode('pod_body')
		local ls = gs.LogicScript('player.lua')
		player_body:AddComponent(ls)

		--	create the camera
		print('game_init.createCamera()')
		local cam = plus:AddCamera(scn)
		cam:SetName('game_camera')
		cam:GetTransform():SetPosition(gs.Vector3(0,0,-75))

		local ls = gs.LogicScript('camera_handler.lua')
		cam:AddComponent(ls)

		--	load the level
		print('game_init.createEnvironment()')

		scn:Load('assets/levels/level_0.scn', gs.SceneLoadContext(plus:GetRenderSystem()))

		while not scn:IsReady() do
			coroutine.yield()
		end

		plus:ResetClock()

		--	game running
		while true do
			coroutine.yield()
		end		
	end

	-- return scn
end