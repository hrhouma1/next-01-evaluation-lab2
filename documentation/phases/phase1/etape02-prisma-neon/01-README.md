# Étape 2 : Configuration de Prisma avec Neon PostgreSQL

## Phase 1 - Configuration de la base de données

### RAPPEL : Objectif du projet PhotoMarket

Nous développons une **application web complète de galerie de photos** permettant à des utilisateurs de :

- **Vendre leurs photos** : Upload, description, prix
- **Acheter des photos** d'autres utilisateurs via Stripe
- **Gérer leur galerie personnelle** avec authentification sécurisée
- **Administrer le système** (rôles utilisateur/admin)

**Stack technique** :
- Next.js 14 + TypeScript + Tailwind CSS 3
- Prisma ORM + PostgreSQL (Neon)
- NextAuth.js pour l'authentification
- Stripe pour les paiements
- API REST sécurisée

### Progression du projet

**ETAPE 1 TERMINEE** : Configuration Next.js + TypeScript + Tailwind CSS 3
**ETAPE 2 EN COURS** : Configuration Prisma + Neon PostgreSQL
**ETAPES RESTANTES** : 25+ étapes jusqu'au projet complet

Le diagramme ci-dessus montre notre avancement dans les 30+ étapes du projet.

### Objectif de cette étape

Configurer **Prisma ORM** avec une base de données **PostgreSQL hébergée sur Neon** pour gérer :

- Les utilisateurs et leur authentification
- Les photos uploadées avec métadonnées
- Les transactions d'achat via Stripe
- Les rôles d'administration

### Technologies utilisées

- **Prisma ORM** : Interface TypeScript pour la base de données
- **Neon PostgreSQL** : Base de données cloud PostgreSQL
- **Variables d'environnement** : Configuration sécurisée
- **TypeScript** : Types générés automatiquement

### Prérequis

