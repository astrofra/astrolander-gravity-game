-- player

dofile("common.lua")
dofile("linear_filter.lua")

keyboard_device = nil
thrust = 30.0
max_speed = 25.0 -- in m/s/s
ship_mass = 125.0
thrust_item_l = nil
thrust_item_r = nil
plus = nil
debug_pos = {}
speed_limit_filter = nil

function Setup(debug_pos)
	print('player:Setup()')

	local scn = this:GetScene()
	local player_edge = scn:GetNode('pod_edge', this)
	player_edge:GetObject():GetGeometry():SetShadowProxy(nil)

	thrust_item = {}
	thrust_item_l = scn:GetNode('thrust_item_l', this)
	thrust_item_r = scn:GetNode('thrust_item_r', this)

	-- Collision shapes
	local rb = gs.MakeRigidBody()
	rb:SetType(gs.RigidBodyDynamic)
	this:AddComponent(rb)

	local col_shape = gs.MakeBoxCollision()
	col_shape:SetDimensions(gs.Vector3(2.25, 1.5, 2.25))
	local col_matrix = gs.Matrix4()
	col_matrix:SetTranslation(gs.Vector3(0, -0.229, 0))
	col_shape:SetMatrix(col_matrix)
	col_shape:SetMass(100.0)
	this:AddComponent(col_shape)

	col_shape = gs.MakeSphereCollision()
	col_shape:SetRadius(1.0)
	col_matrix = gs.Matrix4()
	col_matrix:SetTranslation(gs.Vector3(0, 1.244, 0))
	-- col_matrix.Rotate(gs.Vector3())
	col_shape:SetMatrix(col_matrix)	
	this:AddComponent(col_shape)

	col_shape = gs.MakeSphereCollision()
	col_shape:SetRadius(0.5)
	col_matrix = gs.Matrix4()
	col_matrix:SetTranslation(gs.Vector3(-1, -1.015, 0))
	col_shape:SetMatrix(col_matrix)	
	this:AddComponent(col_shape)	

	col_shape = gs.MakeSphereCollision()
	col_shape:SetRadius(0.5)
	col_matrix = gs.Matrix4()
	col_matrix:SetTranslation(gs.Vector3(1, -1.015, 0))
	col_shape:SetMatrix(col_matrix)	
	this:AddComponent(col_shape)

	col_shape = gs.MakeBoxCollision()
	col_shape:SetDimensions(gs.Vector3(0.35, 1.0, 0.35))
	col_matrix = gs.Matrix4()
	col_matrix:SetTranslation(gs.Vector3(0.65, -1.228, 0.65))
	col_shape:SetMatrix(col_matrix)
	this:AddComponent(col_shape)	

	col_shape = gs.MakeBoxCollision()
	col_shape:SetDimensions(gs.Vector3(0.35, 1.0, 0.35))
	col_matrix = gs.Matrix4()
	col_matrix:SetTranslation(gs.Vector3(-0.65, -1.228, 0.65))
	col_shape:SetMatrix(col_matrix)
	this:AddComponent(col_shape)

	col_shape = gs.MakeBoxCollision()
	col_shape:SetDimensions(gs.Vector3(0.35, 1.0, 0.35))
	col_matrix = gs.Matrix4()
	col_matrix:SetTranslation(gs.Vector3(0.65, -1.228, -0.65))
	col_shape:SetMatrix(col_matrix)
	this:AddComponent(col_shape)	

	col_shape = gs.MakeBoxCollision()
	col_shape:SetDimensions(gs.Vector3(0.35, 1.0, 0.35))
	col_matrix = gs.Matrix4()
	col_matrix:SetTranslation(gs.Vector3(-0.65, -1.228, -0.65))
	col_shape:SetMatrix(col_matrix)
	this:AddComponent(col_shape)	

	speed_limit_filter = LinearFilter(30)

	keyboard_device = gs.GetInputSystem():GetDevice("keyboard")
	plus = gs.GetPlus()
end

