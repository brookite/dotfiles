Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore

Dism.exe /Online /Cleanup-Image /StartComponentCleanup

Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore

powershell -c "Optimize-VHD -Path 'C:\Users\brookit\AppData\Local\Packages\TheDebianProject.DebianGNULinux_76v4gfsz19hv4\LocalState\ext4.vhdx' -Mode Full"

pause