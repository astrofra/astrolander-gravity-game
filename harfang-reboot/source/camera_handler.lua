-- Camera

-- class	CameraHandler
-- {
scene =	nil
player_node = nil
camera_item		=	0
camera 			=	0
camera_pos		=	0
camera_rot		=	0
camera_rot_z	=	0
camera_rot_z_filtered		=	0
camera_offset_z_filtered	=	0
target_vel		=	0
max_sneak_speed	=	1.5		--	max speed when evaluating the camera unzoom
sneak_radius	=	40.0	--	in meters
close_up		=	false
close_up_factor	=	0.0
close_up_factor_filtered	=	0

camera_pos_filtered = 0

function Setup()

	print('camera_handler:Setup()')
	camera_pos = this:GetTransform():GetPosition()
	camera_rot = gs.Vector3(0,0,0)
	camera_rot_z = 0.0
	-- CameraSetFov(ItemCastToCamera(camera_item), DegreeToRadian(22.5))
	-- CameraSetClipping(ItemCastToCamera(camera_item), Mtr(20.0), Mtr(1500.0))
	target_vel = gs.Vector3(0,0,0)
	close_up = false
	close_up_factor = 0.0
	-- close_up_factor_filtered = LinearFilter(30)
	-- camera_rot_z_filtered = LinearFilter(30)
	-- camera_offset_z_filtered = LinearFilter(15)
	-- camera_pos_filtered = LinearFilter(15)

	SetFx()
end

function 	Update()
	if player_node ~= nil and player_node:GetComponent("RigidBody") ~= nil then
		if this:IsReady() and this:GetComponent("Transform") ~= nil then
			FollowPlayerPosition(player_node:GetTransform():GetPosition(), player_node:GetComponent("RigidBody"):GetLinearVelocity())
		end
	else
		local scn = this:GetScene()
		player_node = scn:GetNode('pod_body')
	end
end

function	SetMaxSneakSpeed(_s)
	max_sneak_speed = _s
end

function	EnableCloseUp(flag)
	print("camera_handler::EnableCloseUp(" .. flag .. ").")
	close_up = flag
end

function	SetFx()
	print('camera_handler:SetFx()')
	--	stub
end

--------------------------------------
function	StickToPlayerPosition(player_pos)
--------------------------------------
	player_pos = player_pos or gs.Vector3(0,0,0)
	-- local	_z_save = camera_pos.z
	-- camera_pos = player_pos
	-- camera_pos.z = _z_save
	-- ItemSetPosition(camera_item, camera_pos)
end

--------------------------------------
function	FollowPlayerPosition(player_pos, player_vel)
--------------------------------------
	player_pos = player_pos or gs.Vector3(0,0,0)
	player_vel = player_vel or gs.Vector3(0,0,0)
	-- camera_pos_filtered.SetNewValue(player_pos)
	-- camera_pos = camera_pos_filtered.GetFilteredValue()

	-- --	Compute the delta between the actual "unzoom offset"
	-- --	and the last computed optimal offset
	-- --	Z remains untouched
	-- local	v_d = Vector(0,0,0)
	-- v_d.x = player_vel.x - target_vel.x
	-- v_d.y = player_vel.y - target_vel.y

	-- --	Scale & Clamp this offset, based on the player max speed,
	-- --	modulate it by the framerated.
	-- local	clamp_vel, speed
	-- target_vel = target_vel + v_d.Scale(0.25 / 60.0)
	-- speed = RangeAdjust(target_vel.Len(), 0.0, max_sneak_speed, 0.0, sneak_radius)
	-- speed = Clamp(speed, 0.0, sneak_radius) + Mtr(50.0)
	-- --	Finally converts the offset length into the unzoom distance.
	-- clamp_vel = Vector(0,0, -speed)

	-- --	Filter z offset
	-- camera_offset_z_filtered.SetNewValue(clamp_vel.z)
	-- clamp_vel.z = camera_offset_z_filtered.GetFilteredValue()

	-- --	--------------------------------------------------
	-- --	Camera rotation along the player lateral velocity
	-- --	--------------------------------------------------
	-- local	_clamp_x_vel = Abs(player_vel.x)
	-- _clamp_x_vel = Clamp(_clamp_x_vel, 0.0, g_player_max_speed)
	-- _clamp_x_vel = RangeAdjust(_clamp_x_vel, g_player_max_speed * 0.125, g_player_max_speed * 0.75, 0.0, 1.0)
	-- _clamp_x_vel = Clamp(_clamp_x_vel, 0.0, 1.0)
	-- if (player_vel.x < 0.0)
	-- 	_clamp_x_vel *= -1

	-- camera_rot_z = _clamp_x_vel * -2.5
	-- camera_rot_z = Clamp(camera_rot_z, -2.5, 2.5)
			
	-- --	Filter the camera rotation
	-- camera_rot_z_filtered.SetNewValue(camera_rot_z)
	-- camera_rot.z = DegreeToRadian(camera_rot_z_filtered.GetFilteredValue())

	-- ItemSetPosition(camera_item, camera_pos + clamp_vel)
	-- ItemSetRotation(camera_item, camera_rot)

	camera_pos.x = player_pos.x
	camera_pos.y = player_pos.y
	this:GetTransform():SetPosition(camera_pos)
end

-- }
