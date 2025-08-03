# Étape 3 : Dépannage - Configuration et maîtrise Prisma

## Problèmes de configuration Prisma

### 1. Erreur "Prisma Client not generated"

**Symptômes** :
```
Error: Cannot find module '@prisma/client'
Module not found: Can't resolve '@prisma/client'
```

**Causes possibles** :
- Client Prisma pas généré après modification du schéma
- Installation incomplète ou corrompue
- Cache Node.js problématique

**Solutions étape par étape** :

```bash
# Solution 1: Régénérer le client
npx prisma generate

# Solution 2: Nettoyer et régénérer
rm -rf node_modules/.prisma
npx prisma generate

# Solution 3: Réinstallation complète
npm uninstall @prisma/client prisma
npm install @prisma/client prisma
npx prisma generate

# Solution 4: Cache npm corrompu
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
npx prisma generate
```

**Test de vérification** :
```bash
node -e "console.log(require('@prisma/client').PrismaClient.name)"
# Doit afficher: PrismaClient
```

### 2. Erreur "Schema validation failed"

**Symptômes** :
```
Error: Schema validation failed
Field "xxx" in model "Yyy" is invalid
```

**Causes possibles** :
- Syntaxe incorrecte dans schema.prisma
- Relations mal définies
- Types de données invalides

**Solutions** :

```bash
# Validation détaillée du schéma
npx prisma validate

# Formatage automatique (corrige certains problèmes)
npx prisma format

# Vérification des relations
node -e "
const fs = require('fs');
const schema = fs.readFileSync('prisma/schema.prisma', 'utf8');
console.log('Relations trouvées:');
const relations = schema.match(/@relation.*$/gm);
relations?.forEach(r => console.log('  ', r));
"
```

**Problèmes courants de relations** :

```prisma
// ❌ Incorrect: relation sans champ de référence
model User {
  id     String  @id
  photos Photo[]
}

model Photo {
  id   String @id
  user User   @relation(fields: [userId], references: [id])
  // ❌ Manque: userId String
}

// ✅ Correct: relation complète
model Photo {
  id     String @id
  userId String  // Champ de référence obligatoire
  user   User    @relation(fields: [userId], references: [id])
}
```

### 3. Erreur "Database connection failed"

**Symptômes** :
```
Can't reach database server
Connection timeout
SSL connection required
```

**Diagnostic** :

```bash
# Test 1: Variables d'environnement
node -e "console.log('DATABASE_URL présente:', !!process.env.DATABASE_URL)"

# Test 2: Format de l'URL
node -e "
const url = process.env.DATABASE_URL;
if (url) {
  const match = url.match(/postgresql:\/\/([^:]+):([^@]+)@([^\/]+)\/(.+)/);
  if (match) {
    console.log('Host:', match[3]);
    console.log('Database:', match[4]);
  } else {
    console.log('❌ Format URL invalide');
  }
}
"

# Test 3: Connectivité réseau (Linux/macOS)
ping -c 1 $(echo $DATABASE_URL | grep -o '@[^/]*' | cut -c2- | cut -d: -f1)

# Test 4: Connexion directe
npx prisma db pull --dry-run
```

**Solutions courantes** :

```bash
# Solution 1: URL SSL pour Neon
# Dans .env, s'assurer que l'URL contient sslmode=require
DATABASE_URL="postgresql://user:pass@host/db?sslmode=require"

# Solution 2: Régénérer l'URL sur Neon
# 1. Aller sur console.neon.tech
# 2. Projet → Connection string
# 3. Copier la nouvelle URL

# Solution 3: Vérifier l'état de la base Neon
# Les bases gratuites se mettent en "sleep" après inactivité
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
console.log('Réveil de la base...');
prisma.\$queryRaw\`SELECT NOW()\`
  .then(() => console.log('✅ Base active'))
  .catch(err => console.error('❌', err.message))
  .finally(() => prisma.\$disconnect());
"
```

### 4. Problèmes de types TypeScript

