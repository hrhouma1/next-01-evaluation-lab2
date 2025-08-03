# Dépannage - Étape 1 : Initialisation Next.js

## Problèmes fréquents et solutions

### 1. Erreurs d'installation

#### Problème : "npm command not found"
**Cause** : Node.js/npm non installé
**Solution** :
```bash
# Installer Node.js depuis https://nodejs.org
# Ou via gestionnaire de packages
# Ubuntu/Debian:
sudo apt install nodejs npm

# macOS avec Homebrew:
brew install node

# Windows avec Chocolatey:
choco install nodejs
```

#### Problème : "Permission denied" sur npm
**Cause** : Permissions insuffisantes
**Solution** :
```bash
# Option 1: Configurer npm pour l'utilisateur
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH

# Option 2: Utiliser sudo (non recommandé)
sudo npm install -g npm

# Option 3: Utiliser nvm (recommandé)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install node
```

### 2. Erreurs de création de projet

#### Problème : "create-next-app command failed"
**Cause** : Cache npm corrompu
**Solution** :
```bash
# Nettoyer le cache npm
npm cache clean --force

# Réessayer l'installation
npx create-next-app@latest photo-marketplace --typescript --tailwind --eslint --app --src-dir --import-alias="@/*"
```

#### Problème : "Directory already exists"
**Cause** : Dossier existant
**Solution** :
```bash
# Supprimer le dossier existant
rm -rf photo-marketplace

# Ou choisir un autre nom
npx create-next-app@latest photo-marketplace-v2 --typescript --tailwind --eslint --app --src-dir --import-alias="@/*"
```

### 3. Erreurs de démarrage

#### Problème : "Port 3000 already in use"
**Cause** : Port 3000 occupé
**Solution** :
```bash
# Option 1: Utiliser un autre port
npm run dev -- -p 3001

# Option 2: Tuer le processus sur le port 3000
# Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# macOS/Linux:
lsof -ti:3000 | xargs kill -9
```

#### Problème : "Module not found" errors
**Cause** : Dépendances manquantes
**Solution** :
```bash
# Réinstaller les dépendances
rm -rf node_modules package-lock.json
npm install

# Ou vérifier l'intégrité
npm ci
```

### 4. Erreurs TypeScript

#### Problème : "Cannot find module '@/...'"
**Cause** : Configuration d'alias incorrecte
**Solution** :
Vérifier `tsconfig.json` :
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

#### Problème : "Type errors in default files"
**Cause** : Configuration TypeScript incomplète
**Solution** :
```bash
# Regénérer la configuration TypeScript
rm tsconfig.json
npx tsc --init
# Puis réinstaller les types Next.js
npm install -D @types/react @types/node
```

### 5. Erreurs Tailwind CSS

#### Problème : "Tailwind CSS v4 installé au lieu de v3"
**Cause** : create-next-app installe la dernière version par défaut
**Solution** :
```bash
# Forcer l'installation de Tailwind CSS 3
npm uninstall tailwindcss
npm install tailwindcss@^3.4.0 postcss autoprefixer

# Vérifier la version
npm list tailwindcss

# Regénérer la configuration
npx tailwindcss init -p
```

#### Problème : "Tailwind styles not working"
**Cause** : Configuration Tailwind incomplète
**Solution** :
Vérifier `tailwind.config.ts` :
```typescript
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
export default config
```

Vérifier `src/app/globals.css` :
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### 6. Erreurs Git

#### Problème : "Git not initialized"
**Cause** : Git non installé ou configuré
**Solution** :
```bash
# Installer Git
# Ubuntu/Debian:
sudo apt install git

# macOS:
brew install git

# Windows: Télécharger depuis https://git-scm.com

# Configurer Git
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"

# Initialiser le projet
git init
git add .
git commit -m "Initial commit"
```

### 7. Problèmes de performance

#### Problème : "Slow compilation/hot reload"
**Cause** : Antivirus ou fichiers temporaires
**Solution** :
```bash
# Exclure le dossier du projet de l'antivirus
# Nettoyer les fichiers temporaires
rm -rf .next
rm -rf node_modules/.cache

# Redémarrer
npm run dev
```

### 8. Erreurs d'environnement

#### Problème : "Environment variables not working"
**Cause** : Mauvaise configuration
**Solution** :
```bash
# Créer .env.local (pas .env en développement)
touch .env.local

# Variables publiques doivent commencer par NEXT_PUBLIC_
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## Diagnostic général

### Vérifier l'environnement

```bash
# Versions
node --version    # >= 18.0.0
npm --version     # >= 8.0.0
git --version     # >= 2.0.0

# Espace disque
df -h .

# Permissions
ls -la

# Processus sur le port 3000
netstat -tlnp | grep :3000  # Linux
lsof -i :3000              # macOS
netstat -ano | findstr :3000  # Windows
```

### Logs de débogage

```bash
# Logs verbeux npm
npm run dev --loglevel verbose

# Debug Next.js
DEBUG=* npm run dev

# Vérifier les erreurs ESLint
npm run lint -- --debug
```

## Dépannage spécifique Windows PowerShell

### Problème : Processus Node.js bloqué

**Symptômes** :
- Le serveur Next.js ne s'arrête pas avec `Ctrl+C`
- Message "Port 3000 already in use"
- Processus Node.js en arrière-plan

**Solution PowerShell** :
```powershell
# Étape 1: Identifier les processus Node.js
Get-Process node

# Étape 2: Tuer tous les processus Node.js
Get-Process node | Stop-Process -Force

# Étape 3: Vérifier que le port 3000 est libre
netstat -ano | findstr :3000
```

### Problème : Port 3000 occupé

**Solution rapide PowerShell** :
```powershell
# Libérer automatiquement le port 3000
$port = 3000
Get-NetTCPConnection -LocalPort $port | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }

