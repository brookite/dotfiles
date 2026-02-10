wsl --shutdown
diskpart
select vdisk file="C:\Users\brookit\AppData\Local\Packages\TheDebianProject.DebianGNULinux_76v4gfsz19hv4\LocalState\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit