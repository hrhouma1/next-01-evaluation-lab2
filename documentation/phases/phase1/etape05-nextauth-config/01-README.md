# Étape 5 : Configuration NextAuth.js avec Prisma

## Phase 1 - Configuration de l'authentification

### RAPPEL : Objectif du projet PhotoMarket

Nous développons une **application web complète de galerie de photos** permettant à des utilisateurs de :

- **Vendre leurs photos** : Upload, description, prix
- **Acheter des photos** d'autres utilisateurs via Stripe
- **Gérer leur galerie personnelle** avec authentification sécurisée
- **Administrer le système** (rôles utilisateur/admin)

### Progression du projet

**ETAPE 1 TERMINEE** : Configuration Next.js + TypeScript + Tailwind CSS 3  
**ETAPE 2 TERMINEE** : Configuration Prisma + Neon PostgreSQL  
**ETAPE 3 TERMINEE** : Configuration et maîtrise Prisma ORM  
**ETAPE 4 TERMINEE** : Analyse du schéma et relations Prisma  
**ETAPE 5 EN COURS** : Configuration NextAuth.js avec authentification complète  
**ETAPES RESTANTES** : 20+ étapes jusqu'au projet complet

### Objectif de cette étape

**Configurer l'authentification complète** avec NextAuth.js pour PhotoMarket :

- **Installation et configuration** NextAuth.js v5 (App Router)
- **Prisma Adapter** pour la persistance en base de données
- **Providers OAuth** (Google, GitHub) et credentials
- **Middleware de protection** des routes
- **Pages personnalisées** de connexion/inscription
- **Gestion des rôles** USER/ADMIN
- **Sessions et callbacks** sécurisés

### Technologies utilisées

- **NextAuth.js v5** : Authentification pour Next.js App Router
- **Prisma Adapter** : Intégration avec notre base de données
- **OAuth Providers** : Google, GitHub pour la connexion sociale
- **JWT** : Tokens sécurisés pour les sessions
- **Middleware** : Protection automatique des routes
- **bcryptjs** : Hashage des mots de passe

### Prérequis

- Étapes 1-4 terminées (Next.js + Prisma + Neon fonctionnels)
- Schéma Prisma avec modèles User, Account, Session
- Variables d'environnement NEXTAUTH_SECRET configurées

## Installation et configuration NextAuth.js

### 1. Installation des dépendances

```bash
# Naviguer dans le projet
cd photo-marketplace

# Installer NextAuth.js v5 et dépendances
npm install next-auth@beta
npm install @auth/prisma-adapter
npm install bcryptjs
npm install @types/bcryptjs -D

# Vérifier les versions installées
npm list next-auth @auth/prisma-adapter bcryptjs
```

**Versions recommandées** :
- `next-auth@5.0.0-beta.x` (App Router support)
- `@auth/prisma-adapter@latest`
- `bcryptjs@^2.4.3`

### 2. Structure des fichiers NextAuth.js

**Arborescence des fichiers à créer** :
```
src/
├── app/
│   ├── api/
│   │   └── auth/
│   │       └── [...nextauth]/
│   │           └── route.ts          ← Configuration API NextAuth
│   ├── auth/
│   │   ├── signin/
│   │   │   └── page.tsx              ← Page de connexion personnalisée
│   │   ├── signup/
│   │   │   └── page.tsx              ← Page d'inscription personnalisée
│   │   └── error/
│   │       └── page.tsx              ← Page d'erreur d'authentification
│   └── middleware.ts                 ← Protection des routes
├── lib/
│   ├── auth.ts                       ← Configuration NextAuth
│   ├── auth-config.ts                ← Configuration des providers
│   └── password.ts                   ← Utilitaires mot de passe
└── types/
    └── next-auth.d.ts                ← Types TypeScript NextAuth
```

### 3. Configuration de base NextAuth.js

**Créer `src/lib/auth-config.ts`** :
```typescript
import type { NextAuthConfig } from "next-auth"
import { PrismaAdapter } from "@auth/prisma-adapter"
import { prisma } from "@/lib/prisma"
import Google from "next-auth/providers/google"
import GitHub from "next-auth/providers/github"
import Credentials from "next-auth/providers/credentials"
import bcrypt from "bcryptjs"

export const authConfig: NextAuthConfig = {
  // Configuration de l'adapter Prisma
  adapter: PrismaAdapter(prisma),
  
  // Configuration des providers
  providers: [
    // Provider Google OAuth
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
    
    // Provider GitHub OAuth
    GitHub({
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    }),
    
    // Provider Credentials (email/password)
    Credentials({
      name: "credentials",
      credentials: {
        email: { 
          label: "Email", 
          type: "email",
          placeholder: "votre@email.com" 
        },
        password: { 
          label: "Mot de passe", 
          type: "password" 
        }
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          throw new Error("Email et mot de passe requis")
        }

        // Rechercher l'utilisateur en base
        const user = await prisma.user.findUnique({
          where: { email: credentials.email as string }
        })

        if (!user || !user.password) {
          throw new Error("Utilisateur non trouvé")
        }

        // Vérifier le mot de passe
        const isValidPassword = await bcrypt.compare(
          credentials.password as string,
          user.password
        )

        if (!isValidPassword) {
          throw new Error("Mot de passe incorrect")
        }

        // Retourner l'utilisateur (sans le mot de passe)
        return {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          image: user.image,
        }
      }
    })
  ],

  // Configuration des pages personnalisées
  pages: {
    signIn: "/auth/signin",
    signUp: "/auth/signup",
    error: "/auth/error",
  },

  // Configuration des sessions
  session: {
    strategy: "jwt", // Utiliser JWT pour les sessions
    maxAge: 30 * 24 * 60 * 60, // 30 jours
  },

  // Configuration des callbacks
  callbacks: {
    // Callback JWT : exécuté à chaque création/mise à jour du token
    async jwt({ token, user, account }) {
      // Si c'est une nouvelle connexion, ajouter les infos user au token
      if (user) {
        token.role = user.role
        token.id = user.id
      }
      return token
    },

    // Callback Session : exécuté à chaque récupération de session
    async session({ session, token }) {
      // Ajouter les infos du token à la session
      if (token) {
        session.user.id = token.id as string
        session.user.role = token.role as "USER" | "ADMIN"
      }
      return session
    },

    // Callback Redirect : contrôler les redirections après connexion
    async redirect({ url, baseUrl }) {
      // Rediriger vers le dashboard après connexion
      if (url.startsWith("/")) return `${baseUrl}${url}`
      if (new URL(url).origin === baseUrl) return url
      return `${baseUrl}/dashboard`
    }
  },

  // Configuration des événements
  events: {
    async signIn({ user, account, profile }) {
      console.log(`Connexion: ${user.email} via ${account?.provider}`)
    },
    async signOut({ session, token }) {
      console.log(`Déconnexion: ${token?.email}`)
    }
  },

  // Mode debug en développement
  debug: process.env.NODE_ENV === "development",
}
```