**Symptômes** :
```
Property 'photos' does not exist on type 'User'
Type 'Photo[]' is not assignable to type 'never'
```

**Causes** :
- Client Prisma pas régénéré après modification du schéma
- Import incorrect des types
- Version TypeScript incompatible

**Solutions** :

```bash
# Solution 1: Régénération complète
npx prisma generate
npm run build  # Si projet TypeScript

# Solution 2: Vérifier l'import
```

```typescript
// ✅ Import correct
import { PrismaClient, User, Photo, Purchase } from '@prisma/client'

// ✅ Types avec relations
type UserWithPhotos = User & {
  photos: Photo[]
}

type PhotoWithUser = Photo & {
  user: User
}

// ✅ Usage correct
const userWithPhotos: UserWithPhotos = await prisma.user.findUnique({
  where: { id: userId },
  include: { photos: true }
}) as UserWithPhotos
```

```bash
# Solution 3: Vérifier la configuration TypeScript
cat tsconfig.json | grep -A5 -B5 "types"

# Solution 4: Nettoyer les types
rm -rf node_modules/@types/node
npm install @types/node
npx prisma generate
```

## Problèmes de requêtes et performances

### 5. Requêtes lentes ou qui timeout

**Symptômes** :
- Requêtes qui prennent plus de 5 secondes
- Timeout sur les `include` complexes
- Application qui rame

**Diagnostic** :

```bash
# Activer les logs SQL
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
});

// Tester une requête lente
prisma.user.findMany({
  include: {
    photos: {
      include: {
        purchases: {
          include: {
            user: true
          }
        }
      }
    }
  }
}).then(() => console.log('Requête terminée'))
  .finally(() => prisma.\$disconnect());
"
```

**Solutions d'optimisation** :

```typescript
// ❌ Lent: charge tout
const users = await prisma.user.findMany({
  include: {
    photos: {
      include: {
        purchases: {
          include: { user: true }
        }
      }
    }
  }
})

// ✅ Rapide: seulement les données nécessaires
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
    _count: {
      select: {
        photos: true,
        purchases: true
      }
    }
  }
})

// ✅ Pagination pour gros volumes
const photos = await prisma.photo.findMany({
  where: { status: "PUBLISHED" },
  take: 20,
  skip: page * 20,
  orderBy: { createdAt: "desc" }
})

// ✅ Index sur les champs fréquemment filtrés
// Dans schema.prisma:
model Photo {
  // ... autres champs
  @@index([status, createdAt])
  @@index([userId])
  @@index([price])
}
```

### 6. Erreurs de contraintes de base de données

**Symptômes** :
```
Unique constraint failed on fields: (email)
Foreign key constraint failed
Null constraint violation
```

**Solutions** :

```typescript
// Gestion des erreurs de contrainte unique
async function createUser(email: string, name: string) {
  try {
    return await prisma.user.create({
      data: { email, name, password: "hashed" }
    })
  } catch (error) {
    if (error.code === 'P2002') {
      // Contrainte unique violée
      throw new Error(`L'email ${email} est déjà utilisé`)
    }
    throw error
  }
}

// Vérification avant insertion
async function createUserSafe(email: string, name: string) {
  const existing = await prisma.user.findUnique({
    where: { email }
  })
  
  if (existing) {
    throw new Error("Email déjà utilisé")
  }
  
  return await prisma.user.create({
    data: { email, name, password: "hashed" }
  })
}

// Upsert pour éviter les doublons
const user = await prisma.user.upsert({
  where: { email: "test@example.com" },
  update: { name: "Nom mis à jour" },
  create: {
    email: "test@example.com",
    name: "Nouveau nom",
    password: "hashed"
  }
})
```

## Problèmes de données et migrations

### 7. Erreur "Migration failed"

**Symptômes** :
```
Migration failed to apply
Data loss warning
Cannot drop column with data
```

**Solutions** :

```bash
# Voir l'état des migrations
npx prisma migrate status

# Forcer l'application d'une migration
npx prisma migrate resolve --applied "migration_name"

# Réinitialiser les migrations (ATTENTION: perte de données)
npx prisma migrate reset

