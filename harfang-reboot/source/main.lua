-- main
gs = require('harfang')

require('common')
require('game_globals')
require("game_init")

gs.LoadPlugins()
if not gs.is_bootstrapped then
	print('Mounting local folder as project root.')
	gs.MountFileDriver(gs.StdFileDriver())
end

gs.GetFilesystem():Mount(gs.StdFileDriver("assets/"), "@assets")

plus = gs.GetPlus()
plus:CreateWorkers()

plus:RenderInit(g_screen_width, g_screen_height, "pkg.core")

-- gui = gs.GetDearImGui()
dt_sec = nil

scn = gameInit(plus)

while not plus:IsAppEnded() do
	if plus ~= nil then 
		dt_sec = plus:UpdateClock()
		plus:Clear()

		if scn ~= nil then
			plus:UpdateScene(scn, dt_sec)
		end

		-- require("lovebird").update()

		plus:Flip()
	end
end