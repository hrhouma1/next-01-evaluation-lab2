# Étape 5 : Commandes NextAuth.js - Configuration et test

## Commandes d'installation

### Installation des dépendances principales

```bash
# Naviguer dans le projet
cd photo-marketplace

# Installer NextAuth.js v5 et dépendances
npm install next-auth@beta @auth/prisma-adapter bcryptjs
npm install @types/bcryptjs -D

# Vérifier les versions installées
npm list next-auth @auth/prisma-adapter bcryptjs

# Alternative avec Yarn
yarn add next-auth@beta @auth/prisma-adapter bcryptjs
yarn add -D @types/bcryptjs
```

### Vérification des versions

```bash
# Vérifier la version de NextAuth.js
npm list next-auth

# Vérifier toutes les dépendances auth
npm list | grep -E "(next-auth|bcrypt|prisma)"

# Voir les informations détaillées
npm info next-auth@beta version
npm info @auth/prisma-adapter version
```

## Commandes de configuration

### Génération de clés secrètes

```bash
# Générer NEXTAUTH_SECRET (si pas déjà fait)
node -e "console.log('NEXTAUTH_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"

# Alternative avec OpenSSL
openssl rand -hex 32

# Alternative avec PowerShell (Windows)
powershell -Command "[System.Web.Security.Membership]::GeneratePassword(64, 0)"

# Vérifier que la variable est définie
node -e "console.log('NEXTAUTH_SECRET présente:', !!process.env.NEXTAUTH_SECRET)"
```

### Création de la structure de fichiers

```bash
# Créer tous les dossiers nécessaires
mkdir -p src/app/api/auth/[...nextauth]
mkdir -p src/app/auth/{signin,signup,error}
mkdir -p src/lib
mkdir -p src/types
mkdir -p src/hooks
mkdir -p src/components/auth

# Vérifier la structure créée
find src -type d | sort
```

### Création des fichiers de configuration

```bash
# Créer les fichiers de base (contenus dans le README)
touch src/lib/auth.ts
touch src/lib/auth-config.ts
touch src/lib/password.ts
touch src/middleware.ts
touch src/types/next-auth.d.ts
touch src/app/api/auth/[...nextauth]/route.ts

# Vérifier que tous les fichiers existent
ls -la src/lib/auth*
ls -la src/middleware.ts
ls -la src/types/next-auth.d.ts
```

## Commandes de test et validation

### Tests de configuration de base

```bash
# Test 1: Vérifier les variables d'environnement
node -e "
console.log('=== VARIABLES NEXTAUTH ===');
console.log('NEXTAUTH_SECRET:', !!process.env.NEXTAUTH_SECRET ? '✅' : '❌');
console.log('NEXTAUTH_URL:', process.env.NEXTAUTH_URL || '❌ Manquante');
console.log('GOOGLE_CLIENT_ID:', !!process.env.GOOGLE_CLIENT_ID ? '✅' : '⚠️ Optionnel');
console.log('GITHUB_CLIENT_ID:', !!process.env.GITHUB_CLIENT_ID ? '✅' : '⚠️ Optionnel');
"

# Test 2: Validation des imports NextAuth
node -e "
try {
  require('next-auth');
  console.log('✅ NextAuth.js importable');
} catch (e) {
  console.log('❌ Erreur import NextAuth:', e.message);
}

try {
  require('@auth/prisma-adapter');
  console.log('✅ Prisma Adapter importable');
} catch (e) {
  console.log('❌ Erreur import Prisma Adapter:', e.message);
}
"

# Test 3: Test bcrypt
node -e "
const bcrypt = require('bcryptjs');
(async () => {
  const password = 'test123';
  const hash = await bcrypt.hash(password, 12);
  const isValid = await bcrypt.compare(password, hash);
  console.log('✅ bcrypt fonctionnel:', isValid);
})();
"
```

### Tests de la base de données

```bash
# Test des tables NextAuth avec Prisma
node -e "
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  try {
    const userCount = await prisma.user.count();
    const accountCount = await prisma.account.count();
    const sessionCount = await prisma.session.count();
    console.log('=== TABLES NEXTAUTH ===');
    console.log('Users:', userCount);
    console.log('Accounts:', accountCount);
    console.log('Sessions:', sessionCount);
    console.log('✅ Tables NextAuth accessibles');
  } catch (error) {
    console.log('❌ Erreur tables:', error.message);
  } finally {
    await prisma.\$disconnect();
  }
})();
"

# Vérifier le schéma Prisma contient les modèles NextAuth
grep -E "(model User|model Account|model Session)" prisma/schema.prisma
```