**Créer `src/lib/auth.ts`** :
```typescript
import NextAuth from "next-auth"
import { authConfig } from "./auth-config"

export const {
  handlers: { GET, POST },
  auth,
  signIn,
  signOut
} = NextAuth(authConfig)
```

### 4. Configuration des variables d'environnement

**Mettre à jour `.env`** :
```env
# =======================================
# CONFIGURATION BASE DE DONNÉES (déjà configuré)
# =======================================
DATABASE_URL="postgresql://username:password@ep-xxx-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require"

# =======================================
# CONFIGURATION NEXTAUTH.JS
# =======================================
# Secret pour signer les JWT (déjà configuré)
NEXTAUTH_SECRET="votre-clé-secrète-très-longue-et-sécurisée"
# URL de l'application
NEXTAUTH_URL="http://localhost:3000"

# =======================================
# OAUTH PROVIDERS
# =======================================
# Google OAuth (à configurer sur https://console.developers.google.com)
GOOGLE_CLIENT_ID="your-google-client-id.googleusercontent.com"
GOOGLE_CLIENT_SECRET="your-google-client-secret"

# GitHub OAuth (à configurer sur https://github.com/settings/applications/new)
GITHUB_CLIENT_ID="your-github-client-id"
GITHUB_CLIENT_SECRET="your-github-client-secret"

# =======================================
# CONFIGURATION STRIPE (pour plus tard - déjà en simulation)
# =======================================
STRIPE_SECRET_KEY="sk_test_SIMULATION_CECI_SERA_REMPLACE_PLUS_TARD"
STRIPE_PUBLISHABLE_KEY="pk_test_SIMULATION_CECI_SERA_REMPLACE_PLUS_TARD"
STRIPE_WEBHOOK_SECRET="whsec_SIMULATION_CECI_SERA_REMPLACE_PLUS_TARD"
```

**Mettre à jour `.env.example`** :
```env
# Base de données Neon PostgreSQL
DATABASE_URL="postgresql://username:password@host/database?sslmode=require"

# NextAuth.js - Génération : node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
NEXTAUTH_SECRET="your-generated-secret-key-here"
NEXTAUTH_URL="http://localhost:3000"

# OAuth Providers
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"
GITHUB_CLIENT_ID="your-github-client-id"
GITHUB_CLIENT_SECRET="your-github-client-secret"

# Stripe (à configurer plus tard)
STRIPE_SECRET_KEY="sk_test_your_stripe_secret_key"
STRIPE_PUBLISHABLE_KEY="pk_test_your_stripe_publishable_key"
STRIPE_WEBHOOK_SECRET="whsec_your_webhook_secret"
```

### 5. Route API NextAuth.js

**Créer `src/app/api/auth/[...nextauth]/route.ts`** :
```typescript
import { handlers } from "@/lib/auth"

export const { GET, POST } = handlers
```

**Structure des dossiers API** :
```
src/app/api/
└── auth/
    └── [...nextauth]/
        └── route.ts
```

### 6. Utilitaires pour les mots de passe

