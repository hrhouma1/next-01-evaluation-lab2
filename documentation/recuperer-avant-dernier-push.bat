@echo off
echo =====================================
echo   RECUPERATION AVANT-DERNIER PUSH
echo =====================================

echo.
echo [1/4] Affichage de l'historique des commits...
git log --oneline -5

echo.
echo [2/4] Sauvegarde du commit actuel...
git stash push -m "Sauvegarde avant recuperation"

echo.
echo [3/4] Recuperation de l'avant-dernier push...
REM Revenir 2 commits en arriere (HEAD~2)
git reset --hard HEAD~2

echo.
echo [4/4] Verification des fichiers recuperes...
echo.
echo === FICHIERS ETAPE 1 ===
dir /b phases\phase1\etape01-init-nextjs\ 2>nul || echo "Dossier etape01 non trouve"

echo.
echo === FICHIERS ETAPE 2 ===
dir /b phases\phase1\etape02-prisma-neon\ 2>nul || echo "Dossier etape02 non trouve"

echo.
echo =====================================
echo   RECUPERATION TERMINEE
echo =====================================
echo.
echo Si vous voulez revenir au commit le plus recent :
echo git reset --hard origin/main
echo.
echo Si vous voulez voir les changements sauvegardes :
echo git stash list
echo git stash pop
echo.
pause