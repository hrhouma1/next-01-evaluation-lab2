# Étape 3 : Comprendre le schéma Prisma et les relations

## Phase 1 - Analyse du schéma de base de données

### RAPPEL : Objectif du projet PhotoMarket

Nous développons une **application web complète de galerie de photos** permettant à des utilisateurs de :

- **Vendre leurs photos** : Upload, description, prix
- **Acheter des photos** d'autres utilisateurs via Stripe
- **Gérer leur galerie personnelle** avec authentification sécurisée
- **Administrer le système** (rôles utilisateur/admin)

### Progression du projet

**ETAPE 1 TERMINEE** : Configuration Next.js + TypeScript + Tailwind CSS 3  
**ETAPE 2 TERMINEE** : Configuration Prisma + Neon PostgreSQL + Schéma complet  
**ETAPE 3 EN COURS** : Comprendre les relations et la structure des données  
**ETAPES RESTANTES** : 25+ étapes jusqu'au projet complet

### Objectif de cette étape

**Comprendre en profondeur** le schéma Prisma que nous avons créé dans l'étape 2 :

- **Types de relations** : 1 vers 1, 1 vers plusieurs, plusieurs vers plusieurs
- **Clés étrangères** et contraintes d'intégrité
- **Modèles métier** spécifiques à PhotoMarket
- **Relations NextAuth.js** pour l'authentification
- **Structure de données** optimisée pour les performances

## Comprendre les relations de base de données

### Les 3 types de relations

#### 1. Relation **Un vers Un (1:1)**

**Définition** : Chaque enregistrement dans la table A est lié à exactement un enregistrement dans la table B.

**Exemple** : Un utilisateur a un seul profil, un profil appartient à un seul utilisateur.

```prisma
model User {
  id      String   @id
  profile Profile?
}

model Profile {
  id     String @id  
  userId String @unique
  user   User   @relation(fields: [userId], references: [id])
}
```

#### 2. Relation **Un vers Plusieurs (1:N)**

**Définition** : Un enregistrement dans la table A peut être lié à plusieurs enregistrements dans la table B.

**Exemple** : Un utilisateur peut avoir plusieurs photos, mais chaque photo appartient à un seul utilisateur.

```prisma
model User {
  id     String  @id
  photos Photo[] // Un utilisateur a PLUSIEURS photos
}

model Photo {
  id     String @id
  userId String
  user   User   @relation(fields: [userId], references: [id]) // Une photo appartient à UN utilisateur
}
```

#### 3. Relation **Plusieurs vers Plusieurs (N:N)**

**Définition** : Un enregistrement dans la table A peut être lié à plusieurs enregistrements dans la table B, et vice versa.

**Exemple** : Un utilisateur peut acheter plusieurs photos, et une photo peut être achetée par plusieurs utilisateurs.

```prisma
model User {
  id        String     @id
  purchases Purchase[] // Un utilisateur peut avoir PLUSIEURS achats
}

model Photo {
  id        String     @id
  purchases Purchase[] // Une photo peut avoir PLUSIEURS achats
}

// Table de liaison pour la relation N:N
model Purchase {
  id      String @id
  userId  String
  photoId String
  user    User   @relation(fields: [userId], references: [id])
  photo   Photo  @relation(fields: [photoId], references: [id])
}
```

## Diagramme du schéma PhotoMarket

Le diagramme ci-dessus montre toutes les tables et leurs relations dans notre application PhotoMarket.

### Légende du diagramme