**Créer `src/lib/password.ts`** :
```typescript
import bcrypt from "bcryptjs"

/**
 * Hasher un mot de passe
 */
export async function hashPassword(password: string): Promise<string> {
  const saltRounds = 12
  return await bcrypt.hash(password, saltRounds)
}

/**
 * Vérifier un mot de passe
 */
export async function verifyPassword(
  password: string, 
  hashedPassword: string
): Promise<boolean> {
  return await bcrypt.compare(password, hashedPassword)
}

/**
 * Valider la force d'un mot de passe
 */
export function validatePasswordStrength(password: string): {
  isValid: boolean
  errors: string[]
} {
  const errors: string[] = []

  if (password.length < 8) {
    errors.push("Le mot de passe doit contenir au moins 8 caractères")
  }

  if (!/[A-Z]/.test(password)) {
    errors.push("Le mot de passe doit contenir au moins une majuscule")
  }

  if (!/[a-z]/.test(password)) {
    errors.push("Le mot de passe doit contenir au moins une minuscule")
  }

  if (!/[0-9]/.test(password)) {
    errors.push("Le mot de passe doit contenir au moins un chiffre")
  }

  if (!/[^A-Za-z0-9]/.test(password)) {
    errors.push("Le mot de passe doit contenir au moins un caractère spécial")
  }

  return {
    isValid: errors.length === 0,
    errors
  }
}

/**
 * Générer un mot de passe aléatoire sécurisé
 */
export function generateSecurePassword(length: number = 16): string {
  const lowercase = "abcdefghijklmnopqrstuvwxyz"
  const uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  const numbers = "0123456789"
  const symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?"
  
  const allChars = lowercase + uppercase + numbers + symbols
  let password = ""
  
  // S'assurer qu'on a au moins un caractère de chaque type
  password += lowercase[Math.floor(Math.random() * lowercase.length)]
  password += uppercase[Math.floor(Math.random() * uppercase.length)]
  password += numbers[Math.floor(Math.random() * numbers.length)]
  password += symbols[Math.floor(Math.random() * symbols.length)]
  
  // Compléter avec des caractères aléatoires
  for (let i = password.length; i < length; i++) {
    password += allChars[Math.floor(Math.random() * allChars.length)]
  }
  
  // Mélanger le mot de passe
  return password.split('').sort(() => Math.random() - 0.5).join('')
}
```

## Configuration du middleware de protection

### 7. Middleware NextAuth.js

**Créer `src/middleware.ts`** :
```typescript
import { auth } from "@/lib/auth"
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

// Routes protégées qui nécessitent une authentification
const protectedRoutes = [
  "/dashboard",
  "/profile",
  "/upload",
  "/photos/manage",
  "/purchases",
  "/settings"
]

// Routes admin qui nécessitent le rôle ADMIN
const adminRoutes = [
  "/admin",
  "/admin/users",
  "/admin/photos",
  "/admin/analytics"
]

// Routes publiques (pas de protection)
const publicRoutes = [
  "/",
  "/gallery",
  "/photos",
  "/auth/signin",
  "/auth/signup",
  "/auth/error",
  "/api/auth"
]

export default auth((req: NextRequest & { auth?: any }) => {
  const { pathname } = req.nextUrl
  const session = req.auth

  // Vérifier si la route est publique
  const isPublicRoute = publicRoutes.some(route => 
    pathname.startsWith(route)
  )

  // Vérifier si la route est protégée
  const isProtectedRoute = protectedRoutes.some(route => 
    pathname.startsWith(route)
  )

  // Vérifier si la route est admin
  const isAdminRoute = adminRoutes.some(route => 
    pathname.startsWith(route)
  )

  // Si route publique, autoriser l'accès
  if (isPublicRoute) {
    return NextResponse.next()
  }

  // Si route protégée et pas de session, rediriger vers login
  if (isProtectedRoute && !session) {
    const signInUrl = new URL("/auth/signin", req.url)
    signInUrl.searchParams.set("callbackUrl", pathname)
    return NextResponse.redirect(signInUrl)
  }

  // Si route admin et pas admin, rediriger vers accueil
  if (isAdminRoute && session?.user?.role !== "ADMIN") {
    return NextResponse.redirect(new URL("/", req.url))
  }

  // Si utilisateur connecté tente d'accéder aux pages auth, rediriger
  if (session && (pathname.startsWith("/auth/signin") || pathname.startsWith("/auth/signup"))) {
    return NextResponse.redirect(new URL("/dashboard", req.url))
  }

  return NextResponse.next()
})

// Configuration du matcher pour appliquer le middleware
export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public (public files)
     */
    "/((?!api|_next/static|_next/image|favicon.ico|public).*)",
  ],
}
```

## Pages d'authentification personnalisées

### IMPORTANT : Structure des fichiers et URLs Next.js

**URLs générées automatiquement par Next.js App Router** :

| Dossier app | URL accessible dans le navigateur | Page rendue |
|-------------|-----------------------------------|-------------|
| `app/auth/signin/page.tsx` | `/auth/signin` | Page de connexion |
| `app/auth/signup/page.tsx` | `/auth/signup` | Page d'inscription |
| `app/auth/error/page.tsx` | `/auth/error` | Page d'erreur personnalisée |

**Règles importantes** :
- Les noms de fichiers doivent être `page.tsx` ou `page.jsx` pour que Next.js les reconnaisse comme des routes valides avec App Router
- Chaque dossier de route doit contenir un fichier `page.tsx` obligatoire

**Vérification rapide** :
Assure-toi que dans chaque dossier (`signin`, `signup`, `error`), il y a bien un fichier :
```
page.tsx   ← obligatoire pour que ça fonctionne
```

**Exemple d'accès** :
Si ton projet tourne en local avec Next.js (par exemple via `npm run dev`), tu peux visiter :
- `http://localhost:3000/auth/signin`
- `http://localhost:3000/auth/signup` 
- `http://localhost:3000/auth/error`

### 8. Page de connexion

**Créer `src/app/auth/signin/page.tsx`** :
```tsx
import { Metadata } from "next"
import { SignInForm } from "@/components/auth/signin-form"
import { Suspense } from "react"

export const metadata: Metadata = {
  title: "Connexion | PhotoMarket",
  description: "Connectez-vous à votre compte PhotoMarket",
}

export default function SignInPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Connexion à PhotoMarket
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Accédez à votre galerie de photos
          </p>
        </div>
        
        <Suspense fallback={<div>Chargement...</div>}>
          <SignInForm />
        </Suspense>
      </div>
    </div>
  )
}
```

