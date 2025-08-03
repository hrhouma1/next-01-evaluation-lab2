# Étape 3 : Checklist - Configuration et maîtrise Prisma

## Checklist de compréhension théorique

### Concepts fondamentaux Prisma

- [ ] **Structure du fichier schema.prisma comprise**
  - [ ] Section `generator client` expliquée
  - [ ] Section `datasource db` expliquée
  - [ ] Énumérations (enums) `Role` et `PhotoStatus` comprises
  - [ ] Décorateurs Prisma (`@id`, `@unique`, `@default`, etc.) maîtrisés

- [ ] **Types de relations maîtrisés**
  - [ ] Relation 1:1 (Un vers Un) théorie comprise
  - [ ] Relation 1:N (Un vers Plusieurs) théorie et exemples compris
  - [ ] Relation N:N via table intermédiaire comprise
  - [ ] Différence entre `include` et `select` comprise

- [ ] **Modèles PhotoMarket analysés**
  - [ ] Modèle `User` et tous ses champs compris
  - [ ] Modèle `Photo` avec statuts et tags compris
  - [ ] Modèle `Purchase` comme table de liaison compris
  - [ ] Modèles NextAuth (`Account`, `Session`, `VerificationToken`) compris

### Relations spécifiques PhotoMarket

- [ ] **User → Photo (1:N)**
  - [ ] Un utilisateur peut avoir plusieurs photos
  - [ ] Une photo appartient à un seul utilisateur
  - [ ] Suppression en cascade (`onDelete: Cascade`) comprise
  - [ ] Requêtes avec `include: { photos: true }` testées

- [ ] **User → Purchase (1:N)**
  - [ ] Un utilisateur peut effectuer plusieurs achats
  - [ ] Un achat est effectué par un seul utilisateur
  - [ ] Historique des achats consultable

- [ ] **Photo → Purchase (1:N)**
  - [ ] Une photo peut être achetée plusieurs fois
  - [ ] Un achat concerne une seule photo
  - [ ] Statistiques de vente calculables

- [ ] **Relations circulaires comprises**
  - [ ] User peut être vendeur ET acheteur simultanément
  - [ ] Chaîne User → Photo → Purchase → User comprise

## Checklist technique - Commandes de base

### Commandes de développement

- [ ] **Validation et formatage**
```bash
npx prisma validate
```
- [ ] **Génération du client**
```bash
npx prisma generate
```
- [ ] **Synchronisation base de données**
```bash
npx prisma db push
```
- [ ] **Interface graphique**
```bash
npx prisma studio
```

### Tests de connexion obligatoires

- [ ] **Test 1 : Connexion simple**
```bash
node -e "const{PrismaClient}=require('@prisma/client');new PrismaClient().\$connect().then(()=>console.log('✅ OK')).catch(()=>console.log('❌ ERREUR')).finally(()=>process.exit())"
```

- [ ] **Test 2 : Comptage des tables**
```bash
node -e "const{PrismaClient}=require('@prisma/client');async function test(){const p=new PrismaClient();const [u,ph,pu]=await Promise.all([p.user.count(),p.photo.count(),p.purchase.count()]);console.log('Users:',u,'Photos:',ph,'Purchases:',pu);await p.\$disconnect();}test()"
```

- [ ] **Test 3 : Relations avec include**
```bash
node -e "const{PrismaClient}=require('@prisma/client');async function test(){const p=new PrismaClient();const user=await p.user.findFirst({include:{photos:true,purchases:true}});console.log('Relations OK:',!!user);await p.\$disconnect();}test()"
```

### Prisma Studio vérifié

- [ ] **Interface accessible sur http://localhost:5555**
- [ ] **6 tables visibles** : users, photos, purchases, accounts, sessions, verificationtokens
- [ ] **Relations cliquables** entre les tables
- [ ] **Données consultables** et modifiables via interface

## Checklist pratique - Requêtes métier

### Requêtes de base testées

- [ ] **Créer un utilisateur**
```typescript
const user = await prisma.user.create({
  data: {
    email: "test@example.com",
    password: "hashedPassword",
    name: "Test User"
  }
})
```

- [ ] **Trouver un utilisateur par email**
```typescript
const user = await prisma.user.findUnique({
  where: { email: "test@example.com" }
})
```

- [ ] **Utilisateur avec ses photos**
```typescript
const userWithPhotos = await prisma.user.findUnique({
  where: { email: "test@example.com" },
  include: { photos: true }
})
```

### Requêtes PhotoMarket avancées testées

- [ ] **Galerie publique**
```typescript
const publicPhotos = await prisma.photo.findMany({
  where: { status: "PUBLISHED" },
  include: {
    user: { select: { name: true } },
    _count: { select: { purchases: true } }
  }
})
```

