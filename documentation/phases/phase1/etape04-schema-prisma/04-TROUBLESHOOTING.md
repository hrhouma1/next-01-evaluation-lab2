# Étape 3 : Dépannage - Problèmes avec le schéma Prisma

## Problèmes courants et solutions

### 1. Erreur "Module not found: @prisma/client"

**Symptômes** :
```
Error: Cannot find module '@prisma/client'
```

**Causes possibles** :
- Client Prisma pas généré après modification du schéma
- Installation incomplète de Prisma
- Cache Node.js corrompu

**Solutions** :

```bash
# Solution 1: Régénérer le client Prisma
npx prisma generate

# Solution 2: Réinstaller Prisma
npm uninstall @prisma/client prisma
npm install @prisma/client prisma

# Solution 3: Nettoyer le cache
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
npx prisma generate
```

### 2. Erreur "Table does not exist" lors des tests

**Symptômes** :
```
PrismaClientKnownRequestError: Table 'users' doesn't exist
```

**Causes possibles** :
- Schéma pas poussé vers la base de données
- Base de données vide ou corrompue
- Mauvaise URL de connexion

**Solutions** :

```bash
# Solution 1: Pousser le schéma vers la DB
npx prisma db push

# Solution 2: Vérifier la connexion
npx prisma db pull --dry-run

# Solution 3: Réinitialiser la base
npx prisma db push --force-reset
npx prisma generate

# Solution 4: Vérifier l'URL dans .env
grep "DATABASE_URL" .env
```

### 3. Relations qui ne fonctionnent pas dans les requêtes

**Symptômes** :
```
Type error: Property 'photos' does not exist on type 'User'
```

**Causes possibles** :
- Client Prisma pas régénéré après modification du schéma
- Syntaxe incorrecte dans les relations
- Import incorrect du client

**Solutions** :

```bash
# Solution 1: Régénérer le client avec les nouveaux types
npx prisma generate

# Solution 2: Vérifier la syntaxe des relations
npx prisma validate

# Solution 3: Test simple de relation
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.user.findFirst({
  include: { photos: true }
}).then(user => {
  console.log('Relations OK:', !!user);
}).catch(err => {
  console.error('Erreur relation:', err.message);
}).finally(() => prisma.\$disconnect());
"
```

### 4. Prisma Studio ne s'ouvre pas

**Symptômes** :
- `npx prisma studio` ne répond pas
- Page blanche sur http://localhost:5555
- Erreur de port déjà utilisé

**Solutions** :

```bash
# Solution 1: Vérifier si le port est libre
lsof -i :5555  # Sur macOS/Linux
netstat -ano | findstr :5555  # Sur Windows

# Solution 2: Utiliser un autre port
npx prisma studio --port 5556

# Solution 3: Tuer les processus conflictuels
pkill -f "prisma studio"  # macOS/Linux
taskkill /F /IM node.exe  # Windows

# Solution 4: Vérifier la connexion DB
npx prisma db pull --dry-run
```

### 5. Erreurs de types TypeScript avec Prisma

**Symptômes** :
```
Property 'user' does not exist on type 'Photo'
Argument of type is not assignable to parameter
```

**Causes possibles** :
- Types Prisma pas à jour
- Configuration TypeScript incorrecte
- Import manquant des types Prisma

**Solutions** :

```bash
# Solution 1: Régénérer tous les types
npx prisma generate
npm run build  # Si projet TypeScript

# Solution 2: Vérifier tsconfig.json
cat tsconfig.json | grep -A5 -B5 "types"

# Solution 3: Import explicite des types
```

```typescript
// Dans vos fichiers TypeScript
import { PrismaClient, User, Photo, Purchase } from '@prisma/client'

// Types pour les relations
type UserWithPhotos = User & {
  photos: Photo[]
}

type PhotoWithUser = Photo & {
  user: User
}
```

### 6. Performances lentes des requêtes complexes

**Symptômes** :
- Requêtes qui prennent plusieurs secondes
- Timeout sur les requêtes avec `include`
- Base de données qui rame