# Migration sécurisée avec sauvegarde
pg_dump $DATABASE_URL > backup_before_migration.sql
npx prisma migrate deploy

# En cas de problème, restaurer
psql $DATABASE_URL < backup_before_migration.sql
```

**Migration manuelle pour changements délicats** :

```sql
-- Exemple: renommer une colonne avec données
BEGIN;

-- 1. Ajouter la nouvelle colonne
ALTER TABLE photos ADD COLUMN image_url TEXT;

-- 2. Copier les données
UPDATE photos SET image_url = imageurl WHERE imageurl IS NOT NULL;

-- 3. Rendre la nouvelle colonne obligatoire
ALTER TABLE photos ALTER COLUMN image_url SET NOT NULL;

-- 4. Supprimer l'ancienne colonne
ALTER TABLE photos DROP COLUMN imageurl;

COMMIT;
```

### 8. Données corrompues ou incohérentes

**Diagnostic** :

```bash
# Vérifier l'intégrité des relations
node -e "
const { PrismaClient } = require('@prisma/client');
async function checkIntegrity() {
  const prisma = new PrismaClient();
  
  // Photos orphelines (sans utilisateur)
  const orphanPhotos = await prisma.photo.findMany({
    where: {
      user: null
    }
  });
  console.log('Photos orphelines:', orphanPhotos.length);
  
  // Achats orphelins
  const orphanPurchases = await prisma.purchase.findMany({
    where: {
      OR: [
        { user: null },
        { photo: null }
      ]
    }
  });
  console.log('Achats orphelins:', orphanPurchases.length);
  
  await prisma.\$disconnect();
}
checkIntegrity();
"

# Statistiques générales
node -e "
const { PrismaClient } = require('@prisma/client');
async function stats() {
  const prisma = new PrismaClient();
  
  const [users, photos, purchases] = await Promise.all([
    prisma.user.count(),
    prisma.photo.count(),
    prisma.purchase.count()
  ]);
  
  console.log('Statistiques:');
  console.log('- Utilisateurs:', users);
  console.log('- Photos:', photos);
  console.log('- Achats:', purchases);
  
  // Ratios de cohérence
  if (users > 0) {
    console.log('- Photos/utilisateur:', (photos / users).toFixed(1));
    console.log('- Achats/utilisateur:', (purchases / users).toFixed(1));
  }
  
  await prisma.\$disconnect();
}
stats();
"
```

**Nettoyage des données** :

```typescript
// Script de nettoyage des données orphelines
async function cleanupOrphanData() {
  const prisma = new PrismaClient();
  
  // 1. Supprimer les achats sans photo ou sans utilisateur
  const deletedPurchases = await prisma.purchase.deleteMany({
    where: {
      OR: [
        { photo: null },
        { user: null }
      ]
    }
  });
  
  // 2. Supprimer les sessions expirées
  const deletedSessions = await prisma.session.deleteMany({
    where: {
      expires: {
        lt: new Date()
      }
    }
  });
  
  // 3. Supprimer les comptes OAuth orphelins
  const deletedAccounts = await prisma.account.deleteMany({
    where: {
      user: null
    }
  });
  
  console.log('Nettoyage terminé:');
  console.log('- Achats supprimés:', deletedPurchases.count);
  console.log('- Sessions supprimées:', deletedSessions.count);
  console.log('- Comptes supprimés:', deletedAccounts.count);
  
  await prisma.$disconnect();
}
```

## Problèmes d'environnement et déploiement

### 9. Différences entre environnements

**Symptômes** :
- Ça marche en local mais pas en production
- Schéma différent entre environnements
- Variables d'environnement manquantes

**Solutions** :

```bash
# Comparaison des schémas
npx prisma db pull --print > schema_local.prisma
# Sur production:
npx prisma db pull --print > schema_prod.prisma
diff schema_local.prisma schema_prod.prisma

# Synchronisation forcée
npx prisma db push --force-reset  # ATTENTION: perte de données

