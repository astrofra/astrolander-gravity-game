-- game init

require('common')

local game_init = {}

function game_init.createPlayer(plus,scn)
	print('game_init.createPlayer()')

	scn:Load('assets/pod/pod.scn', gs.SceneLoadContext(plus:GetRenderSystem()))

	while not scn:IsReady() do
		plus:UpdateScene(scn, plus:UpdateClock())
	end

	local player_body = scn:GetNode('pod_body')
	local ls = gs.LogicScript('player.lua')
	player_body:AddComponent(ls)
end

function game_init.createCamera(plus, scn)
	print('game_init.createCamera()')

	local cam = plus:AddCamera(scn)
	cam:SetName('game_camera')
	cam:GetTransform():SetPosition(gs.Vector3(0,0,-75))

	local ls = gs.LogicScript('camera_handler.lua')
	cam:AddComponent(ls)
end

function game_init.createEnvironment(plus, scn)
	print('game_init.createEnvironment()')

	scn:Load('assets/levels/level_0.scn', gs.SceneLoadContext(plus:GetRenderSystem()))

	while not scn:IsReady() do
		plus:UpdateScene(scn, plus:UpdateClock())
	end	

	-- plus:AddLight(scn, gs.Matrix4.Identity:LookAt(gs.Vector3(1,-1,0.5)), gs.Light.Model_Linear, 150.0, true)
	-- plus:AddPhysicPlane(scn, gs.Matrix4.TransformationMatrix(gs.Vector3(0,-5,0), gs.Vector3()), 100, 100, 0.0) 
	plus:ResetClock()
end

return game_init