function cross3D(pos, size_cross)
	size_cross = size_cross or 1.0
	color = gs.Color(0, 1, 1)
	plus:GetRenderSystem():DrawLineAutoRGB(3, {	pos + gs.Vector3(size_cross, 0, 0), 
												pos - gs.Vector3(size_cross, 0, 0),
												pos + gs.Vector3(0, size_cross, 0), 
												pos - gs.Vector3(0, size_cross, 0),
												pos + gs.Vector3(0, 0, size_cross),
												pos - gs.Vector3(0, 0, size_cross)},
												{color, color, color, color, color, color})	
end

function EndDrawFrame()
	-- for i, pos in ipairs(debug_pos) do
	-- 	cross3D(pos, 2.0)
	-- end
end

function Update()
	debug_pos = {}

	if this:IsReady() and this:GetComponent("RigidBody") ~= nil then
		ThrustTypeControl()
		SpeedLimiter()
		AutoAlign()
	end
end

function	ThrustTypeControl()
	local left, right = false, false

	if keyboard_device:IsDown(gs.InputDevice.KeyLeft) then
		left = true
	end

	if keyboard_device:IsDown(gs.InputDevice.KeyRight) then
		right = true
	end

	if left and not right then
		this:GetComponent("RigidBody"):ApplyLinearForce(this:GetTransform():GetWorld():GetRow(0) * thrust * ship_mass)
		this:GetComponent("RigidBody"):ApplyForce(thrust_item_l:GetTransform():GetWorld():GetRow(0) * -thrust * -0.1 * ship_mass, thrust_item_l:GetTransform():GetWorld():GetTranslation())
		table.insert(debug_pos, thrust_item_l:GetTransform():GetWorld():GetTranslation())
	end

	if not left and right then
		this:GetComponent("RigidBody"):ApplyLinearForce(this:GetTransform():GetWorld():GetRow(0) * -thrust * ship_mass)
		this:GetComponent("RigidBody"):ApplyForce(thrust_item_r:GetTransform():GetWorld():GetRow(0) * -thrust * -0.1 * ship_mass, thrust_item_r:GetTransform():GetWorld():GetTranslation())
		table.insert(debug_pos, thrust_item_r:GetTransform():GetWorld():GetTranslation())
	end

	if left and right then
		this:GetComponent("RigidBody"):ApplyLinearForce(gs.Vector3(0,1,0) * thrust * ship_mass)
	end

	if left or right then
		this:GetComponent("RigidBody"):SetIsSleeping(false)
	end

	table.insert(debug_pos, this:GetTransform():GetPosition())	
end

function	AutoAlign()
	local	_align, _speed
	
	local	_rot_z = this:GetTransform():GetRotation().z
	local	_ang_v_z = this:GetComponent("RigidBody"):GetAngularVelocity().z

	_align = Clamp(math.abs(math.deg(_rot_z)) / 180.0,0.0,1.0)
	_align = _align * 250.0

	_speed = this:GetComponent("RigidBody"):GetLinearVelocity():Len()
	_speed = RangeAdjust(_speed, 0.25, 0.5, 0.0, 1.0)
	_speed = Clamp(_speed, 0.0, 1.0)
	_align = _align * _speed

	this:GetComponent("RigidBody"):ApplyTorque(gs.Vector3(0,0, -_rot_z - _ang_v_z) * _align * ship_mass)
end

function 	SpeedLimiter()
	local speed_limiter = math.max(this:GetComponent('RigidBody'):GetLinearVelocity():Len() - max_speed, 0.0)
	local	impulse_limiter = this:GetComponent('RigidBody'):GetLinearVelocity() * (-speed_limiter)
	speed_limit_filter:SetNewValue(impulse_limiter)

	local	_speed_limit = speed_limit_filter:GetFilteredValue()

	if speed_limiter > 0.0 and impulse_limiter:Len() < max_speed then
		this:GetComponent('RigidBody'):ApplyLinearImpulse(speed_limit_filter:GetFilteredValue())
	end
end