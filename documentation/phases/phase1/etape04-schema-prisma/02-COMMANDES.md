# Étape 3 : Commandes pour analyser et tester le schéma Prisma

## Commandes principales

### Visualisation du schéma

```bash
# Ouvrir Prisma Studio pour voir les tables graphiquement
npx prisma studio

# Générer le diagramme ERD (si prisma-erd installé)
npx prisma-erd

# Voir la structure SQL générée
npx prisma db pull --preview-feature
```

### Tests de requêtes

```bash
# Créer un fichier de test pour les relations
touch test-relations.js

# Exécuter les tests de relations
node test-relations.js

# Nettoyer après tests
rm test-relations.js
```

### Analyse des performances

```bash
# Analyser les requêtes lentes dans Neon
npx prisma studio --port 5001

# Voir les index existants
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.\$queryRaw\`
  SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
  FROM pg_indexes 
  WHERE schemaname = 'public'
  ORDER BY tablename, indexname;
\`.then(console.log).finally(() => prisma.\$disconnect());
"
```

### Validation du schéma

```bash
# Valider la syntaxe Prisma
npx prisma validate

# Vérifier la cohérence des relations
npx prisma format

# Détecter les problèmes potentiels
npx prisma db diff --preview-feature
```

## Tests de relations spécifiques

### Test User → Photo (1:N)

```bash
# Créer test-user-photos.js
cat > test-user-photos.js << 'EOF'
const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function testUserPhotos() {
  try {
    // Compter les utilisateurs avec leurs photos
    const usersWithPhotos = await prisma.user.findMany({
      include: {
        _count: {
          select: { photos: true }
        }
      }
    })
    
    console.log('Utilisateurs et nombre de photos:')
    usersWithPhotos.forEach(user => {
      console.log(`- ${user.email}: ${user._count.photos} photos`)
    })
    
    // Test relation inverse
    const photosWithOwners = await prisma.photo.findMany({
      include: {
        user: {
          select: { email: true, name: true }
        }
      }
    })
    
    console.log('\nPhotos avec propriétaires:')
    photosWithOwners.forEach(photo => {
      console.log(`- "${photo.title}" par ${photo.user.name || photo.user.email}`)
    })
    
  } catch (error) {
    console.error('Erreur:', error.message)
  } finally {
    await prisma.$disconnect()
  }
}

testUserPhotos()
EOF

# Exécuter le test
node test-user-photos.js

# Supprimer le fichier
rm test-user-photos.js
```

### Test Purchase relations (N:N via table intermédiaire)

```bash
# Créer test-purchases.js
cat > test-purchases.js << 'EOF'
const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function testPurchases() {
  try {
    // Achats avec acheteur et photo
    const purchases = await prisma.purchase.findMany({
      include: {
        user: {
          select: { email: true, name: true }
        },
        photo: {
          select: { title: true, price: true },
          include: {
            user: {
              select: { email: true, name: true }
            }
          }
        }
      }
    })
    
    console.log('Historique des achats:')
    purchases.forEach(purchase => {
      console.log(`
Achat #${purchase.id}
- Acheteur: ${purchase.user.name || purchase.user.email}
- Photo: "${purchase.photo.title}"
- Vendeur: ${purchase.photo.user.name || purchase.photo.user.email}
- Prix: ${purchase.amount}€
- Statut: ${purchase.status}
      `)
    })
    
  } catch (error) {
    console.error('Erreur:', error.message)
  } finally {
    await prisma.$disconnect()
  }
}

testPurchases()
EOF

# Exécuter le test
node test-purchases.js

# Supprimer le fichier
rm test-purchases.js
```

### Test requêtes complexes

