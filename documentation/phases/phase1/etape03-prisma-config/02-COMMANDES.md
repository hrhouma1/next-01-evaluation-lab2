# Étape 3 : Commandes Prisma - Configuration et maîtrise

## Commandes principales de développement

### Gestion du schéma Prisma

```bash
# Valider la syntaxe du schéma
npx prisma validate

# Formater automatiquement le fichier schema.prisma
npx prisma format

# Générer le client TypeScript/JavaScript
npx prisma generate

# Voir les changements sans les appliquer
npx prisma db push --preview-feature

# Pousser le schéma vers la base de données
npx prisma db push

# Forcer la réinitialisation de la base
npx prisma db push --force-reset
```

### Interface graphique et visualisation

```bash
# Ouvrir Prisma Studio (interface web)
npx prisma studio

# Ouvrir sur un port spécifique
npx prisma studio --port 5000

# Ouvrir en mode browser spécifique
npx prisma studio --browser=chrome
```

### Introspection et synchronisation

```bash
# Importer la structure depuis la base existante
npx prisma db pull

# Voir les différences entre schéma et base
npx prisma db diff

# Mode dry-run (test sans modification)
npx prisma db pull --dry-run
npx prisma db push --dry-run
```

## Commandes de migration (Production)

### Création et gestion des migrations

```bash
# Créer une nouvelle migration
npx prisma migrate dev --name "add_photo_tags"

# Appliquer les migrations en production
npx prisma migrate deploy

# Voir l'état des migrations
npx prisma migrate status

# Réinitialiser toutes les migrations (DANGER)
npx prisma migrate reset

# Résoudre les conflits de migration
npx prisma migrate resolve --applied "migration_name"
```

### Workflow de développement complet

```bash
# 1. Modifier le schema.prisma
# 2. Créer la migration
npx prisma migrate dev --name "descriptive_name"

# 3. Générer le client mis à jour
npx prisma generate

# 4. Tester l'application
npm run dev

# 5. Commit des changements
git add .
git commit -m "feat: Add new Prisma schema changes"
```

## Commandes de base de données

### Connexion et tests

```bash
# Tester la connexion à la base
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.\$connect()
  .then(() => console.log('✅ Connexion réussie'))
  .catch(err => console.error('❌ Erreur:', err.message))
  .finally(() => prisma.\$disconnect());
"

# Vérifier les variables d'environnement
node -e "console.log('DATABASE_URL:', !!process.env.DATABASE_URL)"

# Test complet de santé
node -e "
const { PrismaClient } = require('@prisma/client');
async function healthCheck() {
  const prisma = new PrismaClient();
  try {
    await prisma.\$connect();
    const userCount = await prisma.user.count();
    const photoCount = await prisma.photo.count();
    console.log('✅ Base opérationnelle');
    console.log('Users:', userCount, 'Photos:', photoCount);
  } catch (error) {
    console.error('❌ Problème:', error.message);
  } finally {
    await prisma.\$disconnect();
  }
}
healthCheck();
"
```

### Backup et restauration

```bash
# Backup de la base Neon
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurer un backup
psql $DATABASE_URL < backup_20240115_143000.sql

# Backup seulement des données (sans structure)
pg_dump --data-only $DATABASE_URL > data_backup.sql

# Backup seulement de la structure (sans données)
pg_dump --schema-only $DATABASE_URL > schema_backup.sql
```

### Commandes de nettoyage

```bash
# Vider toutes les tables (garde la structure)
npx prisma db push --force-reset

# Supprimer et recréer la base de données
npx prisma migrate reset

# Nettoyer les données de test
node -e "
const { PrismaClient } = require('@prisma/client');
async function cleanup() {
  const prisma = new PrismaClient();
  await prisma.purchase.deleteMany();
  await prisma.photo.deleteMany();
  await prisma.session.deleteMany();
  await prisma.account.deleteMany();
  await prisma.user.deleteMany();
  console.log('✅ Données nettoyées');
  await prisma.\$disconnect();
}
cleanup();
"
```

## Commandes d'interaction avancées

### Requêtes de diagnostic

