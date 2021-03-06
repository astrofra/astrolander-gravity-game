import gs
# import gs.plus.render as render
# import gs.plus.camera as camera
# import gs.plus.input as input
# import gs.plus.scene as scene
# import gs.plus.clock as clock

import os

gs.LoadPlugins()

class NmlNode():
	def __init__(self):
		self.m_Data = ""
		self.m_Name = ""

		self.list_child = []

	def GetChild(self, name_child):
		for child in self.list_child:
			if child.m_Name == name_child:
				return child

	def GetChilds(self, name_child):
		temp_list = []

		for child in self.list_child:
			if child.m_Name == name_child:
				temp_list.append(child)

		return temp_list

	def LoadNml(self, _FormatFile, _ReadChar, _RootTreeXml, _CurrentDepth=0):

		l_Error = False
		l_CurrentChar = ""

		l_FinishinthisTree = False

		l_NewTree = None

		if len(_FormatFile) <= _ReadChar:
			return _ReadChar

		l_CurrentChar = _FormatFile[_ReadChar]
		_ReadChar += 1

		while _ReadChar < len(_FormatFile) and l_Error == False and l_FinishinthisTree == False:

			# find the next letter
			while l_CurrentChar == '<':			
				l_CurrentChar = _FormatFile[_ReadChar]
				_ReadChar += 1

			# end of this root tree
			if l_CurrentChar == '>':
				l_FinishinthisTree = True
			else:		# another tree began

				# if not the end of the file
				if _ReadChar < len(_FormatFile):

					l_NewTree = NmlNode()
					l_NewTree.m_Name = ""

					while l_CurrentChar != '>' and l_CurrentChar != '=' and _ReadChar < len(_FormatFile):	# read name

						l_NewTree.m_Name = l_NewTree.m_Name + l_CurrentChar

						l_CurrentChar = _FormatFile[_ReadChar]
						_ReadChar += 1				


					# find the next letter
					while l_CurrentChar == '=':
						l_CurrentChar = _FormatFile[_ReadChar]
						_ReadChar += 1				

					# another tree
					if l_CurrentChar == '<':	
						_ReadChar = self.LoadNml(_FormatFile, _ReadChar, l_NewTree, _CurrentDepth+1)

					else:		# find the data

						l_NewTree.m_Data = ""

						while l_CurrentChar != '>' and _ReadChar < len(_FormatFile):	# read Data

							l_NewTree.m_Data = l_NewTree.m_Data + l_CurrentChar

							l_CurrentChar = _FormatFile[_ReadChar]
							_ReadChar += 1				


						# to go one step of the >
						if _ReadChar <  len(_FormatFile):
							l_CurrentChar = _FormatFile[_ReadChar]
							_ReadChar += 1				


					# put in the root tree
					_RootTreeXml.list_child.append(l_NewTree)

		return _ReadChar


class NmlReader():

	def FormatFileXml(self, f):

		l_FormatFile = ""

		l_TempText = f.read()
		read_char = 0
		l_CurrentChar = l_TempText[read_char]
		read_char += 1

		while l_CurrentChar != 0 and read_char < len(l_TempText):

			if l_CurrentChar != '\n' and l_CurrentChar != '\t' :
				l_FormatFile = l_FormatFile + l_CurrentChar

			l_CurrentChar =  l_TempText[read_char]
			read_char += 1

		return l_FormatFile

	def LoadingXmlFile(self, _NameFile):
		f = open(_NameFile, 'r')
		format_file = self.FormatFileXml(f)

		self.main_node = NmlNode()
		self.main_node.LoadNml(format_file, 0, self.main_node)


def clean_nml_string(_str):
	return _str.replace('"', '')


def parse_nml_vector(_nml_node):
	return gs.Vector3(float(_nml_node.GetChild("X").m_Data), float(_nml_node.GetChild("Y").m_Data), float(_nml_node.GetChild("Z").m_Data))


def parse_transformation(item):
	rotation = item.GetChild("Rotation")

	if rotation is None:
		rotation = gs.Vector3()
	else:
		rotation = parse_nml_vector(rotation)

	position = item.GetChild("Position")
	if position is None:
		position = gs.Vector3()
	else:
		position = parse_nml_vector(position)

	scale = item.GetChild("Scale")
	if scale is None:
		scale = gs.Vector3(1, 1, 1)
	else:
		scale = parse_nml_vector(scale)

	rotation_order = item.GetChild("RotationOrder")
	if rotation_order is None:
		rotation_order = "YXZ"
	else:
		rotation_order = rotation_order.m_Data

	return position, rotation, scale, rotation_order


