# Étape 3 : Configuration et compréhension du schéma Prisma

## Phase 1 - Maîtrise de Prisma ORM

### RAPPEL : Objectif du projet PhotoMarket

Nous développons une **application web complète de galerie de photos** permettant à des utilisateurs de :

- **Vendre leurs photos** : Upload, description, prix
- **Acheter des photos** d'autres utilisateurs via Stripe
- **Gérer leur galerie personnelle** avec authentification sécurisée
- **Administrer le système** (rôles utilisateur/admin)

### Progression du projet

**ETAPE 1 TERMINEE** : Configuration Next.js + TypeScript + Tailwind CSS 3  
**ETAPE 2 TERMINEE** : Configuration Prisma + Neon PostgreSQL + Schéma complet  
**ETAPE 3 EN COURS** : Configuration et maîtrise complète de Prisma ORM  
**ETAPES RESTANTES** : 25+ étapes jusqu'au projet complet

### Objectif de cette étape

**Maîtriser complètement Prisma ORM** pour notre application PhotoMarket :

- **Comprendre le fichier `prisma/schema.prisma`** en détail
- **Relations de base de données** : 1:1, 1:N, N:N avec exemples concrets
- **Commandes Prisma** locales et cloud essentielles
- **Requêtes avancées** pour les besoins métier
- **Optimisation et performance** des requêtes
- **Migration et déploiement** en production

## Le fichier prisma/schema.prisma expliqué

### Structure générale du fichier

```prisma
// ===========================================
// CONFIGURATION PRISMA
// ===========================================

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ===========================================
// ÉNUMÉRATIONS (ENUMS)
// ===========================================

enum Role {
  USER   // Utilisateur standard
  ADMIN  // Administrateur
}

enum PhotoStatus {
  DRAFT     // Brouillon
  PUBLISHED // Publié
  SOLD      // Vendu
  ARCHIVED  // Archivé
}

// ===========================================
// MODÈLES DE DONNÉES
// ===========================================

model User {
  // Champs de base...
}
```

### Section 1 : Configuration Prisma

#### Generator (Générateur de client)

```prisma
generator client {
  provider = "prisma-client-js"
}
```

**Explication** :
- **provider** : Spécifie quel client générer (JavaScript/TypeScript)
- **Génère** : Le client Prisma dans `node_modules/@prisma/client`
- **Commande** : `npx prisma generate` pour régénérer

#### Datasource (Source de données)

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

**Explication** :
- **provider** : Type de base de données (postgresql, mysql, sqlite, etc.)
- **url** : Chaîne de connexion depuis la variable d'environnement
- **Sécurité** : Les credentials sont dans `.env`, pas dans le code

### Section 2 : Énumérations (Enums)

Les énumérations définissent des valeurs fixes possibles pour certains champs.

#### Enum Role

```prisma
enum Role {
  USER   // Utilisateur normal (peut acheter et vendre)
  ADMIN  // Administrateur (gestion complète)
}
```

**Usage dans le modèle** :
```prisma
model User {
  role Role @default(USER)  // Par défaut, nouvel utilisateur = USER
}
```

**Usage dans le code TypeScript** :
```typescript
import { Role } from '@prisma/client'

// Créer un admin
const admin = await prisma.user.create({
  data: {
    email: "admin@photomarket.com",
    role: Role.ADMIN  // Type-safe !
  }
})

// Filtrer par rôle
const admins = await prisma.user.findMany({
  where: { role: Role.ADMIN }
})
```

#### Enum PhotoStatus

```prisma
enum PhotoStatus {
  DRAFT     // Photo en brouillon (pas visible publiquement)
  PUBLISHED // Photo publiée (visible et achetable)
  SOLD      // Photo vendue (plus disponible)
  ARCHIVED  // Photo archivée (retirée de la vente)
}
```

**Workflow typique** :
1. **DRAFT** → Photo uploadée mais pas encore publiée
2. **PUBLISHED** → Photo mise en vente publiquement
3. **SOLD** → Photo achetée par un utilisateur
4. **ARCHIVED** → Photo retirée de la vente par le propriétaire

## Diagramme des relations Prisma

Le diagramme ci-dessus montre tous les types de relations dans notre schéma PhotoMarket et comment ils s'articulent.

## Types de relations en détail

### 1. Relation Un vers Un (1:1)

**Définition** : Chaque enregistrement de la table A correspond à exactement un enregistrement de la table B.

**Exemple conceptuel** (pas dans notre schéma actuel) :
```prisma
model User {
  id      String   @id @default(cuid())
  profile Profile?  // Un utilisateur peut avoir un profil (optionnel)
}

model Profile {
  id     String @id @default(cuid())
  bio    String
  userId String @unique  // UNIQUE = relation 1:1
  user   User   @relation(fields: [userId], references: [id])
}
```