**Solutions** :

```bash
# Solution 1: Analyser les requêtes lentes
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
});
// Vos requêtes ici pour voir les logs SQL
"

# Solution 2: Vérifier les index existants
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.\$queryRaw\`
  SELECT indexname, indexdef 
  FROM pg_indexes 
  WHERE schemaname = 'public'
\`.then(console.table).finally(() => prisma.\$disconnect());
"

# Solution 3: Optimiser avec select au lieu d'include
```

```javascript
// ❌ Lent : charge tout
const users = await prisma.user.findMany({
  include: { 
    photos: true,
    purchases: true 
  }
})

// ✅ Rapide : charge seulement ce qui est nécessaire
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    _count: {
      select: {
        photos: true,
        purchases: true
      }
    }
  }
})
```

### 7. Erreurs de contraintes lors des tests

**Symptômes** :
```
Foreign key constraint failed
Unique constraint failed on fields: email
```

**Causes possibles** :
- Données de test en conflit
- Tentative d'insertion de doublons
- Relations cassées

**Solutions** :

```bash
# Solution 1: Nettoyer les données de test
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function cleanup() {
  await prisma.purchase.deleteMany();
  await prisma.photo.deleteMany();
  await prisma.session.deleteMany();
  await prisma.account.deleteMany();
  await prisma.user.deleteMany();
  console.log('✅ Base nettoyée');
}
cleanup().finally(() => prisma.\$disconnect());
"

# Solution 2: Vérifier les contraintes
npx prisma validate

# Solution 3: Réinitialiser complètement
npx prisma db push --force-reset
```

### 8. Problèmes de connexion Neon intermittents

**Symptômes** :
- Connexion qui marche parfois, pas toujours
- Erreurs "Connection timeout"
- Base qui se "réveille" lentement

**Causes possibles** :
- Base Neon en mode "sleep" (plan gratuit)
- Problème de réseau
- URL de connexion expirée

**Solutions** :

```bash
# Solution 1: "Réveiller" la base avec une requête simple
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.\$queryRaw\`SELECT NOW()\`
  .then(() => console.log('✅ Base réveillée'))
  .catch(err => console.error('❌', err.message))
  .finally(() => prisma.\$disconnect());
"

# Solution 2: Vérifier l'URL Neon
curl -I $(grep DATABASE_URL .env | cut -d'=' -f2- | tr -d '"')

# Solution 3: Régénérer l'URL sur Neon Dashboard
# Aller sur console.neon.tech → Votre projet → Connection string
```

## Dépannage spécifique Windows PowerShell

### Tests PowerShell pour diagnostiquer