```bash
# Compter tous les enregistrements
node -e "
const { PrismaClient } = require('@prisma/client');
async function counts() {
  const prisma = new PrismaClient();
  const counts = await Promise.all([
    prisma.user.count(),
    prisma.photo.count(),
    prisma.purchase.count(),
    prisma.account.count(),
    prisma.session.count()
  ]);
  console.log('Users:', counts[0]);
  console.log('Photos:', counts[1]);
  console.log('Purchases:', counts[2]);
  console.log('Accounts:', counts[3]);
  console.log('Sessions:', counts[4]);
  await prisma.\$disconnect();
}
counts();
"

# Statistiques des relations
node -e "
const { PrismaClient } = require('@prisma/client');
async function relations() {
  const prisma = new PrismaClient();
  const users = await prisma.user.findMany({
    include: {
      _count: {
        select: { photos: true, purchases: true }
      }
    }
  });
  users.forEach(user => {
    console.log(\`\${user.email}: \${user._count.photos} photos, \${user._count.purchases} achats\`);
  });
  await prisma.\$disconnect();
}
relations();
"
```

### Création de données de test

```bash
# Créer un utilisateur de test
node -e "
const { PrismaClient } = require('@prisma/client');
async function createTestUser() {
  const prisma = new PrismaClient();
  const user = await prisma.user.create({
    data: {
      email: 'test@example.com',
      password: 'hashedPassword',
      name: 'Utilisateur Test',
      role: 'USER'
    }
  });
  console.log('Utilisateur créé:', user.id);
  await prisma.\$disconnect();
}
createTestUser();
"

# Créer des photos de test
node -e "
const { PrismaClient } = require('@prisma/client');
async function createTestPhotos() {
  const prisma = new PrismaClient();
  
  // Récupérer ou créer un utilisateur
  let user = await prisma.user.findFirst();
  if (!user) {
    user = await prisma.user.create({
      data: {
        email: 'photographer@example.com',
        password: 'hashedPassword',
        name: 'Photographe Test'
      }
    });
  }
  
  // Créer des photos
  const photos = await prisma.photo.createMany({
    data: [
      {
        title: 'Sunset Beach',
        description: 'Beautiful sunset at the beach',
        imageUrl: 'https://example.com/sunset.jpg',
        price: 25.00,
        status: 'PUBLISHED',
        tags: ['sunset', 'beach', 'nature'],
        userId: user.id
      },
      {
        title: 'Mountain View',
        description: 'Panoramic mountain landscape',
        imageUrl: 'https://example.com/mountain.jpg',
        price: 30.00,
        status: 'PUBLISHED',
        tags: ['mountain', 'landscape', 'nature'],
        userId: user.id
      }
    ]
  });
  
  console.log('Photos créées:', photos.count);
  await prisma.\$disconnect();
}
createTestPhotos();
"
```

### Requêtes métier PhotoMarket

```bash
# Galerie publique
node -e "
const { PrismaClient } = require('@prisma/client');
async function publicGallery() {
  const prisma = new PrismaClient();
  const photos = await prisma.photo.findMany({
    where: { status: 'PUBLISHED' },
    include: {
      user: { select: { name: true } },
      _count: { select: { purchases: true } }
    },
    take: 10
  });
  console.log('Photos publiques:');
  photos.forEach(photo => {
    console.log(\`- \${photo.title} par \${photo.user.name} (\${photo.price}€) - \${photo._count.purchases} ventes\`);
  });
  await prisma.\$disconnect();
}
publicGallery();
"

# Top vendeurs
node -e "
const { PrismaClient } = require('@prisma/client');
async function topSellers() {
  const prisma = new PrismaClient();
  const sellers = await prisma.user.findMany({
    include: {
      photos: {
        include: {
          _count: { select: { purchases: true } }
        }
      }
    }
  });
  
  const stats = sellers
    .map(user => ({
      name: user.name || user.email,
      totalSales: user.photos.reduce((sum, photo) => sum + photo._count.purchases, 0)
    }))
    .filter(s => s.totalSales > 0)
    .sort((a, b) => b.totalSales - a.totalSales);
  
  console.log('Top vendeurs:');
  stats.forEach((seller, i) => {
    console.log(\`\${i+1}. \${seller.name}: \${seller.totalSales} ventes\`);
  });
  await prisma.\$disconnect();
}
topSellers();
"

# Revenus par utilisateur
node -e "
const { PrismaClient } = require('@prisma/client');
async function earnings() {
  const prisma = new PrismaClient();
  const result = await prisma.purchase.groupBy({
    by: ['userId'],
    _sum: { amount: true },
    _count: { id: true }
  });
  
  for (const stat of result) {
    const user = await prisma.user.findUnique({
      where: { id: stat.userId },
      select: { name: true, email: true }
    });
    console.log(\`\${user.name || user.email}: \${stat._sum.amount}€ (\${stat._count.id} achats)\`);
  }
  await prisma.\$disconnect();
}
earnings();
"
```

