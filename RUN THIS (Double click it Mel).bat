@echo off
color 02
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
    >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
    >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params= %*
echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B

:gotAdmin
pushd "%CD%"
CD /D "%~dp0"
:--------------------------------------    

set "sourceDirectory=%~dp0"
set "destinationDirectory=%APPDATA%\.minecraft"

if not exist "%destinationDirectory%" (
    mkdir "%destinationDirectory%"
)

rem Move all files in Mods folder to %APPDATA%\.minecraft\mods
if exist "%sourceDirectory%\mods" (
    if not exist "%destinationDirectory%\mods" (
        mkdir "%destinationDirectory%\mods"
    )
    xcopy /E /I "%sourceDirectory%\mods\*" "%destinationDirectory%\mods\"
    echo Mods folder moved successfully.
) else (
    echo Mods folder does not exist in source directory. Skipping...
)

rem Move all files and folders in Config folder to %APPDATA%\.minecraft\config
if exist "%sourceDirectory%\config" (
    if not exist "%destinationDirectory%\config" (
        mkdir "%destinationDirectory%\config"
    )
    xcopy /E /I "%sourceDirectory%\config\*" "%destinationDirectory%\config\"
    echo Config folder moved successfully.
) else (
    echo Config folder does not exist in source directory. Skipping...
)

echo Files moved successfully.

rem Check if Optifine or Embeddium files already exist in %APPDATA%\.minecraft\mods
if exist "%APPDATA%\.minecraft\mods\*optifine*" (
    echo Optifine files already exist in %APPDATA%\.minecraft\mods. Skipping menu.
    goto :skipMenu
) else if exist "%APPDATA%\.minecraft\mods\*embeddium*" (
    echo Embeddium files already exist in %APPDATA%\.minecraft\mods. Skipping menu.
    goto :skipMenu
)

cls
echo.
echo Please choose an option:
echo 1. Optifine (Provides more visual details) 
echo 2. Embeddium (Provides more fps boost RECOMMENDED) 

set /p choice=Enter choice (1 or 2): 

if "%choice%"=="1" (
    rem Move Optifine files to %APPDATA%\.minecraft\mods
    if exist "%sourceDirectory%\FPS MODS\Optifine" (
        move /Y "%sourceDirectory%\FPS MODS\Optifine\*" "%APPDATA%\.minecraft\mods\"
        echo Optifine files moved successfully.
    ) else (
        echo Optifine folder does not exist in FPS MODS directory. Skipping...
    )
) else if "%choice%"=="2" (
    rem Move Embeddium files to %APPDATA%\.minecraft\mods
    if exist "%sourceDirectory%\FPS MODS\Embeddium" (
        move /Y "%sourceDirectory%\FPS MODS\Embeddium\*" "%APPDATA%\.minecraft\mods\"
        echo Embeddium files moved successfully.
    ) else (
        echo Embeddium folder does not exist in FPS MODS directory. Skipping...
    )
    echo Exiting...
)

:skipMenu
cls
echo All mods have been installed.
pause