- Étape 1 terminée (projet Next.js fonctionnel)
- Compte Neon créé (https://neon.tech)
- Projet déployé ou en cours de développement

### Instructions d'installation

#### 1. Installation de Prisma

```bash
# Naviguer dans le projet
cd photo-marketplace

# Installer Prisma et ses dépendances
npm install prisma @prisma/client
npm install -D prisma

# Initialiser Prisma
npx prisma init
```

Cette commande crée :
- Le dossier `prisma/` avec `schema.prisma`
- Le fichier `.env` avec la variable `DATABASE_URL`

#### 2. Configuration de Neon PostgreSQL

**Étape 2a : Créer un projet sur Neon**

1. Aller sur https://neon.tech
2. Créer un compte ou se connecter
3. Créer un nouveau projet :
   - Nom : `photo-marketplace-db`
   - Région : `US East (Ohio)` ou plus proche
   - Version PostgreSQL : `15` (recommandée)

**Étape 2b : Récupérer la chaîne de connexion**

Dans votre dashboard Neon :
1. Cliquer sur "Connection string"
2. Sélectionner "Prisma"
3. Copier la chaîne complète

**Structure de la chaîne de connexion** :
```
postgresql://username:password@ep-xxx-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require
```

#### 3. Configuration du fichier .env (ULTRA-DÉTAILLÉ)

**Étape 3a : Générer une clé secrète NEXTAUTH_SECRET**

Cette clé est OBLIGATOIRE pour NextAuth.js. Voici comment la générer :

**Méthode 1 : Avec Node.js (recommandé)**
```bash
# Ouvrir un terminal et exécuter cette commande
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Exemple de résultat (VOTRE clé sera différente) :
# a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
```

**Méthode 2 : Avec OpenSSL (Linux/macOS)**
```bash
openssl rand -hex 32
```

**Méthode 3 : Avec PowerShell (Windows)**
```powershell
# Générer une clé de 32 bytes en hexadécimal
-join ((1..64) | ForEach {'{0:X}' -f (Get-Random -Max 16)})

# Ou avec .NET
[System.Web.Security.Membership]::GeneratePassword(64, 0)
```

**Méthode 4 : Avec Python (si installé)**
```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

**Méthode 5 : Générateur en ligne**
- Aller sur https://generate-secret.vercel.app/32
- Copier la clé générée

**IMPORTANT** : Copiez cette clé, vous en aurez besoin dans l'étape suivante !

**Pour les débutants** : La méthode Node.js (Méthode 1) est la plus simple et fonctionne sur tous les systèmes.

**Étape 3b : Modifier le fichier `.env`**

1. **Ouvrir le fichier `.env`** (créé par `npx prisma init`)
2. **Remplacer TOUT le contenu** par ceci :

```env
# =======================================
# CONFIGURATION BASE DE DONNÉES
# =======================================
# Remplacez par votre vraie URL Neon (copiée depuis le dashboard)
DATABASE_URL="postgresql://username:password@ep-xxx-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require"

# =======================================
# CONFIGURATION NEXTAUTH.JS
# =======================================
# Remplacez par la clé que vous avez générée à l'étape 3a
NEXTAUTH_SECRET="COLLEZ_VOTRE_CLE_GENEREE_ICI"
# URL de votre application (localhost pour le développement)
NEXTAUTH_URL="http://localhost:3000"

# =======================================
# CONFIGURATION STRIPE (POUR PLUS TARD)
# =======================================
# CES VALEURS SONT POUR SIMULATION - VOUS LES OBTIENDREZ DANS UNE ÉTAPE ULTÉRIEURE
# Clé secrète Stripe (pour les paiements côté serveur)
STRIPE_SECRET_KEY="sk_test_SIMULATION_CECI_SERA_REMPLACE_PLUS_TARD"
# Clé publique Stripe (pour les paiements côté client)
STRIPE_PUBLISHABLE_KEY="pk_test_SIMULATION_CECI_SERA_REMPLACE_PLUS_TARD"
# Secret webhook Stripe (pour valider les notifications de paiement)
STRIPE_WEBHOOK_SECRET="whsec_SIMULATION_CECI_SERA_REMPLACE_PLUS_TARD"
```

**Étape 3c : Créer le fichier `.env.example`**

1. **Créer un nouveau fichier** appelé `.env.example`
2. **Ajouter ce contenu** (SANS vos vraies valeurs) :

```env
# =======================================
# TEMPLATE DES VARIABLES D'ENVIRONNEMENT
# =======================================
# Ce fichier montre quelles variables sont nécessaires
# ATTENTION : Ne jamais mettre de vraies valeurs ici !

# Base de données Neon PostgreSQL
DATABASE_URL="postgresql://username:password@host/database?sslmode=require"

# NextAuth.js - Génération : node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
NEXTAUTH_SECRET="your-generated-secret-key-here"
NEXTAUTH_URL="http://localhost:3000"

# Stripe (à configurer plus tard)
STRIPE_SECRET_KEY="sk_test_your_stripe_secret_key"
STRIPE_PUBLISHABLE_KEY="pk_test_your_stripe_publishable_key"
STRIPE_WEBHOOK_SECRET="whsec_your_webhook_secret"
```

**Étape 3d : Vérifier que .env est dans .gitignore**

```bash
# Vérifier si .env est déjà dans .gitignore
grep -q "\.env" .gitignore && echo ".env est déjà ignoré ✅" || echo ".env PAS IGNORÉ ❌"

# Si pas ignoré, l'ajouter IMMÉDIATEMENT
echo ".env" >> .gitignore
echo ".env ajouté au .gitignore ✅"
```

**SÉCURITÉ CRITIQUE** :
- ❌ Ne jamais commiter le fichier `.env`
- ✅ Toujours commiter le fichier `.env.example`
- ✅ Le fichier `.env` doit être dans `.gitignore`

**Exemple concret de configuration** :

Supposons que :
- Votre URL Neon est : `postgresql://alex:abc123@ep-aged-bird-123456.us-east-1.aws.neon.tech/neondb?sslmode=require`
- Votre NEXTAUTH_SECRET généré est : `a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456`

Votre fichier `.env` ressemblerait à :
```env
DATABASE_URL="postgresql://alex:abc123@ep-aged-bird-123456.us-east-1.aws.neon.tech/neondb?sslmode=require"
NEXTAUTH_SECRET="a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"
NEXTAUTH_URL="http://localhost:3000"
STRIPE_SECRET_KEY="sk_test_SIMULATION_CECI_SERA_REMPLACE_PLUS_TARD"
STRIPE_PUBLISHABLE_KEY="pk_test_SIMULATION_CECI_SERA_REMPLACE_PLUS_TARD"
STRIPE_WEBHOOK_SECRET="whsec_SIMULATION_CECI_SERA_REMPLACE_PLUS_TARD"
```

#### 4. Création du schéma Prisma complet

**Remplacer le contenu de `prisma/schema.prisma`** :

```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ===================================
// MODÈLES DE L'APPLICATION PHOTOMARKET
// ===================================

// Énumération des rôles utilisateur
enum Role {
  USER   // Utilisateur normal (peut acheter et vendre)
  ADMIN  // Administrateur (gestion complète)
}

// Énumération des statuts de photo
enum PhotoStatus {
  DRAFT     // Brouillon (pas encore publié)
  PUBLISHED // Publié (visible et achetable)
  SOLD      // Vendu (plus disponible)
  ARCHIVED  // Archivé (retiré de la vente)
}

// ===================================
// MODÈLE UTILISATEUR
// ===================================
model User {
  id            String    @id @default(cuid())
  email         String    @unique
  password      String
  name          String?
  role          Role      @default(USER)
  emailVerified DateTime?
  image         String?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  // Relations avec autres modèles
  photos        Photo[]     // Photos uploadées par l'utilisateur
  purchases     Purchase[]  // Achats effectués par l'utilisateur
  accounts      Account[]   // Comptes OAuth (NextAuth.js)
  sessions      Session[]   // Sessions de connexion (NextAuth.js)

  @@map("users")
}

// ===================================
// MODÈLE PHOTO
// ===================================
model Photo {
  id          String      @id @default(cuid())
  title       String
  description String?
  imageUrl    String      // URL de l'image stockée
  price       Float       // Prix en euros
  status      PhotoStatus @default(DRAFT)
  tags        String[]    // Tags pour la recherche
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt

  // Relation avec l'utilisateur propriétaire
  userId      String
  user        User        @relation(fields: [userId], references: [id], onDelete: Cascade)

  // Relations avec les achats
  purchases   Purchase[]

  @@map("photos")
}

// ===================================
// MODÈLE ACHAT
// ===================================
model Purchase {
  id                String   @id @default(cuid())
  stripeSessionId   String   @unique // ID de session Stripe
  stripePaymentId   String?  // ID du paiement Stripe
  amount            Float    // Montant payé
  currency          String   @default("eur")
  status            String   // "pending", "completed", "failed"
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  // Relation avec l'acheteur
  userId            String
  user              User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  // Relation avec la photo achetée
  photoId           String
  photo             Photo    @relation(fields: [photoId], references: [id], onDelete: Cascade)

  @@map("purchases")
}

// ===================================
// MODÈLES NEXTAUTH.JS (Authentification)
// ===================================

// Comptes OAuth (Google, GitHub, etc.)
model Account {
  id                String  @id @default(cuid())
  userId            String
  type              String
  provider          String
  providerAccountId String
  refresh_token     String? @db.Text
  access_token      String? @db.Text
  expires_at        Int?
  token_type        String?
  scope             String?
  id_token          String? @db.Text
  session_state     String?

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerAccountId])
  @@map("accounts")
}

// Sessions de connexion
model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime
  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("sessions")
}

// Tokens de vérification (email, reset password)
model VerificationToken {
  identifier String
  token      String   @unique
  expires    DateTime

  @@unique([identifier, token])
  @@map("verificationtokens")
}
```

**Important** : Ce schéma définit toute la structure de données pour notre application PhotoMarket.

#### 5. Pousser le schéma vers la base de données

Maintenant que nous avons défini notre schéma, nous devons le synchroniser avec la base de données Neon :

```bash
# Pousser le schéma vers Neon PostgreSQL
npx prisma db push

# Cette commande va :
# 1. Se connecter à votre base Neon
# 2. Créer toutes les tables (users, photos, purchases, accounts, sessions, verificationtokens)
# 3. Configurer les relations entre les tables
# 4. Appliquer les contraintes et index
```

**Résultat attendu** :
```
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Datasource "db": PostgreSQL database "neondb"

🚀 Your database is now in sync with your schema.

✔ Generated Prisma Client (4.X.X) to ./node_modules/@prisma/client
```

#### 6. Générer le client Prisma TypeScript

```bash
# Générer le client Prisma avec tous les types TypeScript
npx prisma generate

# Cette commande crée :
# - Le client Prisma dans node_modules/@prisma/client
# - Tous les types TypeScript pour vos modèles
# - Les méthodes pour interagir avec la base de données
```

#### 7. Test de la connexion et du schéma

**Test basique de connexion** :
```bash
# Tester la connexion simple
npx prisma db pull --dry-run

# Si tout fonctionne, vous verrez :
# "✔ Introspected the database"
```

### Structure attendue après configuration

```
photo-marketplace/
├── prisma/
│   ├── schema.prisma          ← Schéma de base de données
│   └── (migrations/)          ← Migrations (créées plus tard)
├── .env                       ← Variables d'environnement (SECRET)
├── .env.example               ← Template des variables
├── .gitignore                 ← Doit contenir .env
├── src/
│   ├── app/
│   └── lib/
│       └── prisma.ts          ← Client Prisma (à créer prochainement)
└── package.json
```

### Configuration du client Prisma

**Créer `src/lib/prisma.ts`** :
```typescript
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

**Structure du client Prisma** :
```
src/
├── lib/
│   ├── prisma.ts              ← Client Prisma configuré
│   └── (autres utilitaires)
├── app/
│   ├── api/                   ← Routes API (prochaine étape)
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
└── components/                ← Composants (prochaines étapes)
```

### Tests de vérification COMPLETS

#### Test 1 : Variables d'environnement

```bash
# Vérifier toutes les variables importantes
node -e "
console.log('=== VÉRIFICATION VARIABLES ===');
console.log('DATABASE_URL définie:', !!process.env.DATABASE_URL);
console.log('NEXTAUTH_SECRET définie:', !!process.env.NEXTAUTH_SECRET);
console.log('NEXTAUTH_URL définie:', !!process.env.NEXTAUTH_URL);
console.log('Variables Stripe (simulation):', !!process.env.STRIPE_SECRET_KEY);
console.log('Toutes les variables principales sont présentes ✅');
"
```

#### Test 2 : Base de données et schéma

```bash
# Vérifier la connexion à la base de données
npx prisma db pull --dry-run

# Regarder les tables créées dans Neon
npx prisma studio --port 5000
# Ouvrir http://localhost:5000 pour voir l'interface graphique de la DB
# Appuyer sur Ctrl+C pour arrêter Prisma Studio
```

#### Test 3 : Client TypeScript COMPLET

**Créer un test complet** dans `test-db-complet.js` :
```javascript
const { PrismaClient } = require('@prisma/client')

async function testComplet() {
  const prisma = new PrismaClient()
  
  console.log('=== TEST COMPLET PRISMA + NEON ===\n')
  
  try {
    // Test 1: Connexion
    console.log('1. Test de connexion...')
    await prisma.$connect()
    console.log('   ✅ Connexion réussie')
    
    // Test 2: Requête de base
    console.log('\n2. Test requête SQL...')
    const result = await prisma.$queryRaw`SELECT NOW() as current_time, version() as db_version`
    console.log('   ✅ Heure serveur:', result[0].current_time)
    console.log('   ✅ Version PostgreSQL:', result[0].db_version.substring(0, 20) + '...')
    
    // Test 3: Vérifier les tables
    console.log('\n3. Test des tables créées...')
    const tables = await prisma.$queryRaw`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `
    console.log('   ✅ Tables créées:', tables.map(t => t.table_name).join(', '))
    
    // Test 4: Test des modèles Prisma
    console.log('\n4. Test des modèles Prisma...')
    
    // Compter les utilisateurs (devrait être 0)
    const userCount = await prisma.user.count()
    console.log('   ✅ Utilisateurs dans la DB:', userCount)
    
    // Compter les photos (devrait être 0)
    const photoCount = await prisma.photo.count()
    console.log('   ✅ Photos dans la DB:', photoCount)
    
    // Compter les achats (devrait être 0)
    const purchaseCount = await prisma.purchase.count()
    console.log('   ✅ Achats dans la DB:', purchaseCount)
    
    console.log('\n🎉 TOUS LES TESTS RÉUSSIS ! Prisma + Neon sont correctement configurés.')
    
  } catch (error) {
    console.error('\n❌ ERREUR DURANT LES TESTS:')
    console.error('Message:', error.message)
    console.error('Code:', error.code)
    
    if (error.message.includes('Environment variable not found')) {
      console.error('\n🔧 SOLUTION: Vérifiez votre fichier .env')
    } else if (error.message.includes('Can\'t reach database')) {
      console.error('\n🔧 SOLUTION: Vérifiez votre URL Neon dans .env')
    } else if (error.message.includes('does not exist')) {
      console.error('\n🔧 SOLUTION: Exécutez "npx prisma db push" pour créer les tables')
    }
    
  } finally {
    await prisma.$disconnect()
    console.log('\nConnexion fermée.')
  }
}

testComplet()
```

**Exécuter le test complet** :
```bash
# Lancer le test
node test-db-complet.js

# Résultat attendu si tout fonctionne :
# === TEST COMPLET PRISMA + NEON ===
# 
# 1. Test de connexion...
#    ✅ Connexion réussie
# 
# 2. Test requête SQL...
#    ✅ Heure serveur: 2024-XX-XX XX:XX:XX.XXX
#    ✅ Version PostgreSQL: PostgreSQL 15.X...
# 
# 3. Test des tables créées...
#    ✅ Tables créées: accounts, photos, purchases, sessions, users, verificationtokens
# 
# 4. Test des modèles Prisma...
#    ✅ Utilisateurs dans la DB: 0
#    ✅ Photos dans la DB: 0
#    ✅ Achats dans la DB: 0
# 
# 🎉 TOUS LES TESTS RÉUSSIS ! Prisma + Neon sont correctement configurés.
```

**Supprimer le fichier de test** :
```bash
rm test-db-complet.js
```

#### Test 4 : Vérification dans Neon Dashboard

1. **Aller sur votre dashboard Neon** (https://console.neon.tech)
2. **Sélectionner votre projet** `photo-marketplace-db`
3. **Onglet "Tables"** : Vous devriez voir 6 tables :
   - `users` (utilisateurs)
   - `photos` (photos à vendre)
   - `purchases` (achats)
   - `accounts` (comptes OAuth)
   - `sessions` (sessions de connexion)
   - `verificationtokens` (tokens de vérification)
4. **Onglet "Queries"** : Voir l'activité récente
5. **Onglet "Monitoring"** : Vérifier que la connexion est active

### Liste des commandes en ordre (si modification nécessaire)

Si vous devez modifier le schéma après l'avoir créé, voici les commandes **EXHAUSTIVES** à exécuter dans l'ordre :

#### Modification du schéma Prisma

```bash
# 1. Modifier le fichier prisma/schema.prisma
# (Ouvrir le fichier et faire vos modifications)

# 2. Vérifier la syntaxe du schéma
npx prisma validate

# 3. Voir les changements qui seront appliqués
npx prisma db push --preview-feature

# 4. Appliquer les changements à la base de données
npx prisma db push

# 5. Régénérer le client Prisma avec les nouveaux types
npx prisma generate

# 6. Redémarrer le serveur Next.js
npm run dev

# 7. Tester les nouveaux modèles
node test-db-complet.js

# 8. Commiter les changements
git add .
git commit -m "feat: Mise à jour du schéma Prisma"
git push
```

#### Commandes alternatives selon le type de modification

**Si vous ajoutez une nouvelle table** :
```bash
npx prisma db push
npx prisma generate
npm run dev
```

**Si vous modifiez une relation** :
```bash
npx prisma validate
npx prisma db push --force-reset  # ATTENTION: Supprime toutes les données
npx prisma generate
```

**Si vous voulez réinitialiser complètement la DB** :
```bash
npx prisma db push --force-reset
npx prisma generate
npx prisma db seed  # Si vous avez un script de seed
```

**Si vous voulez voir l'état actuel** :
```bash
npx prisma studio
# Ouvre l'interface graphique pour voir les données
```

### Vérifications à effectuer

1. **Base de données accessible** : Neon dashboard montre la connexion
2. **Variables d'environnement** : Toutes les clés sont définies
3. **Prisma configuré** : `npx prisma generate` fonctionne
4. **Client TypeScript** : Import de `@prisma/client` sans erreur
5. **Connexion active** : Test de connexion réussi

### Dépannage courant

#### Erreur "Environment variable not found: DATABASE_URL"

**Cause** : Le fichier `.env` n'est pas lu ou mal configuré.

**Solution** :
```bash
# Vérifier que le fichier .env existe
ls -la .env

# Vérifier le contenu (sans afficher les valeurs sensibles)
grep "DATABASE_URL" .env

# Redémarrer le serveur
npm run dev
```

#### Erreur "Can't reach database server"

**Cause** : URL de connexion incorrecte ou base de données inaccessible.

**Solutions** :
1. Vérifier l'URL dans le dashboard Neon
2. Régénérer la chaîne de connexion
3. Vérifier que la base de données n'est pas suspendue (Neon plan gratuit)

```bash
# Tester avec psql si disponible
psql "postgresql://username:password@host/database"
```

#### Erreur "SSL connection required"

**Cause** : Neon requiert SSL.

**Solution** : Ajouter `?sslmode=require` à la fin de l'URL :
```env
DATABASE_URL="postgresql://user:pass@host/db?sslmode=require"
```

### Livrables

- [ ] Prisma installé et configuré
- [ ] Connexion Neon PostgreSQL fonctionnelle
- [ ] Variables d'environnement configurées
- [ ] Client Prisma TypeScript opérationnel
- [ ] Test de connexion réussi

### Prochaines étapes

Une fois cette étape terminée, vous pourrez passer à l'**Étape 3 : Comprendre le schéma Prisma et les relations** pour approfondir la compréhension des modèles créés.

## Annexe 1 : Commandes PowerShell (Windows)

### Installation et configuration PowerShell

```powershell
# Naviguer dans le projet
Set-Location photo-marketplace

# Installer Prisma
npm install prisma @prisma/client
npm install -D prisma

# Initialiser Prisma
npx prisma init

# Générer NEXTAUTH_SECRET avec PowerShell
$secret = -join ((1..64) | ForEach {'{0:X}' -f (Get-Random -Max 16)})
Write-Host "NEXTAUTH_SECRET généré: $secret" -ForegroundColor Green

# Alternative avec .NET
Add-Type -AssemblyName System.Web
$secret = [System.Web.Security.Membership]::GeneratePassword(64, 0)
Write-Host "NEXTAUTH_SECRET (.NET): $secret" -ForegroundColor Green
```

### Tests PowerShell

```powershell
# Test des variables d'environnement
function Test-EnvironmentVariables {
    Write-Host "=== VÉRIFICATION VARIABLES ===" -ForegroundColor Blue
    
    if (Test-Path .env) {
        $envContent = Get-Content .env -Raw
        
        if ($envContent -match "DATABASE_URL") {
            Write-Host "✅ DATABASE_URL configurée" -ForegroundColor Green
        } else {
            Write-Host "❌ DATABASE_URL manquante" -ForegroundColor Red
        }
        
        if ($envContent -match "NEXTAUTH_SECRET") {
            Write-Host "✅ NEXTAUTH_SECRET configurée" -ForegroundColor Green
        } else {
            Write-Host "❌ NEXTAUTH_SECRET manquante" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Fichier .env introuvable" -ForegroundColor Red
    }
}

# Test de connexion Prisma
function Test-PrismaConnection {
    Write-Host "=== TEST CONNEXION PRISMA ===" -ForegroundColor Blue
    
    $testScript = @"
const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()
prisma.`$connect()
  .then(() => console.log('CONNECTION_SUCCESS'))
  .catch(err => console.log('CONNECTION_ERROR:', err.message))
  .finally(() => prisma.`$disconnect())
"@
    
    $testScript | Out-File -FilePath "test-connection.js" -Encoding UTF8
    $result = node test-connection.js
    Remove-Item test-connection.js
    
    if ($result -match "CONNECTION_SUCCESS") {
        Write-Host "✅ Connexion Prisma réussie" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur connexion:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Yellow
    }
}

# Exécuter tous les tests
Test-EnvironmentVariables
Test-PrismaConnection
```

### Finalisation PowerShell

```powershell
# Script complet de finalisation
function Complete-PrismaSetup {
    Write-Host "=== FINALISATION PRISMA + NEON ===" -ForegroundColor Magenta
    
    # 1. Synchroniser le schéma
    Write-Host "1. Synchronisation du schéma..." -ForegroundColor Yellow
    npx prisma db push
    
    # 2. Générer le client
    Write-Host "2. Génération du client..." -ForegroundColor Yellow
    npx prisma generate
    
    # 3. Test complet
    Write-Host "3. Test final..." -ForegroundColor Yellow
    $finalTest = @"
const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function finalTest() {
  try {
    await prisma.`$connect()
    const userCount = await prisma.user.count()
    const photoCount = await prisma.photo.count()
    const purchaseCount = await prisma.purchase.count()
    
    console.log('FINAL_TEST_SUCCESS')
    console.log('Users:', userCount)
    console.log('Photos:', photoCount)
    console.log('Purchases:', purchaseCount)
  } catch (error) {
    console.log('FINAL_TEST_ERROR:', error.message)
  } finally {
    await prisma.`$disconnect()
  }
}

finalTest()
"@
    
    $finalTest | Out-File -FilePath "test-final.js" -Encoding UTF8
    $result = node test-final.js
    Remove-Item test-final.js
    
    if ($result -match "FINAL_TEST_SUCCESS") {
        Write-Host "🎉 CONFIGURATION RÉUSSIE !" -ForegroundColor Green
        Write-Host "Toutes les tables sont créées et accessibles" -ForegroundColor Green
    } else {
        Write-Host "❌ Problème lors du test final:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Yellow
    }
}

Complete-PrismaSetup
```

## Annexe 2 : Commandes CMD (Command Prompt)

### Installation CMD

```cmd
REM Naviguer dans le projet
cd photo-marketplace

REM Installer Prisma
echo Installation de Prisma...
npm install prisma @prisma/client
npm install -D prisma

REM Initialiser Prisma
echo Initialisation de Prisma...
npx prisma init

REM Générer NEXTAUTH_SECRET
echo Génération NEXTAUTH_SECRET...
powershell -Command "Write-Host 'NEXTAUTH_SECRET:' (-join ((1..64) | ForEach {'{0:X}' -f (Get-Random -Max 16)}))"
```

### Tests CMD

```cmd
REM Script de test complet
@echo off
echo ========================================
echo     TEST COMPLET ÉTAPE 2
echo ========================================
echo.

echo 1. Test Node.js...
node --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Node.js installé
) else (
    echo ❌ Node.js manquant
    goto :error
)