## Commandes cloud et déploiement

### Neon PostgreSQL

```bash
# Connexion directe à Neon via psql
psql $DATABASE_URL

# Lister les bases de données
psql $DATABASE_URL -c "\l"

# Lister les tables
psql $DATABASE_URL -c "\dt"

# Voir la taille de la base
psql $DATABASE_URL -c "
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"

# Voir les index
psql $DATABASE_URL -c "
SELECT 
  tablename,
  indexname,
  indexdef 
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename;
"
```

### Scripts de déploiement

```bash
# Script complet de déploiement
cat > deploy.sh << 'EOF'
#!/bin/bash
echo "🚀 Déploiement PhotoMarket..."

# 1. Variables d'environnement
echo "📋 Vérification des variables..."
if [ -z "$DATABASE_URL" ]; then
  echo "❌ DATABASE_URL manquante"
  exit 1
fi

# 2. Installation des dépendances
echo "📦 Installation..."
npm ci

# 3. Génération Prisma
echo "🔧 Génération Prisma..."
npx prisma generate

# 4. Migrations
echo "🗄️ Migrations..."
npx prisma migrate deploy

# 5. Build de l'application
echo "🏗️ Build..."
npm run build

# 6. Test de santé
echo "🏥 Test de santé..."
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.\$connect()
  .then(() => console.log('✅ Base accessible'))
  .catch(() => { console.error('❌ Base inaccessible'); process.exit(1); })
  .finally(() => prisma.\$disconnect());
"

echo "✅ Déploiement terminé !"
EOF

chmod +x deploy.sh
```

## Annexe 1 : Commandes PowerShell (Windows)

### Tests et diagnostics PowerShell

```powershell
# Fonction de test complète Prisma
function Test-PrismaSetup {
    Write-Host "=== TEST PRISMA COMPLET ===" -ForegroundColor Blue
    
    # Test 1: Vérifier l'installation
    try {
        $version = npx prisma --version
        Write-Host "✅ Prisma installé: $($version -split '\n' | Select-Object -First 1)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Prisma non installé" -ForegroundColor Red
        return
    }
    
    # Test 2: Validation du schéma
    Write-Host "Test validation schéma..." -ForegroundColor Yellow
    $validation = npx prisma validate 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Schéma valide" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur schéma: $validation" -ForegroundColor Red
    }
    
    # Test 3: Connexion base
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
        Write-Host "❌ Connexion DB échouée: $result" -ForegroundColor Red
    }
}

# Fonction de création de données de test
function New-TestData {
    param(
        [int]$UserCount = 3,
        [int]$PhotosPerUser = 5
    )
    
    Write-Host "Création de $UserCount utilisateurs avec $PhotosPerUser photos chacun..." -ForegroundColor Blue
    
    $script = @"
const { PrismaClient } = require('@prisma/client');
async function createTestData() {
  const prisma = new PrismaClient();
  
  for (let i = 1; i <= $UserCount; i++) {
    const user = await prisma.user.create({
      data: {
        email: `user`${i}@test.com`,
        password: 'hashedPassword',
        name: `Utilisateur `${i}`,
        role: i === 1 ? 'ADMIN' : 'USER'
      }
    });
    
    for (let j = 1; j <= $PhotosPerUser; j++) {
      await prisma.photo.create({
        data: {
          title: `Photo `${j} de `${user.name}`,
          description: `Description de la photo `${j}`,
          imageUrl: `https://picsum.photos/800/600?random=`${i}${j}`,
          price: Math.floor(Math.random() * 50) + 10,
          status: Math.random() > 0.3 ? 'PUBLISHED' : 'DRAFT',
          tags: ['tag`${i}', 'tag`${j}', 'test'],
          userId: user.id
        }
      });
    }
  }
  
  console.log('✅ Données de test créées');
  await prisma.`$disconnect();
}
createTestData().catch(console.error);
"@
    
    $script | Out-File -FilePath "create-test-data.js" -Encoding UTF8
    node create-test-data.js
    Remove-Item create-test-data.js
}