- [ ] **Dashboard vendeur**
```typescript
const sellerStats = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    photos: {
      include: {
        _count: { select: { purchases: true } }
      }
    }
  }
})
```

- [ ] **Historique d'achats**
```typescript
const purchases = await prisma.purchase.findMany({
  where: { userId },
  include: {
    photo: {
      include: {
        user: { select: { name: true } }
      }
    }
  }
})
```

### Requêtes d'agrégation testées

- [ ] **Revenus total d'un vendeur**
```typescript
const earnings = await prisma.purchase.aggregate({
  where: { photo: { userId: sellerId } },
  _sum: { amount: true },
  _count: true
})
```

- [ ] **Top vendeurs**
```typescript
const topSellers = await prisma.user.findMany({
  include: {
    photos: {
      include: {
        _count: { select: { purchases: true } }
      }
    }
  }
})
```

- [ ] **Photos les plus vendues**
```typescript
const popularPhotos = await prisma.photo.findMany({
  include: {
    _count: { select: { purchases: true } }
  },
  orderBy: {
    purchases: { _count: "desc" }
  }
})
```

## Checklist de production

### Migrations et déploiement

- [ ] **Comprendre la différence entre `db push` et `migrate`**
  - [ ] `db push` : développement, prototypage
  - [ ] `migrate` : production, versioning des changements

- [ ] **Créer une migration de test**
```bash
npx prisma migrate dev --name "test_migration"
```

- [ ] **Appliquer les migrations**
```bash
npx prisma migrate deploy
```

- [ ] **Vérifier l'état des migrations**
```bash
npx prisma migrate status
```

### Backup et sécurité

- [ ] **Backup de la base de données**
```bash
pg_dump $DATABASE_URL > backup.sql
```

- [ ] **Variables d'environnement sécurisées**
  - [ ] `.env` dans `.gitignore`
  - [ ] `.env.example` documenté
  - [ ] URLs différentes pour dev/staging/prod

- [ ] **Accès base de données protégé**
  - [ ] Connexions SSL obligatoires
  - [ ] Mots de passe forts
  - [ ] Accès par IP limité (si possible)

## Checklist performance et optimisation

### Index et requêtes optimisées

- [ ] **Index automatiques identifiés**
  - [ ] Clés primaires indexées
  - [ ] Clés étrangères indexées
  - [ ] Contraintes uniques indexées

- [ ] **Index supplémentaires recommandés ajoutés**
```prisma
model Photo {
  // Index composé pour galerie
  @@index([status, createdAt])
  // Index pour recherche par prix
  @@index([price])
}
```

- [ ] **Requêtes optimisées avec `select`**
```typescript
// ✅ Optimisé
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    _count: { select: { photos: true } }
  }
})
```

### Pagination et limites

- [ ] **Pagination implémentée**
```typescript
const photos = await prisma.photo.findMany({
  take: 20,
  skip: page * 20,
  orderBy: { createdAt: "desc" }
})
```

- [ ] **Limites sur les requêtes coûteuses**
- [ ] **Monitoring des performances activé**

## Checklist de données de test

### Création de données cohérentes

- [ ] **Utilisateurs de test créés**
  - [ ] Au moins 1 ADMIN
  - [ ] Plusieurs utilisateurs USER
  - [ ] Emails uniques respectés

- [ ] **Photos de test créées**
  - [ ] Différents statuts (DRAFT, PUBLISHED, SOLD)
  - [ ] Prix variés
  - [ ] Tags diversifiés
  - [ ] Appartenant à différents utilisateurs

- [ ] **Achats de test créés**
  - [ ] Transactions complètes
  - [ ] Différents montants
  - [ ] Statuts variés (completed, pending)

### Scénarios métier testés

- [ ] **Scénario vendeur**
  - [ ] Upload de photos
  - [ ] Modification des prix
  - [ ] Changement de statut
  - [ ] Consultation des revenus

- [ ] **Scénario acheteur**
  - [ ] Navigation dans la galerie
  - [ ] Filtrage par prix/tags
  - [ ] Processus d'achat
  - [ ] Consultation de l'historique

- [ ] **Scénario admin**
  - [ ] Vue d'ensemble de tous les utilisateurs
  - [ ] Gestion de toutes les photos
  - [ ] Statistiques globales

## Checklist de validation avancée

### Tests de contraintes métier

- [ ] **Un utilisateur ne peut pas acheter sa propre photo**
```typescript
// Test avec transaction atomique
const purchase = await prisma.$transaction(async (tx) => {
  const photo = await tx.photo.findUnique({ where: { id: photoId } })
  if (photo.userId === buyerId) {
    throw new Error("Auto-achat interdit")
  }
  // ... rest of purchase logic
})
```