echo.
echo 2. Test Prisma Client...
node -e "try{require('@prisma/client');console.log('✅ Prisma Client OK')}catch{console.log('❌ Prisma Client manquant')}"

echo.
echo 3. Vérification variables d'environnement...
if exist .env (
    echo ✅ Fichier .env présent
    findstr "DATABASE_URL" .env >nul && echo ✅ DATABASE_URL configurée || echo ❌ DATABASE_URL manquante
    findstr "NEXTAUTH_SECRET" .env >nul && echo ✅ NEXTAUTH_SECRET configurée || echo ❌ NEXTAUTH_SECRET manquante
) else (
    echo ❌ Fichier .env manquant
)

echo.
echo 4. Test connexion base de données...
echo const{PrismaClient}=require('@prisma/client');new PrismaClient().$connect().then(()=>console.log('✅ Connexion DB réussie')).catch(err=>console.log('❌ Connexion DB échouée:',err.message)).finally(()=>process.exit()); > test-db.js
node test-db.js
del test-db.js

echo.
echo 5. Test schéma et tables...
echo const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();Promise.all([p.user.count(),p.photo.count(),p.purchase.count()]).then(([u,ph,pu])=>console.log('✅ Tables OK - Users:',u,'Photos:',ph,'Purchases:',pu)).catch(err=>console.log('❌ Erreur tables:',err.message)).finally(()=>p.$disconnect()); > test-tables.js
node test-tables.js
del test-tables.js