# Fonction de nettoyage
function Clear-TestData {
    Write-Host "⚠️ Suppression de toutes les données de test..." -ForegroundColor Yellow
    
    $cleanScript = @"
const { PrismaClient } = require('@prisma/client');
async function cleanup() {
  const prisma = new PrismaClient();
  await prisma.purchase.deleteMany();
  await prisma.photo.deleteMany();
  await prisma.session.deleteMany();
  await prisma.account.deleteMany();
  await prisma.user.deleteMany();
  console.log('✅ Toutes les données supprimées');
  await prisma.`$disconnect();
}
cleanup();
"@
    
    $cleanScript | Out-File -FilePath "cleanup.js" -Encoding UTF8
    node cleanup.js
    Remove-Item cleanup.js
}

# Exécution des fonctions
Write-Host "Commandes disponibles:" -ForegroundColor Cyan
Write-Host "- Test-PrismaSetup" -ForegroundColor White
Write-Host "- New-TestData -UserCount 5 -PhotosPerUser 3" -ForegroundColor White
Write-Host "- Clear-TestData" -ForegroundColor White
```

### Maintenance PowerShell

```powershell
# Backup automatique avec PowerShell
function Backup-Database {
    param(
        [string]$BackupPath = "backups"
    )
    
    if (!(Test-Path $BackupPath)) {
        New-Item -ItemType Directory -Path $BackupPath
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "$BackupPath\photomarket_backup_$timestamp.sql"
    
    Write-Host "Backup en cours vers $backupFile..." -ForegroundColor Blue
    
    $env:PGPASSWORD = (Get-Content .env | Where-Object { $_ -match "DATABASE_URL" } | ForEach-Object { $_.Split('=')[1] })
    
    # Extraction des infos de connexion depuis DATABASE_URL
    if ($env:DATABASE_URL -match "postgresql://([^:]+):([^@]+)@([^/]+)/(.+)") {
        $user = $matches[1]
        $password = $matches[2]  
        $host = $matches[3]
        $database = $matches[4]
        
        pg_dump -h $host -U $user -d $database -f $backupFile
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Backup réussi: $backupFile" -ForegroundColor Green
        } else {
            Write-Host "❌ Erreur backup" -ForegroundColor Red
        }
    }
}

# Surveillance des performances
function Watch-DatabasePerformance {
    Write-Host "Surveillance des performances (Ctrl+C pour arrêter)..." -ForegroundColor Blue
    
    while ($true) {
        $perfScript = @"
const { PrismaClient } = require('@prisma/client');
async function perf() {
  const prisma = new PrismaClient();
  const start = Date.now();
  
  const [userCount, photoCount, purchaseCount] = await Promise.all([
    prisma.user.count(),
    prisma.photo.count(), 
    prisma.purchase.count()
  ]);
  
  const duration = Date.now() - start;
  console.log(`[`${new Date().toLocaleTimeString()}`] Users: `${userCount}, Photos: `${photoCount}, Purchases: `${purchaseCount} (` ${duration}ms)`);
  await prisma.`$disconnect();
}
perf();
"@
        
        $perfScript | Out-File -FilePath "perf-check.js" -Encoding UTF8
        node perf-check.js
        Remove-Item perf-check.js
        
        Start-Sleep -Seconds 5
    }
}
```

## Annexe 2 : Commandes CMD (Command Prompt)

### Scripts batch pour tests

```cmd
REM test-prisma.bat
@echo off
echo === TEST COMPLET PRISMA ===
echo.

