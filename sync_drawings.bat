@echo off
setlocal enabledelayedexpansion

set "SOURCE_FOLDER=%CD%"
set "OUTPUT_FILE=drawings.js"

echo Scanning folders for Pole Drawings...

:: --- Get timestamp with fallback ---
set "dt="
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul') do (
    if not "%%I"=="" set "dt=%%I"
)

:: If wmic failed, fall back to %date% and %time%
if "!dt!"=="" (
    echo Warning: wmic unavailable, using fallback date source.
    set "datestr=%DATE%"
    set "timestr=%TIME:~0,5%"
) else (
    set "yyyy=!dt:~0,4!"
    set "mm=!dt:~4,2!"
    set "dd=!dt:~6,2!"
    set "hh=!dt:~8,2!"
    set "mi=!dt:~10,2!"
    set "datestr=!dd!/!mm!/!yyyy!"
    set "timestr=!hh!:!mi!"
)

echo Timestamp: !datestr! !timestr!

:: --- Write the JS file ---
echo var drawingData = { > "%OUTPUT_FILE%"
echo   "lastUpdated": "!datestr! !timestr!", >> "%OUTPUT_FILE%"
echo   "folders": { >> "%OUTPUT_FILE%"

set "firstFolder=true"

for /d %%D in ("%SOURCE_FOLDER%\*") do (
    set "folderName=%%~nxD"
    if exist "%%D\*.pdf" (
        if "!firstFolder!"=="false" (
            echo       , >> "%OUTPUT_FILE%"
        )
        set "firstFolder=false"
        echo     "!folderName!": [ >> "%OUTPUT_FILE%"
        set "firstFile=true"
        for %%F in ("%%D\*.pdf") do (
            set "fileName=%%~nxF"
            if "!firstFile!"=="false" (
                echo         , "!fileName!" >> "%OUTPUT_FILE%"
            ) else (
                echo           "!fileName!" >> "%OUTPUT_FILE%"
            )
            set "firstFile=false"
        )
        <nul set /p ="      ]" >> "%OUTPUT_FILE%"
    )
)

echo. >> "%OUTPUT_FILE%"
echo   } >> "%OUTPUT_FILE%"
echo }; >> "%OUTPUT_FILE%"

echo.
echo Success! %OUTPUT_FILE% has been updated.
echo Path: %CD%\%OUTPUT_FILE%
echo.
echo Refresh your browser to see the changes.
pause