# Variables d'environnement par environnement
```

**.env.development** :
```env
DATABASE_URL="postgresql://user:pass@localhost:5432/photomarket_dev"
NEXTAUTH_URL="http://localhost:3000"
```

**.env.production** :
```env
DATABASE_URL="postgresql://user:pass@prod.neon.tech/photomarket"
NEXTAUTH_URL="https://photomarket.vercel.app"
```

### 10. Problèmes de cache et état incohérent

**Symptômes** :
- Changements de schéma pas pris en compte
- Types TypeScript obsolètes
- Requêtes qui retournent des résultats inattendus

**Solutions de nettoyage complet** :

```bash
# Nettoyage maximum
rm -rf node_modules
rm -rf .next
rm -rf .prisma
rm package-lock.json
npm cache clean --force

# Réinstallation complète
npm install
npx prisma generate
npx prisma db push

# Test de santé après nettoyage
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.\$connect()
  .then(() => console.log('✅ Prisma OK après nettoyage'))
  .catch(err => console.error('❌ Problème persistant:', err.message))
  .finally(() => prisma.\$disconnect());
"
```

## Dépannage spécifique Windows PowerShell

### Tests de diagnostic PowerShell

```powershell
# Fonction de diagnostic complète
function Diagnose-PrismaIssues {
    Write-Host "=== DIAGNOSTIC PRISMA COMPLET ===" -ForegroundColor Blue
    
    # Test 1: Installation
    try {
        $prismaVersion = npx prisma --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Prisma installé" -ForegroundColor Green
        } else {
            Write-Host "❌ Prisma non installé" -ForegroundColor Red
            return
        }
    } catch {
        Write-Host "❌ Erreur lors du test Prisma" -ForegroundColor Red
        return
    }
    
    # Test 2: Variables d'environnement
    if (Test-Path .env) {
        $envContent = Get-Content .env -Raw
        if ($envContent -match "DATABASE_URL") {
            Write-Host "✅ DATABASE_URL présente" -ForegroundColor Green
        } else {
            Write-Host "❌ DATABASE_URL manquante" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Fichier .env introuvable" -ForegroundColor Red
    }
    
    # Test 3: Validation du schéma
    Write-Host "Test validation schéma..." -ForegroundColor Yellow
    $validation = npx prisma validate 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Schéma valide" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur schéma:" -ForegroundColor Red
        Write-Host $validation -ForegroundColor Yellow
    }
    
    # Test 4: Client généré
    if (Test-Path "node_modules/@prisma/client") {
        Write-Host "✅ Client Prisma généré" -ForegroundColor Green
    } else {
        Write-Host "❌ Client Prisma manquant" -ForegroundColor Red
        Write-Host "Solution: npx prisma generate" -ForegroundColor Yellow
    }
    
    # Test 5: Connexion base
    Write-Host "Test connexion base..." -ForegroundColor Yellow
    $connectionTest = @"
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.`$connect()
  .then(() => console.log('CONNECTION_OK'))
  .catch(err => console.log('CONNECTION_ERROR:', err.message))
  .finally(() => prisma.`$disconnect());
"@
    
    $connectionTest | Out-File -FilePath "test-connection.js" -Encoding UTF8
    $result = node test-connection.js
    Remove-Item test-connection.js
    
    if ($result -match "CONNECTION_OK") {
        Write-Host "✅ Connexion DB réussie" -ForegroundColor Green
    } else {
        Write-Host "❌ Connexion DB échouée:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Yellow
    }
}

# Fonction de réparation automatique
function Repair-PrismaSetup {
    Write-Host "=== RÉPARATION AUTOMATIQUE PRISMA ===" -ForegroundColor Magenta
    
    # 1. Nettoyage cache
    Write-Host "1. Nettoyage du cache..." -ForegroundColor Yellow
    npm cache clean --force
    
    # 2. Réinstallation Prisma
    Write-Host "2. Réinstallation Prisma..." -ForegroundColor Yellow
    npm uninstall @prisma/client prisma
    npm install @prisma/client prisma
    
    # 3. Génération client
    Write-Host "3. Génération du client..." -ForegroundColor Yellow
    npx prisma generate
    
    # 4. Synchronisation base
    Write-Host "4. Synchronisation base..." -ForegroundColor Yellow
    npx prisma db push
    
    # 5. Test final
    Write-Host "5. Test final..." -ForegroundColor Yellow
    $finalTest = @"
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.`$connect()
  .then(() => console.log('REPAIR_SUCCESS'))
  .catch(err => console.log('REPAIR_FAILED:', err.message))
  .finally(() => prisma.`$disconnect());
