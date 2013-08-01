/*
	File: sunlight.nut
	Author: Movida
*/

/*!
	@short	SunLight
	@author	Movida
*/
class	SunLight
{
	main_light				=	0
	sun_light_item			=	0
	sun_item				=	0
	sun_light_picture 		=	0

	current_hour = 0
	
	cam_light = 0
	cam_light_2 = 0
		
	function SetHour(_current_hour)		// between 0.0 and 24.0
	{		
		print("SunLight::SeHour()")
		current_hour = _current_hour
		
		local lat = 0.3; //(_current_hour / 24.0) * 3.141592 * 2.0
		local lon = (_current_hour / 24.0) * 3.141592 * 2.0 - 3.141592
		
		local lightdir = Vector(sin(lon) * sin(lat), cos(lon), sin(lon) * cos(lat))
		lightdir = (Vector(0,0,0) - lightdir).Normalize()

		// daylight between 6H and 21h		
		if(6.0 < _current_hour && _current_hour < 21.0)
		{			
			LightSetDiffuseIntensity(main_light, 1.25)
			LightSetSpecularIntensity(main_light, 1.25)
//			ItemSetRotation(sun_light_item, Vector(RangeAdjust(Clamp(_current_hour, 6.0, 21.0), 6.0, 21.0, 0.0, PI), ItemGetRotation(sun_light_item).y, ItemGetRotation(sun_light_item).z))
			ItemSetRotation(sun_light_item, EulerFromDirection(lightdir))
		}
		else
		// night
		{			
			if(_current_hour >= 21.0)
			{
				LightSetDiffuseIntensity(main_light, RangeAdjust(Clamp(_current_hour, 21.0, 22.0), 21.0, 22.0, 1.0, 0.0))				
				LightSetSpecularIntensity(main_light, RangeAdjust(Clamp(_current_hour, 21.0, 22.0), 21.0, 22.0, 1.0, 0.0))										
			}
			else			
			{
				ItemSetRotation(sun_light_item, Vector(0.0, ItemGetRotation(sun_light_item).y, ItemGetRotation(sun_light_item).z))
				LightSetDiffuseIntensity(main_light, RangeAdjust(Clamp(_current_hour, 5.0, 6.0), 5.0, 6.0, 0.0, 1.0))
				LightSetSpecularIntensity(main_light, RangeAdjust(Clamp(_current_hour, 5.0, 6.0), 5.0, 6.0, 0.0, 1.0))
			}						
		}
		
		if(_current_hour >= 19)
		{
			ItemGetScriptInstance(sun_item).strength = 0.25 * RangeAdjust(Clamp(_current_hour, 19.0, 20.4), 19.0, 20.4, 10.0, 0.0)			
		}
		else
		if(_current_hour < 7)
		{
			ItemGetScriptInstance(sun_item).strength = 0.25 * RangeAdjust(Clamp(_current_hour, 5.5, 7.0), 5.5, 7.0, 0.0, 10.0)	
		}
		else
		{
			ItemGetScriptInstance(sun_item).strength = 0.25 * 10.0	
		}

		SceneSetTimeOfDay(g_scene, RangeAdjust(_current_hour, 0.0, 24.0, 0.0, 1.0))
				
		
		//set sun color 
		local pixel_x = RangeAdjust(Clamp(_current_hour, 0.0, 24.0), 0.0, 24.0, 0.0, PictureGetRect(sun_light_picture).ex).tointeger()
		LightSetDiffuseColor(main_light, PictureGetPixel(sun_light_picture, pixel_x, 1))
		LightSetSpecularColor(main_light, PictureGetPixel(sun_light_picture, pixel_x, 1))
		
		// set fog color
		local	range_near, range_far, fog_luminosity

		if (_current_hour < 12)
		{
		 	range_near = RangeAdjust(Clamp(_current_hour, 0.0, 12.0), 0.0, 12.0, 0.0, 50.0)
		 	range_far = RangeAdjust(Clamp(_current_hour, 0.0, 12.0), 0.0, 12.0, 250.0, 750.0)
		 	fog_luminosity  =  Clamp(RangeAdjust(_current_hour, 0.0, 12.0, 0.0, 1.0), 0.0, 1.0)
		}
		else
		{
			range_near = RangeAdjust(Clamp(_current_hour, 12.0, 24.0), 12.0, 24.0, 50.0, 0.0)
		 	range_far = RangeAdjust(Clamp(_current_hour, 12.0, 24.0), 12.0, 24.0, 750.0, 250.0)
		 	fog_luminosity  =  Clamp(RangeAdjust(_current_hour, 12.0, 24.0, 1.0, 0.0), 0.0, 1.0)
		}

		local	_fog_color = PictureGetPixel(sun_light_picture, pixel_x, (PictureGetRect(sun_light_picture).ey*0.5).tointeger())
		local	_ambient_color = PictureGetPixel(sun_light_picture, pixel_x, PictureGetRect(sun_light_picture).ey-1)
		_fog_color = _fog_color.Scale(fog_luminosity)
		SceneSetFog(g_scene, true, _fog_color, range_near, range_far)
		SceneSetBackgroundColor(g_scene, _fog_color.Scale(fog_luminosity))
		
		// set ambient
		SceneSetAmbientColor(g_scene, _ambient_color)
	}
	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/
	function	OnUpdate(item)
	{
		ItemSetPosition(sun_item, ItemGetWorldPosition(CameraGetItem(SceneGetCurrentCamera(g_scene)))+ItemGetMatrix(sun_light_item).GetFront()*-1000.0)
		ItemSetRotationMatrix(sun_item, RotationMatrixFromDirection((ItemGetWorldPosition(sun_item)-ItemGetWorldPosition(CameraGetItem(SceneGetCurrentCamera(g_scene)))).Normalize()))
	}

	function	OnReset(item)
	{			
		print("SunLight::OnReset()")
//		SetHour(10.0)
	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup. 
	*/
	function	OnSetup(item)
	{		
		print("SunLight::OnSetup()")
		sun_light_item = item
		main_light = ItemCastToLight(SceneFindItemChild(g_scene, item, "sun"))
		
		sun_item = SceneFindItem(g_scene, "lens_flare")
		sun_light_picture = PictureNew()
		PictureLoadContent(sun_light_picture, "graphics/time_of_day.png")					
	}
}