### 9. Page d'inscription

**Créer `src/app/auth/signup/page.tsx`** :
```tsx
import { Metadata } from "next"
import { SignUpForm } from "@/components/auth/signup-form"
import { Suspense } from "react"

export const metadata: Metadata = {
  title: "Inscription | PhotoMarket",
  description: "Créez votre compte PhotoMarket",
}

export default function SignUpPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Créer un compte PhotoMarket
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Rejoignez notre communauté de photographes
          </p>
        </div>
        
        <Suspense fallback={<div>Chargement...</div>}>
          <SignUpForm />
        </Suspense>
      </div>
    </div>
  )
}
```

### 10. Page d'erreur d'authentification

**Créer `src/app/auth/error/page.tsx`** :
```tsx
import { Metadata } from "next"
import Link from "next/link"
import { Suspense } from "react"

export const metadata: Metadata = {
  title: "Erreur d'authentification | PhotoMarket",
  description: "Une erreur est survenue lors de la connexion",
}

function ErrorContent() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8 text-center">
        <div>
          <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
            Erreur d'authentification
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Une erreur est survenue lors de la connexion
          </p>
        </div>
        
        <div className="space-y-4">
          <div className="bg-red-50 border border-red-200 rounded-md p-4">
            <div className="flex">
              <div className="ml-3">
                <h3 className="text-sm font-medium text-red-800">
                  Problème de connexion
                </h3>
                <div className="mt-2 text-sm text-red-700">
                  <p>
                    Il semblerait qu'il y ait eu un problème avec votre tentative de connexion.
                    Veuillez réessayer ou contacter le support si le problème persiste.
                  </p>
                </div>
              </div>
            </div>
          </div>
          
          <div className="space-y-3">
            <Link
              href="/auth/signin"
              className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Réessayer la connexion
            </Link>
            
            <Link
              href="/"
              className="w-full flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Retour à l'accueil
            </Link>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function AuthErrorPage() {
  return (
    <Suspense fallback={<div>Chargement...</div>}>
      <ErrorContent />
    </Suspense>
  )
}
```

### IMPORTANT : Composants de base temporaires pour éviter les erreurs

**ATTENTION ULTRA-DÉBUTANTS** : 
- ❌ **AUCUN fichier n'est généré automatiquement par NextAuth.js**
- ✅ **TOUT doit être créé manuellement par vous**
- ✅ **Chaque fichier doit être créé avec le code fourni ci-dessous**

Les pages ci-dessus importent des composants (`SignInForm`, `SignUpForm`) qui **N'EXISTENT PAS ENCORE**. Pour éviter les erreurs de build, vous devez **CRÉER MANUELLEMENT** ces composants temporaires :

**Créer `src/components/auth/signin-form.tsx`** :
```tsx
"use client"

export function SignInForm() {
  return (
    <div className="space-y-6">
      <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
        <p className="text-blue-800 text-sm">
          <strong>Composant temporaire</strong> - Le formulaire de connexion sera implémenté dans les prochaines étapes.
        </p>
      </div>
      
      <div className="space-y-4">
        <p className="text-gray-600 text-center">
          En attendant, utilisez les boutons NextAuth.js par défaut :
        </p>
        
        <div className="space-y-3">
          <a
            href="/api/auth/signin"
            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
          >
            Se connecter (NextAuth par défaut)
          </a>
          
          <a
            href="/"
            className="w-full flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            Retour à l'accueil
          </a>
        </div>
      </div>
    </div>
  )
}
```

**Créer `src/components/auth/signup-form.tsx`** :
```tsx
"use client"

export function SignUpForm() {
  return (
    <div className="space-y-6">
      <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
        <p className="text-blue-800 text-sm">
          <strong>Composant temporaire</strong> - Le formulaire d'inscription sera implémenté dans les prochaines étapes.
        </p>
      </div>
      
      <div className="space-y-4">
        <p className="text-gray-600 text-center">
          En attendant, utilisez les boutons NextAuth.js par défaut :
        </p>
        
        <div className="space-y-3">
          <a
            href="/api/auth/signin"
            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
          >
            Se connecter ou s'inscrire (NextAuth par défaut)
          </a>
          
          <a
            href="/"
            className="w-full flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            Retour à l'accueil
          </a>
        </div>
      </div>
    </div>
  )
}
```

### ÉTAPES MANUELLES OBLIGATOIRES - À FAIRE UNE PAR UNE

**Étape 1 : Créer le dossier des composants** :
```bash
# Dans le terminal, dans le dossier de votre projet :
mkdir -p src/components/auth

# Vérifier que le dossier est créé :
ls -la src/components/
# Vous devez voir le dossier "auth"
```

**Étape 2 : Créer MANUELLEMENT le fichier signin-form.tsx** :
```bash
# Créer le fichier vide
touch src/components/auth/signin-form.tsx

# OU avec votre éditeur :
# - Aller dans src/components/auth/
# - Créer un nouveau fichier
# - Le nommer "signin-form.tsx"
# - Copier-coller le code fourni ci-dessus
```

**Étape 3 : Créer MANUELLEMENT le fichier signup-form.tsx** :
```bash
# Créer le fichier vide
touch src/components/auth/signup-form.tsx

# OU avec votre éditeur :
# - Aller dans src/components/auth/
# - Créer un nouveau fichier  
# - Le nommer "signup-form.tsx"
# - Copier-coller le code fourni ci-dessus
```