"@
    
    $finalTest | Out-File -FilePath "test-repair.js" -Encoding UTF8
    $result = node test-repair.js
    Remove-Item test-repair.js
    
    if ($result -match "REPAIR_SUCCESS") {
        Write-Host "🎉 RÉPARATION RÉUSSIE !" -ForegroundColor Green
    } else {
        Write-Host "❌ Réparation échouée:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Yellow
    }
}

# Fonction de backup avant réparation
function Backup-DatabaseBeforeRepair {
    if (Test-Path .env) {
        $envContent = Get-Content .env -Raw
        if ($envContent -match 'DATABASE_URL="([^"]*)"') {
            $dbUrl = $matches[1]
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupFile = "backup_before_repair_$timestamp.sql"
            
            Write-Host "Création backup: $backupFile" -ForegroundColor Blue
            # Note: pg_dump doit être installé pour cette commande
            # pg_dump $dbUrl > $backupFile
            Write-Host "Backup terminé (si pg_dump installé)" -ForegroundColor Green
        }
    }
}

Write-Host "Fonctions disponibles:" -ForegroundColor Cyan
Write-Host "- Diagnose-PrismaIssues" -ForegroundColor White
Write-Host "- Repair-PrismaSetup" -ForegroundColor White
Write-Host "- Backup-DatabaseBeforeRepair" -ForegroundColor White
```

### Surveillance en temps réel PowerShell

```powershell
# Surveillance des performances Prisma
function Watch-PrismaPerformance {
    param([int]$IntervalSeconds = 5)
    
    Write-Host "Surveillance des performances Prisma (Ctrl+C pour arrêter)" -ForegroundColor Blue
    
    while ($true) {
        $perfTest = @"
const { PrismaClient } = require('@prisma/client');
async function perf() {
  const prisma = new PrismaClient();
  const start = Date.now();
  
  try {
    const [userCount, photoCount, purchaseCount] = await Promise.all([
      prisma.user.count(),
      prisma.photo.count(),
      prisma.purchase.count()
    ]);
    
    const duration = Date.now() - start;
    const timestamp = new Date().toLocaleTimeString();
    console.log(`[`${timestamp}`] Users: `${userCount}, Photos: `${photoCount}, Purchases: `${purchaseCount} (` ${duration}ms)`);
  } catch (error) {
    console.log(`[ERROR] `${error.message}`);
  } finally {
    await prisma.`$disconnect();
  }
}
perf();
"@
        
        $perfTest | Out-File -FilePath "perf-monitor.js" -Encoding UTF8
        node perf-monitor.js
        Remove-Item perf-monitor.js
        
        Start-Sleep -Seconds $IntervalSeconds
    }
}
```

## Annexe 2 : Dépannage CMD (Command Prompt)

### Scripts de diagnostic CMD

```cmd
REM diagnostic-prisma.bat
@echo off
echo === DIAGNOSTIC PRISMA ===
echo.

echo 1. Test installation Prisma...
npx prisma --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Prisma installé
) else (
    echo ❌ Prisma non installé
    goto :end
)

echo.
echo 2. Test variables d'environnement...
if exist .env (
    findstr "DATABASE_URL" .env >nul
    if %errorlevel% == 0 (
        echo ✅ DATABASE_URL présente
    ) else (
        echo ❌ DATABASE_URL manquante
    )
) else (
    echo ❌ Fichier .env introuvable
)

echo.
echo 3. Test validation schéma...
npx prisma validate >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Schéma valide
) else (
    echo ❌ Erreur dans le schéma
)

