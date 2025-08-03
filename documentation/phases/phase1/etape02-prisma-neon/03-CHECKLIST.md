# Checklist - Étape 2 : Configuration Prisma + Neon PostgreSQL

## Liste de vérification complète

### Prérequis

- [ ] Étape 1 terminée (projet Next.js fonctionnel)
- [ ] Compte Neon créé sur https://neon.tech
- [ ] Accès terminal/PowerShell/CMD
- [ ] Node.js et npm installés

### Installation des dépendances

- [ ] `npm install prisma @prisma/client` exécuté avec succès
- [ ] `npm install -D prisma` exécuté avec succès
- [ ] `npx prisma init` exécuté et dossier `prisma/` créé
- [ ] Fichier `.env` créé automatiquement
- [ ] Fichier `prisma/schema.prisma` créé

### Configuration Neon PostgreSQL

- [ ] Projet créé sur Neon dashboard
- [ ] Nom du projet : `photo-marketplace-db` (ou similaire)
- [ ] Région sélectionnée appropriée
- [ ] Version PostgreSQL 15 choisie
- [ ] Chaîne de connexion copiée depuis le dashboard
- [ ] Format de l'URL vérifié : `postgresql://user:pass@host/db?sslmode=require`

### Configuration des variables d'environnement

- [ ] Fichier `.env` modifié avec la DATABASE_URL
- [ ] Variable `NEXTAUTH_SECRET` ajoutée (clé longue et sécurisée)
- [ ] Variable `NEXTAUTH_URL` configurée (`http://localhost:3000`)
- [ ] Variables Stripe ajoutées (clés de test)
- [ ] Fichier `.env.example` créé avec des exemples
- [ ] Fichier `.env` ajouté au `.gitignore`

### Configuration du client Prisma

- [ ] Dossier `src/lib/` créé
- [ ] Fichier `src/lib/prisma.ts` créé avec le client Prisma
- [ ] Import `PrismaClient` configuré correctement
- [ ] Configuration singleton pour éviter les multiples connexions
- [ ] Gestion de l'environnement de développement/production

### Tests de fonctionnement

- [ ] `npx prisma generate` exécuté sans erreur
- [ ] `npx prisma db pull` exécuté avec succès
- [ ] Message "Introspected 0 models" affiché
- [ ] Client Prisma généré dans `node_modules/.prisma/`
- [ ] Test de connexion JavaScript réussi

### Vérifications techniques

- [ ] Variables d'environnement bien chargées
- [ ] `node -e "console.log(!!process.env.DATABASE_URL)"` retourne `true`
- [ ] `node -e "console.log(!!process.env.NEXTAUTH_SECRET)"` retourne `true`
- [ ] `npm list prisma` montre la version installée
- [ ] `npm list @prisma/client` montre la version installée

### Tests de connexion

- [ ] Test de connexion basique réussi
- [ ] Requête `SELECT NOW()` fonctionne
- [ ] Neon dashboard montre la connexion active
- [ ] Aucune erreur SSL
- [ ] Temps de réponse acceptable (< 2 secondes)

### Structure de fichiers

- [ ] `prisma/schema.prisma` existe et contient la configuration de base
- [ ] `src/lib/prisma.ts` existe avec le client configuré
- [ ] `.env` existe et contient toutes les variables
- [ ] `.env.example` existe pour documentation
- [ ] `.gitignore` contient `.env`

### Tests d'intégration

- [ ] `npm run dev` démarre sans erreur Prisma
- [ ] Aucune erreur TypeScript liée à Prisma
- [ ] Import `@prisma/client` fonctionne dans le code
- [ ] Connexion à la base de données stable

### Nettoyage et finalisation

- [ ] Fichiers de test supprimés (`test-db.js`, etc.)
- [ ] Cache npm nettoyé si nécessaire
- [ ] Commit Git créé avec les changements
- [ ] Documentation comprise et accessible

## Validation finale

### Test manuel complet

Exécuter cette séquence de commandes pour validation :

