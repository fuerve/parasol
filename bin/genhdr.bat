setlocal

set BIN=%~dp0
if "%BIN:~-1%"=="\" set BIN=%BIN:~0,-1%

for %%i in (%BIN%) do set PARASOL_HOME=%%~dpi
if "%PARASOL_HOME:~-1%"=="\" set PARASOL_HOME=%PARASOL_HOME:~0,-1%

%PARASOL_HOME%\debug\parasol %PARASOL_HOME%\compiler/main.p %1 %2 --header=%PARASOL_HOME%\parasol/parasol_enums.h %PARASOL_HOME%\compiler/main.p

endlocal