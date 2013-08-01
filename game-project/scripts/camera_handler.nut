/*
	File: scripts/camera_handler.nut
	Author: Astrofra
*/

/*!
	@short	CameraHandler
	@author	Astrofra
*/
class	CameraHandler
{
	scene			=	0
	camera_item		=	0
	camera 			=	0
	camera_pos		=	0
	camera_rot		=	0
	camera_rot_z	=	0
	camera_rot_z_filtered		=	0
	camera_offset_z_filtered	=	0
	target_vel		=	0
	max_sneak_speed	=	1.5		//	max speed when evaluating the camera unzoom
	sneak_radius	=	Mtr(40.0)
	close_up		=	false
	close_up_factor	=	0.0
	close_up_factor_filtered	=	0

	camera_pos_filtered = 0

	constructor(_scene)
	{
		scene = _scene
		camera_item = LegacySceneFindItem(scene,"game_camera")
		camera_pos = ItemGetWorldPosition(camera_item)
		camera_rot = Vector(0,0,0)
		camera_rot_z = 0.0
		camera = ItemCastToCamera(camera_item)
		SceneSetCurrentCamera(scene, camera)
		CameraSetFov(ItemCastToCamera(camera_item), DegreeToRadian(22.5))
		CameraSetClipping(ItemCastToCamera(camera_item), Mtr(20.0), Mtr(1500.0))
		target_vel = Vector(0,0,0)
		close_up		=	false
		close_up_factor	=	0.0
		close_up_factor_filtered = LinearFilter(30)
		camera_rot_z_filtered = LinearFilter(30)
		camera_offset_z_filtered = LinearFilter(15)
		camera_pos_filtered = LinearFilter(15)

		SetFx()
	}

	function	SetMaxSneakSpeed(_s)
	{	max_sneak_speed = _s	}

	function	EnableCloseUp(flag)
	{
		print("CameraHandler::EnableCloseUp(" + flag + ").")
		close_up = flag
	}

	function	SetFx()
	{
		return

		//	Enable Bloom
		ItemRegistrySetKey(camera_item, "PostProcess:Bloom:Strength", 2.5)
		ItemRegistrySetKey(camera_item, "PostProcess:Bloom:Threshold", 0.75)
		ItemRegistrySetKey(camera_item, "PostProcess:Bloom:Radius", 15.0)


		//	Enable Motion Blur
		ItemRegistrySetKey(camera_item, "PostProcess:MotionBlur:Strength", 0.5)

		//	Enable SSAO
		ItemRegistrySetKey(camera_item, "PostProcess:SSAO:Strength", 5.0)
		ItemRegistrySetKey(camera_item, "PostProcess:SSAO:Radius", 250)
		ItemRegistrySetKey(camera_item, "PostProcess:SSAO:DistanceScale", 5.0)
		ItemRegistrySetKey(camera_item, "PostProcess:SSAO:BlurRadius", 2.0)

	}

	//------------------------------------
	function	StickToPlayerPosition(player_pos)
	//------------------------------------
	{
		local	_z_save = camera_pos.z
		camera_pos = player_pos
		camera_pos.z = _z_save
		ItemSetPosition(camera_item, camera_pos)
	}

	//------------------------------------
	function	FollowPlayerPosition(player_pos = Vector(0,0,0), player_vel = Vector(0,0,0))
	//------------------------------------
	{
		camera_pos_filtered.SetNewValue(player_pos)
		camera_pos = camera_pos_filtered.GetFilteredValue()

		//	Compute the delta between the actual "unzoom offset"
		//	and the last computed optimal offset
		//	Z remains untouched
		local	v_d = Vector(0,0,0)
		v_d.x = player_vel.x - target_vel.x
		v_d.y = player_vel.y - target_vel.y

		//	Scale & Clamp this offset, based on the player max speed,
		//	modulate it by the framerated.
		local	clamp_vel, speed
		target_vel = target_vel + v_d.Scale(0.25 / 60.0)
		speed = RangeAdjust(target_vel.Len(), 0.0, max_sneak_speed, 0.0, sneak_radius)
		speed = Clamp(speed, 0.0, sneak_radius) + Mtr(50.0)
		//	Finally converts the offset length into the unzoom distance.
		clamp_vel = Vector(0,0, -speed)

		//	Filter z offset
		camera_offset_z_filtered.SetNewValue(clamp_vel.z)
		clamp_vel.z = camera_offset_z_filtered.GetFilteredValue()

		//	--------------------------------------------------
		//	Camera rotation along the player lateral velocity
		//	--------------------------------------------------
		local	_clamp_x_vel = Abs(player_vel.x)
		_clamp_x_vel = Clamp(_clamp_x_vel, 0.0, g_player_max_speed)
		_clamp_x_vel = RangeAdjust(_clamp_x_vel, g_player_max_speed * 0.125, g_player_max_speed * 0.75, 0.0, 1.0)
		_clamp_x_vel = Clamp(_clamp_x_vel, 0.0, 1.0)
		if (player_vel.x < 0.0)
			_clamp_x_vel *= -1

		camera_rot_z = _clamp_x_vel * -2.5
		camera_rot_z = Clamp(camera_rot_z, -2.5, 2.5)
				
		//	Filter the camera rotation
		camera_rot_z_filtered.SetNewValue(camera_rot_z)
		camera_rot.z = DegreeToRadian(camera_rot_z_filtered.GetFilteredValue())

		ItemSetPosition(camera_item, camera_pos + clamp_vel)
		ItemSetRotation(camera_item, camera_rot)
	}