**Étape 4 : Vérifier que les fichiers existent** :
```bash
# Vérifier la structure complète :
find src/components -name "*.tsx"

# Doit afficher :
# src/components/auth/signin-form.tsx
# src/components/auth/signup-form.tsx
```

**Vérification des composants** :
Une fois les composants créés, vérifie que :
- [ ] Le dossier `src/components/auth/` existe
- [ ] Le fichier `signin-form.tsx` existe et contient le composant `SignInForm`
- [ ] Le fichier `signup-form.tsx` existe et contient le composant `SignUpForm`
- [ ] Aucune erreur de build `Module not found` dans la console

### URLS À TESTER - ÉTAPE PAR ÉTAPE

**Étape 1 : Démarrer le serveur de développement** :
```bash
# Dans le terminal, dans votre projet :
npm run dev

# Attendre que le serveur démarre - vous devez voir :
# ✓ Ready in XXXms
# ○ Local:        http://localhost:3000
```

**Étape 2 : Tester les URLs NextAuth.js par défaut** :
```bash
# Dans votre navigateur, aller sur :
http://localhost:3000/api/auth/signin

# Vous devez voir :
# - La page de connexion par défaut de NextAuth.js
# - Avec les boutons "Sign in with Google" etc. (si configuré)
# - OU un formulaire de connexion basique
```

**Étape 3 : Tester vos pages personnalisées** :
```bash
# Dans votre navigateur, aller sur :
http://localhost:3000/auth/signin

# Vous devez voir :
# - Votre page personnalisée avec le titre "Connexion à PhotoMarket"
# - Un encadré bleu avec "Composant temporaire"
# - Un bouton "Se connecter (NextAuth par défaut)"

# Puis tester :
http://localhost:3000/auth/signup

# Vous devez voir :
# - Votre page personnalisée avec le titre "Créer un compte PhotoMarket" 
# - Un encadré bleu avec "Composant temporaire"
# - Un bouton "Se connecter ou s'inscrire (NextAuth par défaut)"
```

**Étape 4 : Tester que les boutons fonctionnent** :
```bash
# Sur http://localhost:3000/auth/signin
# - Cliquer sur "Se connecter (NextAuth par défaut)"
# - Vous devez être redirigé vers http://localhost:3000/api/auth/signin
# - Vous voyez la page de connexion NextAuth.js

# Sur http://localhost:3000/auth/signup  
# - Cliquer sur "Se connecter ou s'inscrire (NextAuth par défaut)"
# - Vous devez être redirigé vers http://localhost:3000/api/auth/signin
# - Vous voyez la page de connexion NextAuth.js
```

**Étape 5 : Vérifier qu'il n'y a pas d'erreurs** :
```bash
# Dans le terminal où tourne npm run dev, vérifier :
# - Aucune erreur rouge
# - Aucun "Module not found"
# - Aucun "Cannot resolve"

# Si vous voyez des erreurs, relire les sections précédentes
```

### IMPORTANT : Structure complète des composants (étapes futures)

**QUESTION FRÉQUENTE** : "Et les autres fichiers comme oauth-buttons.tsx, logout-button.tsx, etc. ?"

**RÉPONSE** : Ces fichiers **NE SONT PAS CRÉÉS MAINTENANT** ! Voici la planification :

**Structure ACTUELLE (Étape 5)** :
```
src/components/auth/
├── signin-form.tsx           ← ✅ CRÉÉ (composant temporaire)
└── signup-form.tsx           ← ✅ CRÉÉ (composant temporaire)
```

**Structure COMPLÈTE (Étapes futures)** :
```
src/components/auth/
├── signin-form.tsx           ← ✅ Étape 5 (temporaire)
├── signup-form.tsx           ← ✅ Étape 5 (temporaire)  
├── oauth-buttons.tsx         ← ⏳ Étape 8 (Composants React)
├── logout-button.tsx         ← ⏳ Étape 8 (Composants React)
├── user-menu.tsx             ← ⏳ Étape 9 (Interface utilisateur)
└── auth-guard.tsx            ← ⏳ Étape 10 (Protection de routes)
```

**Planning des étapes** :
- **Étape 5 (ACTUELLE)** : Configuration NextAuth.js + composants temporaires
- **Étape 6** : Types TypeScript avancés  
- **Étape 7** : Types pour toute l'application
- **Étape 8** : Composants React d'authentification (VRAIS formulaires)
- **Étape 9** : Interface utilisateur complète
- **Étape 10** : Protection de routes et sécurité

**À RETENIR** :
- ❌ **NE PAS** créer les autres fichiers maintenant
- ✅ **SEULEMENT** signin-form.tsx et signup-form.tsx pour l'instant
- ✅ Les autres fichiers seront créés dans les prochaines étapes avec le code complet

## Types TypeScript pour NextAuth.js

### 11. Configuration des types

**Créer `src/types/next-auth.d.ts`** :
```typescript
import { DefaultSession, DefaultUser } from "next-auth"
import { JWT, DefaultJWT } from "next-auth/jwt"

declare module "next-auth" {
  interface Session {
    user: {
      id: string
      role: "USER" | "ADMIN"
      emailVerified?: Date | null
    } & DefaultSession["user"]
  }

  interface User extends DefaultUser {
    role: "USER" | "ADMIN"
    emailVerified?: Date | null
  }
}

declare module "next-auth/jwt" {
  interface JWT extends DefaultJWT {
    id: string
    role: "USER" | "ADMIN"
  }
}
```