- **PK** = Clé primaire (Primary Key)
- **FK** = Clé étrangère (Foreign Key)  
- **UK** = Contrainte unique (Unique Key)
- **||--o{** = Relation un vers plusieurs (1:N)
- **||--||** = Relation un vers un (1:1)

## Analyse détaillée des relations PhotoMarket

### 1. Relation User ↔ Photo (1:N)

**Type** : Un vers Plusieurs  
**Description** : Un utilisateur peut posséder plusieurs photos, mais chaque photo appartient à un seul utilisateur.

```prisma
model User {
  id     String  @id @default(cuid())
  photos Photo[] // Un utilisateur peut avoir PLUSIEURS photos
}

model Photo {
  id     String @id @default(cuid())
  userId String // Clé étrangère vers User
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

**Règles métier** :
- ✅ Un utilisateur peut uploader autant de photos qu'il veut
- ✅ Si un utilisateur est supprimé, toutes ses photos sont supprimées (`onDelete: Cascade`)
- ✅ Une photo ne peut pas exister sans propriétaire

**Exemples concrets** :
```javascript
// Alice a uploadé 3 photos
const alice = await prisma.user.findUnique({
  where: { email: "alice@example.com" },
  include: { photos: true }
})
// alice.photos = [photo1, photo2, photo3]

// Cette photo appartient à Alice
const photo = await prisma.photo.findUnique({
  where: { id: "photo123" },
  include: { user: true }
})
// photo.user = { id: "alice123", name: "Alice", ... }
```

### 2. Relation User ↔ Purchase (1:N)

**Type** : Un vers Plusieurs  
**Description** : Un utilisateur peut effectuer plusieurs achats, mais chaque achat est effectué par un seul utilisateur.

```prisma
model User {
  id        String     @id @default(cuid())
  purchases Purchase[] // Un utilisateur peut avoir PLUSIEURS achats
}

model Purchase {
  id     String @id @default(cuid())
  userId String // Clé étrangère vers User (acheteur)
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

**Règles métier** :
- ✅ Un utilisateur peut acheter autant de photos qu'il veut
- ✅ Si un utilisateur est supprimé, ses achats sont supprimés
- ✅ Un achat ne peut pas exister sans acheteur

### 3. Relation Photo ↔ Purchase (1:N)

**Type** : Un vers Plusieurs  
**Description** : Une photo peut être achetée plusieurs fois, mais chaque achat concerne une seule photo.

```prisma
model Photo {
  id        String     @id @default(cuid())
  purchases Purchase[] // Une photo peut être achetée PLUSIEURS fois
}

model Purchase {
  id      String @id @default(cuid())
  photoId String // Clé étrangère vers Photo
  photo   Photo  @relation(fields: [photoId], references: [id], onDelete: Cascade)
}
```

**Règles métier** :
- ✅ Une photo peut être vendue à plusieurs acheteurs
- ✅ Si une photo est supprimée, tous ses achats sont supprimés
- ✅ Un achat ne peut pas exister sans photo

**Note importante** : Notre modèle permet à la même photo d'être achetée plusieurs fois par différents utilisateurs (ou même le même utilisateur). Si vous voulez limiter à un achat par utilisateur par photo, vous devriez ajouter une contrainte unique :

```prisma
model Purchase {
  // ... autres champs
  userId  String
  photoId String
  
  @@unique([userId, photoId]) // Un utilisateur ne peut acheter la même photo qu'une fois
}
```

### 4. Relations NextAuth.js

#### User ↔ Account (1:N)

**Description** : Un utilisateur peut avoir plusieurs comptes de connexion (Google, GitHub, email, etc.).

```prisma
model User {
  id       String    @id @default(cuid())
  accounts Account[] // Un utilisateur peut avoir PLUSIEURS comptes OAuth
}

model Account {
  id       String @id @default(cuid())
  userId   String // Clé étrangère vers User
  provider String // "google", "github", "credentials"
  user     User   @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

**Exemples** :
- Alice peut se connecter avec Google ET GitHub
- Bob peut avoir un compte email ET un compte Google

#### User ↔ Session (1:N)

**Description** : Un utilisateur peut avoir plusieurs sessions actives (mobile, desktop, etc.).

```prisma
model User {
  id       String    @id @default(cuid())
  sessions Session[] // Un utilisateur peut avoir PLUSIEURS sessions
}

model Session {
  id           String @id @default(cuid())
  sessionToken String @unique
  userId       String // Clé étrangère vers User
  user         User   @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

## Relations complexes dans notre schéma

### Relation User → Photo → Purchase (Chaîne de relations)

Cette chaîne de relations permet de répondre à des questions complexes :

```javascript
// Qui a acheté les photos d'Alice ?
const alicePhotoBuyers = await prisma.user.findUnique({
  where: { email: "alice@example.com" },
  include: {
    photos: {
      include: {
        purchases: {
          include: {
            user: true // Les acheteurs
          }
        }
      }
    }
  }
})

// Combien Alice a-t-elle gagné avec ses photos ?
const aliceEarnings = await prisma.purchase.aggregate({
  where: {
    photo: {
      userId: "alice-id"
    }
  },
  _sum: {
    amount: true
  }
})
```

### Relation circulaire : User peut être vendeur ET acheteur

Dans notre modèle, un utilisateur peut être :
- **Vendeur** : via la relation `User → Photo`
- **Acheteur** : via la relation `User → Purchase`

```javascript
// Bob vend ses photos ET achète des photos d'autres utilisateurs
const bob = await prisma.user.findUnique({
  where: { email: "bob@example.com" },
  include: {
    photos: true,     // Photos que Bob vend
    purchases: {      // Photos que Bob a achetées
      include: {
        photo: {
          include: {
            user: true // Les vendeurs dont Bob a acheté des photos
          }
        }
      }
    }
  }
})
```

## Contraintes d'intégrité et règles métier

### Contraintes Prisma automatiques

1. **Clés primaires** : Chaque modèle a un `id` unique
2. **Clés étrangères** : Les relations sont automatiquement validées
3. **Contraintes unique** : `email`, `sessionToken`, `stripeSessionId`
4. **Cascade delete** : Suppression en cascade configurée

### Contraintes métier à valider côté application

```typescript
// Exemple : Un utilisateur ne peut pas acheter sa propre photo
async function validatePurchase(userId: string, photoId: string) {
  const photo = await prisma.photo.findUnique({
    where: { id: photoId }
  })
  
  if (photo?.userId === userId) {
    throw new Error("Vous ne pouvez pas acheter votre propre photo")
  }
}

// Exemple : Une photo doit être PUBLISHED pour être achetée
async function validatePhotoStatus(photoId: string) {
  const photo = await prisma.photo.findUnique({
    where: { id: photoId }
  })
  
  if (photo?.status !== "PUBLISHED") {
    throw new Error("Cette photo n'est pas disponible à l'achat")
  }
}
```

## Requêtes typiques pour PhotoMarket

### Afficher la galerie publique

```typescript
// Toutes les photos disponibles à l'achat
const publicPhotos = await prisma.photo.findMany({
  where: {
    status: "PUBLISHED"
  },
  include: {
    user: {
      select: {
        name: true,
        image: true
      }
    },
    _count: {
      select: {
        purchases: true // Nombre d'achats
      }
    }
  },
  orderBy: {
    createdAt: "desc"
  }
})
```

### Dashboard vendeur

```typescript
// Statistiques pour un vendeur
const sellerStats = await prisma.user.findUnique({
  where: { id: sellerId },
  include: {
    photos: {
      include: {
        _count: {
          select: {
            purchases: true
          }
        }
      }
    },
    _count: {
      select: {
        photos: true
      }
    }
  }
})

// Revenus total du vendeur
const totalEarnings = await prisma.purchase.aggregate({
  where: {
    photo: {
      userId: sellerId
    }
  },
  _sum: {
    amount: true
  }
})
```

### Historique d'achats utilisateur

```typescript
// Historique des achats d'un utilisateur
const purchaseHistory = await prisma.purchase.findMany({
  where: {
    userId: buyerId
  },
  include: {
    photo: {
      include: {
        user: {
          select: {
            name: true
          }
        }
      }
    }
  },
  orderBy: {
    createdAt: "desc"
  }
})
```

## Optimisations et index

### Index automatiques Prisma

Prisma crée automatiquement des index pour :
- Toutes les clés primaires (`@id`)
- Toutes les contraintes uniques (`@unique`)
- Toutes les clés étrangères (relations)

### Index supplémentaires recommandés

```prisma
model Photo {
  // ... autres champs
  status    PhotoStatus @default(DRAFT)
  createdAt DateTime    @default(now())
  price     Float
  
  // Index composé pour les requêtes de galerie
  @@index([status, createdAt])
  // Index pour les recherches par prix
  @@index([price])
}

model Purchase {
  // ... autres champs
  createdAt DateTime @default(now())
  
  // Index pour l'historique des achats
  @@index([userId, createdAt])
  // Index pour les statistiques vendeur
  @@index([photoId, createdAt])
}
```

## Prochaines étapes

Une fois que vous comprenez parfaitement ce schéma et ses relations, vous pourrez passer à :

**Étape 4** : Configuration de NextAuth.js pour l'authentification avec nos modèles User, Account et Session.

Cette compréhension est cruciale car elle détermine comment nous structurerons nos API routes et nos composants React dans les étapes suivantes.