**Caractéristiques** :
- Clé étrangère avec contrainte `@unique`
- Relation souvent optionnelle (`Profile?`)
- Utilisée pour séparer des données rares ou volumineuses

### 2. Relation Un vers Plusieurs (1:N) - LA PLUS COURANTE

**Définition** : Un enregistrement de la table A peut avoir plusieurs enregistrements dans la table B.

#### Exemple 1 : User → Photo

```prisma
model User {
  id     String  @id @default(cuid())
  email  String  @unique
  photos Photo[] // Un utilisateur a PLUSIEURS photos
}

model Photo {
  id     String @id @default(cuid())
  title  String
  userId String // Clé étrangère vers User
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  //                       ↑ champ local    ↑ champ référencé
}
```

**Explications** :
- **`photos Photo[]`** : Côté "un", array de photos
- **`userId String`** : Côté "plusieurs", clé étrangère
- **`@relation(fields: [userId], references: [id])`** : Définit la relation
- **`onDelete: Cascade`** : Si User supprimé → toutes ses photos supprimées

**Requêtes typiques** :
```typescript
// Utilisateur avec ses photos
const userWithPhotos = await prisma.user.findUnique({
  where: { email: "alice@example.com" },
  include: { photos: true }  // Inclure les photos
})

// Photo avec son propriétaire
const photoWithOwner = await prisma.photo.findUnique({
  where: { id: "photo123" },
  include: { user: true }    // Inclure le propriétaire
})

// Compter les photos par utilisateur
const usersWithPhotoCount = await prisma.user.findMany({
  include: {
    _count: {
      select: { photos: true }
    }
  }
})
```

#### Exemple 2 : User → Purchase

```prisma
model User {
  id        String     @id @default(cuid())
  purchases Purchase[] // Un utilisateur a PLUSIEURS achats
}

model Purchase {
  id     String @id @default(cuid())
  amount Float
  userId String // Clé étrangère vers User (acheteur)
  user   User   @relation(fields: [userId], references: [id])
}
```

### 3. Relation Plusieurs vers Plusieurs (N:N) via table intermédiaire

**Notre approche** : Plutôt qu'une vraie relation N:N, nous utilisons une table intermédiaire explicite.

#### Photo ↔ Purchase (via table Purchase)

```prisma
model Photo {
  id        String     @id @default(cuid())
  title     String
  purchases Purchase[] // Une photo peut être achetée plusieurs fois
}

model Purchase {
  id      String @id @default(cuid())
  userId  String // Acheteur
  photoId String // Photo achetée
  
  user    User   @relation(fields: [userId], references: [id])
  photo   Photo  @relation(fields: [photoId], references: [id])
}

model User {
  id        String     @id @default(cuid())
  purchases Purchase[] // Achats de cet utilisateur
}
```

**Avantages de cette approche** :
- **Métadonnées** : On peut stocker `amount`, `createdAt`, `stripeSessionId`
- **Flexibilité** : Un user peut acheter la même photo plusieurs fois
- **Auditabilité** : Historique complet des transactions

**Requêtes complexes** :
```typescript
// Qui a acheté les photos d'Alice ?
const alicePhotosBuyers = await prisma.user.findUnique({
  where: { email: "alice@example.com" },
  include: {
    photos: {
      include: {
        purchases: {
          include: {
            user: true  // Les acheteurs
          }
        }
      }
    }
  }
})

// Photos achetées par Bob
const bobPurchases = await prisma.user.findUnique({
  where: { email: "bob@example.com" },
  include: {
    purchases: {
      include: {
        photo: {
          include: {
            user: true  // Les vendeurs
          }
        }
      }
    }
  }
})
```

## Modèles de données détaillés

### Modèle User (Utilisateur)

```prisma
model User {
  id            String    @id @default(cuid())
  email         String    @unique
  password      String
  name          String?   // Optionnel
  role          Role      @default(USER)
  emailVerified DateTime? // Optionnel, pour NextAuth
  image         String?   // Avatar URL
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  // Relations 1:N
  photos        Photo[]     // Photos vendues par l'utilisateur
  purchases     Purchase[]  // Achats effectués par l'utilisateur
  accounts      Account[]   // Comptes OAuth (Google, GitHub...)
  sessions      Session[]   // Sessions de connexion actives

  @@map("users")  // Nom de table en base
}
```

**Champs expliqués** :
- **`@id @default(cuid())`** : Clé primaire auto-générée
- **`@unique`** : Contrainte d'unicité sur l'email
- **`@default(USER)`** : Valeur par défaut pour le rôle
- **`@default(now())`** : Timestamp automatique à la création
- **`@updatedAt`** : Timestamp automatique à chaque modification
- **`@@map("users")`** : Table s'appelle "users" en base (pluriel)