echo 1. Validation schéma...
npx prisma validate
if %errorlevel% == 0 (
    echo ✅ Schéma valide
) else (
    echo ❌ Erreur schéma
    goto :error
)

echo.
echo 2. Test connexion...
echo const{PrismaClient}=require('@prisma/client');new PrismaClient().$connect().then(()=>console.log('OK')).catch(e=>console.log('ERROR:',e.message)).finally(()=>process.exit()); > test-connection.js
node test-connection.js
del test-connection.js

echo.
echo 3. Comptage des données...
echo const{PrismaClient}=require('@prisma/client');async function count(){const p=new PrismaClient();const [u,ph,pu]=await Promise.all([p.user.count(),p.photo.count(),p.purchase.count()]);console.log('Users:',u,'Photos:',ph,'Purchases:',pu);await p.$disconnect();}count(); > count-data.js
node count-data.js
del count-data.js

echo.
echo ✅ Tests terminés
goto :end

:error
echo ❌ Tests échoués
pause
exit /b 1

:end
pause
```

### Maintenance CMD

```cmd
REM create-test-data.bat
@echo off
echo === CRÉATION DONNÉES DE TEST ===
echo.

set /p userCount="Nombre d'utilisateurs (défaut 3): "
if "%userCount%"=="" set userCount=3

set /p photoCount="Photos par utilisateur (défaut 5): "
if "%photoCount%"=="" set photoCount=5

echo Création de %userCount% utilisateurs avec %photoCount% photos chacun...

echo const{PrismaClient}=require('@prisma/client');async function create(){const p=new PrismaClient();for(let i=1;i<=%userCount%;i++){const u=await p.user.create({data:{email:`user${i}@test.com`,password:'hashed',name:`User ${i}`,role:i===1?'ADMIN':'USER'}});for(let j=1;j<=%photoCount%;j++){await p.photo.create({data:{title:`Photo ${j}`,description:'Test photo',imageUrl:`https://picsum.photos/800/600?random=${i}${j}`,price:Math.floor(Math.random()*50)+10,status:Math.random()>0.3?'PUBLISHED':'DRAFT',tags:['test','tag'+i],userId:u.id}});}}console.log('✅ Données créées');await p.$disconnect();}create(); > create-data.js
node create-data.js
del create-data.js

echo ✅ Données de test créées
pause
```

### Nettoyage CMD

```cmd
REM cleanup-data.bat
@echo off
echo === NETTOYAGE DONNÉES ===
echo.
echo ⚠️ ATTENTION: Cette action supprimera TOUTES les données
set /p confirm="Continuer? (y/N): "
if not "%confirm%"=="y" goto :end

echo Suppression en cours...
echo const{PrismaClient}=require('@prisma/client');async function clean(){const p=new PrismaClient();await p.purchase.deleteMany();await p.photo.deleteMany();await p.session.deleteMany();await p.account.deleteMany();await p.user.deleteMany();console.log('✅ Données supprimées');await p.$disconnect();}clean(); > cleanup.js
node cleanup.js
del cleanup.js

echo ✅ Nettoyage terminé

:end
pause
```

## Commandes de référence rapide

### Développement quotidien

```bash
# Workflow standard
npx prisma format && npx prisma validate && npx prisma generate && npx prisma db push

# Test rapide
node -e "const{PrismaClient}=require('@prisma/client');new PrismaClient().\$connect().then(()=>console.log('OK')).catch(console.error)"

# Ouvrir l'interface graphique
npx prisma studio
```

### Dépannage express

```bash
# Réinitialisation complète
npx prisma db push --force-reset && npx prisma generate

# Régénération client
rm -rf node_modules/.prisma && npx prisma generate

# Test de santé complet
npx prisma validate && npx prisma db push --dry-run && echo "✅ Schéma OK"
```

Cette documentation complète vous permet de maîtriser toutes les commandes Prisma nécessaires pour développer et maintenir l'application PhotoMarket efficacement.