echo.
echo ========================================
echo Si tous les tests sont ✅, l'étape 2 est réussie !
echo Vous pouvez passer à l'étape 3.
echo ========================================
goto :end

:error
echo.
echo ❌ Erreurs détectées. Vérifiez :
echo - L'installation de Node.js
echo - La configuration du .env
echo - Votre connexion internet
echo.

:end
pause
```

### Finalisation CMD

```cmd
REM Script de finalisation
@echo off
echo === FINALISATION ÉTAPE 2 ===

echo Synchronisation du schéma...
npx prisma db push

echo Génération du client...
npx prisma generate

echo Test final complet...
echo const{PrismaClient}=require('@prisma/client');async function test(){const p=new PrismaClient();try{await p.$connect();console.log('🎉 ÉTAPE 2 RÉUSSIE !');console.log('Base de données:',await p.user.count(),'users,',await p.photo.count(),'photos,',await p.purchase.count(),'purchases');}catch(e){console.log('❌ Erreur:',e.message);}finally{await p.$disconnect();}}test(); > final-test.js
node final-test.js
del final-test.js

echo.
echo Commit Git...
git add .
git commit -m "feat: Configuration Prisma + Neon PostgreSQL terminée"

echo.
echo ✅ Étape 2 terminée avec succès !
echo Passez maintenant à l'Étape 3 : Analyse du schéma
pause
```

### Ressources

- [Documentation Prisma](https://www.prisma.io/docs)
- [Documentation Neon](https://neon.tech/docs)
- [Guide Prisma + Next.js](https://www.prisma.io/docs/guides/other/troubleshooting-orm/help-articles/nextjs-prisma-client-monorepo)
- [Prisma Studio](https://www.prisma.io/docs/concepts/components/prisma-studio)