### Modèle Photo

```prisma
model Photo {
  id          String      @id @default(cuid())
  title       String
  description String?     // Description optionnelle
  imageUrl    String      // URL de l'image stockée (Cloudinary, S3...)
  price       Float       // Prix en euros
  status      PhotoStatus @default(DRAFT)
  tags        String[]    // Array de tags pour la recherche
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt

  // Relations
  userId      String      // Clé étrangère vers User
  user        User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  purchases   Purchase[]  // Achats de cette photo

  @@map("photos")
}
```

**Champs spéciaux** :
- **`String[]`** : Array PostgreSQL pour les tags
- **`Float`** : Nombres décimaux pour les prix
- **`onDelete: Cascade`** : Suppression en cascade

### Modèle Purchase (Transaction)

```prisma
model Purchase {
  id                String   @id @default(cuid())
  stripeSessionId   String   @unique  // ID de session Stripe
  stripePaymentId   String?  // ID du paiement confirmé
  amount            Float    // Montant payé
  currency          String   @default("eur")
  status            String   // "pending", "completed", "failed"
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  // Relations
  userId            String   // Acheteur
  user              User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  photoId           String   // Photo achetée
  photo             Photo    @relation(fields: [photoId], references: [id], onDelete: Cascade)

  @@map("purchases")
}
```

**Champs Stripe** :
- **`stripeSessionId`** : Pour suivre la session de paiement
- **`stripePaymentId`** : ID du paiement confirmé (webhook)
- **`status`** : État de la transaction

## Commandes Prisma essentielles

### Commandes de développement local

#### Gestion du schéma

```bash
# Valider la syntaxe du schéma
npx prisma validate

# Formater le fichier schema.prisma
npx prisma format

# Générer le client TypeScript
npx prisma generate

# Pousser le schéma vers la DB (développement)
npx prisma db push

# Voir les changements qui seraient appliqués
npx prisma db push --preview-feature
```

#### Gestion des données

```bash
# Interface graphique pour visualiser/éditer les données
npx prisma studio

# Réinitialiser la base de données
npx prisma db push --force-reset

# Importer des données depuis la DB vers le schéma
npx prisma db pull
```

#### Requêtes et tests

```bash
# Console interactive Prisma
npx prisma studio

# Exécuter un script de test
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
// Vos requêtes ici
prisma.\$disconnect();
"
```

### Commandes pour production

#### Migrations

```bash
# Créer une migration
npx prisma migrate dev --name add_photo_tags

# Appliquer les migrations en production
npx prisma migrate deploy

# Voir l'état des migrations
npx prisma migrate status

# Réinitialiser les migrations (DANGER)
npx prisma migrate reset
```

#### Déploiement

```bash
# Générer le client pour production
npx prisma generate

# Appliquer migrations + générer client
npx prisma migrate deploy && npx prisma generate

# Script de déploiement typique
npm run build
npx prisma migrate deploy
npx prisma generate
npm start
```

### Commandes cloud (Neon, Railway, PlanetScale...)

#### Avec Neon PostgreSQL

```bash
# Connexion directe à Neon
npx prisma db push  # Utilise DATABASE_URL du .env

# Backup de la base Neon
pg_dump $DATABASE_URL > backup.sql

# Restaurer un backup
psql $DATABASE_URL < backup.sql

# Voir les tables créées
npx prisma db pull --preview-feature
```

#### Variables d'environnement pour différents environnements

```bash
# Développement local
DATABASE_URL="postgresql://user:pass@localhost:5432/photomarket_dev"

# Staging
DATABASE_URL="postgresql://user:pass@staging.neon.tech/photomarket_staging"

# Production
DATABASE_URL="postgresql://user:pass@production.neon.tech/photomarket_prod"
```

## Requêtes Prisma avancées pour PhotoMarket

### Requêtes de base

```typescript
import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()

// Créer un utilisateur
const newUser = await prisma.user.create({
  data: {
    email: "alice@example.com",
    password: "hashedPassword",
    name: "Alice Dupont"
  }
})

// Trouver un utilisateur par email
const user = await prisma.user.findUnique({
  where: { email: "alice@example.com" }
})

// Tous les utilisateurs
const allUsers = await prisma.user.findMany()

// Utilisateurs avec condition
const admins = await prisma.user.findMany({
  where: { role: "ADMIN" }
})
```

### Requêtes avec relations

