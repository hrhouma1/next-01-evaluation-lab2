@echo off
echo Recuperation de l'avant-dernier push...

REM Sauvegarder le travail actuel
git stash push -m "Auto-save avant recuperation"

REM Revenir 2 commits en arriere (avant-dernier push)
git reset --hard HEAD~2

echo.
echo ✅ Avant-dernier push recupere !
echo.
echo Fichiers presents :
dir /b phases\phase1\ 2>nul

echo.
echo Pour revenir au dernier commit si besoin :
echo git reset --hard origin/main
echo.
pause