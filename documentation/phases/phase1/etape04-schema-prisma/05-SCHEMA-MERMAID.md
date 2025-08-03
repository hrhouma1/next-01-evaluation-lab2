# Étape 4 : Diagramme Mermaid du schéma PhotoMarket

## Diagramme ERD complet du schéma Prisma

Le diagramme ci-dessous représente l'ensemble du schéma de base de données de l'application PhotoMarket avec toutes les relations et contraintes.

```mermaid
erDiagram
    User {
        string id PK "Identifiant unique"
        string email UK "Email (unique)"
        string password "Mot de passe hashé"
        string name "Nom complet"
        Role role "USER ou ADMIN"
        datetime emailVerified "Email vérifié"
        string image "Avatar URL"
        datetime createdAt "Date création"
        datetime updatedAt "Date modification"
    }
    
    Photo {
        string id PK "Identifiant unique"
        string title "Titre de la photo"
        string description "Description"
        string imageUrl "URL de l'image"
        float price "Prix en euros"
        PhotoStatus status "DRAFT, PUBLISHED, SOLD, ARCHIVED"
        string[] tags "Tags de recherche"
        string userId FK "Propriétaire"
        datetime createdAt "Date création"
        datetime updatedAt "Date modification"
    }
    
    Purchase {
        string id PK "Identifiant unique"
        string stripeSessionId UK "ID session Stripe"
        string stripePaymentId "ID paiement Stripe"
        float amount "Montant payé"
        string currency "Devise (EUR)"
        string status "pending, completed, failed"
        string userId FK "Acheteur"
        string photoId FK "Photo achetée"
        datetime createdAt "Date achat"
        datetime updatedAt "Date modification"
    }
    
    Account {
        string id PK "Identifiant unique"
        string userId FK "Utilisateur lié"
        string type "oauth, email"
        string provider "google, github"
        string providerAccountId "ID compte provider"
        string refresh_token "Token rafraîchissement"
        string access_token "Token d'accès"
        int expires_at "Expiration token"
        string token_type "Type de token"
        string scope "Portée des permissions"
        string id_token "Token d'identité"
        string session_state "État de session"
    }
    
    Session {
        string id PK "Identifiant unique"
        string sessionToken UK "Token de session"
        string userId FK "Utilisateur connecté"
        datetime expires "Date d'expiration"
    }
    
    VerificationToken {
        string identifier "Email ou phone"
        string token UK "Token de vérification"
        datetime expires "Date d'expiration"
    }

    %% Relations principales
    User ||--o{ Photo : "possède (1:N)"
    User ||--o{ Purchase : "effectue (1:N)"
    Photo ||--o{ Purchase : "est achetée (1:N)"
    
    %% Relations NextAuth.js
    User ||--o{ Account : "authentification (1:N)"
    User ||--o{ Session : "sessions actives (1:N)"
    
    %% Énumérations
    Role {
        USER "Utilisateur standard"
        ADMIN "Administrateur"
    }
    
    PhotoStatus {
        DRAFT "Brouillon"
        PUBLISHED "Publié"
        SOLD "Vendu"
        ARCHIVED "Archivé"
    }
```

## Légende du diagramme

### Symboles et notations

