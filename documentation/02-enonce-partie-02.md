<h1 id="explication-evaluations">Explication des évaluations et grille des évaluations des Laboratoire #2 (20%) et du Projet intégrateur (40%)</h1>

Bonjour à toutes et à tous,

Afin d'éviter toute confusion et clarifier définitivement l’organisation des évaluations dans le cours, voici des précisions importantes concernant le **Laboratoire #2** et le **Projet intégrateur final** :

# 1 - Situation annoncée en classe

| Évaluation         | Contenu promis initialement                                               | Pondération |
| ------------------ | ------------------------------------------------------------------------- | ----------- |
| Laboratoire #2     | Création des services web uniquement (API REST créée par vous)            | **20 %**    |
| Projet intégrateur | Création + Consommation (Stripe) + Documentation API + Présentation orale | **40 %**    |

### Clarification importante (à lire attentivement)

**Vous allez réaliser un seul et unique projet intégrateur complet, divisé clairement en deux étapes :**

1. **Laboratoire #2 (20%) :**
   Vous rendrez une première version intermédiare du projet intégrateur. Cette remise concerne **uniquement la partie création des services web** (routes API REST créées par vous-mêmes : authentification, gestion des photos, interface administrateur, etc.).

   À ce stade, **vous ne serez évalués que sur les parties où vous jouez le rôle de "producteur" d’une API REST**.

