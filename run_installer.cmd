:: Run the installer with the local seed and external files

@ECHO OFF
SETLOCAL EnableDelayedExpansion

CALL :NORMALIZEPATH "."
SET ROOT=%RETVAL%
SET INSTALLER="%ROOT%\Output\MedusaInstaller.exe"

IF NOT EXIST %INSTALLER% (
  ECHO Installer not found, have you compiled the .iss file?
  EXIT /B 1
)

IF "%~1" NEQ "" (
  SET REPO=%~dpfn1
  IF NOT EXIST !REPO!\ (
    ECHO Provided local repo location does not exist.
    EXIT /B 1
  )
  SET LOCALREPO=/LOCALREPO="!REPO!"
) ELSE (
  SET LOCALREPO=
)

:: Runs the installer with the local seed and local install files
%INSTALLER% ^
  /SEED="%ROOT%\seed.ini" ^
  /LOCALFILES="%ROOT%\files" ^
  /LOG="%ROOT%\Output\installer.log" ^
  %LOCALREPO%

:: ========== FUNCTIONS ==========
EXIT /B %ERRORLEVEL%

:NORMALIZEPATH
  SET RETVAL=%~dpfn1
  EXIT /B
