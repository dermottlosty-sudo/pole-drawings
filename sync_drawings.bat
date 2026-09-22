@echo off
setlocal enabledelayedexpansion

:: --- CONFIGURATION ---
:: Ensure this path matches the folder shown in your screenshot
set "SOURCE_FOLDER=%CD%"
set "OUTPUT_FILE=drawings.js"

echo Scanning folders for Pole Drawings...

:: Get date and time in a way that isn't dependent on regional settings
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "datestr=!datetime:~6,2!/!datetime:~4,2!/!datetime:~0,4!"
set "timestr=!datetime:~8,2!:!datetime:~10,2!"

:: Start writing the JS file (wrapping the JSON in a variable)
echo var drawingData = { > "%OUTPUT_FILE%"
echo   "lastUpdated": "%datestr% %timestr%", >> "%OUTPUT_FILE%"
echo   "folders": { >> "%OUTPUT_FILE%"

set "firstFolder=true"

:: Loop through subdirectories in the SOURCE_FOLDER
for /d %%D in ("%SOURCE_FOLDER%\*") do (
    set "folderName=%%~nxD"
    
    :: Check if PDFs exist in this specific customer folder
    if exist "%%D\*.pdf" (
        if "!firstFolder!"=="false" (
            echo       , >> "%OUTPUT_FILE%"
        )
        set "firstFolder=false"
        
        echo     "!folderName!": [ >> "%OUTPUT_FILE%"
        
        set "firstFile=true"
        :: Loop through PDF files and add to JSON array
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

:: Close the JS structure properly
echo. >> "%OUTPUT_FILE%"
echo   } >> "%OUTPUT_FILE%"
echo }; >> "%OUTPUT_FILE%"

echo.
echo Success! %OUTPUT_FILE% has been updated.
echo Path: %CD%\%OUTPUT_FILE%
echo.
echo Refresh your browser to see the changes.
pause