2. **Projet intégrateur final (40%) :**
   Vous allez continuer et compléter votre projet intégrateur pour remettre une version finale exhaustive comprenant :

   * La partie **création d’API** (qui aura déjà été évaluée dans le Lab #2 mais devra être complétée et améliorée si nécessaire).
   * La partie **consommation** (intégration complète du paiement Stripe, création des sessions de paiement et gestion des webhooks).
   * La **documentation complète de votre API** avec Postman (ou Swagger).
   * Une courte **présentation orale** accompagnée d’un fichier PPT (PowerPoint), où vous présentez brièvement votre projet, votre architecture, les services web créés et consommés, ainsi que votre expérience sur Stripe.

### Résumé sous forme de tableau synthétique :

| Évaluation                   | Éléments évalués                                                                            | Pondération |
| ---------------------------- | ------------------------------------------------------------------------------------------- | ----------- |
| **Laboratoire #2**           | **Création uniquement : API REST** (authentification, photos, routes privées/admin)         | **20 %**   |
| **Projet intégrateur final** | **Création (finalisée) + Consommation (Stripe) + Documentation + Présentation orale (PPT)** | **40 %**   |

**Important :**

* Le **Laboratoire #2** représente une première version de votre projet intégrateur (partie création seulement). Vous aurez du feedback sur cette étape, ce qui vous permettra d'améliorer votre travail pour le projet intégrateur final.
* Le **projet intégrateur final** inclut tout le projet : création finale (avec prise en compte du feedback), consommation Stripe, documentation et présentation orale.

N'hésitez pas à me contacter si vous avez des questions complémentaires ou besoin d'une clarification.

Bon courage à tous !




# 2 - Grilles d’évaluation 

> Ces deux tableaux sont indépendants :
> – **TP2** évalue exclusivement la **création** des services web.
> – **Projet intégrateur final** évalue l’ensemble du projet (création finalisée + consommation Stripe + documentation + présentation).



# 2.1. Grille d’évaluation — **TP2 : Création des services web**

| # | Critère évalué                                                                                     | Poids |
| - | -------------------------------------------------------------------------------------------------- | ----: |
| 1 | Modélisation et schéma Prisma (User, Photo, rôles)                                                 |  20 % |
| 2 | Routes API Auth : `/api/register`, `/api/login`, `/api/logout`  (validation, hashage mot de passe) |  20 % |
| 3 | Routes CRUD Photos : `/api/photos`, `/api/photos/:id` (upload, update, delete sécurisés)           |  20 % |
| 4 | Middleware de sécurité (vérification JWT/cookie, protection des routes privées)                    |  20 % |
| 5 | Qualité du code & organisation (conventions Next.js, gestion des erreurs HTTP)                     |  10 % |
| 6 | Tests manuels Postman (collection fournie et fonctionnelle)                                        |  10 % |
|   | **Total TP2**                                                                                      | 100 % |



# 2.2. Grille d’évaluation — **Projet intégrateur final**

| # | Critère évalué                                                                                |  Poids |
| - | --------------------------------------------------------------------------------------------- | -----: |
| 1 | API REST finalisée (corrections TP2 appliquées, interface admin complète)                     |   25 % |
| 2 | Intégration Stripe Checkout (création de session, gestion des erreurs)                        |   20 % |
| 3 | Webhook Stripe (vérification de signature, attribution des photos achetées)                   |   15 % |
| 4 | Documentation API (collection Postman ou Swagger complète et à jour)                          | 12,5 % |
| 5 | Interface utilisateur (pages Next.js fonctionnelles : register, login, gallery, dashboard)    |   10 % |
| 6 | Présentation orale + support PPT (architecture, démo fluide en ≈ 5 min)                       |   10 % |
| 7 | Qualité du code, déploiement & README (variables d’environnement, procédure de mise en route) |  7,5 % |
|   | **Total Projet intégrateur**                                                                  |  100 % |




# <h1 id="technologies-autorisées"> 3 - Choix technologiques autorisés pour le TP2 et le Projet intégrateur (Stack)</h1>

Le tableau ci-dessous dresse la liste **des options officiellement acceptées** pour chaque composant de votre stack.
Vous êtes libres de combiner les technologies d’une même ligne (ex. Prisma + Neon + NextAuth) ; toute solution hors tableau doit être validée au préalable.

| Couche / Composant                        | Options autorisées                                                                                                                                                                                                        | Remarques et exigences                                                                                                  |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Base de données**                       | - **Neon (PostgreSQL)**<br>- Supabase DB (PostgreSQL)<br>- Xata (base KV/PostgreSQL)<br>- SQLite (local, fichier `.db` dans le repo)<br>- PostgreSQL local (Docker ou installation native)                                | Utilisez les plans gratuits quand c’est possible. Fournissez un script ou des migrations pour la création des tables.   |
| **ORM / Accès aux données**               | - **Prisma** (compatible Neon, Supabase, SQLite, Postgres local)<br>- **Drizzle ORM**<br>- Kysely (optionnel)<br>- TypeORM (optionnel)                                                                                    | Fournir le fichier `schema.prisma`, `drizzle.config.ts`, ou équivalent. Les migrations doivent être traçables dans Git. |
| **Backend / API**                         | - **Next.js App Router** (routes API intégrées)<br>- Express.js (si vous choisissez un front React séparé)<br>- Fastify (optionnel)<br>- Strapi (uniquement pour la partie Admin, si vous préférez une solution headless) | L’option par défaut et recommandée reste **Next.js full-stack** (« un seul projet »).                                   |
| **Authentification**                      | - **NextAuth.js** (JWT ou Sessions)<br>- Auth.js<br>- Auth0 (plan gratuit)<br>- **Clerk**<br>- Custom JWT + cookies signés                                                                                                | Le middleware de protection des routes privées est obligatoire.                                                         |
| **Paiement**                              | - **Stripe Checkout + Webhook** (imposé)                                                                                                                                                                                  | La vérification de signature est obligatoire (`stripe.webhooks.constructEvent`).                                        |
| **Stockage des images**                   | - Répertoire local `public/uploads` (par défaut)<br>- Cloudinary (plan gratuit)<br>- Supabase Storage<br>- AWS S3 (Free Tier)                                                                                             | Les URL publiques doivent être stockées en base.                                                                        |
| **Documentation API**                     | - Collection **Postman**<br>- **Swagger / OpenAPI** (ex. `swagger-ui-express`)                                                                                                                                            | La documentation doit couvrir **tous** les endpoints exposés.                                                           |
| **Interface administrateur**              | - Pages Next.js protégées (`/admin/*`)<br>- Strapi Admin (si Strapi choisi comme backend)<br>- React Admin (optionnel)                                                                                                    | L’accès doit être restreint au rôle `admin`.                                                                            |
| **Front-end**                             | - React + Next.js (pages App Router)<br>- React + Vite (si backend distinct)<br>- React Admin (pour l’admin si besoin)                                                                                                    | Vos appels API doivent respecter les conventions REST décrites dans l’énoncé.                                           |
| **Déploiement (facultatif pour la note)** | - Vercel<br>- Render<br>- Railway<br>- Supabase Hosting                                                                                                                                                                   | Fournir une URL publique fonctionnelle (mode test Stripe).                                                              |

**Règle générale :**

* Choisissez **une option par ligne** (ex. Prisma + Neon + NextAuth + Stripe + Cloudinary).
* Déclarez vos choix dans le `README.md` et fournissez les instructions d’installation correspondantes.
* Toute technologie non listée doit être approuvée par l’enseignant avant utilisation.

Vous disposez ainsi d’un cadre clair pour sélectionner votre stack et garantir la cohérence de vos livrables.