```bash
# 1. Vérification de base
cd photo-marketplace
ls -la .env
ls -la prisma/

# 2. Test Prisma
npx prisma generate
npx prisma db pull

# 3. Test de connexion
node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.\$connect()
  .then(() => {
    console.log('✅ Connexion réussie');
    return prisma.\$queryRaw\`SELECT 'Hello Neon!' as message\`;
  })
  .then(result => {
    console.log('✅ Requête test:', result[0].message);
  })
  .catch(err => {
    console.error('❌ Erreur:', err.message);
  })
  .finally(() => prisma.\$disconnect());
"

# 4. Test serveur Next.js
npm run dev
```

**Résultats attendus** :
- [ ] Tous les fichiers existent
- [ ] Prisma génère le client sans erreur
- [ ] Connexion à Neon réussie
- [ ] Message "Hello Neon!" affiché
- [ ] Serveur Next.js démarre sans erreur

### Checklist de sécurité

- [ ] Fichier `.env` n'est jamais commité dans Git
- [ ] Variables d'environnement sensibles protégées
- [ ] Clés Stripe en mode test (commencent par `sk_test_` et `pk_test_`)
- [ ] `NEXTAUTH_SECRET` est une chaîne longue et aléatoire
- [ ] URL Neon contient `?sslmode=require`

### Checklist de performance

- [ ] Client Prisma configuré en singleton
- [ ] Connexions fermées correctement
- [ ] Pas de multiples instances de PrismaClient
- [ ] Cache Prisma généré présent

### Checklist de documentation

- [ ] README de l'étape lu et compris
- [ ] Commandes documentées et testées
- [ ] Variables d'environnement documentées dans `.env.example`
- [ ] Prochaines étapes identifiées

## Temps estimé

**Durée totale** : 20-30 minutes

**Répartition** :
- Installation Prisma : 5 minutes
- Configuration Neon : 10 minutes
- Tests et validation : 10 minutes
- Documentation : 5 minutes

## En cas de problème

### Erreurs courantes à vérifier

- [ ] **Variables d'environnement** : `.env` lu correctement
- [ ] **URL Neon** : Format correct avec SSL
- [ ] **Réseau** : Connexion internet stable
- [ ] **Versions** : Node.js compatible (>= 16)
- [ ] **Permissions** : Droits d'écriture dans le projet

### Actions de dépannage

- [ ] Redémarrer le serveur Next.js
- [ ] Régénérer le client Prisma
- [ ] Vérifier les logs Neon dashboard
- [ ] Nettoyer le cache npm
- [ ] Recréer la chaîne de connexion Neon

### Support et ressources

- [ ] Documentation Prisma consultée
- [ ] Documentation Neon consultée
- [ ] Logs d'erreur analysés
- [ ] Tests de connexion alternatifs essayés

## Validation par un pair

**À faire vérifier par un collègue/enseignant** :

- [ ] Configuration des variables d'environnement
- [ ] Sécurité du fichier `.env`
- [ ] Test de connexion réussi
- [ ] Structure de fichiers correcte
- [ ] Code du client Prisma

## Résultat attendu

À la fin de cette étape, vous devez avoir :

**Infrastructure technique** :
- Prisma ORM installé et configuré
- Base de données PostgreSQL Neon connectée
- Client TypeScript généré et fonctionnel
- Variables d'environnement sécurisées

**Fonctionnalités testées** :
- Connexion à la base de données stable
- Requêtes SQL basiques fonctionnelles
- Intégration Next.js sans erreur
- Configuration prête pour les prochaines étapes

**Documentation** :
- Variables d'environnement documentées
- Configuration reproductible
- Tests de validation opérationnels

## Prochaine étape

Une fois cette checklist complètement validée :

**Étape 3** : Création du schéma Prisma complet avec les modèles User, Photo, Purchase, Account, Session et toutes les relations nécessaires au projet PhotoMarket.

## Notes personnelles

**Problèmes rencontrés** :
```
[Espace pour noter les problèmes et solutions]
```

**Temps réel passé** :
```
[Noter le temps effectif pour référence]
```

**Améliorations suggérées** :
```
[Suggestions pour optimiser le processus]
```