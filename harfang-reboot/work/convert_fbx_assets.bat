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

timeout 2
REM delete all in build
del /s /f /q ..\build\assets\*.*
timeout 2

for /f %%f in ('dir /ad /b ..\build\assets\') do rd /s /q ..\build\assets\%%f
timeout 2

REM copy all assets in source to assets in build
mkdir ..\build\assets
xcopy /s ..\source\assets ..\build\assets

pause