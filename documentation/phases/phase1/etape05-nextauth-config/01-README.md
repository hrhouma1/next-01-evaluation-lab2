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