```bash
# Créer test-complex-queries.js
cat > test-complex-queries.js << 'EOF'
const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function testComplexQueries() {
  try {
    console.log('=== TESTS REQUÊTES COMPLEXES ===\n')
    
    // 1. Top vendeurs
    console.log('1. Top vendeurs (par nombre de ventes):')
    const topSellers = await prisma.user.findMany({
      include: {
        photos: {
          include: {
            _count: {
              select: { purchases: true }
            }
          }
        }
      }
    })
    
    const sellersWithSales = topSellers
      .map(user => ({
        email: user.email,
        name: user.name,
        totalSales: user.photos.reduce((sum, photo) => sum + photo._count.purchases, 0)
      }))
      .filter(seller => seller.totalSales > 0)
      .sort((a, b) => b.totalSales - a.totalSales)
    
    sellersWithSales.forEach((seller, index) => {
      console.log(`${index + 1}. ${seller.name || seller.email}: ${seller.totalSales} ventes`)
    })
    
    // 2. Photos les plus vendues
    console.log('\n2. Photos les plus vendues:')
    const popularPhotos = await prisma.photo.findMany({
      include: {
        user: {
          select: { name: true, email: true }
        },
        _count: {
          select: { purchases: true }
        }
      }
    })
    
    popularPhotos
      .filter(photo => photo._count.purchases > 0)
      .sort((a, b) => b._count.purchases - a._count.purchases)
      .forEach((photo, index) => {
        console.log(`${index + 1}. "${photo.title}" (${photo.price}€) - ${photo._count.purchases} achats`)
      })
    
    // 3. Revenus par utilisateur
    console.log('\n3. Revenus par vendeur:')
    const earnings = await prisma.purchase.groupBy({
      by: ['photoId'],
      _sum: {
        amount: true
      },
      _count: {
        id: true
      }
    })
    
    for (const earning of earnings) {
      const photo = await prisma.photo.findUnique({
        where: { id: earning.photoId },
        include: {
          user: {
            select: { name: true, email: true }
          }
        }
      })
      
      if (photo) {
        console.log(`- ${photo.user.name || photo.user.email}: ${earning._sum.amount}€ (${earning._count.id} ventes)`)
      }
    }
    
  } catch (error) {
    console.error('Erreur:', error.message)
  } finally {
    await prisma.$disconnect()
  }
}

testComplexQueries()
EOF

# Exécuter le test
node test-complex-queries.js

# Supprimer le fichier
rm test-complex-queries.js
```

## Commandes d'analyse des performances

### Analyse des index

```bash
# Voir tous les index de la base
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
(async () => {
  const indexes = await prisma.\$queryRaw\`
    SELECT 
      t.relname as table_name,
      i.relname as index_name,
      ix.indisprimary as is_primary,
      ix.indisunique as is_unique,
      array_to_string(array_agg(a.attname), ', ') as column_names
    FROM 
      pg_class t,
      pg_class i,
      pg_index ix,
      pg_attribute a
    WHERE 
      t.oid = ix.indrelid
      AND i.oid = ix.indexrelid
      AND a.attrelid = t.oid
      AND a.attnum = ANY(ix.indkey)
      AND t.relkind = 'r'
      AND t.relname IN ('users', 'photos', 'purchases', 'accounts', 'sessions')
    GROUP BY t.relname, i.relname, ix.indisprimary, ix.indisunique
    ORDER BY t.relname, i.relname;
  \`;
  console.table(indexes);
  await prisma.\$disconnect();
})();
"
```

### Statistiques des tables

```bash
# Statistiques complètes des tables
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
(async () => {
  console.log('=== STATISTIQUES DES TABLES ===\n');
  
  const tables = ['users', 'photos', 'purchases', 'accounts', 'sessions', 'verificationtokens'];
  
  for (const table of tables) {
    try {
      const count = await prisma.\$queryRaw\`SELECT COUNT(*) as count FROM \${table}\`;
      const size = await prisma.\$queryRaw\`
        SELECT pg_size_pretty(pg_total_relation_size('\${table}')) as size
      \`;
      console.log(\`\${table.toUpperCase()}:\`);
      console.log(\`  - Enregistrements: \${count[0].count}\`);
      console.log(\`  - Taille: \${size[0].size}\`);
      console.log();
    } catch (error) {
      console.log(\`\${table}: Erreur - \${error.message}\`);
    }
  }
  
  await prisma.\$disconnect();
})();
"
```

## Annexe 1 : Commandes PowerShell (Windows)

### Visualisation PowerShell

```powershell
# Ouvrir Prisma Studio
Start-Process npx -ArgumentList "prisma", "studio" -NoNewWindow

# Créer fichier de test avec PowerShell
@"
const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function test() {
  const users = await prisma.user.findMany({
    include: { _count: { select: { photos: true, purchases: true } } }
  })
  console.table(users)
  await prisma.$disconnect()
}
test()
"@ | Out-File -FilePath "test-schema.js" -Encoding UTF8

# Exécuter le test
node test-schema.js

# Supprimer le fichier
Remove-Item test-schema.js
```

### Analyse avec PowerShell