### Test de l'application NextAuth

```bash
# Démarrer le serveur de développement
npm run dev

# Dans un autre terminal, tester les endpoints
curl http://localhost:3000/api/auth/providers
curl http://localhost:3000/api/auth/session
curl http://localhost:3000/api/auth/csrf
```

## Commandes de création d'utilisateurs

### Créer un utilisateur test

```bash
# Script pour créer un utilisateur avec mot de passe
cat > create-test-user.js << 'EOF'
const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

async function createTestUser() {
  const prisma = new PrismaClient()
  
  try {
    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash('TestPassword123!', 12)
    
    // Créer l'utilisateur
    const user = await prisma.user.create({
      data: {
        email: 'test@photomarket.com',
        password: hashedPassword,
        name: 'Utilisateur Test',
        role: 'USER',
        emailVerified: new Date()
      }
    })
    
    console.log('✅ Utilisateur test créé:', user.email)
    console.log('   ID:', user.id)
    console.log('   Rôle:', user.role)
    console.log('   Mot de passe: TestPassword123!')
    
  } catch (error) {
    if (error.code === 'P2002') {
      console.log('⚠️ Utilisateur test existe déjà')
    } else {
      console.error('❌ Erreur:', error.message)
    }
  } finally {
    await prisma.$disconnect()
  }
}

createTestUser()
EOF

# Exécuter la création
node create-test-user.js

# Supprimer le script
rm create-test-user.js
```

### Créer un administrateur

```bash
# Script pour créer un admin
cat > create-admin.js << 'EOF'
const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

async function createAdmin() {
  const prisma = new PrismaClient()
  
  try {
    const hashedPassword = await bcrypt.hash('AdminPassword123!', 12)
    
    const admin = await prisma.user.create({
      data: {
        email: 'admin@photomarket.com',
        password: hashedPassword,
        name: 'Administrateur PhotoMarket',
        role: 'ADMIN',
        emailVerified: new Date()
      }
    })
    
    console.log('✅ Administrateur créé:', admin.email)
    console.log('   Mot de passe: AdminPassword123!')
    
  } catch (error) {
    if (error.code === 'P2002') {
      console.log('⚠️ Administrateur existe déjà')
    } else {
      console.error('❌ Erreur:', error.message)
    }
  } finally {
    await prisma.$disconnect()
  }
}

createAdmin()
EOF

node create-admin.js
rm create-admin.js
```

## Commandes OAuth (Google, GitHub)

### Configuration Google OAuth

```bash
# Ouvrir la console Google Cloud
echo "🔗 Ouvrir: https://console.developers.google.com"

# Guide de configuration
echo "1. Créer/sélectionner un projet"
echo "2. Activer Google+ API ou Google Identity"
echo "3. Créer identifiants OAuth 2.0"
echo "4. Ajouter URI de redirection:"
echo "   - Dev: http://localhost:3000/api/auth/callback/google"
echo "   - Prod: https://votre-domaine.com/api/auth/callback/google"

# Tester la configuration Google (si configuré)
node -e "
if (process.env.GOOGLE_CLIENT_ID) {
  console.log('✅ Google OAuth configuré');
  console.log('Client ID:', process.env.GOOGLE_CLIENT_ID.substring(0, 20) + '...');
} else {
  console.log('⚠️ Google OAuth non configuré (optionnel)');
}
"
```

### Configuration GitHub OAuth

```bash
# Ouvrir les paramètres GitHub
echo "🔗 Ouvrir: https://github.com/settings/applications/new"

# Guide de configuration
echo "1. Application name: PhotoMarket"
echo "2. Homepage URL: http://localhost:3000"
echo "3. Authorization callback URL: http://localhost:3000/api/auth/callback/github"

# Tester la configuration GitHub (si configuré)
node -e "
if (process.env.GITHUB_CLIENT_ID) {
  console.log('✅ GitHub OAuth configuré');
  console.log('Client ID:', process.env.GITHUB_CLIENT_ID);
} else {
  console.log('⚠️ GitHub OAuth non configuré (optionnel)');
}
"
```

