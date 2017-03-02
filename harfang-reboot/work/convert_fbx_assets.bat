REM input : fbx_files/
REM output : ../source/assets/

mkdir ..\source\assets

REM pod
mkdir ..\source\assets\pod
fbx_converter_bin fbx/pod/pod.fbx -fix-geometry-orientation -o ../source/assets/pod/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite

rem generic_blocks
mkdir ..\source\assets\generic_blocks
fbx_converter_bin fbx/generic_blocks/generic_blocks.fbx -fix-geometry-orientation -o ../source/assets/generic_blocks/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite

rem shield
mkdir ..\source\assets\shield
fbx_converter_bin fbx/shield/shield.fbx -fix-geometry-orientation -o ../source/assets/shield/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite

rem mobile_items
fbx_converter_bin fbx/mobile_items/mobiles_items.FBX -fix-geometry-orientation -o ../source/assets/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite

rem bonus
fbx_converter_bin fbx/mobile_items/bonus.FBX -fix-geometry-orientation -o ../source/assets/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite

rem static_props
fbx_converter_bin fbx/static_props/prop_greek_columns.FBX -fix-geometry-orientation -o ../source/assets/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite
fbx_converter_bin fbx/static_props/prop_reservoir.FBX -fix-geometry-orientation -o ../source/assets/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite
fbx_converter_bin fbx/static_props/prop_sea.FBX -fix-geometry-orientation -o ../source/assets/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite
fbx_converter_bin fbx/static_props/prop_statue.FBX -fix-geometry-orientation -o ../source/assets/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite
fbx_converter_bin fbx/static_props/prop_trees.FBX -fix-geometry-orientation -o ../source/assets/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite -finalizer-script finalizer.lua

rem background
fbx_converter_bin fbx/background/background_elements.FBX -fix-geometry-orientation -o ../source/assets/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite
fbx_converter_bin fbx/background/background_mountain.FBX -fix-geometry-orientation -o ../source/assets/ -base-resource-path ../source/ -material-policy overwrite -geometry-policy overwrite -texture-policy overwrite -scene-policy overwrite


rem timeout 2
rem REM delete all in build
rem del /s /f /q ..\build\assets\*.*
rem timeout 2

rem for /f %%f in ('dir /ad /b ..\build\assets\') do rd /s /q ..\build\assets\%%f
rem timeout 2

rem REM copy all assets in source to assets in build
rem mkdir ..\build\assets
rem xcopy /s ..\source\assets ..\build\assets

pause