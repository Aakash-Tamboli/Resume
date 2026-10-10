@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: build-resume.bat ^<folder^>
    exit /b 1
)

set "TARGET=%~1"

if exist "%TARGET%" if not exist "%TARGET%\" (
    if /I "%~x1"==".tex" (
        set "TARGET_DIR=%~dp1"
        set "TEX_FILE=%~f1"
    ) else (
        echo Folder not found: %TARGET%
        exit /b 1
    )
) else if exist "%TARGET%\" (
    set "TARGET_DIR=%~f1"
) else (
    echo Folder not found: %TARGET%
    exit /b 1
)

where pdflatex >nul 2>nul
if errorlevel 1 (
    echo ERROR: pdflatex was not found in PATH.
    exit /b 1
)

if defined TEX_FILE (
    echo Compiling %TEX_FILE%...
    pushd "%TARGET_DIR%" >nul
    pdflatex -interaction=nonstopmode "%~nx1" >nul 2>&1
    if errorlevel 1 (
        echo ERROR: pdflatex failed for %TEX_FILE%
        popd >nul
        exit /b 1
    )
    popd >nul
) else (
    dir /b /a-d "%TARGET_DIR%\*.tex" >nul 2>&1
    if errorlevel 1 (
        echo No .tex files found in %TARGET_DIR%
        exit /b 1
    )

    echo Searching for .tex files in %TARGET_DIR%...
    pushd "%TARGET_DIR%" >nul
    for /f "delims=" %%F in ('dir /b /a-d "*.tex" 2^>nul') do (
        echo Compiling %%F...
        pdflatex -interaction=nonstopmode "%%F" >nul 2>&1
        if errorlevel 1 (
            echo ERROR: pdflatex failed for %%F
            popd >nul
            exit /b 1
        )
    )
    popd >nul
)

echo Removing intermediate files for %TARGET_DIR%...
for %%f in ("%TARGET_DIR%\*.aux" "%TARGET_DIR%\*.log" "%TARGET_DIR%\*.out" "%TARGET_DIR%\*.toc" "%TARGET_DIR%\*.lof" "%TARGET_DIR%\*.lot" "%TARGET_DIR%\*.fls" "%TARGET_DIR%\*.fdb_latexmk" "%TARGET_DIR%\*.synctex.gz") do (
    if exist "%%~f" del /q "%%~f"
)

echo Done. PDF and source are kept in %TARGET_DIR%.