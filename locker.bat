@echo off
title Secure Folder Locker
cls

:: Check if Locker exists
if EXIST "Locker" goto LOCK
if EXIST "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}" goto UNLOCK

:: If folder does not exist, create it
echo Folder not found! Creating new Locker folder...
mkdir Locker
echo Folder created successfully!
pause
exit

:LOCK
echo Locking the folder...
attrib -h -s Locker
ren Locker "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"
attrib +h +s "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"
echo Folder locked successfully!
echo [%date% %time%] Folder locked >> locker.log
pause
exit

:UNLOCK
cscript //nologo password.vbs
if %ERRORLEVEL% NEQ 0 (
    echo Incorrect password!
    echo [%date% %time%] Incorrect password attempt >> locker.log
    pause
    exit
)
attrib -h -s "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}"
ren "Control Panel.{21EC2020-3AEA-1069-A2DD-08002B30309D}" Locker
echo Folder unlocked successfully!
echo [%date% %time%] Folder unlocked >> locker.log
pause
exit

:CHANGE_PASS
cscript //nologo password.vbs change
if %ERRORLEVEL% NEQ 0 (
    echo Incorrect password! Cannot change password.
    echo [%date% %time%] Incorrect password attempt on password change >> locker.log
    pause
    exit
)
echo Password changed successfully!
echo [%date% %time%] Password changed >> locker.log
pause
exit
