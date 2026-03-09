@echo off
setlocal enabledelayedexpansion

set FILES[0]="C:\Users\brookit\AppData\Local\Packages\TheDebianProject.DebianGNULinux_76v4gfsz19hv4\LocalState\ext4.vhdx"
set FILES[1]="C:\Users\brookit\AppData\Local\Docker\wsl\main\ext4.vhdx"
set FILES[2]="C:\Users\brookit\AppData\Local\Docker\wsl\disk\docker_data.vhdx"
set COUNT=3

echo Shutting down WSL...
wsl --shutdown

for /L %%i in (0,1,%COUNT%-1) do (
    set "FILE=!FILES[%%i]!"
    echo Processing: !FILE!

    set "TMP_SCRIPT=%TEMP%\diskpart_%%i.txt"
    (
        echo select vdisk file="!FILE!"
        echo attach vdisk readonly
        echo compact vdisk
        echo detach vdisk
        echo exit
    ) > "!TMP_SCRIPT!"

    diskpart /s "!TMP_SCRIPT!"
    del "!TMP_SCRIPT!"
)

echo Done.