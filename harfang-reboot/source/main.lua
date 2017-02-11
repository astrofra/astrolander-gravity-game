-- main

require('common')
require('game_globals')
game_init = require("game_init")

gs.LoadPlugins()
if not gs.is_bootstrapped then
	print('Mounting local folder as project root.')
	gs.MountFileDriver(gs.StdFileDriver())
end

gs.GetFilesystem():Mount(gs.StdFileDriver("assets/"), "@assets")

plus = gs.GetPlus()
plus:CreateWorkers()

plus:RenderInit(800, 600, "pkg.core")

gui = gs.GetDearImGui()
dt_sec = nil

scn = plus:NewScene(true, true)

while not scn:IsReady() do
	plus:UpdateScene(scn, plus:UpdateClock())
end

scn:GetPhysicSystem():SetDebugVisuals(true)
scn:GetPhysicSystem():SetForceRigidBodyAxisLockOnCreation(gs.LockZ + gs.LockRotX + gs.LockRotY + gs.LockRotZ)
scn:GetPhysicSystem():SetGravity(g_gravity)

game_init.createCamera(plus, scn)
game_init.createPlayer(plus, scn)
game_init.createEnvironment(plus, scn)

while not plus:IsAppEnded() do
	if plus ~= nil then 
		dt_sec = plus:UpdateClock()
		plus:Clear()

		plus:UpdateScene(scn, dt_sec)

		plus:Flip()
	end
end