## Configuration des providers OAuth

### 12. Configuration Google OAuth

**Étapes pour configurer Google OAuth** :

1. **Aller sur Google Cloud Console** : https://console.developers.google.com
2. **Créer un nouveau projet** ou sélectionner un projet existant
3. **Activer l'API Google+ ou Google Identity** 
4. **Créer des identifiants OAuth 2.0** :
   - Type d'application : Application Web
   - Nom : PhotoMarket
   - URI de redirection autorisées : `http://localhost:3000/api/auth/callback/google`
   - Pour la production : `https://votre-domaine.com/api/auth/callback/google`

5. **Copier les identifiants** dans votre `.env` :
```env
GOOGLE_CLIENT_ID="123456789-abcdef.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="GOCSPX-abcdefghijklmnop"
```

### 13. Configuration GitHub OAuth

**Étapes pour configurer GitHub OAuth** :

1. **Aller sur GitHub Settings** : https://github.com/settings/applications/new
2. **Créer une nouvelle OAuth App** :
   - Application name : PhotoMarket
   - Homepage URL : `http://localhost:3000`
   - Authorization callback URL : `http://localhost:3000/api/auth/callback/github`

3. **Copier les identifiants** dans votre `.env` :
```env
GITHUB_CLIENT_ID="abcdef123456"
GITHUB_CLIENT_SECRET="abcdef123456789012345678901234567890abcd"
```

## Test de la configuration

### 14. Tests de connexion

**Créer un composant de test** `src/app/test-auth/page.tsx` :
```tsx
import { auth } from "@/lib/auth"
import { redirect } from "next/navigation"

export default async function TestAuthPage() {
  const session = await auth()

  if (!session) {
    redirect("/auth/signin")
  }

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Test d'authentification</h1>
      
      <div className="bg-green-50 border border-green-200 rounded-lg p-4 mb-6">
        <h2 className="text-lg font-semibold text-green-800 mb-2">
          ✅ Authentification réussie !
        </h2>
        <p className="text-green-700">
          Vous êtes connecté et cette page est protégée.
        </p>
      </div>

      <div className="bg-white shadow rounded-lg p-6">
        <h3 className="text-lg font-medium mb-4">Informations de session</h3>
        <pre className="bg-gray-100 p-4 rounded text-sm overflow-auto">
          {JSON.stringify(session, null, 2)}
        </pre>
      </div>
    </div>
  )
}
```

### 15. Test des providers

**Script de test rapide** `test-auth.js` :
```javascript
const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

async function testAuth() {
  const prisma = new PrismaClient()
  
  try {
    console.log('🧪 Test de la configuration d\'authentification...\n')
    
    // Test 1: Vérifier les variables d'environnement
    console.log('1. Variables d\'environnement:')
    console.log('   NEXTAUTH_SECRET:', !!process.env.NEXTAUTH_SECRET ? '✅' : '❌')
    console.log('   NEXTAUTH_URL:', process.env.NEXTAUTH_URL || '❌ Manquante')
    console.log('   GOOGLE_CLIENT_ID:', !!process.env.GOOGLE_CLIENT_ID ? '✅' : '⚠️ Optionnel')
    console.log('   GITHUB_CLIENT_ID:', !!process.env.GITHUB_CLIENT_ID ? '✅' : '⚠️ Optionnel')
    
    // Test 2: Vérifier la connexion à la base
    console.log('\n2. Connexion base de données:')
    await prisma.$connect()
    console.log('   ✅ Prisma connecté')
    
    // Test 3: Vérifier les tables NextAuth
    const userCount = await prisma.user.count()
    const accountCount = await prisma.account.count()
    const sessionCount = await prisma.session.count()
    
    console.log('\n3. Tables NextAuth.js:')
    console.log(`   Users: ${userCount}`)
    console.log(`   Accounts: ${accountCount}`)
    console.log(`   Sessions: ${sessionCount}`)
    
    // Test 4: Test de hashage de mot de passe
    console.log('\n4. Test hashage mot de passe:')
    const testPassword = 'TestPassword123!'
    const hashedPassword = await bcrypt.hash(testPassword, 12)
    const isValid = await bcrypt.compare(testPassword, hashedPassword)
    console.log('   ✅ Hashage et vérification fonctionnels:', isValid)
    
    console.log('\n🎉 Configuration NextAuth.js prête !')
    
  } catch (error) {
    console.error('❌ Erreur:', error.message)
  } finally {
    await prisma.$disconnect()
  }
}

testAuth()
```

**Exécuter le test** :
```bash
node test-auth.js
rm test-auth.js
```

## Diagnostic et résolution des erreurs

### Erreurs courantes et solutions

**1. Erreur "Module not found: Can't resolve '@/components/auth/signin-form'"**

**Cause** : Les composants importés dans les pages n'existent pas encore.

**Solution** :
```bash
# Créer la structure manquante
mkdir -p src/components/auth

# Créer les composants temporaires (voir section précédente)
# Ou utiliser la page par défaut NextAuth.js temporairement
```

**Alternative temporaire** - Modifier les pages pour utiliser NextAuth.js par défaut :
```tsx
// Dans src/app/auth/signin/page.tsx - Version sans composant personnalisé
export default function SignInPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full space-y-8 text-center">
        <h2 className="text-3xl font-extrabold text-gray-900">
          Connexion à PhotoMarket
        </h2>
        <a 
          href="/api/auth/signin"
          className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700"
        >
          Se connecter avec NextAuth.js
        </a>
      </div>
    </div>
  )
}
```

