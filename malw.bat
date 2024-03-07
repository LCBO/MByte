@echo off

:: Check if user has administrative privileges, if not, elevate
net session >nul 2>&1
if %errorLevel% == 0 (
    echo User has administrative privileges
) else (
    echo Requesting administrative privileges...
    powershell Start-Process "%0" -Verb RunAs
    exit /B
)

:: Stop Malwarebytes
start "" "%ProgramFiles%\Malwarebytes\Anti-Malware\malwarebytes_assistant.exe" --stopservice

:: Wait for Malwarebytes to exit (optional)
ping -n 1 127.0.0.1 >nul

:: Generate a new code and set it in the registry
REM Generate a new GUID
setlocal EnableDelayedExpansion
set "CHARS=0123456789ABCDEF"
set "GUID="
for /L %%i in (1,1,32) do (
    set /A "R=!RANDOM! %% 16"
    for %%j in (!R!) do (
        set "GUID=!GUID!!CHARS:~%%j,1!"
    )
)
endlocal & set "GUID=%GUID%"

REM Set the new GUID in the registry
reg add "HKLM\SOFTWARE\Microsoft\Cryptography" /v MachineGuid /t REG_SZ /d "%GUID%" /f

echo New MachineGuid value set to: %GUID%

:: Wait for a few seconds before automatically exiting
timeout /t 2 >nul
