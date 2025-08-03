# Commandes - Étape 1 : Initialisation Next.js

## Commandes à exécuter

### 1. Création du projet

```bash
# Commande principale d'initialisation
npx create-next-app@latest photo-marketplace --typescript --tailwind --eslint --app --src-dir --import-alias="@/*"
```

**Options expliquées :**
- `photo-marketplace` : Nom du projet
- `--typescript` : Active TypeScript
- `--tailwind` : Installe Tailwind CSS 3
- `--eslint` : Configure ESLint
- `--app` : Utilise App Router (Next.js 14)
- `--src-dir` : Place le code dans src/
- `--import-alias="@/*"` : Alias d'import depuis src/

### 2. Navigation et forcer Tailwind CSS 3

```bash
# Aller dans le dossier du projet
cd photo-marketplace

# IMPORTANT: Forcer l'installation de Tailwind CSS 3 (pas la v4)
npm uninstall tailwindcss
npm install tailwindcss@^3.4.0 postcss autoprefixer

# Regénérer la configuration Tailwind pour la v3
npx tailwindcss init -p

# Créer globals.css si il n'existe pas (Windows)
if not exist "src\app\globals.css" echo @tailwind base; @tailwind components; @tailwind utilities; > src\app\globals.css

# Créer globals.css si il n'existe pas (macOS/Linux)
[ ! -f src/app/globals.css ] && echo -e "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > src/app/globals.css
```

### 3. Vérification de la structure

```bash
# Vérifier que tous les fichiers sont en place
tree src/ -I node_modules

# Ou avec ls (si tree n'est pas disponible)
ls -la src/app/
```

**Structure attendue** :
```
src/
├── app/
│   ├── globals.css     ← Doit contenir les directives Tailwind
│   ├── layout.tsx      ← Doit importer globals.css
│   ├── page.tsx        ← Page d'accueil
│   └── favicon.ico
└── components/         ← Dossier à créer plus tard
```

### 4. Lancement du serveur

```bash
# Lancer le serveur de développement
npm run dev
```

### 5. Commandes de vérification

```bash
# Vérifier la version de Node.js
node --version

# Vérifier la version de npm
npm --version

# Lister les dépendances installées
npm list --depth=0

# Vérifier les erreurs TypeScript
npx tsc --noEmit

# Lancer ESLint
npm run lint

# Vérifier la version de Tailwind CSS (doit être 3.x.x)
npm list tailwindcss

# Vérifier le contenu de globals.css
cat src/app/globals.css

# Vérifier que layout.tsx importe globals.css
grep "globals.css" src/app/layout.tsx
```

### 6. Gestion Git

```bash
# Initialiser Git (si pas déjà fait)
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit - Next.js 14 setup with TypeScript and Tailwind"

# Ajouter l'origine GitHub (remplacer URL)
git remote add origin https://github.com/username/photo-marketplace.git

# Pousser sur GitHub
git push -u origin main
```

## Commandes de développement

### Serveur de développement

```bash
# Démarrer sur port par défaut (3000)
npm run dev

# Démarrer sur port spécifique
npm run dev -- -p 3001

# Démarrer avec host spécifique
npm run dev -- --hostname 0.0.0.0
```

### Build et production

```bash
# Construire pour la production
npm run build

# Lancer en mode production
npm start

# Analyser le bundle
npm run build -- --analyze
```

## Commandes de dépannage

### Nettoyage du cache

```bash
# Nettoyer le cache npm
npm cache clean --force

# Supprimer node_modules et réinstaller
rm -rf node_modules
npm install

# Nettoyer le cache Next.js
rm -rf .next
npm run dev
```

### Diagnostic

```bash
# Vérifier les vulnérabilités
npm audit

# Corriger les vulnérabilités
npm audit fix

# Vérifier les packages obsolètes
npm outdated

# Mettre à jour les packages
npm update
```

## Variables d'environnement

### Créer .env.local

```bash
# Créer le fichier d'environnement local
touch .env.local
```

### Contenu initial .env.local

```env
# Development
NODE_ENV=development
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

## Commandes utiles pour la suite

```bash
# Installer des dépendances supplémentaires (pour les étapes suivantes)
npm install prisma @prisma/client
npm install next-auth
npm install stripe @stripe/stripe-js

# Installer des dépendances de développement
npm install -D @types/node
npm install -D prisma
```

## Scripts package.json

Le fichier package.json contient ces scripts par défaut :

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  }
}
```