def parse_collision_shape_transformation(item):
	rotation = item.GetChild("Rotation")

	if rotation is None:
		rotation = gs.Vector3()
	else:
		rotation = parse_nml_vector(rotation)

	position = item.GetChild("Position")
	if position is None:
		position = gs.Vector3()
	else:
		position = parse_nml_vector(position)

	scale = item.GetChild("Scale")
	if scale is None:
		scale = gs.Vector3(1, 1, 1)
	else:
		scale = parse_nml_vector(scale)

	dimensions = item.GetChild("Dimensions")
	if dimensions is None:
		dimensions = gs.Vector3(1, 1, 1)
	else:
		dimensions = parse_nml_vector(dimensions)

	return position, rotation, scale, dimensions


def parse_light_color(light):
	diffuse = light.GetChild("Diffuse")

	if diffuse is None:
		diffuse = gs.Color.White
	else:
		diffuse = parse_nml_vector(diffuse)
		diffuse = gs.Color(diffuse.x, diffuse.y, diffuse.z, 1.0)

	specular = light.GetChild("Specular")

	if specular is None:
		specular = gs.Color.Black
	else:
		specular = parse_nml_vector(specular)
		specular = gs.Color(specular.x, specular.y, specular.z, 1.0)

	shadow = light.GetChild("ShadowColor")

	if shadow is None:
		shadow = gs.Color.Black
	else:
		shadow = parse_nml_vector(shadow)
		shadow = gs.Color(shadow.x, shadow.y, shadow.z, 1.0)

	return diffuse, specular, shadow


def parse_globals_color(globals):
	bg_color = globals.GetChild("BackgroundColor")

	if bg_color is None:
		bg_color = gs.Color.Black
	else:
		bg_color = parse_nml_vector(bg_color)
		bg_color = gs.Color(bg_color.x, bg_color.y, bg_color.z, 1.0)

	ambient_color = globals.GetChild("AmbientColor")

	if ambient_color is None:
		ambient_color = gs.Color.Grey
	else:
		ambient_color = parse_nml_vector(ambient_color)
		ambient_color = gs.Color(ambient_color.x, ambient_color.y, ambient_color.z, 1.0)

	fog_color = globals.GetChild("FogColor")

	if fog_color is None:
		fog_color = gs.Color.Black
	else:
		fog_color = parse_nml_vector(fog_color)
		fog_color = gs.Color(fog_color.x, fog_color.y, fog_color.z, 1.0)

	return bg_color, ambient_color, fog_color


def get_nml_node_data(node, default_value = None):
	if node is None:
		return default_value

	return clean_nml_string(node.m_Data)

# Conversion routine
# - Load manually each relevant node from a NML file
# - Recreate each node into the scene graph
# - Save the resulting scene into a new file (Json or XML)

root_in = "in"
root_out = "../../source/assets/" # "out"
root_assets = "../../source/assets/"
folder_assets = "@assets"

mapping_rules = [[["g_block"], "generic_blocks"]]

gs.GetFilesystem().Mount(gs.StdFileDriver("../../game/pkg.core"), "@core")
gs.GetFilesystem().Mount(gs.StdFileDriver(root_assets), "@assets")
gs.GetFilesystem().Mount(gs.StdFileDriver(root_out), "@out")

# Init the engine
plus = gs.GetPlus()
plus.RenderInit(640, 400, "../pkg.core")