```typescript
// Utilisateur avec ses photos
const userWithPhotos = await prisma.user.findUnique({
  where: { email: "alice@example.com" },
  include: {
    photos: true,
    _count: {
      select: {
        photos: true,
        purchases: true
      }
    }
  }
})

// Photos publiées avec propriétaire
const publicPhotos = await prisma.photo.findMany({
  where: { status: "PUBLISHED" },
  include: {
    user: {
      select: {
        name: true,
        email: true
      }
    }
  },
  orderBy: { createdAt: "desc" }
})

// Achats avec détails complets
const purchases = await prisma.purchase.findMany({
  include: {
    user: true,   // Acheteur
    photo: {      // Photo achetée
      include: {
        user: true  // Vendeur
      }
    }
  }
})
```

### Requêtes métier PhotoMarket

```typescript
// Dashboard vendeur : revenus et statistiques
async function getSellerDashboard(userId: string) {
  const seller = await prisma.user.findUnique({
    where: { id: userId },
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

  // Revenus total
  const earnings = await prisma.purchase.aggregate({
    where: {
      photo: { userId: userId }
    },
    _sum: { amount: true },
    _count: true
  })

  return {
    seller,
    totalEarnings: earnings._sum.amount || 0,
    totalSales: earnings._count,
    photos: seller.photos
  }
}

// Galerie publique avec filtres
async function getPublicGallery(filters?: {
  search?: string
  minPrice?: number
  maxPrice?: number
  tags?: string[]
}) {
  return await prisma.photo.findMany({
    where: {
      status: "PUBLISHED",
      ...(filters?.search && {
        OR: [
          { title: { contains: filters.search, mode: "insensitive" } },
          { description: { contains: filters.search, mode: "insensitive" } }
        ]
      }),
      ...(filters?.minPrice && { price: { gte: filters.minPrice } }),
      ...(filters?.maxPrice && { price: { lte: filters.maxPrice } }),
      ...(filters?.tags && { tags: { hasSome: filters.tags } })
    },
    include: {
      user: {
        select: { name: true, image: true }
      },
      _count: {
        select: { purchases: true }
      }
    },
    orderBy: { createdAt: "desc" }
  })
}

// Historique d'achats utilisateur
async function getUserPurchaseHistory(userId: string) {
  return await prisma.purchase.findMany({
    where: { userId },
    include: {
      photo: {
        include: {
          user: {
            select: { name: true }
          }
        }
      }
    },
    orderBy: { createdAt: "desc" }
  })
}

// Top vendeurs
async function getTopSellers(limit = 10) {
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

  return topSellers
    .map(user => ({
      ...user,
      totalSales: user.photos.reduce((sum, photo) => sum + photo._count.purchases, 0)
    }))
    .filter(user => user.totalSales > 0)
    .sort((a, b) => b.totalSales - a.totalSales)
    .slice(0, limit)
}
```

### Transactions et opérations atomiques

```typescript
// Achat d'une photo (transaction atomique)
async function purchasePhoto(userId: string, photoId: string, stripeSessionId: string, amount: number) {
  return await prisma.$transaction(async (tx) => {
    // Vérifier que la photo est disponible
    const photo = await tx.photo.findUnique({
      where: { id: photoId },
      include: { user: true }
    })

    if (!photo || photo.status !== "PUBLISHED") {
      throw new Error("Photo non disponible")
    }

    if (photo.userId === userId) {
      throw new Error("Vous ne pouvez pas acheter votre propre photo")
    }

    // Créer l'achat
    const purchase = await tx.purchase.create({
      data: {
        userId,
        photoId,
        stripeSessionId,
        amount,
        status: "completed"
      }
    })

    // Marquer la photo comme vendue (optionnel selon business logic)
    await tx.photo.update({
      where: { id: photoId },
      data: { status: "SOLD" }
    })

    return purchase
  })
}
```

## Optimisations et performances

### Index recommandés

```prisma
model Photo {
  // ... autres champs
  
  // Index composé pour les requêtes de galerie
  @@index([status, createdAt])
  // Index pour les recherches par prix
  @@index([price])
  // Index pour les recherches par tags
  @@index([tags])
}

model Purchase {
  // ... autres champs
  
  // Index pour l'historique par utilisateur
  @@index([userId, createdAt])
  // Index pour les statistiques par photo
  @@index([photoId, createdAt])
}
```

### Requêtes optimisées

```typescript
// ❌ Lent : charge toutes les données
const users = await prisma.user.findMany({
  include: {
    photos: true,
    purchases: true
  }
})

// ✅ Rapide : seulement les données nécessaires
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

// ✅ Pagination pour de gros datasets
const photos = await prisma.photo.findMany({
  where: { status: "PUBLISHED" },
  take: 20,      // Limite
  skip: page * 20, // Offset
  orderBy: { createdAt: "desc" }
})
```

## Prochaines étapes

Une fois cette étape maîtrisée, vous pourrez passer à l'**Étape 4 : Configuration NextAuth.js** en utilisant les modèles User, Account et Session que nous avons définis.