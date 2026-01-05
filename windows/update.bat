@echo off

echo Updating topgrade...

rem Force upgrade topgrade first
winget upgrade topgrade-rs.topgrade --force --silent

echo.
echo Running topgrade...

rem Then run topgrade itself
topgrade

echo.
echo Done. Press any key to exit.

pause