| Symbole | Signification |
|---------|---------------|
| **PK** | Clé primaire (Primary Key) |
| **FK** | Clé étrangère (Foreign Key) |
| **UK** | Contrainte unique (Unique Key) |
| **\|\|--o{** | Relation un vers plusieurs (1:N) |
| **\|\|--\|\|** | Relation un vers un (1:1) |

### Types de données

| Type | Description | Exemple |
|------|-------------|---------|
| `string` | Chaîne de caractères | "alice@example.com" |
| `float` | Nombre décimal | 25.99 |
| `int` | Nombre entier | 3600 |
| `datetime` | Date et heure | 2024-01-15 14:30:00 |
| `string[]` | Tableau de chaînes | ["nature", "sunset", "beach"] |
| `Role` | Énumération | USER ou ADMIN |
| `PhotoStatus` | Énumération | DRAFT, PUBLISHED, SOLD, ARCHIVED |

## Relations détaillées

### 1. User → Photo (1:N)
- **Description** : Un utilisateur peut posséder plusieurs photos
- **Clé étrangère** : `Photo.userId` → `User.id`
- **Contrainte** : `onDelete: Cascade` (si user supprimé → photos supprimées)
- **Usage** : Galerie personnelle, revenus vendeur

### 2. User → Purchase (1:N)
- **Description** : Un utilisateur peut effectuer plusieurs achats
- **Clé étrangère** : `Purchase.userId` → `User.id`
- **Contrainte** : `onDelete: Cascade`
- **Usage** : Historique d'achats, statistiques acheteur

### 3. Photo → Purchase (1:N)
- **Description** : Une photo peut être achetée plusieurs fois
- **Clé étrangère** : `Purchase.photoId` → `Photo.id`
- **Contrainte** : `onDelete: Cascade`
- **Usage** : Statistiques de vente, popularité des photos

### 4. User → Account (1:N) - NextAuth.js
- **Description** : Un utilisateur peut avoir plusieurs comptes de connexion
- **Clé étrangère** : `Account.userId` → `User.id`
- **Usage** : OAuth Google, GitHub, connexion email

### 5. User → Session (1:N) - NextAuth.js
- **Description** : Un utilisateur peut avoir plusieurs sessions actives
- **Clé étrangère** : `Session.userId` → `User.id`
- **Usage** : Connexion simultanée sur plusieurs appareils

## Diagramme des flux métier

```mermaid
graph TD
    A[Utilisateur s'inscrit] --> B[Compte User créé]
    B --> C[Session créée]
    C --> D[Upload de photos]
    D --> E[Photo en statut DRAFT]
    E --> F[Publication - statut PUBLISHED]
    F --> G[Autre utilisateur voit la galerie]
    G --> H[Achat de la photo]
    H --> I[Purchase créé]
    I --> J[Photo en statut SOLD]
    J --> K[Revenus pour le vendeur]
    
    %% OAuth Flow
    A --> L[Connexion OAuth Google/GitHub]
    L --> M[Account créé]
    M --> B
    
    %% Admin Flow
    B --> N{Rôle USER ou ADMIN?}
    N -->|ADMIN| O[Accès administration]
    N -->|USER| P[Accès utilisateur standard]
    
    style A fill:#e1f5fe
    style I fill:#e8f5e8
    style O fill:#fff3e0
```

## Requêtes typiques basées sur le schéma

### 1. Dashboard vendeur
```sql
-- Revenus total d'un vendeur
SELECT 
  u.name,
  COUNT(ph.id) as total_photos,
  SUM(pu.amount) as total_revenus
FROM users u
LEFT JOIN photos ph ON ph.userId = u.id
LEFT JOIN purchases pu ON pu.photoId = ph.id
WHERE u.id = 'user-id'
GROUP BY u.id, u.name
```

### 2. Galerie publique
```sql
-- Photos disponibles à l'achat
SELECT 
  ph.id,
  ph.title,
  ph.price,
  ph.tags,
  u.name as vendor_name,
  COUNT(pu.id) as sales_count
FROM photos ph
JOIN users u ON u.id = ph.userId
LEFT JOIN purchases pu ON pu.photoId = ph.id
WHERE ph.status = 'PUBLISHED'
GROUP BY ph.id, ph.title, ph.price, ph.tags, u.name
ORDER BY ph.createdAt DESC
```

### 3. Historique d'achats
```sql
-- Achats d'un utilisateur
SELECT 
  pu.id,
  pu.amount,
  pu.createdAt,
  ph.title,
  ph.imageUrl,
  vendor.name as vendor_name
FROM purchases pu
JOIN photos ph ON ph.id = pu.photoId
JOIN users vendor ON vendor.id = ph.userId
WHERE pu.userId = 'buyer-id'
ORDER BY pu.createdAt DESC
```

## Contraintes et validations métier

### Contraintes automatiques (Prisma)
1. **Clés primaires** : Uniques et non nulles
2. **Clés étrangères** : Références valides obligatoires
3. **Contraintes uniques** : email, sessionToken, stripeSessionId
4. **Types de données** : Validation automatique

### Contraintes métier à implémenter
1. **Auto-achat interdit** : Un user ne peut pas acheter sa propre photo
2. **Photos DRAFT** : Non visibles dans la galerie publique
3. **Sessions expirées** : Nettoyage automatique
4. **Prix positifs** : Photos avec prix > 0

## Optimisations recommandées

### Index additionnels
```prisma
model Photo {
  // Index composé pour galerie
  @@index([status, createdAt])
  @@index([userId, status])
  @@index([price])
}

model Purchase {
  // Index pour historiques
  @@index([userId, createdAt])
  @@index([photoId, createdAt])
}
```

### Vues matérialisées suggérées
1. **seller_stats** : Statistiques pré-calculées par vendeur
2. **popular_photos** : Photos les plus achetées
3. **monthly_revenue** : Revenus mensuels

## Architecture de sécurité

```mermaid
graph LR
    A[Client Next.js] --> B[NextAuth.js Middleware]
    B --> C{Session valide?}
    C -->|Oui| D[API Routes protégées]
    C -->|Non| E[Redirection login]
    D --> F[Prisma Client]
    F --> G[Neon PostgreSQL]
    
    H[OAuth Providers] --> I[Account table]
    I --> J[User table]
    J --> K[Session table]
    
    style C fill:#fff3e0
    style F fill:#e8f5e8
    style G fill:#e1f5fe
```

Ce diagramme Mermaid et cette documentation complètent parfaitement l'analyse du schéma Prisma pour l'étape 4 !