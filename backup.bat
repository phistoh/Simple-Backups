@ECHO off

REM include the directory where backup.lua is located
SET simple_backups_dir=D:\Simple-Backups\
SET current_path=%CD%

ECHO %simple_backups_dir%

cd %simple_backups_dir%
lua backup.lua %1

cd %current_path%