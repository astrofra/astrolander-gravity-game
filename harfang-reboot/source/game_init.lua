-- game init

require('common')

function waitSceneReady(plus,scn)
	while not scn:IsReady() do
		plus:UpdateScene(scn, plus:UpdateClock())
	end
end

function gameInit(plus)
	local scn = plus:NewScene(true, true)

	waitSceneReady(plus,scn)
	
	--	physics
	scn:GetPhysicSystem():SetDebugVisuals(false)
	scn:GetPhysicSystem():SetForceRigidBodyAxisLockOnCreation(gs.LockZ + gs.LockRotX + gs.LockRotY)
	scn:GetPhysicSystem():SetGravity(g_gravity)

	-- player
	print('game_init.createPlayer()')

	scn:Load('assets/pod/pod.scn', gs.SceneLoadContext(plus:GetRenderSystem()))

	waitSceneReady(plus, scn)

	local player_body = scn:GetNode('pod_body')
	local ls = gs.LogicScript('player.lua')
	player_body:AddComponent(ls)

	--	camera
	print('game_init.createCamera()')
	local cam = plus:AddCamera(scn)
	cam:SetName('game_camera')
	cam:GetTransform():SetPosition(gs.Vector3(0,0,-75))

	local ls = gs.LogicScript('camera_handler.lua')
	cam:AddComponent(ls)

	--	level
	print('game_init.createEnvironment()')

	scn:Load('assets/levels/level_0.scn', gs.SceneLoadContext(plus:GetRenderSystem()))

	waitSceneReady(plus, scn)

	local start_node = scn:GetNode('start')

	plus:ResetClock()

	return scn
end