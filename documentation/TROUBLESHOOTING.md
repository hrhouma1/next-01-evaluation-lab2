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