```powershell
# Fonction pour analyser les relations
function Test-PrismaRelations {
    Write-Host "=== ANALYSE DES RELATIONS PRISMA ===" -ForegroundColor Green
    
    # Test de connexion
    $testConnection = @"
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.`$connect()
  .then(() => console.log('✅ Connexion réussie'))
  .catch(err => console.error('❌ Erreur:', err.message))
  .finally(() => prisma.`$disconnect());
"@
    
    $testConnection | Out-File -FilePath "test-connection.js" -Encoding UTF8
    node test-connection.js
    Remove-Item test-connection.js
    
    Write-Host "Test de connexion terminé" -ForegroundColor Yellow
}

# Exécuter la fonction
Test-PrismaRelations
```

### Commandes de diagnostic PowerShell

```powershell
# Vérifier les variables d'environnement
Get-Content .env | Where-Object { $_ -match "DATABASE_URL|NEXTAUTH" }

# Vérifier l'installation Prisma
npm list @prisma/client prisma

# Voir les processus Node.js actifs
Get-Process node -ErrorAction SilentlyContinue

# Vérifier le port de Prisma Studio
Get-NetTCPConnection -LocalPort 5555 -ErrorAction SilentlyContinue
```

## Annexe 2 : Commandes CMD (Command Prompt)

### Tests avec CMD

```cmd
REM Créer fichier de test simple
echo const { PrismaClient } = require('@prisma/client') > test-simple.js
echo const prisma = new PrismaClient() >> test-simple.js
echo prisma.user.count().then(count =^> console.log('Utilisateurs:', count)).finally(() =^> prisma.$disconnect()) >> test-simple.js

REM Exécuter le test
node test-simple.js

REM Supprimer le fichier
del test-simple.js
```

### Diagnostic avec CMD

```cmd
REM Vérifier les variables d'environnement
findstr "DATABASE_URL NEXTAUTH" .env

REM Voir les processus Node.js
tasklist /FI "IMAGENAME eq node.exe"

REM Vérifier les ports utilisés
netstat -ano | findstr :5555
netstat -ano | findstr :3000

REM Test de connectivité PostgreSQL (si psql installé)
echo SELECT version(); | psql "%DATABASE_URL%"
```

### Script batch pour tests complets

```cmd
REM Créer test-complete.bat
@echo off
echo === TEST COMPLET SCHEMA PRISMA ===
echo.

echo 1. Test de connexion...
node -e "const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();p.$connect().then(()=>console.log('OK')).catch(e=>console.log('ERREUR:',e.message)).finally(()=>p.$disconnect());"

echo.
echo 2. Comptage des tables...
node -e "const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();Promise.all([p.user.count(),p.photo.count(),p.purchase.count()]).then(([u,ph,pu])=>console.log('Users:',u,'Photos:',ph,'Purchases:',pu)).finally(()=>p.$disconnect());"

echo.
echo 3. Test des relations...
node -e "const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();p.user.findMany({include:{_count:{select:{photos:true,purchases:true}}}}).then(u=>u.forEach(user=>console.log(user.email,'-',user._count.photos,'photos,',user._count.purchases,'achats'))).finally(()=>p.$disconnect());"

echo.
echo === TESTS TERMINES ===
pause
```

## Commandes de nettoyage

### Nettoyage général

```bash
# Supprimer tous les fichiers de test
rm -f test-*.js

# Fermer Prisma Studio si ouvert
pkill -f "prisma studio"

# Vérifier que tout est propre
ls test-*.js 2>/dev/null || echo "Aucun fichier de test trouvé"
```

### Nettoyage PowerShell

```powershell
# Supprimer fichiers de test
Get-ChildItem -Name "test-*.js" | Remove-Item

# Arrêter Prisma Studio
Get-Process -Name "node" | Where-Object { $_.CommandLine -like "*prisma studio*" } | Stop-Process

# Vérification
if (!(Get-ChildItem -Name "test-*.js")) {
    Write-Host "✅ Tous les fichiers de test supprimés" -ForegroundColor Green
}
```

### Nettoyage CMD

```cmd
REM Supprimer fichiers de test
del test-*.js 2>nul

REM Arrêter les processus Node.js liés à Prisma Studio
for /f "tokens=2" %%i in ('tasklist /FI "WINDOWTITLE eq Prisma Studio*" /NH') do taskkill /PID %%i /F 2>nul

REM Vérification
if not exist test-*.js echo ✅ Fichiers de test supprimés

echo Nettoyage terminé
```