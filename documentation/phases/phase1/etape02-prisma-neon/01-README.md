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

#### 3. Configuration du fichier .env

**Modifier `.env`** :
```env
# Database
DATABASE_URL="postgresql://username:password@ep-xxx-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require"

# NextAuth.js
NEXTAUTH_SECRET="votre-clé-secrète-très-longue-et-sécurisée"
NEXTAUTH_URL="http://localhost:3000"

# Stripe (clés de test)
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."
```

**Créer `.env.example`** :
```env
# Database
DATABASE_URL="postgresql://username:password@host/database"

# NextAuth.js
NEXTAUTH_SECRET="generate-a-random-secret-key"
NEXTAUTH_URL="http://localhost:3000"

# Stripe (test keys)
STRIPE_SECRET_KEY="sk_test_your_key_here"
STRIPE_PUBLISHABLE_KEY="pk_test_your_key_here"
STRIPE_WEBHOOK_SECRET="whsec_your_webhook_secret"
```

**Important** : Ne jamais commiter le fichier `.env` ! Il doit être dans `.gitignore`.

#### 4. Test de la connexion

```bash
# Tester la connexion à la base de données
npx prisma db pull

# Si la connexion fonctionne, vous verrez :
# "Introspecting based on database url from .env"
# "✔ Introspected 0 models and wrote them into prisma/schema.prisma"
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

### Vérification de la configuration

#### Test 1 : Variables d'environnement

```bash
# Vérifier que les variables sont bien définies
node -e "console.log('DATABASE_URL existe:', !!process.env.DATABASE_URL)"
node -e "console.log('NEXTAUTH_SECRET existe:', !!process.env.NEXTAUTH_SECRET)"
```

#### Test 2 : Connexion Prisma

```bash
# Générer le client Prisma
npx prisma generate

# Tester la connexion
npx prisma db pull
```

**Résultat attendu** :
```
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Datasource "db": PostgreSQL database "neondb", schema "public"

✔ Introspected 0 models and wrote them into prisma/schema.prisma
```

#### Test 3 : Client TypeScript

**Créer un test rapide** dans `test-db.js` :
```javascript
const { PrismaClient } = require('@prisma/client')

async function testConnection() {
  const prisma = new PrismaClient()
  
  try {
    await prisma.$connect()
    console.log('✅ Connexion à Neon PostgreSQL réussie!')
  } catch (error) {
    console.error('❌ Erreur de connexion:', error.message)
  } finally {
    await prisma.$disconnect()
  }
}

testConnection()
```

**Exécuter le test** :
```bash
node test-db.js
```

**Supprimer le fichier de test** :
```bash
rm test-db.js
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

Une fois cette étape terminée, vous pourrez passer à l'**Étape 3 : Création du schéma Prisma complet** avec les modèles User, Photo, Purchase, etc.

### Ressources

- [Documentation Prisma](https://www.prisma.io/docs)
- [Documentation Neon](https://neon.tech/docs)
- [Prisma avec Next.js](https://www.prisma.io/docs/guides/other/troubleshooting-orm/help-articles/nextjs-prisma-client-monorepo)