def convert_folder(folder_path):
	scn = None

	nml_reader = NmlReader()

	for in_file in os.listdir(folder_path):

		if os.path.isdir(os.path.join(folder_path, in_file)):
			convert_folder(os.path.join(folder_path, in_file))
		else:
			if in_file.find(".nms") > -1:
				# Found a NMS file, creates a new scene
				scn = plus.NewScene(True, True)

				while not scn.IsReady():
					plus.UpdateScene(scn, plus.UpdateClock())

				links = []
				uid_dict = {}

				print("Reading file ", os.path.join(folder_path, in_file))
				nml_reader.LoadingXmlFile(os.path.join(folder_path, in_file))

				in_root = nml_reader.main_node.GetChild("Scene")
				in_items = in_root.GetChilds("Items")

				# ----------- LINKAGE ----------------------
				in_links_root = in_root.GetChild("Links")

				if in_links_root is not None:
					in_links = in_links_root.GetChilds("Link")

					for in_link in in_links:
						child_item = int(get_nml_node_data(in_link.GetChild("Item"), -1))
						parent_item = int(get_nml_node_data(in_link.GetChild("Link"), -1))

						if child_item != -1 and parent_item != -1:
							links.append({'child':child_item, 'parent': parent_item})

				# ----------- INSTANCES ----------------------
				for in_item in in_items:
					#   Load instances
					instances = in_item.GetChilds("Instance")

					for instance in instances:
						mitem = instance.GetChild("MItem")
						item = instance.GetChild("Item")
						template = instance.GetChild("Template")

						if mitem is not None and mitem.GetChild("Active") is not None and mitem.GetChild("Helper") is None:
							instance_path = get_nml_node_data(instance.GetChild("Template"))

							if instance_path is not None:
								# get item name
								item_name = get_nml_node_data(mitem.GetChild("Id"), "default_name")
								uid = int(get_nml_node_data(mitem.GetChild("UId"), -1))

								# transformation
								position, rotation, scale, rotation_order = parse_transformation(item)

								new_node = gs.Node(item_name)
								scn.AddNode(new_node)

								node_transform = gs.Transform()
								node_transform.SetPosition(position)
								node_transform.SetRotation(rotation)
								node_transform.SetScale(scale)
								new_node.AddComponent(node_transform)

								instance_path = instance_path.replace(".nms", ".scn")
								instance_path = instance_path.replace("graphics/", folder_assets)

								node_instance = gs.Instance()
								node_instance.SetPath(instance_path)
								new_node.AddComponent(node_instance)

				# ----------- CAMERAS ----------------------
				for in_item in in_items:
					#   Load cameras
					mcameras = in_item.GetChilds("MCamera")

					for mcamera in mcameras:
						mitem = mcamera.GetChild("MItem")
						if mitem is not None and mitem.GetChild("Active") is not None and mitem.GetChild("Helper") is None:
							camera = mcamera.GetChild("Camera")
							item = camera.GetChild("Item")

							# get item name
							item_name = get_nml_node_data(mitem.GetChild("Id"), "default_name")
							uid = int(get_nml_node_data(mitem.GetChild("UId"), -1))

							# transformation
							position, rotation, scale, rotation_order = parse_transformation(item)

							znear = float(get_nml_node_data(item.GetChild("ZNear"), 0.2))
							zfar = float(get_nml_node_data(item.GetChild("ZFar"), 50000.0))
							zoom = float(get_nml_node_data(item.GetChild("ZoomFactor"), 5.0)) / 2.0

							new_node = plus.AddCamera(scn)
							new_node.SetName(item_name)
							new_node.GetTransform().SetPosition(position)
							new_node.GetTransform().SetRotation(rotation)

							new_node.GetComponents("Camera")[0].SetZNear(znear)
							new_node.GetComponents("Camera")[0].SetZFar(zfar)
							new_node.GetComponents("Camera")[0].SetZoomFactor(zoom)

							uid_dict[str(uid)] = new_node

				# ----------- LIGHT ----------------------
				for in_item in in_items:
					#   Load lights
					mlights = in_item.GetChilds("MLight")

					for mlight in mlights:
						mitem = mlight.GetChild("MItem")
						if mitem is not None and mitem.GetChild("Active") is not None and mitem.GetChild("Helper") is None:
							light = mlight.GetChild("Light")
							item = light.GetChild("Item")

							# get item name
							item_name = get_nml_node_data(mitem.GetChild("Id"), "default_name")
							uid = int(get_nml_node_data(mitem.GetChild("UId"), -1))

							# transformation
							position, rotation, scale, rotation_order = parse_transformation(item)
							diffuse_color, specular_color, shadow_color = parse_light_color(light)

							new_node = plus.AddLight(scn)
							new_node.SetName(item_name)
							new_node.GetTransform().SetPosition(position)
							new_node.GetTransform().SetRotation(rotation)
							new_node.GetTransform().SetScale(scale)

							# light type
							light_type = light.GetChild("Type")
							light_type = get_nml_node_data(light_type, "Point")

							light_range = float(get_nml_node_data(light.GetChild("Range"), 0.0))

							if light_type == "Point":
								new_node.GetComponents("Light")[0].SetModel(gs.Light.Model_Point)
								new_node.GetComponents("Light")[0].SetRange(light_range)

							if light_type == "Parallel":
								new_node.GetComponents("Light")[0].SetModel(gs.Light.Model_Linear)

							if light_type == "Spot":
								new_node.GetComponents("Light")[0].SetModel(gs.Light.Model_Spot)
								new_node.GetComponents("Light")[0].SetRange(light_range)
								new_node.GetComponents("Light")[0].SetConeAngle(float(get_nml_node_data(light.GetChild("ConeAngle"), 30.0)))
								new_node.GetComponents("Light")[0].SetEdgeAngle(float(get_nml_node_data(light.GetChild("EdgeAngle"), 15.0)))

							new_node.GetComponents("Light")[0].SetShadowRange(float(get_nml_node_data(light.GetChild("ShadowRange"), 0.0)))
							new_node.GetComponents("Light")[0].SetClipDistance(float(get_nml_node_data(light.GetChild("ClipDistance"), 300.0)))

							new_node.GetComponents("Light")[0].SetDiffuseColor(diffuse_color)
							new_node.GetComponents("Light")[0].SetSpecularColor(specular_color)
							new_node.GetComponents("Light")[0].SetShadowColor(shadow_color)

							new_node.GetComponents("Light")[0].SetDiffuseIntensity(float(get_nml_node_data(light.GetChild("DiffuseIntensity"), 1.0)))
							new_node.GetComponents("Light")[0].SetSpecularIntensity(float(get_nml_node_data(light.GetChild("SpecularIntensity"), 0.0)))

							new_node.GetComponents("Light")[0].SetZNear(float(get_nml_node_data(light.GetChild("ZNear"), 0.01)))
							new_node.GetComponents("Light")[0].SetShadowBias(float(get_nml_node_data(light.GetChild("ShadowBias"), 0.01)))

							uid_dict[str(uid)] = new_node

				# ----------- GEOMETRIES & NULL OBJECTS ----------------------
				for in_item in in_items:
					#   Load items with geometry
					mobjects = in_item.GetChilds("MObject")
					for mobject in mobjects:
						mitem = mobject.GetChild("MItem")
						if mitem is not None and mitem.GetChild("Active") is not None and mitem.GetChild("Helper") is None:
							object = mobject.GetChild("Object")
							item = object.GetChild("Item")

							# get item name
							item_name = get_nml_node_data(mitem.GetChild("Id"), "default_name")
							uid = int(get_nml_node_data(mitem.GetChild("UId"), -1))

							# get item geometry
							geometry_filename = None
							if object is not None:
								geometry = object.GetChild("Geometry")
								if geometry is not None:
									geometry_filename = geometry.m_Data
									geometry_filename = clean_nml_string(geometry_filename)
									if geometry_filename.find("/") > -1:
										geometry_filename = geometry_filename.split("/")[-1]
									geometry_filename = geometry_filename.replace(".nmg", ".geo")

							# transformation
							position, rotation, scale, rotation_order = parse_transformation(item)

							node_geo_filename = ""

							if geometry_filename is not None and geometry_filename != '':
								intermediate_folder = None
								for mapping_rule in mapping_rules:
									for rule_item_name in mapping_rule[0]:
										if item_name.startswith(rule_item_name):
											intermediate_folder = mapping_rule[1]

								if intermediate_folder is not None:
									node_geo_filename = os.path.join(folder_assets, intermediate_folder, geometry_filename)
								else:
									node_geo_filename = os.path.join(folder_assets, geometry_filename)

							new_node = plus.AddGeometry(scn, node_geo_filename)

							if new_node is not None:
								new_node.SetName(item_name)
								new_node.GetTransform().SetPosition(position)
								new_node.GetTransform().SetRotation(rotation)
								new_node.GetTransform().SetScale(scale)

								# physics
								physic_item = mitem.GetChild("PhysicItem")
								if physic_item is not None:
									physic_mode = get_nml_node_data(physic_item.GetChild("Mode"), "None")
									if physic_mode != "None":
										rigid_body = gs.MakeRigidBody()

										rb_type = {'Dynamic': gs.RigidBodyDynamic,
												   'Kinematic': gs.RigidBodyKinematic,
												   'Static': gs.RigidBodyStatic}
										if physic_mode in rb_type:
											rigid_body.SetType(rb_type[physic_mode])
										else:
											print("!Physic mode unknown!")

										linear_damping = 1.0 - float(get_nml_node_data(physic_item.GetChild("LinearDamping_v2"), 1.0))
										angular_damping = 1.0 - float(get_nml_node_data(physic_item.GetChild("AngularDamping_v2"), 1.0))
										rigid_body.SetLinearDamping(linear_damping)
										rigid_body.SetAngularDamping(angular_damping)

										# physic_self_mask = int(get_nml_node_data(physic_item.GetChild("SelfMask"), 1))
										# physic_collision_mask = int(get_nml_node_data(physic_item.GetChild("Mask"), 1))

										new_node.AddComponent(rigid_body)

										while True:
											scn.Commit()
											scn.WaitCommit()
											scn.Update()
											if scn.IsReady():
												break

										# iterate on shapes
										physic_root_shapes = physic_item.GetChild("Shapes")
										if physic_root_shapes is not None:
											physic_shapes = physic_root_shapes.GetChilds("PhysicShape")
											if physic_shapes is not None:
												for physic_shape in physic_shapes:
													physic_shape_type = get_nml_node_data(physic_shape.GetChild("Type"), "Box")

													new_collision_shape = None
													col_type_dict = {'Box': gs.MakeBoxCollision(),
													                 'Sphere': gs.MakeSphereCollision(),
													                 'Capsule': gs.MakeCapsuleCollision(),
													                 'Cylinder': gs.MakeCapsuleCollision(),
													                 'Mesh': gs.MakeMeshCollision(),
													                 'Convex': gs.MakeConvexCollision()}

													if physic_shape_type in col_type_dict:
														new_collision_shape = col_type_dict[physic_shape_type]
													else:
														new_collision_shape = gs.MakeBoxCollision()

													if physic_mode == "Static":
														new_collision_shape.SetMass(0.0)
													else:
														new_collision_shape.SetMass(float(get_nml_node_data(physic_shape.GetChild("Mass"), 1.0)))
													# new_collision_shape.SetSelfMask(physic_self_mask)
													# new_collision_shape.SetCollisionMask(physic_collision_mask)

													position, rotation, scale, dimensions = parse_collision_shape_transformation(physic_shape)

													col_matrix = gs.Matrix4()
													col_matrix.SetTranslation(position)
													col_matrix.Rotate(rotation)
													new_collision_shape.SetMatrix(col_matrix)

													if physic_shape_type == 'Box':
														new_collision_shape.SetDimensions(dimensions)
													elif physic_shape_type == 'Sphere':
														new_collision_shape.SetRadius(dimensions.x)
													elif physic_shape_type == 'Capsule' or physic_shape_type == 'Cylinder':
														new_collision_shape.SetRadius(dimensions.x)
														new_collision_shape.SetLength(dimensions.y)
													elif physic_shape_type == 'Convex':
														col_geo = gs.LoadCoreGeometry(node_geo_filename)
														if col_geo is not None:
															new_collision_shape.SetGeometry(col_geo)

													new_node.AddComponent(new_collision_shape)

								uid_dict[str(uid)] = new_node

							while True:
								scn.Commit()
								scn.WaitCommit()
								scn.Update()
								if scn.IsReady():
									break

				# ----------- RE-LINKAGE ----------------------
				for linkage in links:
					if linkage['parent'] is not None and linkage['child'] is not None:

						if str(linkage['child']) in uid_dict and str(linkage['parent']) in uid_dict:
							uid_dict[str(linkage['child'])].GetTransform().SetParent(uid_dict[str(linkage['parent'])])

				# ----------- ENVIRONMENT ----------------------
				in_globals = in_root.GetChild("Globals")

				env_global = gs.Environment()
				bg_color, ambient_color, fog_color = parse_globals_color(in_globals)

				ambient_intensity = float(get_nml_node_data(in_globals.GetChild("AmbientIntensity"), 0.5))
				fog_near = float(get_nml_node_data(in_globals.GetChild("FogNear"), 0.5))
				fog_far = float(get_nml_node_data(in_globals.GetChild("FogFar"), 0.5))

				env_global.SetBackgroundColor(bg_color)

				env_global.SetAmbientIntensity(ambient_intensity)
				env_global.SetAmbientColor(ambient_color)

				env_global.SetFogNear(fog_near)
				env_global.SetFogFar(fog_far)
				env_global.SetFogColor(fog_color)

				scn.AddComponent(env_global)

				while True:
					scn.Commit()
					scn.WaitCommit()
					scn.Update()
					if scn.IsReady():
						break

		# Creates the output folder
				folder_out = folder_path.replace(root_in + '\\', '')
				folder_out = folder_out.replace(root_in + '/', '')
				folder_out = folder_out.replace(root_in, '')

				os.makedirs(root_out, exist_ok=True)
				if folder_out !='' and not os.path.exists(os.path.join(root_out, folder_out)):
					os.makedirs(os.path.join(root_out, folder_out), exist_ok=True)

				# Saves the scene
				out_file = os.path.join("@out", folder_out, in_file.replace(".nms", ".scn"))
				print('saving to ', out_file)
				scn.Save(out_file, gs.SceneSaveContext(plus.GetRenderSystem()))

				# Clears the scene
				scn.Clear()
				scn.Dispose()
				scn = None

convert_folder(root_in)