**2. Erreur "Cannot find module '@/lib/auth'"**

**Cause** : Le chemin d'alias `@/` n'est pas configuré ou le fichier n'existe pas.

**Solution** :
```bash
# Vérifier que tsconfig.json contient les chemins d'alias
grep -A 5 '"paths"' tsconfig.json

# Vérifier que le fichier auth.ts existe
ls -la src/lib/auth.ts

# Si manquant, créer le fichier (voir section 3 du guide)
```

**3. Erreur "Prisma Client not found"**

**Cause** : Prisma n'est pas généré ou configuré.

**Solution** :
```bash
# Régénérer Prisma
npx prisma generate

# Vérifier la connexion
npx prisma db push

# Test de connexion
node -e "const { PrismaClient } = require('@prisma/client'); new PrismaClient().\$connect().then(() => console.log('OK')).catch(e => console.error(e))"
```

**4. Erreur "NEXTAUTH_SECRET is not defined"**

**Cause** : Variable d'environnement manquante.

**Solution** :
```bash
# Générer un secret
node -e "console.log('NEXTAUTH_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"

# Ajouter dans .env
echo "NEXTAUTH_SECRET=votre-secret-généré" >> .env

# Redémarrer le serveur
npm run dev
```

**5. Erreur de route 404 sur /auth/signin**

**Cause** : Structure de fichiers incorrecte.

**Solution** :
```bash
# Vérifier la structure exacte
find src/app -name "page.tsx" | grep auth

# Doit afficher :
# src/app/auth/signin/page.tsx
# src/app/auth/signup/page.tsx  
# src/app/auth/error/page.tsx

# Si manquant, créer les dossiers et fichiers
mkdir -p src/app/auth/{signin,signup,error}
```

### Tests de vérification rapide

**Test 1 : Vérifier les URLs NextAuth.js**
```bash
# Démarrer le serveur
npm run dev

# Tester les URLs (dans un autre terminal)
curl -I http://localhost:3000/api/auth/signin
curl -I http://localhost:3000/auth/signin
curl -I http://localhost:3000/auth/signup
```

**Test 2 : Vérifier la configuration**
```bash
# Test des variables d'environnement
node -e "console.log('NEXTAUTH_SECRET:', !!process.env.NEXTAUTH_SECRET); console.log('DATABASE_URL:', !!process.env.DATABASE_URL)"

# Test import des modules
node -e "try { require('./src/lib/auth-config'); console.log('✅ auth-config OK'); } catch(e) { console.log('❌', e.message); }"
```

**Test 3 : Vérifier les types TypeScript**
```bash
# Compilation TypeScript
npx tsc --noEmit

# Si erreurs, vérifier que next-auth.d.ts existe
ls -la src/types/next-auth.d.ts
```

## Utilisation dans l'application

### 16. Hooks et utilitaires côté client

**Créer `src/hooks/use-auth.ts`** :
```typescript
"use client"

import { useSession } from "next-auth/react"
import { redirect } from "next/navigation"

export function useAuth(required: boolean = false) {
  const { data: session, status } = useSession()

  if (required && status === "unauthenticated") {
    redirect("/auth/signin")
  }

  return {
    session,
    user: session?.user,
    isLoading: status === "loading",
    isAuthenticated: status === "authenticated",
    isAdmin: session?.user?.role === "ADMIN"
  }
}

export function useRequireAuth() {
  return useAuth(true)
}

export function useRequireAdmin() {
  const { session, isLoading } = useAuth(true)
  
  if (!isLoading && session?.user?.role !== "ADMIN") {
    redirect("/")
  }
  
  return { session, user: session?.user }
}
```

### 17. Composants d'authentification de base

**Structure des composants à créer** (détails dans les prochaines étapes) :
```
src/components/auth/
├── signin-form.tsx           ← Formulaire de connexion
├── signup-form.tsx           ← Formulaire d'inscription
├── oauth-buttons.tsx         ← Boutons Google/GitHub
├── logout-button.tsx         ← Bouton de déconnexion
├── user-menu.tsx             ← Menu utilisateur connecté
└── auth-guard.tsx            ← Composant de protection
```

## Configuration de production

### 18. Variables d'environnement de production

**Production `.env`** :
```env
# Base de données production
DATABASE_URL="postgresql://user:pass@production.neon.tech/photomarket"

# NextAuth.js production
NEXTAUTH_SECRET="super-secret-production-key-64-chars-long-and-secure"
NEXTAUTH_URL="https://photomarket.vercel.app"

# OAuth production
GOOGLE_CLIENT_ID="prod-client-id.googleusercontent.com"
GOOGLE_CLIENT_SECRET="prod-client-secret"
GITHUB_CLIENT_ID="prod-github-client-id"
GITHUB_CLIENT_SECRET="prod-github-client-secret"
```

### 19. Sécurité et bonnes pratiques

**Checklist de sécurité** :
- ✅ NEXTAUTH_SECRET unique et long (>32 caractères)
- ✅ Variables d'environnement jamais commitées
- ✅ HTTPS obligatoire en production
- ✅ Callbacks URL validées
- ✅ Sessions avec expiration appropriée
- ✅ Middleware de protection correctement configuré
- ✅ Validation des rôles côté serveur
- ✅ Mots de passe hashés avec bcrypt (saltRounds >= 12)

### Checklist de vérification finale

Avant de passer aux étapes suivantes, vérifie que tous ces éléments sont en place :

