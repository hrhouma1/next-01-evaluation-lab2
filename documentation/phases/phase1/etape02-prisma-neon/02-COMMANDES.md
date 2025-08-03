# Commandes - Étape 2 : Configuration Prisma + Neon PostgreSQL

## Toutes les commandes à exécuter

### 1. Installation des dépendances Prisma

```bash
# Naviguer dans le projet
cd photo-marketplace

# Installer Prisma et le client
npm install prisma @prisma/client

# Installer Prisma en dépendance de développement
npm install -D prisma

# Initialiser Prisma
npx prisma init
```

### 2. Configuration des variables d'environnement

```bash
# Créer le fichier .env.example pour documentation
touch .env.example

# Vérifier que .env existe (créé par prisma init)
ls -la .env

# Windows PowerShell
Test-Path .env

# Windows CMD
dir .env
```

### 3. Configuration du client Prisma

```bash
# Créer le dossier lib s'il n'existe pas
mkdir -p src/lib

# Windows PowerShell
New-Item -ItemType Directory -Force -Path src\lib

# Windows CMD
if not exist "src\lib" mkdir src\lib
```

### 4. Tests de connexion

```bash
# Générer le client Prisma
npx prisma generate

# Tester la connexion à la base de données
npx prisma db pull

# Vérifier la connexion (test rapide)
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.\$connect()
  .then(() => console.log('Connexion réussie'))
  .catch(err => console.error('Erreur:', err.message))
  .finally(() => prisma.\$disconnect());
"
```

### 5. Commandes de vérification

```bash
# Vérifier les variables d'environnement
node -e "console.log('DATABASE_URL:', !!process.env.DATABASE_URL)"
node -e "console.log('NEXTAUTH_SECRET:', !!process.env.NEXTAUTH_SECRET)"

# Vérifier l'installation de Prisma
npx prisma --version

# Voir le statut de la base de données
npx prisma db pull --dry-run

# Lister les packages installés
npm list prisma
npm list @prisma/client
```

### 6. Test de connexion complet

```bash
# Créer un fichier de test temporaire
cat > test-db.js << 'EOF'
const { PrismaClient } = require('@prisma/client')

async function testConnection() {
  const prisma = new PrismaClient()
  
  try {
    await prisma.$connect()
    console.log('Connexion à Neon PostgreSQL réussie!')
    
    // Test d'une requête simple
    const result = await prisma.$queryRaw`SELECT NOW() as current_time`
    console.log('Heure serveur:', result[0].current_time)
    
  } catch (error) {
    console.error('Erreur de connexion:', error.message)
  } finally {
    await prisma.$disconnect()
  }
}

testConnection()
EOF

# Exécuter le test
node test-db.js

# Supprimer le fichier de test
rm test-db.js
```

### 7. Commandes de développement

```bash
# Redémarrer le serveur Next.js
npm run dev

# En cas de problème, nettoyer et réinstaller
npm cache clean --force
rm -rf node_modules
npm install
npx prisma generate
```

### 8. Commandes Git

```bash
# Vérifier que .env est dans .gitignore
grep -q "\.env" .gitignore && echo ".env est ignoré" || echo "Ajouter .env au .gitignore"

# Ajouter .env au .gitignore si nécessaire
echo ".env" >> .gitignore

# Commiter les changements
git add .
git commit -m "feat: Configuration Prisma + Neon PostgreSQL"
git push
```

## Commandes de diagnostic

### Variables d'environnement

```bash
# Vérifier toutes les variables (sans afficher les valeurs)
printenv | grep -E "(DATABASE_URL|NEXTAUTH_|STRIPE_)" | sed 's/=.*/=***/'

# Windows PowerShell
Get-ChildItem Env: | Where-Object {$_.Name -match "(DATABASE_URL|NEXTAUTH_|STRIPE_)"} | Select-Object Name

# Tester le chargement des variables dans Node.js
node -e "
require('dotenv').config();
console.log('Variables chargées:');
console.log('DATABASE_URL:', process.env.DATABASE_URL ? 'DEFINIE' : 'MANQUANTE');
console.log('NEXTAUTH_SECRET:', process.env.NEXTAUTH_SECRET ? 'DEFINIE' : 'MANQUANTE');
"
```

### Prisma