## Commandes de test de l'authentification

### Test de connexion credentials

```bash
# Test d'authentification avec credentials
cat > test-auth-credentials.js << 'EOF'
const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

async function testCredentialsAuth() {
  const prisma = new PrismaClient()
  
  try {
    console.log('🧪 Test authentification credentials...')
    
    // Chercher l'utilisateur test
    const user = await prisma.user.findUnique({
      where: { email: 'test@photomarket.com' }
    })
    
    if (!user) {
      console.log('❌ Utilisateur test introuvable')
      console.log('   Créez-le avec: node create-test-user.js')
      return
    }
    
    // Tester le mot de passe
    const isValid = await bcrypt.compare('TestPassword123!', user.password)
    
    if (isValid) {
      console.log('✅ Authentification credentials fonctionnelle')
      console.log('   Email:', user.email)
      console.log('   Rôle:', user.role)
    } else {
      console.log('❌ Mot de passe incorrect')
    }
    
  } catch (error) {
    console.error('❌ Erreur test auth:', error.message)
  } finally {
    await prisma.$disconnect()
  }
}

testCredentialsAuth()
EOF

node test-auth-credentials.js
rm test-auth-credentials.js
```

### Test complet de la configuration

```bash
# Script de test complet NextAuth
cat > test-nextauth-complete.js << 'EOF'
const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')
const fs = require('fs')

async function testNextAuthComplete() {
  console.log('🧪 TEST COMPLET NEXTAUTH.JS\n')
  
  // Test 1: Variables d'environnement
  console.log('1. Variables d\'environnement:')
  console.log('   NEXTAUTH_SECRET:', !!process.env.NEXTAUTH_SECRET ? '✅' : '❌')
  console.log('   NEXTAUTH_URL:', process.env.NEXTAUTH_URL || '❌')
  console.log('   GOOGLE_CLIENT_ID:', !!process.env.GOOGLE_CLIENT_ID ? '✅' : '⚠️')
  console.log('   GITHUB_CLIENT_ID:', !!process.env.GITHUB_CLIENT_ID ? '✅' : '⚠️')
  
  // Test 2: Fichiers de configuration
  console.log('\n2. Fichiers de configuration:')
  const files = [
    'src/lib/auth.ts',
    'src/lib/auth-config.ts',
    'src/lib/password.ts',
    'src/middleware.ts',
    'src/types/next-auth.d.ts',
    'src/app/api/auth/[...nextauth]/route.ts'
  ]
  
  files.forEach(file => {
    console.log(`   ${file}:`, fs.existsSync(file) ? '✅' : '❌')
  })
  
  // Test 3: Base de données
  console.log('\n3. Base de données:')
  const prisma = new PrismaClient()
  
  try {
    await prisma.$connect()
    const userCount = await prisma.user.count()
    const accountCount = await prisma.account.count()
    const sessionCount = await prisma.session.count()
    
    console.log('   Connexion Prisma: ✅')
    console.log(`   Users: ${userCount}`)
    console.log(`   Accounts: ${accountCount}`)
    console.log(`   Sessions: ${sessionCount}`)
    
  } catch (error) {
    console.log('   Connexion Prisma: ❌', error.message)
  }
  
  // Test 4: bcrypt
  console.log('\n4. Hashage de mot de passe:')
  try {
    const testPassword = 'Test123!'
    const hash = await bcrypt.hash(testPassword, 12)
    const isValid = await bcrypt.compare(testPassword, hash)
    console.log('   bcrypt fonctionnel:', isValid ? '✅' : '❌')
  } catch (error) {
    console.log('   bcrypt: ❌', error.message)
  }
  
  // Test 5: Modules NextAuth
  console.log('\n5. Modules NextAuth:')
  try {
    require('next-auth')
    console.log('   next-auth: ✅')
  } catch (error) {
    console.log('   next-auth: ❌')
  }
  
  try {
    require('@auth/prisma-adapter')
    console.log('   prisma-adapter: ✅')
  } catch (error) {
    console.log('   prisma-adapter: ❌')
  }
  
  console.log('\n🎉 Test NextAuth.js terminé!')
  
  await prisma.$disconnect()
}

testNextAuthComplete()
EOF

node test-nextauth-complete.js
rm test-nextauth-complete.js
```

