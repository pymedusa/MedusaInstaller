:: Run the installer with the local seed and external files

@ECHO OFF

CALL :NORMALIZEPATH "."
SET ROOT=%RETVAL%
SET INSTALLER="%ROOT%\Output\MedusaInstaller.exe"

if not exist %INSTALLER% (
  echo Installer not found, have you compiled the .iss file?
  EXIT /B 1
)

:: Runs the installer with the local seed and local install files
%INSTALLER% ^
  /SEED="%ROOT%\seed.ini" ^
  /LOCALFILES="%ROOT%\files" ^
  /LOCALREPO="%ROOT%\repo" ^
  /LOG="%ROOT%\Output\installer.log" ^
  %*

:: ========== FUNCTIONS ==========
EXIT /B

:NORMALIZEPATH
  SET RETVAL=%~dpfn1
  EXIT /B
