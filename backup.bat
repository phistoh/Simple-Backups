@ECHO off

SET simple_backups_dir=E:\GitHub\Simple-Backups\
SET current_path=%CD%

E:
cd %simple_backups_dir%
lua backup.lua %1

%CD:~0,2%
cd %current_path%