## Commandes de développement

### Démarrage et test en développement

```bash
# Démarrer le serveur de développement
npm run dev

# Dans un autre terminal, tester les pages auth
curl -s http://localhost:3000/auth/signin | grep -q "PhotoMarket" && echo "✅ Page signin OK" || echo "❌ Page signin problème"

# Tester les API routes NextAuth
curl -s http://localhost:3000/api/auth/providers | jq . 2>/dev/null && echo "✅ API providers OK" || echo "❌ API providers problème"

curl -s http://localhost:3000/api/auth/session | jq . 2>/dev/null && echo "✅ API session OK" || echo "❌ API session problème"

# Tester le middleware (doit rediriger)
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/dashboard
```

### Debug et logs

```bash
# Activer les logs NextAuth en développement
export DEBUG=next-auth*
npm run dev

# Ou ajouter à .env.local
echo "DEBUG=next-auth*" >> .env.local

# Voir les logs en temps réel
tail -f .next/server.log 2>/dev/null || echo "Pas de fichier de log trouvé"
```

### Reset et nettoyage

```bash
# Nettoyer les sessions expirées
node -e "
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  const deleted = await prisma.session.deleteMany({
    where: { expires: { lt: new Date() } }
  });
  console.log('Sessions expirées supprimées:', deleted.count);
  await prisma.\$disconnect();
})();
"

# Supprimer tous les comptes OAuth de test
node -e "
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  const deleted = await prisma.account.deleteMany({
    where: { user: { email: { endsWith: '@test.com' } } }
  });
  console.log('Comptes de test supprimés:', deleted.count);
  await prisma.\$disconnect();
})();
"

# Reset complet des données auth de test
node -e "
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  await prisma.session.deleteMany();
  await prisma.account.deleteMany();
  await prisma.user.deleteMany({ where: { email: { contains: 'test' } } });
  console.log('✅ Données de test supprimées');
  await prisma.\$disconnect();
})();
"
```

## Annexe 1 : Commandes PowerShell (Windows)

### Installation PowerShell

```powershell
# Installation des dépendances
npm install next-auth@beta @auth/prisma-adapter bcryptjs
npm install @types/bcryptjs -D

# Génération NEXTAUTH_SECRET
$secret = -join ((1..64) | ForEach {'{0:X}' -f (Get-Random -Max 16)})
Write-Host "NEXTAUTH_SECRET=$secret"

# Création de la structure de dossiers
New-Item -ItemType Directory -Path "src\app\api\auth\[...nextauth]" -Force
New-Item -ItemType Directory -Path "src\app\auth\signin" -Force
New-Item -ItemType Directory -Path "src\app\auth\signup" -Force
New-Item -ItemType Directory -Path "src\app\auth\error" -Force
New-Item -ItemType Directory -Path "src\lib" -Force
New-Item -ItemType Directory -Path "src\types" -Force
New-Item -ItemType Directory -Path "src\hooks" -Force
New-Item -ItemType Directory -Path "src\components\auth" -Force
```

### Tests PowerShell

```powershell
# Fonction de test NextAuth
function Test-NextAuthSetup {
    Write-Host "=== TEST NEXTAUTH SETUP ===" -ForegroundColor Blue
    
    # Test variables d'environnement
    if ($env:NEXTAUTH_SECRET) {
        Write-Host "✅ NEXTAUTH_SECRET définie" -ForegroundColor Green
    } else {
        Write-Host "❌ NEXTAUTH_SECRET manquante" -ForegroundColor Red
    }
    
    if ($env:NEXTAUTH_URL) {
        Write-Host "✅ NEXTAUTH_URL: $env:NEXTAUTH_URL" -ForegroundColor Green
    } else {
        Write-Host "❌ NEXTAUTH_URL manquante" -ForegroundColor Yellow
    }
    
    # Test fichiers
    $files = @(
        "src\lib\auth.ts",
        "src\lib\auth-config.ts",
        "src\middleware.ts",
        "src\types\next-auth.d.ts"
    )
    
    foreach ($file in $files) {
        if (Test-Path $file) {
            Write-Host "✅ $file" -ForegroundColor Green
        } else {
            Write-Host "❌ $file manquant" -ForegroundColor Red
        }
    }
    
    # Test modules npm
    try {
        $nextAuthVersion = npm list next-auth --depth=0 2>$null
        if ($nextAuthVersion) {
            Write-Host "✅ NextAuth.js installé" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ NextAuth.js non installé" -ForegroundColor Red
    }
}

# Fonction de création d'utilisateur test
function New-TestUser {
    $script = @"
const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

async function createUser() {
  const prisma = new PrismaClient()
  try {
    const hash = await bcrypt.hash('TestPassword123!', 12)
    const user = await prisma.user.create({
      data: {
        email: 'test@photomarket.com',
        password: hash,
        name: 'Test User',
        role: 'USER'
      }
    })
    console.log('✅ Utilisateur créé:', user.email)
  } catch (error) {
    console.log('⚠️ Utilisateur existe ou erreur:', error.message)
  } finally {
    await prisma.`$disconnect()
  }
}
createUser()
"@
    
    $script | Out-File -FilePath "temp-create-user.js" -Encoding UTF8
    node temp-create-user.js
    Remove-Item temp-create-user.js
}