**Structure des fichiers (OBLIGATOIRES pour cette étape)** :
- [ ] `src/lib/auth-config.ts` - Configuration NextAuth
- [ ] `src/lib/auth.ts` - Export des handlers NextAuth  
- [ ] `src/lib/password.ts` - Utilitaires mot de passe
- [ ] `src/app/api/auth/[...nextauth]/route.ts` - Route API NextAuth
- [ ] `src/app/auth/signin/page.tsx` - Page de connexion
- [ ] `src/app/auth/signup/page.tsx` - Page d'inscription
- [ ] `src/app/auth/error/page.tsx` - Page d'erreur
- [ ] `src/middleware.ts` - Middleware de protection
- [ ] `src/types/next-auth.d.ts` - Types TypeScript
- [ ] `src/components/auth/signin-form.tsx` - Composant temporaire (CRÉÉ MANUELLEMENT)
- [ ] `src/components/auth/signup-form.tsx` - Composant temporaire (CRÉÉ MANUELLEMENT)

**Fichiers QUI NE DOIVENT PAS exister maintenant** :
- [ ] ❌ `src/components/auth/oauth-buttons.tsx` - Sera créé à l'étape 8
- [ ] ❌ `src/components/auth/logout-button.tsx` - Sera créé à l'étape 8  
- [ ] ❌ `src/components/auth/user-menu.tsx` - Sera créé à l'étape 9
- [ ] ❌ `src/components/auth/auth-guard.tsx` - Sera créé à l'étape 10

**Variables d'environnement** :
- [ ] `NEXTAUTH_SECRET` - Clé secrète générée
- [ ] `NEXTAUTH_URL` - URL de l'application
- [ ] `DATABASE_URL` - URL de base de données Neon
- [ ] `GOOGLE_CLIENT_ID` et `GOOGLE_CLIENT_SECRET` (optionnel)
- [ ] `GITHUB_CLIENT_ID` et `GITHUB_CLIENT_SECRET` (optionnel)

**Tests fonctionnels** :
- [ ] `npm run dev` démarre sans erreur
- [ ] `/api/auth/signin` accessible (page NextAuth par défaut)
- [ ] `/auth/signin` accessible (page personnalisée)
- [ ] `/auth/signup` accessible (page personnalisée)
- [ ] `/auth/error` accessible (page d'erreur)
- [ ] Aucune erreur "Module not found" dans la console
- [ ] TypeScript compile sans erreur (`npx tsc --noEmit`)

**Base de données** :
- [ ] Tables NextAuth.js créées (User, Account, Session, VerificationToken)
- [ ] Connexion Prisma fonctionnelle
- [ ] `npx prisma db push` réussi

**Commandes de vérification rapide** :
```bash
# Vérification structure des fichiers obligatoires
echo "=== VÉRIFICATION STRUCTURE ÉTAPE 5 ==="
echo "Fichiers obligatoires :"
for file in "src/lib/auth-config.ts" "src/lib/auth.ts" "src/app/api/auth/[...nextauth]/route.ts" "src/app/auth/signin/page.tsx" "src/components/auth/signin-form.tsx"; do
  if [ -f "$file" ]; then
    echo "✅ $file"
  else
    echo "❌ $file MANQUANT"
  fi
done

echo ""
echo "Fichiers qui NE DOIVENT PAS exister :"
for file in "src/components/auth/oauth-buttons.tsx" "src/components/auth/logout-button.tsx" "src/components/auth/user-menu.tsx"; do
  if [ ! -f "$file" ]; then
    echo "✅ $file (correct - pas encore créé)"
  else
    echo "⚠️ $file existe déjà (pas grave mais pas nécessaire maintenant)"
  fi
done

echo ""
echo "Test serveur de développement :"
npm run dev & SERVER_PID=$!
sleep 8
curl -s -I http://localhost:3000/auth/signin | head -1
curl -s -I http://localhost:3000/api/auth/signin | head -1
kill $SERVER_PID
echo "=== FIN VÉRIFICATION ==="
```

**Commande simple pour débutants** :
```bash
# Juste vérifier que les fichiers principaux existent
ls -la src/components/auth/
ls -la src/app/auth/signin/
ls -la src/lib/

# Puis démarrer le serveur et tester dans le navigateur
npm run dev
# Aller sur http://localhost:3000/auth/signin
```

Si tous les éléments sont cochés, l'étape 5 est terminée avec succès !

## Livrables de l'étape 5

### Configuration terminée

- [ ] NextAuth.js v5 installé et configuré
- [ ] Prisma Adapter intégré avec la base de données
- [ ] Providers OAuth (Google, GitHub, Credentials) configurés
- [ ] Variables d'environnement OAuth configurées
- [ ] Middleware de protection des routes fonctionnel
- [ ] Pages d'authentification personnalisées créées
- [ ] Types TypeScript NextAuth configurés
- [ ] Utilitaires de mot de passe implémentés
- [ ] Tests d'authentification réussis

### Prochaines étapes

Une fois cette étape terminée, vous pourrez passer à :
- **Étape 6** : Types NextAuth et gestion avancée des sessions
- **Étape 7** : Types TypeScript avancés pour toute l'application

## Ressources

- [Documentation NextAuth.js v5](https://next-auth.js.org)
- [Prisma Adapter](https://authjs.dev/reference/adapter/prisma)
- [OAuth Google Setup](https://developers.google.com/identity/protocols/oauth2)
- [OAuth GitHub Setup](https://docs.github.com/en/developers/apps/building-oauth-apps)