# Vérifier que le port est libre
netstat -ano | findstr :3000
# Aucun résultat = port libre ✅
```

### Problème : Cache Node.js corrompu (Windows)

**Solution PowerShell** :
```powershell
# Nettoyer le cache npm
npm cache clean --force

# Supprimer node_modules avec PowerShell
Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue

# Supprimer le cache Next.js
Remove-Item -Recurse -Force .next -ErrorAction SilentlyContinue

# Réinstaller et redémarrer
npm install
npm run dev
```

### Commandes de diagnostic PowerShell

```powershell
# Vérifier les versions
node --version
npm --version

# Voir tous les ports occupés
netstat -ano

# Voir les processus Node.js avec détails
Get-Process node | Format-Table Id,ProcessName,CPU,WorkingSet

# Tuer un processus spécifique
Stop-Process -Id [PID] -Force

# Redémarrer proprement
Stop-Process -Name "node" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
npm run dev
```

## Annexe 2 : Dépannage avec CMD (Command Prompt)

### Alternative CMD aux commandes PowerShell

Pour les utilisateurs qui préfèrent CMD :

### Problème : Processus Node.js bloqué (CMD)

**Solution CMD** :
```cmd
REM Étape 1: Voir tous les processus Node.js (plusieurs méthodes)
tasklist | findstr node
tasklist /fi "imagename eq node.exe"
tasklist /fi "imagename eq node.exe" /fo table

REM Étape 2: Tuer tous les processus Node.js (plusieurs variantes)
taskkill /f /im node.exe
taskkill /f /im node.exe /t
taskkill /f /im "node*"

REM Alternative puissante avec WMIC
wmic process where "name='node.exe'" delete

REM Boucle robuste pour tous les processus Node.js
for /f "tokens=2 delims=," %i in ('tasklist /fi "imagename eq node.exe" /fo csv ^| findstr /v "PID"') do taskkill /f /pid %i

REM Étape 3: Vérifier que les processus sont arrêtés
tasklist | findstr node
```

### Problème : Port 3000 occupé (CMD)

**Solution rapide CMD** :
```cmd
REM Libérer automatiquement le port 3000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000') do taskkill /f /pid %%a

REM Ou étape par étape :
netstat -ano | findstr :3000
REM Noter le PID et l'utiliser :
taskkill /f /pid [PID_TROUVÉ]

REM Vérifier que le port est libre
netstat -ano | findstr :3000
REM Aucun résultat = port libre ✅
```

### Problème : Cache corrompu (CMD)

**Solution CMD** :
```cmd
REM Nettoyer le cache npm
npm cache clean --force

REM Supprimer node_modules
rmdir /s /q node_modules

REM Supprimer le cache Next.js  
rmdir /s /q .next

REM Réinstaller et redémarrer
npm install
npm run dev
```

### Commandes de diagnostic CMD

```cmd
REM Vérifier les versions
node --version
npm --version

REM Voir tous les processus Node.js avec détails (plusieurs formats)
tasklist /fi "imagename eq node.exe" /fo table
tasklist /fi "imagename eq node.exe" /fo csv
tasklist | findstr node

REM Voir les processus avec CPU et mémoire
wmic process where "name='node.exe'" get ProcessId,PageFileUsage,WorkingSetSize

REM Voir tous les ports occupés
netstat -ano
netstat -ano | findstr "LISTENING"

REM Tuer un processus spécifique (plusieurs méthodes)
taskkill /f /pid [PID]
taskkill /f /im node.exe /t

REM Nettoyage complet et redémarrage
taskkill /f /im node.exe /t
timeout /t 2
rmdir /s /q .next 2>nul
npm run dev

REM Diagnostic complet en une commande
echo === Processus Node.js === && tasklist | findstr node && echo === Port 3000 === && netstat -ano | findstr :3000
```

### Batch script de nettoyage (CMD)

Créer un fichier `clean-project.bat` :
```batch
@echo off
echo ===================================
echo   NETTOYAGE PROJET NEXT.JS
echo ===================================

echo [1/6] Diagnostic initial...
echo Processus Node.js detectes:
tasklist | findstr node

echo.
echo [2/6] Arret des processus Node.js...
taskkill /f /im node.exe /t 2>nul
wmic process where "name='node.exe'" delete 2>nul

echo.
echo [3/6] Verification port 3000...
netstat -ano | findstr :3000

echo.
echo [4/6] Suppression des caches...
rmdir /s /q node_modules 2>nul
rmdir /s /q .next 2>nul

echo.
echo [5/6] Nettoyage du cache npm...
npm cache clean --force

echo.
echo [6/6] Reinstallation des dependances...
npm install

echo.
echo ===================================
echo   NETTOYAGE TERMINE!
echo ===================================
echo Verifications finales:
tasklist | findstr node || echo Aucun processus Node.js actif
netstat -ano | findstr :3000 || echo Port 3000 libre

echo.
echo Vous pouvez maintenant lancer: npm run dev
pause
```

**Utilisation** : Double-cliquer sur `clean-project.bat` dans le dossier du projet.

## Ressources de support

### Documentation officielle
- [Next.js Troubleshooting](https://nextjs.org/docs/messages)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Tailwind CSS Installation](https://tailwindcss.com/docs/installation)

### Communautés
- [Next.js Discord](https://discord.gg/nextjs)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/next.js)
- [GitHub Issues Next.js](https://github.com/vercel/next.js/issues)

### Outils de diagnostic
- [Next.js Bundle Analyzer](https://www.npmjs.com/package/@next/bundle-analyzer)
- [TypeScript Playground](https://www.typescriptlang.org/play)
- [Can I Use](https://caniuse.com/) pour la compatibilité navigateur