	//------------------------------------
	function	oldFollowPlayerPosition(player_pos = Vector(0,0,0), player_vel = Vector(0,0,0))
	//------------------------------------
	{
			local	v_d = Vector(0,0,0)

			//	Compute the delta between the actual player position
			//	and the last computed camera position
			//	Z remains untouched.
			v_d.x = player_pos.x - camera_pos.x
			v_d.y = player_pos.y - camera_pos.y
			v_d.z = 0.0

			//	Apply this delta to the camera position,
			//	modulated by the framerated.
			camera_pos = camera_pos + v_d.Scale(5.0 * g_dt_frame)

			//	Compute the delta between the actual "unzoom offset"
			//	and the last computed optimal offset
			//	Z remains untouched
			v_d.x = player_vel.x - target_vel.x
			v_d.y = player_vel.y - target_vel.y
			v_d.z = 0.0

			//	Scale & Clamp this offset, based on the player max speed,
			//	modulate it by the framerated.
			local	clamp_vel, speed
			target_vel = target_vel + v_d.Scale(0.25 * g_dt_frame)
			speed = RangeAdjust(target_vel.Len(), 0.0, max_sneak_speed, 0.0, sneak_radius)
			speed = Clamp(speed, 0.0, sneak_radius)
			//	Finally converts the offset length into the unzoom distance.
			clamp_vel = Vector(0,0, -speed)

			//	Filter z offset
			camera_offset_z_filtered.SetNewValue(clamp_vel.z)
			clamp_vel.z = camera_offset_z_filtered.GetFilteredValue()

			//	--------------------------------------------------
			//	Camera rotation along the player lateral velocity
			//	--------------------------------------------------
			local	_clamp_x_vel = Abs(player_vel.x)
			_clamp_x_vel = Clamp(_clamp_x_vel, 0.0, g_player_max_speed)
			_clamp_x_vel = RangeAdjust(_clamp_x_vel, g_player_max_speed * 0.125, g_player_max_speed * 0.75, 0.0, 1.0)
			_clamp_x_vel = Clamp(_clamp_x_vel, 0.0, 1.0)
			if (player_vel.x < 0.0)
				_clamp_x_vel *= -1

			camera_rot_z = _clamp_x_vel * -2.5
			camera_rot_z = Clamp(camera_rot_z, -2.5, 2.5)
				
			//	Filter the camera rotation on 15 iterations
			//	FIXME : make the filter framerate independent
			camera_rot_z_filtered.SetNewValue(camera_rot_z)
			camera_rot.z = DegreeToRadian(camera_rot_z_filtered.GetFilteredValue())

			//	Close Up mode ?
			if (close_up)
				close_up_factor += (g_dt_frame * 0.75)
			else
				close_up_factor -= (g_dt_frame * 0.25)

			close_up_factor = Clamp(close_up_factor, 0.0, 1.0)

			close_up_factor_filtered.SetNewValue(close_up_factor)

			local	_cam_pos_z
			_cam_pos_z = clamp_vel.Lerp(1.0 - close_up_factor_filtered.GetFilteredValue(), Vector(0,0,Mtr(10.0)) )

			ItemSetPosition(camera_item, camera_pos + _cam_pos_z)
			ItemSetRotation(camera_item, camera_rot)

//ItemSetPosition(camera_item,player_pos + Vector(0,0,-60))
	}

}
