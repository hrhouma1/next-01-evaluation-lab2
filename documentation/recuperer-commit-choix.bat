@echo off
echo =====================================
echo   RECUPERATION COMMIT AU CHOIX
echo =====================================

echo.
echo Historique des derniers commits :
echo.
git log --oneline -10 --graph

echo.
echo =====================================
echo   OPTIONS DE RECUPERATION
echo =====================================
echo.
echo 1. Revenir 1 commit en arriere (HEAD~1)
echo 2. Revenir 2 commits en arriere (HEAD~2) 
echo 3. Revenir 3 commits en arriere (HEAD~3)
echo 4. Entrer un hash de commit specifique
echo 5. Annuler et quitter
echo.

set /p choice="Votre choix (1-5): "

if "%choice%"=="1" (
    set target=HEAD~1
    goto :execute
)
if "%choice%"=="2" (
    set target=HEAD~2
    goto :execute
)
if "%choice%"=="3" (
    set target=HEAD~3
    goto :execute
)
if "%choice%"=="4" (
    set /p target="Entrez le hash du commit: "
    goto :execute
)
if "%choice%"=="5" (
    echo Operation annulee.
    goto :end
)

echo Choix invalide.
goto :end

:execute
echo.
echo [1/3] Sauvegarde du commit actuel...
git stash push -m "Sauvegarde automatique avant recuperation"

echo.
echo [2/3] Recuperation du commit %target%...
git reset --hard %target%

echo.
echo [3/3] Verification...
echo.
echo === STATUS ACTUEL ===
git status --short

echo.
echo === FICHIERS DOCUMENTATION ===
if exist "phases\phase1\etape01-init-nextjs" (
    echo ✅ Etape 1 presente
    dir /b phases\phase1\etape01-init-nextjs\
) else (
    echo ❌ Etape 1 manquante
)

echo.
if exist "phases\phase1\etape02-prisma-neon" (
    echo ✅ Etape 2 presente  
    dir /b phases\phase1\etape02-prisma-neon\
) else (
    echo ❌ Etape 2 manquante
)

echo.
echo =====================================
echo   RECUPERATION TERMINEE
echo =====================================
echo.
echo COMMANDES UTILES :
echo.
echo Pour revenir au dernier commit :
echo   git reset --hard origin/main
echo.
echo Pour voir les sauvegardes :
echo   git stash list
echo.
echo Pour restaurer une sauvegarde :
echo   git stash pop
echo.

:end
pause