- [ ] **Photos DRAFT non visibles publiquement**
```typescript
const publicPhotos = await prisma.photo.findMany({
  where: { status: "PUBLISHED" }  // Pas de DRAFT
})
```

- [ ] **Suppression en cascade vérifiée**
  - [ ] Supprimer un User → ses Photos supprimées
  - [ ] Supprimer une Photo → ses Purchases supprimées

### Tests de performance

- [ ] **Requêtes complexes sous 500ms**
- [ ] **Galerie publique charge rapidement**
- [ ] **Dashboard vendeur responsive**
- [ ] **Pagination efficace sur gros volumes**

## Validation finale

### Critères de réussite

✅ **L'étape 3 est RÉUSSIE si :**

1. **Compréhension théorique** : Tous les concepts Prisma sont maîtrisés
2. **Commandes pratiques** : Toutes les commandes essentielles fonctionnent
3. **Requêtes métier** : Tous les cas d'usage PhotoMarket sont couverts
4. **Performance** : L'application répond rapidement
5. **Production** : Les migrations et backups sont compris
6. **Sécurité** : Les bonnes pratiques sont appliquées

### Tests de validation obligatoires

Exécutez ces commandes finales pour valider l'étape :

```bash
# 1. Validation complète
npx prisma validate && npx prisma generate && echo "✅ Prisma OK"

# 2. Test de santé base
node -e "const{PrismaClient}=require('@prisma/client');new PrismaClient().\$connect().then(()=>console.log('✅ DB OK')).catch(()=>console.log('❌ DB ERROR'))"

# 3. Test des relations
node -e "const{PrismaClient}=require('@prisma/client');async function test(){const p=new PrismaClient();const user=await p.user.findFirst({include:{_count:{select:{photos:true,purchases:true}}}});console.log('✅ Relations:',!!user);await p.\$disconnect();}test()"

# 4. Ouverture Prisma Studio
npx prisma studio &
echo "✅ Studio ouvert sur http://localhost:5555"
```

## Prêt pour l'étape suivante

- [ ] **Étape 4 préparée** : Configuration NextAuth.js
  - [ ] Modèles User/Account/Session maîtrisés
  - [ ] Authentification OAuth comprise
  - [ ] Rôles USER/ADMIN identifiés

Une fois cette checklist complètement validée, vous pouvez passer à l'**Étape 4 : Configuration NextAuth.js** en toute confiance !

## Annexe 1 : Checklist PowerShell (Windows)

### Tests PowerShell spécifiques

- [ ] **Fonction de test complète**
```powershell
Test-PrismaSetup
# Doit afficher ✅ pour tous les tests
```

- [ ] **Création de données de test**
```powershell
New-TestData -UserCount 3 -PhotosPerUser 5
# Doit créer 3 utilisateurs avec 5 photos chacun
```

- [ ] **Nettoyage**
```powershell
Clear-TestData
# Doit supprimer toutes les données de test
```

### Vérifications système PowerShell

- [ ] **Variables d'environnement**
```powershell
Get-Content .env | Select-String "DATABASE_URL|NEXTAUTH"
# Doit afficher les variables configurées
```

- [ ] **Processus Node.js**
```powershell
Get-Process node -ErrorAction SilentlyContinue
# Vérifier les processus actifs
```

- [ ] **Ports utilisés**
```powershell
Get-NetTCPConnection -LocalPort 5555 -ErrorAction SilentlyContinue
# Vérifier que Prisma Studio peut démarrer
```

## Annexe 2 : Checklist CMD (Command Prompt)

### Tests CMD obligatoires

- [ ] **Script de test complet**
```cmd
test-prisma.bat
REM Doit afficher ✅ pour toutes les vérifications
```

- [ ] **Création de données**
```cmd
create-test-data.bat
REM Doit permettre de spécifier le nombre d'utilisateurs/photos
```

- [ ] **Nettoyage**
```cmd
cleanup-data.bat
REM Doit demander confirmation avant suppression
```

### Vérifications système CMD

- [ ] **Variables d'environnement**
```cmd
findstr "DATABASE_URL NEXTAUTH" .env
REM Doit afficher les variables configurées
```

- [ ] **Processus Node.js**
```cmd
tasklist | findstr node.exe
REM Voir les processus Node.js actifs
```

- [ ] **Test de connectivité**
```cmd
ping -n 1 %NEON_HOST%
REM Tester la connectivité vers Neon (si host extrait)
```

Cette checklist exhaustive garantit une maîtrise complète de Prisma ORM pour le projet PhotoMarket !