# Exécuter les fonctions
Test-NextAuthSetup
```

## Annexe 2 : Commandes CMD (Command Prompt)

### Installation CMD

```cmd
REM Installation
npm install next-auth@beta @auth/prisma-adapter bcryptjs
npm install @types/bcryptjs -D

REM Vérification
npm list next-auth @auth/prisma-adapter bcryptjs

REM Génération secret (utilise PowerShell)
powershell -Command "[System.Web.Security.Membership]::GeneratePassword(64, 0)"
```

### Test CMD

```cmd
REM Script de test NextAuth
@echo off
echo === TEST NEXTAUTH.JS ===

echo 1. Test variables...
node -e "console.log('NEXTAUTH_SECRET:', !!process.env.NEXTAUTH_SECRET)"
node -e "console.log('NEXTAUTH_URL:', process.env.NEXTAUTH_URL || 'Manquante')"

echo.
echo 2. Test modules...
node -e "try{require('next-auth');console.log('✅ NextAuth OK')}catch{console.log('❌ NextAuth manquant')}"
node -e "try{require('@auth/prisma-adapter');console.log('✅ Adapter OK')}catch{console.log('❌ Adapter manquant')}"

echo.
echo 3. Test bcrypt...
node -e "const bcrypt=require('bcryptjs');(async()=>{const h=await bcrypt.hash('test',12);console.log('✅ bcrypt OK')})();"

echo.
echo 4. Test base...
node -e "const{PrismaClient}=require('@prisma/client');(async()=>{const p=new PrismaClient();await p.user.count();console.log('✅ DB OK');await p.$disconnect()})();"

echo.
echo === TESTS TERMINES ===
pause
```

### Création d'utilisateur CMD

```cmd
REM Créer utilisateur test
echo const{PrismaClient}=require('@prisma/client');const bcrypt=require('bcryptjs');(async()=>{const p=new PrismaClient();try{const h=await bcrypt.hash('TestPassword123!',12);const u=await p.user.create({data:{email:'test@photomarket.com',password:h,name:'Test User',role:'USER'}});console.log('✅ User:',u.email);}catch(e){console.log('⚠️',e.message);}finally{await p.$disconnect();}})(); > create-user.js
node create-user.js
del create-user.js
```

## Commandes de déploiement

### Build de production

```bash
# Build avec NextAuth.js
npm run build

# Vérifier que les routes API sont générées
ls -la .next/server/app/api/auth/

# Test de production en local
npm start

# Vérifier que NextAuth fonctionne en production
curl http://localhost:3000/api/auth/providers
```

### Variables de production

```bash
# Générer un nouveau secret pour la production
node -e "console.log('NEXTAUTH_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"

# Vérifier les variables de production (sans révéler les valeurs)
node -e "
const requiredVars = ['NEXTAUTH_SECRET', 'NEXTAUTH_URL', 'DATABASE_URL'];
requiredVars.forEach(v => {
  console.log(v + ':', !!process.env[v] ? '✅ Définie' : '❌ Manquante');
});
"
```

Cette documentation complète des commandes vous permet de configurer, tester et déployer NextAuth.js efficacement pour le projet PhotoMarket.