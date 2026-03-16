@echo off
setlocal enabledelayedexpansion

set "FILES[0]=C:\Users\%USERNAME%\AppData\Local\Packages\TheDebianProject.DebianGNULinux_76v4gfsz19hv4\LocalState\ext4.vhdx"
set "FILES[1]=C:\Users\%USERNAME%\AppData\Local\Docker\wsl\main\ext4.vhdx"
set "FILES[2]=C:\Users\%USERNAME%\AppData\Local\Docker\wsl\disk\docker_data.vhdx"
set /a COUNT=3
set /a LAST=COUNT-1

echo Shutting down WSL...
wsl --shutdown

for /L %%i in (0,1,%LAST%) do (
    set "FILE=!FILES[%%i]!"
    echo.
    echo Processing: !FILE!

    set "TMP_SCRIPT=%TEMP%\diskpart_%%i.txt"
    (
        echo select vdisk file="!FILE!"
        echo attach vdisk readonly
        echo compact vdisk
        echo detach vdisk
    ) > "!TMP_SCRIPT!"

    echo DiskPart script:
    type "!TMP_SCRIPT!"
    echo.

    diskpart /s "!TMP_SCRIPT!"
    if errorlevel 1 (
        echo Error while processing: !FILE!
    )

    del "!TMP_SCRIPT!"
)

echo.
echo Done.
pause