```powershell
# Test 1: Vérifier l'installation Prisma
function Test-PrismaInstallation {
    Write-Host "=== TEST INSTALLATION PRISMA ===" -ForegroundColor Blue
    
    try {
        $prismaVersion = npm list @prisma/client --depth=0 2>$null
        if ($prismaVersion -match "@prisma/client") {
            Write-Host "✅ Prisma Client installé" -ForegroundColor Green
        } else {
            Write-Host "❌ Prisma Client manquant" -ForegroundColor Red
            Write-Host "Solution: npm install @prisma/client" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Erreur vérification Prisma" -ForegroundColor Red
    }
}

# Test 2: Vérifier les variables d'environnement
function Test-EnvironmentVariables {
    Write-Host "=== TEST VARIABLES ENVIRONNEMENT ===" -ForegroundColor Blue
    
    if (Test-Path .env) {
        $envContent = Get-Content .env -Raw
        
        if ($envContent -match "DATABASE_URL") {
            Write-Host "✅ DATABASE_URL présente" -ForegroundColor Green
        } else {
            Write-Host "❌ DATABASE_URL manquante" -ForegroundColor Red
        }
        
        if ($envContent -match "NEXTAUTH_SECRET") {
            Write-Host "✅ NEXTAUTH_SECRET présente" -ForegroundColor Green
        } else {
            Write-Host "❌ NEXTAUTH_SECRET manquante" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Fichier .env introuvable" -ForegroundColor Red
    }
}

# Test 3: Tester la connexion DB
function Test-DatabaseConnection {
    Write-Host "=== TEST CONNEXION BASE DE DONNÉES ===" -ForegroundColor Blue
    
    $testScript = @"
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.`$connect()
  .then(() => console.log('CONNECTION_OK'))
  .catch(err => console.log('CONNECTION_ERROR:', err.message))
  .finally(() => prisma.`$disconnect());
"@
    
    $testScript | Out-File -FilePath "test-connection.js" -Encoding UTF8
    $result = node test-connection.js
    Remove-Item test-connection.js
    
    if ($result -match "CONNECTION_OK") {
        Write-Host "✅ Connexion DB réussie" -ForegroundColor Green
    } else {
        Write-Host "❌ Connexion DB échouée" -ForegroundColor Red
        Write-Host "Erreur: $result" -ForegroundColor Yellow
    }
}

# Exécuter tous les tests
Test-PrismaInstallation
Test-EnvironmentVariables  
Test-DatabaseConnection
```

### Diagnostic réseau PowerShell

```powershell
# Vérifier la connectivité vers Neon
function Test-NeonConnectivity {
    $envContent = Get-Content .env -Raw
    if ($envContent -match 'DATABASE_URL="([^"]*)"') {
        $dbUrl = $matches[1]
        
        # Extraire l'hostname
        if ($dbUrl -match "postgresql://[^@]*@([^/]*)/") {
            $hostname = $matches[1].Split(':')[0]
            
            Write-Host "Test connectivité vers $hostname..." -ForegroundColor Blue
            $ping = Test-NetConnection -ComputerName $hostname -Port 5432
            
            if ($ping.TcpTestSucceeded) {
                Write-Host "✅ Connectivité réseau OK" -ForegroundColor Green
            } else {
                Write-Host "❌ Problème réseau vers Neon" -ForegroundColor Red
                Write-Host "Vérifiez votre connexion internet" -ForegroundColor Yellow
            }
        }
    }
}

Test-NeonConnectivity
```

## Annexe 2 : Dépannage CMD (Command Prompt)

### Script de diagnostic complet CMD

```cmd
@echo off
echo === DIAGNOSTIC COMPLET PRISMA SCHEMA ===
echo.

echo 1. Test Node.js...
node --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Node.js OK
) else (
    echo ❌ Node.js manquant ou problématique
    goto :end
)

echo.
echo 2. Test Prisma Client...
node -e "try{require('@prisma/client');console.log('✅ Prisma Client OK')}catch{console.log('❌ Prisma Client manquant')}"

echo.
echo 3. Test variables d'environnement...
if exist .env (
    findstr "DATABASE_URL" .env >nul
    if %errorlevel% == 0 (
        echo ✅ DATABASE_URL présente
    ) else (
        echo ❌ DATABASE_URL manquante
    )
    
    findstr "NEXTAUTH_SECRET" .env >nul
    if %errorlevel% == 0 (
        echo ✅ NEXTAUTH_SECRET présente
    ) else (
        echo ❌ NEXTAUTH_SECRET manquante
    )
) else (
    echo ❌ Fichier .env introuvable
)

echo.
echo 4. Test connexion base de données...
echo const{PrismaClient}=require('@prisma/client');new PrismaClient().$connect().then(()=>console.log('✅ DB OK')).catch(e=>console.log('❌ DB ERROR:',e.message)).finally(()=>process.exit()); > test-db.js
node test-db.js
del test-db.js

echo.
echo 5. Test des tables...
echo const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();Promise.all([p.user.count(),p.photo.count(),p.purchase.count()]).then(([u,ph,pu])=>console.log('Tables - Users:',u,'Photos:',ph,'Purchases:',pu)).catch(e=>console.log('❌ Erreur tables:',e.message)).finally(()=>p.$disconnect()); > test-tables.js
node test-tables.js
del test-tables.js

echo.
echo 6. Vérification fichiers...
if exist "prisma\schema.prisma" (
    echo ✅ Schema Prisma présent
) else (
    echo ❌ Schema Prisma manquant
)

if exist "node_modules\@prisma\client" (
    echo ✅ Client Prisma installé
) else (
    echo ❌ Client Prisma non installé
)

echo.
echo === DIAGNOSTIC TERMINÉ ===
echo.
echo Si des erreurs persistent, vérifiez :
echo - La connexion internet
echo - L'URL Neon dans .env
echo - Que 'npx prisma db push' a été exécuté
echo.
:end
pause
```

### Script de réparation CMD

```cmd
@echo off
echo === SCRIPT DE RÉPARATION PRISMA ===
echo.

echo Étape 1: Nettoyage cache...
npm cache clean --force
echo ✅ Cache nettoyé

echo.
echo Étape 2: Réinstallation Prisma...
npm uninstall @prisma/client prisma
npm install @prisma/client prisma
echo ✅ Prisma réinstallé

echo.
echo Étape 3: Regénération client...
npx prisma generate
echo ✅ Client régénéré

echo.
echo Étape 4: Synchronisation base...
npx prisma db push
echo ✅ Base synchronisée

echo.
echo Étape 5: Test final...
echo const{PrismaClient}=require('@prisma/client');new PrismaClient().$connect().then(()=>console.log('✅ RÉPARATION RÉUSSIE')).catch(e=>console.log('❌ PROBLÈME PERSISTE:',e.message)).finally(()=>process.exit()); > test-final.js
node test-final.js
del test-final.js

echo.
echo === RÉPARATION TERMINÉE ===
pause
```

### Nettoyage complet CMD

```cmd
@echo off
echo === NETTOYAGE COMPLET PROJET ===
echo ATTENTION: Cette action supprime node_modules et package-lock.json
echo.
set /p confirm="Continuer? (y/N): "
if not "%confirm%"=="y" goto :end

echo.
echo Suppression des dépendances...
rmdir /s /q node_modules 2>nul
del package-lock.json 2>nul
echo ✅ Dépendances supprimées

echo.
echo Réinstallation...
npm install
echo ✅ Dépendances réinstallées

echo.
echo Configuration Prisma...
npx prisma generate
npx prisma db push
echo ✅ Prisma configuré

echo.
echo Test final...
echo const{PrismaClient}=require('@prisma/client');new PrismaClient().$connect().then(()=>console.log('✅ PROJET NETTOYÉ ET FONCTIONNEL')).catch(e=>console.log('❌ ERREUR:',e.message)).finally(()=>process.exit()); > test-clean.js
node test-clean.js
del test-clean.js

:end
pause
```

## Solutions d'urgence

### Si rien ne fonctionne

1. **Réinitialisation complète** :
```bash
rm -rf node_modules package-lock.json
npm install
npx prisma db push --force-reset
npx prisma generate
```

2. **Créer un nouveau projet de test** :
```bash
mkdir test-prisma
cd test-prisma
npm init -y
npm install @prisma/client prisma
npx prisma init
# Copier votre DATABASE_URL
npx prisma db pull
```

3. **Contacter le support** :
- Documentation Prisma : https://www.prisma.io/docs
- Discord Prisma : https://pris.ly/discord
- Support Neon : https://neon.tech/docs/support/support

### Logs utiles à collecter

Avant de demander de l'aide, collectez ces informations :

```bash
# Version Node.js
node --version

# Version Prisma
npx prisma --version

# Contenu du schéma (sans données sensibles)
cat prisma/schema.prisma

# Test de connexion avec logs
npx prisma db pull --dry-run 2>&1

# Variables d'environnement (masquées)
grep -E "DATABASE_URL|NEXTAUTH" .env | sed 's/=.*/=***MASQUÉ***/'
```

En suivant ces guides de dépannage, vous devriez pouvoir résoudre la majorité des problèmes rencontrés lors de l'analyse du schéma Prisma.