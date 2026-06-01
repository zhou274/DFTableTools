@echo off
setlocal
chcp 65001 >nul 2>&1

cd /d "%~dp0"

set "LUBAN_EXE=luban\src\Luban\bin\Release\net8.0\Luban.exe"
set "CONF_FILE=luban.conf"

if not exist "%CONF_FILE%" set "CONF_FILE=luban.json"

if not exist "%LUBAN_EXE%" (
    echo [ERROR] Luban.exe not found: %CD%\%LUBAN_EXE%
    pause
    exit /b 1
)
if not exist "%CONF_FILE%" (
    echo [ERROR] Config file not found: %CD%\%CONF_FILE%
    pause
    exit /b 1
)

set "TARGET=code"
set "FMT="

:parse_args
if "%~1"=="" goto run
if /i "%~1"=="code"   (set "MODE=c"   & shift & goto parse_args)
if /i "%~1"=="data"   (set "MODE=d"   & shift & goto parse_args)
if /i "%~1"=="all"    (set "MODE=cd"  & shift & goto parse_args)
if /i "%~1"=="client" (set "TARGET=client" & shift & goto parse_args)
if /i "%~1"=="server" (set "TARGET=server" & shift & goto parse_args)
if /i "%~1"=="bin"    (set "FMT=bin"   & shift & goto parse_args)
if /i "%~1"=="json"   (set "FMT=json"  & shift & goto parse_args)
if /i "%~1"=="xml"    (set "FMT=xml"   & shift & goto parse_args)
if /i "%~1"=="lua"    (set "FMT=lua"   & shift & goto parse_args)
if /i "%~1"=="both"   (set "FMT=both"  & shift & goto parse_args)
if /i "%~1"=="watch"  (set "WATCH=1"   & shift & goto parse_args)
if /i "%~1"=="-t"     (set "TARGET=%~2" & shift & shift & goto parse_args)
if /i "%~1"=="-h"     goto help
if /i "%~1"=="-help"  goto help
if /i "%~1"=="--help" goto help
shift
goto parse_args

:run
if not defined MODE set "MODE=cd"
if not defined FMT  set "FMT=both"

set "CMD_ARGS=--conf %CONF_FILE% -t %TARGET%"

if "%FMT%"=="both" goto run_both

if "%MODE%"=="c"  set "CMD_ARGS=%CMD_ARGS% -c cs-%FMT%"
if "%MODE%"=="d"  set "CMD_ARGS=%CMD_ARGS% -d %FMT%"
if "%MODE%"=="cd" set "CMD_ARGS=%CMD_ARGS% -c cs-%FMT% -d %FMT%"
if defined WATCH  set "CMD_ARGS=%CMD_ARGS% -w Datas"

echo.
echo ============================================
echo   Luban Table Export
echo   Mode: %MODE%   Format: %FMT%   Target: %TARGET%
echo ============================================
echo.

"%LUBAN_EXE%" %CMD_ARGS%
goto result

:run_both
echo.
echo ============================================
echo   Luban Table Export
echo   Mode: %MODE%   Format: json + bin   Target: %TARGET%
echo ============================================
echo.

set "ARGS_BASE=--conf %CONF_FILE% -t %TARGET%"
if defined WATCH  set "ARGS_WATCH=-w Datas"

echo --- Code + JSON ---
set "CMD_ARGS=%ARGS_BASE%"
if "%MODE%"=="c"  set "CMD_ARGS=%CMD_ARGS% -c cs-bin -d json"
if "%MODE%"=="d"  set "CMD_ARGS=%CMD_ARGS% -d json"
if "%MODE%"=="cd" set "CMD_ARGS=%CMD_ARGS% -c cs-bin -d json"
if defined WATCH  set "CMD_ARGS=%CMD_ARGS% %ARGS_WATCH%"
"%LUBAN_EXE%" %CMD_ARGS%
if %ERRORLEVEL% neq 0 goto result

echo.
echo --- Bin ---
set "CMD_ARGS=%ARGS_BASE%"
if "%MODE%"=="c"  set "CMD_ARGS=%CMD_ARGS% -c cs-bin -d bin"
if "%MODE%"=="d"  set "CMD_ARGS=%CMD_ARGS% -d bin"
if "%MODE%"=="cd" set "CMD_ARGS=%CMD_ARGS% -c cs-bin -d bin"
if defined WATCH  set "CMD_ARGS=%CMD_ARGS% %ARGS_WATCH%"
"%LUBAN_EXE%" %CMD_ARGS%

:result

echo.
if %ERRORLEVEL% neq 0 (
    echo [FAIL] exit code: %ERRORLEVEL%
) else (
    echo [OK] Done.
)
echo.
pause
goto :EOF

:help
echo.
echo  Usage:  gen [mode] [format] [options]
echo.
echo  Mode (default: all):
echo    code      Generate C# code only
echo    data      Export table data only
echo    all       Generate code + data
echo.
echo  Format:  both(json+bin, default) ^| json ^| bin ^| xml ^| lua
echo  Target:  code(client+server, default) ^| client ^| server
echo.
echo  Examples:
echo    gen              code + json data
echo    gen code         C# code only
echo    gen data json    export JSON data
echo    gen all json     code + JSON data
echo.
pause
