-- Finalizer script example for the FBX converter.

function FinalizeMaterial(mat, name, geo_name)
    print("Finalizer called for material "..name.." in geometry "..geo_name)
    if string.find(name, "pine_needles") ~= nil then
    	print("Updating shader")
    	mat:SetShader("shaders/diffuse_map_alpha-test.isl")
    end

	values = {"diffuse_map", "specular_map", "normal_map", "opacity_map", "self_map", "light_map"}
	for n=1, #values do
		local value = mat:GetValue(values[n])
		if value ~= nil then
			local tex_cfg = value:GetTextureUnitConfig()

			tex_cfg.min_filter = gs.TextureFilterAnisotropic
			tex_cfg.mag_filter = gs.TextureFilterAnisotropic
		end
	end    
end

function FinalizeGeometry(geo, name)
    print("Finalizer called for geometry "..name)
end

function FinalizeNode(node)
    print("Finalizer called for node "..node:GetName())
end

function FinalizeScene(scene)
    print("Finalizer called for scene")
end