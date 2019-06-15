:: Generate seed data for seed.ini

@ECHO OFF

IF NOT EXIST %1 (
  ECHO %1 is not a valid file
  EXIT /B 1
)

SET FILENAME=%~nx1
SET SIZE=%~z1
FOR /F "tokens=*" %%i IN ('CertUtil -hashfile "%~1" SHA1 ^| find /i /v "SHA1" ^| find /i /v "certutil"') do (
  SET SHA1=%%i
)

echo filename=%FILENAME%
echo size=%SIZE%
echo sha1=%SHA1%