```bash
# Informations sur Prisma
npx prisma --version
npx prisma --help

# Statut de la base de données
npx prisma db pull --dry-run

# Voir le schéma généré
cat prisma/schema.prisma

# Windows
type prisma\schema.prisma
```

### Neon PostgreSQL

```bash
# Test avec psql si installé
psql "$DATABASE_URL" -c "SELECT version();"

# Test avec curl (API Neon)
curl -s "https://console.neon.tech/api/v2/projects" \
  -H "Authorization: Bearer YOUR_API_KEY" | jq '.projects[].name'
```

## Commandes de résolution de problèmes

### Réinstallation complète

```bash
# Nettoyer complètement
rm -rf node_modules
rm package-lock.json
rm -rf prisma/migrations
rm -rf .next

# Réinstaller
npm install
npx prisma generate

# Redémarrer
npm run dev
```

### Régénération Prisma

```bash
# Supprimer le client généré
rm -rf node_modules/.prisma
rm -rf node_modules/@prisma/client

# Régénérer
npx prisma generate

# Vérifier
npm list @prisma/client
```

### Test de connectivité

```bash
# Test ping vers Neon (extraire l'host de DATABASE_URL)
HOST=$(node -e "
const url = process.env.DATABASE_URL;
if (url) {
  const match = url.match(/\/\/[^:]+:([^@]+)@([^\/]+)/);
  if (match) console.log(match[2]);
}
")

if [ ! -z "$HOST" ]; then
  ping -c 3 $HOST
else
  echo "Impossible d'extraire l'host de DATABASE_URL"
fi
```

## Annexe 1 : Commandes PowerShell (Windows)

### Installation et configuration

```powershell
# Naviguer dans le projet
Set-Location photo-marketplace

# Installer les dépendances
npm install prisma @prisma/client
npm install -D prisma

# Initialiser Prisma
npx prisma init

# Créer le dossier lib
New-Item -ItemType Directory -Force -Path src\lib

# Vérifier les fichiers créés
Get-ChildItem prisma\
Get-ChildItem .env
```

### Tests de connexion PowerShell

```powershell
# Test des variables d'environnement
$env:NODE_ENV = "development"
node -e "console.log('DATABASE_URL définie:', !!process.env.DATABASE_URL)"

# Test de connexion Prisma
npx prisma generate
npx prisma db pull

# Vérifier l'installation
npm list prisma
npm list @prisma/client
```

### Nettoyage PowerShell

```powershell
# Supprimer node_modules
Remove-Item -Recurse -Force node_modules -ErrorAction SilentlyContinue

# Supprimer le cache
Remove-Item -Recurse -Force .next -ErrorAction SilentlyContinue

# Réinstaller
npm install
npx prisma generate
npm run dev
```

## Annexe 2 : Commandes CMD (Command Prompt)

### Installation CMD

```cmd
REM Naviguer dans le projet
cd photo-marketplace

REM Installer Prisma
npm install prisma @prisma/client
npm install -D prisma

REM Initialiser Prisma
npx prisma init

REM Créer le dossier lib
if not exist "src\lib" mkdir src\lib
```

### Tests CMD

```cmd
REM Test de génération
npx prisma generate

REM Test de connexion
npx prisma db pull

REM Vérifier les packages
npm list prisma
npm list @prisma/client

REM Test des variables d'environnement
node -e "console.log('DATABASE_URL:', !!process.env.DATABASE_URL)"
```

### Nettoyage CMD

```cmd
REM Supprimer node_modules
rmdir /s /q node_modules 2>nul

REM Supprimer le cache Next.js
rmdir /s /q .next 2>nul

REM Réinstaller
npm install
npx prisma generate
npm run dev
```

## Scripts package.json utiles

Ajouter ces scripts à votre `package.json` :

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "db:generate": "npx prisma generate",
    "db:push": "npx prisma db push",
    "db:pull": "npx prisma db pull",
    "db:studio": "npx prisma studio",
    "db:reset": "npx prisma migrate reset",
    "db:test": "node -e \"const { PrismaClient } = require('@prisma/client'); const prisma = new PrismaClient(); prisma.$connect().then(() => console.log('DB OK')).catch(err => console.error(err)).finally(() => prisma.$disconnect());\""
  }
}
```

Usage :
```bash
npm run db:generate
npm run db:test
npm run db:studio
```