echo.
echo 4. Test client généré...
if exist "node_modules\@prisma\client" (
    echo ✅ Client Prisma présent
) else (
    echo ❌ Client Prisma manquant
    echo Solution: npx prisma generate
)

echo.
echo 5. Test connexion base...
echo const{PrismaClient}=require('@prisma/client');new PrismaClient().$connect().then(()=>console.log('OK')).catch(e=>console.log('ERROR:',e.message)).finally(()=>process.exit()); > test-db.js
node test-db.js
del test-db.js

:end
pause
```

### Script de réparation CMD

```cmd
REM repair-prisma.bat
@echo off
echo === RÉPARATION PRISMA ===
echo.
echo ⚠️ Cette opération va :
echo - Nettoyer le cache npm
echo - Réinstaller Prisma
echo - Régénérer le client
echo - Synchroniser la base
echo.
set /p confirm="Continuer? (y/N): "
if not "%confirm%"=="y" goto :end

echo.
echo Étape 1: Nettoyage cache...
npm cache clean --force

echo.
echo Étape 2: Réinstallation Prisma...
npm uninstall @prisma/client prisma
npm install @prisma/client prisma

echo.
echo Étape 3: Génération client...
npx prisma generate

echo.
echo Étape 4: Synchronisation base...
npx prisma db push

echo.
echo Étape 5: Test final...
echo const{PrismaClient}=require('@prisma/client');new PrismaClient().$connect().then(()=>console.log('✅ RÉPARATION RÉUSSIE')).catch(e=>console.log('❌ ÉCHEC:',e.message)).finally(()=>process.exit()); > test-final.js
node test-final.js
del test-final.js

:end
pause
```

## Solutions d'urgence

### Si rien ne fonctionne

1. **Réinitialisation complète du projet** :
```bash
# Sauvegarder les fichiers importants
cp prisma/schema.prisma schema_backup.prisma
cp .env env_backup

# Nettoyage radical
rm -rf node_modules
rm -rf .next
rm -rf .prisma
rm package-lock.json

# Réinstallation
npm install
npx prisma generate
npx prisma db push --force-reset
```

2. **Créer un projet test pour isoler le problème** :
```bash
mkdir test-prisma-debug
cd test-prisma-debug
npm init -y
npm install @prisma/client prisma
npx prisma init

# Copier votre DATABASE_URL dans .env
# Tester avec un schéma minimal
```

3. **Vérification de la compatibilité des versions** :
```bash
node --version  # >= 16.x recommandé
npm --version   # >= 8.x recommandé
npx prisma --version

# Vérifier package.json
cat package.json | grep -E "prisma|@prisma"
```

### Contacts support et ressources

- **Documentation officielle** : https://www.prisma.io/docs
- **Discord Prisma** : https://pris.ly/discord  
- **GitHub Issues** : https://github.com/prisma/prisma/issues
- **Support Neon** : https://neon.tech/docs/support

### Logs à collecter avant demande d'aide

```bash
# Informations système
echo "=== INFORMATIONS SYSTÈME ===" > debug-info.txt
node --version >> debug-info.txt
npm --version >> debug-info.txt
npx prisma --version >> debug-info.txt

# Configuration
echo -e "\n=== CONFIGURATION ===" >> debug-info.txt
cat package.json | grep -A10 -B10 prisma >> debug-info.txt

# Variables d'environnement (masquées)
echo -e "\n=== VARIABLES ENV ===" >> debug-info.txt
grep -E "DATABASE_URL|NEXTAUTH" .env | sed 's/=.*/=***MASQUÉ***/' >> debug-info.txt

# Logs d'erreur
echo -e "\n=== LOGS ERREUR ===" >> debug-info.txt
npx prisma validate 2>&1 >> debug-info.txt

echo "Fichier debug-info.txt créé pour le support"
```

En suivant ce guide de dépannage étape par étape, vous devriez pouvoir résoudre la majorité des problèmes rencontrés avec Prisma dans le projet PhotoMarket.