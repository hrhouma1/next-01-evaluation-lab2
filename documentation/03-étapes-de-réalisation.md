
## ✅ Étape 1 : Initialisation du projet Next.js (vide)

* Créer un compte GitHub.
* Créer un dossier vide sur votre ordinateur.
* Ouvrir un terminal dans ce dossier puis :

```bash
npx create-next-app@latest mon-projet-photo
```

* Choisir :

  * ✔️ **App Router (Yes)**
  * ✔️ **TypeScript recommandé (Yes)**
  * ✔️ **ESLint (Yes)**
  * ✔️ **Tailwind CSS (Yes recommandé)**
  * ✔️ **Src directory (Yes recommandé)**
  * ✔️ **Alias @ (Yes recommandé)**

* Aller dans le dossier créé :

```bash
cd mon-projet-photo
```

* Lancer pour vérifier :

```bash
npm run dev
```

* Pousser le projet initial sur GitHub (commit : "Initial commit")

---

## ✅ Étape 2 : Mise en place de Prisma ORM + Base de données

* Installer Prisma :

```bash
npm install @prisma/client
npm install -D prisma
npx prisma init
```

* Choisir **Neon (PostgreSQL)** ou SQLite local.
* Modifier `.env` avec les informations DB.
* Définir dans `schema.prisma` le modèle initial :

```prisma
model User {
  id Int @id @default(autoincrement())
  email String @unique
  password String
  photos Photo[]
}

model Photo {
  id Int @id @default(autoincrement())
  title String
  url String
  public Boolean @default(true)
  userId Int
  user User @relation(fields: [userId], references: [id])
}
```

* Migration initiale :

```bash
npx prisma migrate dev --name init
```

---

## ✅ Étape 3 : Authentification sécurisée (JWT)

* Installer bcrypt et JWT :

```bash
npm install bcrypt jsonwebtoken
npm install @types/bcrypt @types/jsonwebtoken
```

* Créer routes API :

  * `/api/register` → créer utilisateur
  * `/api/login` → connexion, JWT

* Ajouter middleware JWT sécurisé (`auth.ts`) dans Next.js :

```bash
src/middleware.ts
```

* Vérifier l’authentification avec Postman.

---

## ✅ Étape 4 : CRUD Photos sécurisé (API REST)

Créer les routes suivantes :

* `POST /api/photos` (upload)
* `GET /api/photos/public` (afficher galerie publique)
* `GET /api/photos/my` (photos utilisateur authentifié)
* `PUT /api/photos/:id` (modifier)
* `DELETE /api/photos/:id` (supprimer)

Chaque route doit vérifier l'utilisateur via JWT middleware.

Tester avec Postman.

---

## ✅ Étape 5 : Interface Frontend (Pages React / Next.js)

Développer les pages de base :

* Page Accueil (`/`) → affiche galerie publique.
* Page Inscription (`/register`) → formulaire inscription.
* Page Connexion (`/login`) → formulaire connexion.
* Page Galerie utilisateur (`/dashboard`) → afficher les photos privées.
* Page Ajouter photo (`/dashboard/add-photo`) → formulaire upload photo.

Utiliser `fetch()` pour communiquer avec votre API créée précédemment.

---

## ✅ Étape 6 : Interface administration sécurisée (Admin)

* Ajouter champ `role` à `User` (prisma : "USER" | "ADMIN")

* Ajouter routes admin :

  * `/api/admin/users` (GET)
  * `/api/admin/users/:id` (DELETE)
  * `/api/admin/photos` (GET)
  * `/api/admin/photos/:id` (DELETE)

* Middleware pour protéger `/api/admin/*`.

* Créer pages admin React sécurisées (`/admin/users`, `/admin/photos`).

---

## ✅ Étape 7 : Intégration Stripe (paiement)

* Créer compte Stripe (test)
* Installer SDK Stripe :

```bash
npm install stripe @stripe/stripe-js
```

* Créer route Checkout Stripe :

  * `POST /api/checkout` → création session paiement.

* Ajouter bouton acheter côté frontend (redirection checkout Stripe).

---

## ✅ Étape 8 : Gestion Webhook Stripe (confirmation paiement)

* Créer route Webhook sécurisée Stripe :

  * `/api/webhook` pour confirmer paiement et attribuer les photos achetées.

* Utiliser signature Webhook Stripe pour vérifier intégrité.

* Mise à jour automatique des droits d’accès aux photos.

---

## ✅ Étape 9 : Documentation API (Postman ou Swagger)

* Installer Postman
* Créer une collection Postman
* Documenter clairement chaque route créée :

  * Exemple : méthode, URL, paramètres, exemple de requête et réponse attendue.

Exporter la collection en `.json` et intégrer au GitHub.

---

## ✅ Étape 10 : Préparation de la livraison finale

* Créer fichier `README.md` complet avec :

  * Instructions installation précises (cloner, .env, Prisma migration, Stripe keys)
  * Lancer l’application (`npm run dev`)
  * Lien vers documentation API (Postman)

* Enregistrer courte vidéo (2 min) montrant :

  * Inscription, connexion
  * Upload, modification, suppression photos
  * Achat photo Stripe et attribution automatique

* Uploader tout sur GitHub clairement structuré.

---

## 🚀 **Résumé rapide des étapes pour débutants :**

| #  | Étapes simples (récapitulatif)                     |
| -- | -------------------------------------------------- |
| 1  | Créer projet Next.js vide                          |
| 2  | Ajouter Prisma et Base de données                  |
| 3  | Développer Authentification JWT                    |
| 4  | Routes CRUD Photos sécurisées                      |
| 5  | Créer pages Frontend React                         |
| 6  | Créer Administration sécurisée                     |
| 7  | Intégrer Stripe Checkout                           |
| 8  | Gérer Webhook Stripe                               |
| 9  | Documentation API Postman                          |
| 10 | Livraison finale (README + Vidéo + GitHub complet) |

---

🎯 **Avec ces étapes très explicites, les étudiants débutants pourront facilement suivre le projet, étape par étape.**
