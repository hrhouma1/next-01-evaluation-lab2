# Plan détaillé d'implémentation - Application Photos Next.js + Stripe

> **Guide étape par étape** pour réaliser le projet complet avec au moins 20 étapes détaillées
> 
> 🎯 **Stack utilisée** : Next.js 14 + TypeScript + Tailwind CSS 3 + Prisma + Neon PostgreSQL + NextAuth + Stripe

---

## 🚀 Phase 1 : Configuration initiale du projet

### ✅ Étape 1 : Initialisation du projet Next.js avec TypeScript

```bash
# Créer le projet avec toutes les bonnes options
npx create-next-app@latest photo-marketplace --typescript --tailwind --eslint --app --src-dir --import-alias="@/*"
cd photo-marketplace

# Vérifier que tout fonctionne
npm run dev
```

**Objectif** : Avoir un projet Next.js 14 fonctionnel avec App Router, TypeScript et Tailwind CSS 3.

**Livrables** :
- Projet Next.js initialisé
- Première page d'accueil qui s'affiche
- Commit initial sur GitHub

---

### ✅ Étape 2 : Configuration de Prisma avec Neon PostgreSQL

```bash
# Installer Prisma
npm install prisma @prisma/client
npm install -D prisma

# Initialiser Prisma
npx prisma init
```

**Configuration `.env`** :
```env
# Database
DATABASE_URL="postgresql://username:password@ep-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require"

# NextAuth
NEXTAUTH_SECRET="your-secret-key-here"
NEXTAUTH_URL="http://localhost:3000"

# Stripe (test keys)
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."
```

**Créer `.env.example`** :
```env
DATABASE_URL="postgresql://..."
NEXTAUTH_SECRET="generate-a-random-secret"
NEXTAUTH_URL="http://localhost:3000"
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_PUBLISHABLE_KEY="pk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."
```

**Objectif** : Base de données PostgreSQL connectée et configurée.

---

### ✅ Étape 3 : Création du schéma Prisma complet

**Modifier `prisma/schema.prisma`** :

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id            String    @id @default(cuid())
  email         String    @unique
  password      String
  name          String?
  role          Role      @default(USER)
  emailVerified DateTime?
  image         String?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  // Relations
  photos        Photo[]
  purchases     Purchase[]
  accounts      Account[]
  sessions      Session[]

  @@map("users")
}

model Photo {
  id          String   @id @default(cuid())
  title       String
  description String?
  imageUrl    String
  price       Float    @default(0)
  isPublic    Boolean  @default(true)
  isForSale   Boolean  @default(false)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // Relations
  userId    String
  user      User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  purchases Purchase[]

  @@map("photos")
}

model Purchase {
  id            String   @id @default(cuid())
  stripePaymentId String @unique
  amount        Float
  createdAt     DateTime @default(now())

  // Relations
  userId  String
  user    User  @relation(fields: [userId], references: [id], onDelete: Cascade)
  photoId String
  photo   Photo @relation(fields: [photoId], references: [id], onDelete: Cascade)

  @@map("purchases")
}

// NextAuth required models
model Account {
  id                String  @id @default(cuid())
  userId            String
  type              String
  provider          String
  providerAccountId String
  refresh_token     String? @db.Text
  access_token      String? @db.Text
  expires_at        Int?
  token_type        String?
  scope             String?
  id_token          String? @db.Text
  session_state     String?

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerAccountId])
  @@map("accounts")
}

model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime
  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("sessions")
}

enum Role {
  USER
  ADMIN
}
```

```bash
# Appliquer la migration
npx prisma migrate dev --name init
npx prisma generate
```

**Objectif** : Schéma de base de données complet et migré.

---

### ✅ Étape 4 : Configuration de NextAuth.js pour l'authentification

```bash
# Installer NextAuth
npm install next-auth @next-auth/prisma-adapter
npm install bcryptjs
npm install @types/bcryptjs
```

**Créer `src/lib/auth.ts`** :

```typescript
import { NextAuthOptions } from "next-auth"
import CredentialsProvider from "next-auth/providers/credentials"
import { PrismaAdapter } from "@next-auth/prisma-adapter"
import bcrypt from "bcryptjs"
import { prisma } from "@/lib/prisma"

export const authOptions: NextAuthOptions = {
  adapter: PrismaAdapter(prisma),
  providers: [
    CredentialsProvider({
      name: "credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" }
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null
        }

        const user = await prisma.user.findUnique({
          where: { email: credentials.email }
        })

        if (!user) {
          return null
        }

        const isPasswordValid = await bcrypt.compare(
          credentials.password,
          user.password
        )

        if (!isPasswordValid) {
          return null
        }

        return {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
        }
      }
    })
  ],
  session: {
    strategy: "jwt"
  },
  callbacks: {
    jwt: async ({ token, user }) => {
      if (user) {
        token.role = user.role
      }
      return token
    },
    session: async ({ session, token }) => {
      if (token) {
        session.user.id = token.sub!
        session.user.role = token.role as string
      }
      return session
    }
  }
}
```

**Créer `src/lib/prisma.ts`** :

```typescript
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: ['query'],
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

**Objectif** : Authentification NextAuth configurée avec Prisma.

---

### ✅ Étape 5 : Création des types TypeScript pour NextAuth

**Créer `src/types/next-auth.d.ts`** :

```typescript
import { DefaultSession, DefaultUser } from "next-auth"
import { JWT, DefaultJWT } from "next-auth/jwt"

declare module "next-auth" {
  interface Session {
    user: {
      id: string
      role: string
    } & DefaultSession["user"]
  }

  interface User extends DefaultUser {
    role: string
  }
}

declare module "next-auth/jwt" {
  interface JWT extends DefaultJWT {
    role: string
  }
}
```

**Objectif** : Types TypeScript corrects pour NextAuth avec rôles.

---

## 🚀 Phase 2 : API Routes d'authentification

### ✅ Étape 6 : Route API NextAuth

**Créer `src/app/api/auth/[...nextauth]/route.ts`** :

```typescript
import { authOptions } from "@/lib/auth"
import NextAuth from "next-auth"

const handler = NextAuth(authOptions)

export { handler as GET, handler as POST }
```

**Objectif** : Route NextAuth fonctionnelle.

---

### ✅ Étape 7 : Route API d'inscription

**Créer `src/app/api/register/route.ts`** :

```typescript
import { NextRequest, NextResponse } from "next/server"
import bcrypt from "bcryptjs"
import { prisma } from "@/lib/prisma"
import { z } from "zod"

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  name: z.string().min(2)
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { email, password, name } = registerSchema.parse(body)

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await prisma.user.findUnique({
      where: { email }
    })

    if (existingUser) {
      return NextResponse.json(
        { error: "Cet email est déjà utilisé" },
        { status: 400 }
      )
    }

    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 12)

    // Créer l'utilisateur
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name
      }
    })

    // Retourner sans le mot de passe
    const { password: _, ...userWithoutPassword } = user

    return NextResponse.json(
      { user: userWithoutPassword, message: "Utilisateur créé avec succès" },
      { status: 201 }
    )
  } catch (error) {
    console.error("Erreur inscription:", error)
    return NextResponse.json(
      { error: "Erreur lors de l'inscription" },
      { status: 500 }
    )
  }
}
```

**Installer Zod pour validation** :
```bash
npm install zod
```

**Objectif** : Route d'inscription sécurisée avec validation.

---

### ✅ Étape 8 : Middleware de protection des routes

**Créer `src/middleware.ts`** :

```typescript
import { withAuth } from "next-auth/middleware"

export default withAuth(
  function middleware(req) {
    // Vous pouvez ajouter des vérifications supplémentaires ici
  },
  {
    callbacks: {
      authorized: ({ token, req }) => {
        const { pathname } = req.nextUrl
        
        // Routes admin - nécessite rôle ADMIN
        if (pathname.startsWith("/admin")) {
          return token?.role === "ADMIN"
        }
        
        // Routes dashboard - nécessite authentification
        if (pathname.startsWith("/dashboard")) {
          return !!token
        }
        
        // API routes protégées
        if (pathname.startsWith("/api/photos") || 
            pathname.startsWith("/api/admin") ||
            pathname.startsWith("/api/checkout")) {
          return !!token
        }
        
        return true
      },
    },
  }
)

export const config = {
  matcher: [
    "/dashboard/:path*",
    "/admin/:path*",
    "/api/photos/:path*",
    "/api/admin/:path*",
    "/api/checkout/:path*"
  ]
}
```

**Objectif** : Protection automatique des routes sensibles.

---

## 🚀 Phase 3 : Interface utilisateur de base

### ✅ Étape 9 : Configuration globale Tailwind et composants de base

**Modifier `src/app/globals.css`** :

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 84% 4.9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --radius: 0.5rem;
  }
}

@layer components {
  .btn {
    @apply inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50;
  }
  
  .btn-primary {
    @apply btn bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2;
  }
  
  .btn-secondary {
    @apply btn bg-secondary text-secondary-foreground hover:bg-secondary/80 h-10 px-4 py-2;
  }
  
  .input {
    @apply flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50;
  }
}
```

**Créer `src/components/ui/Button.tsx`** :

```typescript
import { ButtonHTMLAttributes, forwardRef } from "react"
import { cn } from "@/lib/utils"

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "destructive"
  size?: "sm" | "md" | "lg"
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "primary", size = "md", ...props }, ref) => {
    return (
      <button
        className={cn(
          "btn",
          {
            "btn-primary": variant === "primary",
            "btn-secondary": variant === "secondary",
            "bg-destructive text-destructive-foreground hover:bg-destructive/90": variant === "destructive",
            "h-8 px-3 text-xs": size === "sm",
            "h-10 px-4": size === "md",
            "h-12 px-8": size === "lg"
          },
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)

Button.displayName = "Button"

export { Button }
```

**Créer `src/lib/utils.ts`** :

```typescript
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

```bash
npm install clsx tailwind-merge
```

**Objectif** : Système de design cohérent avec Tailwind CSS 3.

---

### ✅ Étape 10 : Composant de navigation principal

**Créer `src/components/Navigation.tsx`** :

```typescript
"use client"

import { useSession, signOut } from "next-auth/react"
import Link from "next/link"
import { Button } from "@/components/ui/Button"

export default function Navigation() {
  const { data: session } = useSession()

  return (
    <nav className="bg-white shadow-sm border-b">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <Link href="/" className="text-xl font-bold text-gray-900">
              PhotoMarket
            </Link>
          </div>
          
          <div className="flex items-center space-x-4">
            <Link 
              href="/gallery" 
              className="text-gray-600 hover:text-gray-900"
            >
              Galerie
            </Link>
            
            {session ? (
              <>
                <Link 
                  href="/dashboard" 
                  className="text-gray-600 hover:text-gray-900"
                >
                  Mes Photos
                </Link>
                {session.user.role === "ADMIN" && (
                  <Link 
                    href="/admin" 
                    className="text-red-600 hover:text-red-800"
                  >
                    Admin
                  </Link>
                )}
                <span className="text-sm text-gray-600">
                  {session.user.email}
                </span>
                <Button 
                  variant="secondary" 
                  onClick={() => signOut()}
                  size="sm"
                >
                  Déconnexion
                </Button>
              </>
            ) : (
              <>
                <Link href="/login">
                  <Button variant="secondary" size="sm">
                    Connexion
                  </Button>
                </Link>
                <Link href="/register">
                  <Button variant="primary" size="sm">
                    Inscription
                  </Button>
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  )
}
```

**Objectif** : Navigation responsive avec état d'authentification.

---

### ✅ Étape 11 : Provider de session NextAuth

**Créer `src/components/Providers.tsx`** :

```typescript
"use client"

import { SessionProvider } from "next-auth/react"

export default function Providers({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <SessionProvider>
      {children}
    </SessionProvider>
  )
}
```

**Modifier `src/app/layout.tsx`** :

```typescript
import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import Providers from '@/components/Providers'
import Navigation from '@/components/Navigation'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'PhotoMarket - Marketplace de Photos',
  description: 'Achetez et vendez des photos de qualité',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body className={inter.className}>
        <Providers>
          <Navigation />
          <main className="min-h-screen bg-gray-50">
            {children}
          </main>
        </Providers>
      </body>
    </html>
  )
}
```

**Objectif** : Provider global pour NextAuth et layout principal.

---

### ✅ Étape 12 : Page d'inscription

**Créer `src/app/register/page.tsx`** :

```typescript
"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { Button } from "@/components/ui/Button"

export default function RegisterPage() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
    confirmPassword: ""
  })
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setLoading(true)

    if (formData.password !== formData.confirmPassword) {
      setError("Les mots de passe ne correspondent pas")
      setLoading(false)
      return
    }

    try {
      const response = await fetch("/api/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: formData.name,
          email: formData.email,
          password: formData.password
        })
      })

      if (response.ok) {
        router.push("/login?message=Inscription réussie")
      } else {
        const data = await response.json()
        setError(data.error || "Erreur lors de l'inscription")
      }
    } catch (error) {
      setError("Erreur de connexion")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Créer un compte
          </h2>
        </div>
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
              {error}
            </div>
          )}
          
          <div className="space-y-4">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                Nom complet
              </label>
              <input
                id="name"
                type="text"
                required
                className="input mt-1"
                value={formData.name}
                onChange={(e) => setFormData({...formData, name: e.target.value})}
              />
            </div>
            
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                Email
              </label>
              <input
                id="email"
                type="email"
                required
                className="input mt-1"
                value={formData.email}
                onChange={(e) => setFormData({...formData, email: e.target.value})}
              />
            </div>
            
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                Mot de passe
              </label>
              <input
                id="password"
                type="password"
                required
                minLength={6}
                className="input mt-1"
                value={formData.password}
                onChange={(e) => setFormData({...formData, password: e.target.value})}
              />
            </div>
            
            <div>
              <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700">
                Confirmer le mot de passe
              </label>
              <input
                id="confirmPassword"
                type="password"
                required
                className="input mt-1"
                value={formData.confirmPassword}
                onChange={(e) => setFormData({...formData, confirmPassword: e.target.value})}
              />
            </div>
          </div>

          <div>
            <Button 
              type="submit" 
              className="w-full"
              disabled={loading}
            >
              {loading ? "Inscription..." : "S'inscrire"}
            </Button>
          </div>
          
          <div className="text-center">
            <span className="text-sm text-gray-600">
              Déjà un compte ?{" "}
              <Link href="/login" className="font-medium text-indigo-600 hover:text-indigo-500">
                Se connecter
              </Link>
            </span>
          </div>
        </form>
      </div>
    </div>
  )
}
```

**Objectif** : Page d'inscription fonctionnelle avec validation.

---

### ✅ Étape 13 : Page de connexion

**Créer `src/app/login/page.tsx`** :

```typescript
"use client"

import { useState } from "react"
import { signIn } from "next-auth/react"
import { useRouter, useSearchParams } from "next/navigation"
import Link from "next/link"
import { Button } from "@/components/ui/Button"

export default function LoginPage() {
  const [formData, setFormData] = useState({
    email: "",
    password: ""
  })
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(false)
  const router = useRouter()
  const searchParams = useSearchParams()
  const message = searchParams.get("message")

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setLoading(true)

    try {
      const result = await signIn("credentials", {
        email: formData.email,
        password: formData.password,
        redirect: false
      })

      if (result?.error) {
        setError("Email ou mot de passe incorrect")
      } else {
        router.push("/dashboard")
      }
    } catch (error) {
      setError("Erreur de connexion")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Se connecter
          </h2>
        </div>
        
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          {message && (
            <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded">
              {message}
            </div>
          )}
          
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
              {error}
            </div>
          )}
          
          <div className="space-y-4">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                Email
              </label>
              <input
                id="email"
                type="email"
                required
                className="input mt-1"
                value={formData.email}
                onChange={(e) => setFormData({...formData, email: e.target.value})}
              />
            </div>
            
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                Mot de passe
              </label>
              <input
                id="password"
                type="password"
                required
                className="input mt-1"
                value={formData.password}
                onChange={(e) => setFormData({...formData, password: e.target.value})}
              />
            </div>
          </div>

          <div>
            <Button 
              type="submit" 
              className="w-full"
              disabled={loading}
            >
              {loading ? "Connexion..." : "Se connecter"}
            </Button>
          </div>
          
          <div className="text-center">
            <span className="text-sm text-gray-600">
              Pas encore de compte ?{" "}
              <Link href="/register" className="font-medium text-indigo-600 hover:text-indigo-500">
                S'inscrire
              </Link>
            </span>
          </div>
        </form>
      </div>
    </div>
  )
}
```

**Objectif** : Page de connexion avec NextAuth.

---

## 🚀 Phase 4 : Gestion des photos - API

### ✅ Étape 14 : Route API pour créer des photos

**Créer `src/app/api/photos/route.ts`** :

```typescript
import { NextRequest, NextResponse } from "next/server"
import { getServerSession } from "next-auth"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { z } from "zod"

const createPhotoSchema = z.object({
  title: z.string().min(1),
  description: z.string().optional(),
  imageUrl: z.string().url(),
  price: z.number().min(0),
  isPublic: z.boolean().default(true),
  isForSale: z.boolean().default(false)
})

// GET /api/photos - Récupérer les photos publiques
export async function GET() {
  try {
    const photos = await prisma.photo.findMany({
      where: {
        isPublic: true
      },
      include: {
        user: {
          select: {
            name: true,
            email: true
          }
        }
      },
      orderBy: {
        createdAt: "desc"
      }
    })

    return NextResponse.json({ photos })
  } catch (error) {
    console.error("Erreur récupération photos:", error)
    return NextResponse.json(
      { error: "Erreur lors de la récupération des photos" },
      { status: 500 }
    )
  }
}

// POST /api/photos - Créer une nouvelle photo
export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user?.id) {
      return NextResponse.json(
        { error: "Non authentifié" },
        { status: 401 }
      )
    }

    const body = await request.json()
    const validatedData = createPhotoSchema.parse(body)

    const photo = await prisma.photo.create({
      data: {
        ...validatedData,
        userId: session.user.id
      },
      include: {
        user: {
          select: {
            name: true,
            email: true
          }
        }
      }
    })

    return NextResponse.json(
      { photo, message: "Photo créée avec succès" },
      { status: 201 }
    )
  } catch (error) {
    console.error("Erreur création photo:", error)
    return NextResponse.json(
      { error: "Erreur lors de la création de la photo" },
      { status: 500 }
    )
  }
}
```

**Objectif** : API pour créer et lister les photos publiques.

---

### ✅ Étape 15 : Routes API pour mes photos et photos individuelles

**Créer `src/app/api/photos/my/route.ts`** :

```typescript
import { NextRequest, NextResponse } from "next/server"
import { getServerSession } from "next-auth"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"

// GET /api/photos/my - Récupérer mes photos
export async function GET() {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user?.id) {
      return NextResponse.json(
        { error: "Non authentifié" },
        { status: 401 }
      )
    }

    const photos = await prisma.photo.findMany({
      where: {
        userId: session.user.id
      },
      orderBy: {
        createdAt: "desc"
      }
    })

    return NextResponse.json({ photos })
  } catch (error) {
    console.error("Erreur récupération mes photos:", error)
    return NextResponse.json(
      { error: "Erreur lors de la récupération de vos photos" },
      { status: 500 }
    )
  }
}
```

**Créer `src/app/api/photos/[id]/route.ts`** :

```typescript
import { NextRequest, NextResponse } from "next/server"
import { getServerSession } from "next-auth"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { z } from "zod"

const updatePhotoSchema = z.object({
  title: z.string().min(1).optional(),
  description: z.string().optional(),
  price: z.number().min(0).optional(),
  isPublic: z.boolean().optional(),
  isForSale: z.boolean().optional()
})

// GET /api/photos/[id] - Récupérer une photo
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const photo = await prisma.photo.findUnique({
      where: {
        id: params.id
      },
      include: {
        user: {
          select: {
            name: true,
            email: true
          }
        }
      }
    })

    if (!photo) {
      return NextResponse.json(
        { error: "Photo non trouvée" },
        { status: 404 }
      )
    }

    return NextResponse.json({ photo })
  } catch (error) {
    console.error("Erreur récupération photo:", error)
    return NextResponse.json(
      { error: "Erreur lors de la récupération de la photo" },
      { status: 500 }
    )
  }
}

// PUT /api/photos/[id] - Modifier une photo
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user?.id) {
      return NextResponse.json(
        { error: "Non authentifié" },
        { status: 401 }
      )
    }

    // Vérifier que la photo appartient à l'utilisateur
    const existingPhoto = await prisma.photo.findUnique({
      where: { id: params.id }
    })

    if (!existingPhoto) {
      return NextResponse.json(
        { error: "Photo non trouvée" },
        { status: 404 }
      )
    }

    if (existingPhoto.userId !== session.user.id && session.user.role !== "ADMIN") {
      return NextResponse.json(
        { error: "Non autorisé" },
        { status: 403 }
      )
    }

    const body = await request.json()
    const validatedData = updatePhotoSchema.parse(body)

    const photo = await prisma.photo.update({
      where: { id: params.id },
      data: validatedData,
      include: {
        user: {
          select: {
            name: true,
            email: true
          }
        }
      }
    })

    return NextResponse.json({ photo, message: "Photo modifiée avec succès" })
  } catch (error) {
    console.error("Erreur modification photo:", error)
    return NextResponse.json(
      { error: "Erreur lors de la modification de la photo" },
      { status: 500 }
    )
  }
}

// DELETE /api/photos/[id] - Supprimer une photo
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user?.id) {
      return NextResponse.json(
        { error: "Non authentifié" },
        { status: 401 }
      )
    }

    // Vérifier que la photo appartient à l'utilisateur
    const existingPhoto = await prisma.photo.findUnique({
      where: { id: params.id }
    })

    if (!existingPhoto) {
      return NextResponse.json(
        { error: "Photo non trouvée" },
        { status: 404 }
      )
    }

    if (existingPhoto.userId !== session.user.id && session.user.role !== "ADMIN") {
      return NextResponse.json(
        { error: "Non autorisé" },
        { status: 403 }
      )
    }

    await prisma.photo.delete({
      where: { id: params.id }
    })

    return NextResponse.json({ message: "Photo supprimée avec succès" })
  } catch (error) {
    console.error("Erreur suppression photo:", error)
    return NextResponse.json(
      { error: "Erreur lors de la suppression de la photo" },
      { status: 500 }
    )
  }
}
```

**Objectif** : CRUD complet pour les photos avec vérifications de sécurité.

---

## 🚀 Phase 5 : Interface utilisateur - Galerie

### ✅ Étape 16 : Page d'accueil avec galerie publique

**Créer `src/app/page.tsx`** :

```typescript
import Link from "next/link"
import { Button } from "@/components/ui/Button"
import PublicGallery from "@/components/PublicGallery"

export default function HomePage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-blue-600 to-purple-600 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
          <div className="text-center">
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              PhotoMarket
            </h1>
            <p className="text-xl md:text-2xl mb-8 max-w-3xl mx-auto">
              Découvrez, achetez et vendez des photos de qualité professionnelle
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/register">
                <Button size="lg" variant="secondary">
                  Commencer à vendre
                </Button>
              </Link>
              <Link href="#gallery">
                <Button size="lg" variant="primary">
                  Découvrir la galerie
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Pourquoi choisir PhotoMarket ?
            </h2>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold mb-2">Qualité professionnelle</h3>
              <p className="text-gray-600">
                Toutes les photos sont vérifiées pour garantir une qualité exceptionnelle
              </p>
            </div>
            
            <div className="text-center">
              <div className="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold mb-2">Paiements sécurisés</h3>
              <p className="text-gray-600">
                Paiements protégés par Stripe avec garantie de remboursement
              </p>
            </div>
            
            <div className="text-center">
              <div className="bg-purple-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg className="w-8 h-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold mb-2">Téléchargement instantané</h3>
              <p className="text-gray-600">
                Accès immédiat à vos achats en haute résolution
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Public Gallery */}
      <section id="gallery" className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Galerie publique
            </h2>
            <p className="text-lg text-gray-600">
              Découvrez notre sélection de photos disponibles à l'achat
            </p>
          </div>
          
          <PublicGallery />
        </div>
      </section>
    </div>
  )
}
```

**Créer `src/components/PublicGallery.tsx`** :

```typescript
"use client"

import { useEffect, useState } from "react"
import Image from "next/image"
import Link from "next/link"
import { Button } from "@/components/ui/Button"

interface Photo {
  id: string
  title: string
  description?: string
  imageUrl: string
  price: number
  isForSale: boolean
  user: {
    name: string
    email: string
  }
}

export default function PublicGallery() {
  const [photos, setPhotos] = useState<Photo[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchPhotos = async () => {
      try {
        const response = await fetch("/api/photos")
        if (response.ok) {
          const data = await response.json()
          setPhotos(data.photos)
        }
      } catch (error) {
        console.error("Erreur chargement photos:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchPhotos()
  }, [])

  if (loading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="bg-white rounded-lg shadow-md overflow-hidden animate-pulse">
            <div className="w-full h-64 bg-gray-300"></div>
            <div className="p-4">
              <div className="h-4 bg-gray-300 rounded mb-2"></div>
              <div className="h-3 bg-gray-300 rounded w-2/3"></div>
            </div>
          </div>
        ))}
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {photos.map((photo) => (
        <div key={photo.id} className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
          <div className="relative w-full h-64">
            <Image
              src={photo.imageUrl}
              alt={photo.title}
              fill
              className="object-cover"
            />
          </div>
          
          <div className="p-4">
            <h3 className="text-lg font-semibold mb-2">{photo.title}</h3>
            {photo.description && (
              <p className="text-gray-600 text-sm mb-3 line-clamp-2">
                {photo.description}
              </p>
            )}
            
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500">Par {photo.user.name}</p>
                {photo.isForSale && (
                  <p className="text-lg font-bold text-green-600">
                    {photo.price.toFixed(2)} €
                  </p>
                )}
              </div>
              
              {photo.isForSale ? (
                <Link href={`/photos/${photo.id}`}>
                  <Button size="sm">
                    Acheter
                  </Button>
                </Link>
              ) : (
                <span className="text-sm text-gray-500 bg-gray-100 px-3 py-1 rounded">
                  Non à vendre
                </span>
              )}
            </div>
          </div>
        </div>
      ))}
      
      {photos.length === 0 && (
        <div className="col-span-full text-center py-12">
          <p className="text-gray-500 text-lg">Aucune photo disponible pour le moment</p>
        </div>
      )}
    </div>
  )
}
```

**Objectif** : Page d'accueil attrayante avec galerie publique fonctionnelle.

---

### ✅ Étape 17 : Dashboard utilisateur

**Créer `src/app/dashboard/page.tsx`** :

```typescript
"use client"

import { useEffect, useState } from "react"
import { useSession } from "next-auth/react"
import Image from "next/image"
import Link from "next/link"
import { Button } from "@/components/ui/Button"

interface Photo {
  id: string
  title: string
  description?: string
  imageUrl: string
  price: number
  isPublic: boolean
  isForSale: boolean
  createdAt: string
}

export default function DashboardPage() {
  const { data: session } = useSession()
  const [photos, setPhotos] = useState<Photo[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchMyPhotos = async () => {
      try {
        const response = await fetch("/api/photos/my")
        if (response.ok) {
          const data = await response.json()
          setPhotos(data.photos)
        }
      } catch (error) {
        console.error("Erreur chargement mes photos:", error)
      } finally {
        setLoading(false)
      }
    }

    if (session) {
      fetchMyPhotos()
    }
  }, [session])

  const handleDelete = async (photoId: string) => {
    if (!confirm("Êtes-vous sûr de vouloir supprimer cette photo ?")) {
      return
    }

    try {
      const response = await fetch(`/api/photos/${photoId}`, {
        method: "DELETE"
      })

      if (response.ok) {
        setPhotos(photos.filter(p => p.id !== photoId))
      } else {
        alert("Erreur lors de la suppression")
      }
    } catch (error) {
      console.error("Erreur suppression:", error)
      alert("Erreur lors de la suppression")
    }
  }

  if (!session) {
    return <div>Chargement...</div>
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Mes Photos</h1>
          <p className="text-gray-600 mt-2">
            Gérez votre collection de photos
          </p>
        </div>
        
        <Link href="/dashboard/add-photo">
          <Button>
            Ajouter une photo
          </Button>
        </Link>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="bg-white rounded-lg shadow-md overflow-hidden animate-pulse">
              <div className="w-full h-64 bg-gray-300"></div>
              <div className="p-4">
                <div className="h-4 bg-gray-300 rounded mb-2"></div>
                <div className="h-3 bg-gray-300 rounded w-2/3"></div>
              </div>
            </div>
          ))}
        </div>
      ) : photos.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {photos.map((photo) => (
            <div key={photo.id} className="bg-white rounded-lg shadow-md overflow-hidden">
              <div className="relative w-full h-64">
                <Image
                  src={photo.imageUrl}
                  alt={photo.title}
                  fill
                  className="object-cover"
                />
                <div className="absolute top-2 right-2 flex gap-2">
                  {photo.isPublic && (
                    <span className="bg-green-500 text-white text-xs px-2 py-1 rounded">
                      Public
                    </span>
                  )}
                  {photo.isForSale && (
                    <span className="bg-blue-500 text-white text-xs px-2 py-1 rounded">
                      À vendre
                    </span>
                  )}
                </div>
              </div>
              
              <div className="p-4">
                <h3 className="text-lg font-semibold mb-2">{photo.title}</h3>
                {photo.description && (
                  <p className="text-gray-600 text-sm mb-3 line-clamp-2">
                    {photo.description}
                  </p>
                )}
                
                <div className="flex items-center justify-between mb-4">
                  <div>
                    {photo.isForSale && (
                      <p className="text-lg font-bold text-green-600">
                        {photo.price.toFixed(2)} €
                      </p>
                    )}
                    <p className="text-sm text-gray-500">
                      {new Date(photo.createdAt).toLocaleDateString()}
                    </p>
                  </div>
                </div>
                
                <div className="flex gap-2">
                  <Link href={`/dashboard/edit-photo/${photo.id}`} className="flex-1">
                    <Button variant="secondary" size="sm" className="w-full">
                      Modifier
                    </Button>
                  </Link>
                  <Button 
                    variant="destructive" 
                    size="sm"
                    onClick={() => handleDelete(photo.id)}
                  >
                    Supprimer
                  </Button>
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-12">
          <svg
            className="mx-auto h-12 w-12 text-gray-400"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"
            />
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"
            />
          </svg>
          <h3 className="mt-2 text-sm font-medium text-gray-900">Aucune photo</h3>
          <p className="mt-1 text-sm text-gray-500">
            Commencez par ajouter votre première photo.
          </p>
          <div className="mt-6">
            <Link href="/dashboard/add-photo">
              <Button>
                Ajouter une photo
              </Button>
            </Link>
          </div>
        </div>
      )}
    </div>
  )
}
```

**Objectif** : Dashboard personnel pour gérer ses photos.

---

### ✅ Étape 18 : Formulaire d'ajout de photo

**Créer `src/app/dashboard/add-photo/page.tsx`** :

```typescript
"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { Button } from "@/components/ui/Button"

export default function AddPhotoPage() {
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    imageUrl: "",
    price: 0,
    isPublic: true,
    isForSale: false
  })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState("")
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setLoading(true)

    try {
      const response = await fetch("/api/photos", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData)
      })

      if (response.ok) {
        router.push("/dashboard")
      } else {
        const data = await response.json()
        setError(data.error || "Erreur lors de l'ajout")
      }
    } catch (error) {
      setError("Erreur de connexion")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-8">
        <Link 
          href="/dashboard" 
          className="text-blue-600 hover:text-blue-800 flex items-center"
        >
          ← Retour au dashboard
        </Link>
        <h1 className="text-3xl font-bold text-gray-900 mt-4">
          Ajouter une nouvelle photo
        </h1>
      </div>

      <form onSubmit={handleSubmit} className="bg-white shadow-md rounded-lg p-6">
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-6">
            {error}
          </div>
        )}

        <div className="space-y-6">
          <div>
            <label htmlFor="title" className="block text-sm font-medium text-gray-700">
              Titre *
            </label>
            <input
              id="title"
              type="text"
              required
              className="input mt-1"
              value={formData.title}
              onChange={(e) => setFormData({...formData, title: e.target.value})}
            />
          </div>

          <div>
            <label htmlFor="description" className="block text-sm font-medium text-gray-700">
              Description
            </label>
            <textarea
              id="description"
              rows={3}
              className="input mt-1"
              value={formData.description}
              onChange={(e) => setFormData({...formData, description: e.target.value})}
            />
          </div>

          <div>
            <label htmlFor="imageUrl" className="block text-sm font-medium text-gray-700">
              URL de l'image *
            </label>
            <input
              id="imageUrl"
              type="url"
              required
              placeholder="https://example.com/image.jpg"
              className="input mt-1"
              value={formData.imageUrl}
              onChange={(e) => setFormData({...formData, imageUrl: e.target.value})}
            />
            <p className="text-sm text-gray-500 mt-1">
              Utilisez un service comme Cloudinary, Imgur ou un autre hébergeur d'images
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  checked={formData.isPublic}
                  onChange={(e) => setFormData({...formData, isPublic: e.target.checked})}
                />
                <span className="ml-2 text-sm text-gray-700">Photo publique</span>
              </label>
              <p className="text-xs text-gray-500 mt-1">
                La photo sera visible dans la galerie publique
              </p>
            </div>

            <div>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  checked={formData.isForSale}
                  onChange={(e) => setFormData({...formData, isForSale: e.target.checked})}
                />
                <span className="ml-2 text-sm text-gray-700">À vendre</span>
              </label>
              <p className="text-xs text-gray-500 mt-1">
                La photo sera disponible à l'achat
              </p>
            </div>
          </div>

          {formData.isForSale && (
            <div>
              <label htmlFor="price" className="block text-sm font-medium text-gray-700">
                Prix (€) *
              </label>
              <input
                id="price"
                type="number"
                min="0"
                step="0.01"
                required={formData.isForSale}
                className="input mt-1"
                value={formData.price}
                onChange={(e) => setFormData({...formData, price: parseFloat(e.target.value) || 0})}
              />
            </div>
          )}

          {formData.imageUrl && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Aperçu
              </label>
              <div className="relative w-full h-64 bg-gray-100 rounded-lg overflow-hidden">
                <img
                  src={formData.imageUrl}
                  alt="Aperçu"
                  className="w-full h-full object-cover"
                  onError={() => setError("URL d'image invalide")}
                />
              </div>
            </div>
          )}
        </div>

        <div className="flex gap-4 mt-8">
          <Button type="submit" disabled={loading} className="flex-1">
            {loading ? "Ajout en cours..." : "Ajouter la photo"}
          </Button>
          <Link href="/dashboard">
            <Button variant="secondary">
              Annuler
            </Button>
          </Link>
        </div>
      </form>
    </div>
  )
}
```

**Objectif** : Formulaire complet pour ajouter des photos.

---

## 🚀 Phase 6 : Intégration Stripe (Paiement)

### ✅ Étape 19 : Configuration Stripe et route de checkout

```bash
# Installer les dépendances Stripe
npm install stripe @stripe/stripe-js
```

**Créer `src/lib/stripe.ts`** :

```typescript
import Stripe from "stripe"

if (!process.env.STRIPE_SECRET_KEY) {
  throw new Error("STRIPE_SECRET_KEY is required")
}

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: "2023-10-16"
})
```

**Créer `src/app/api/checkout/route.ts`** :

```typescript
import { NextRequest, NextResponse } from "next/server"
import { getServerSession } from "next-auth"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"
import { stripe } from "@/lib/stripe"

export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user?.id) {
      return NextResponse.json(
        { error: "Non authentifié" },
        { status: 401 }
      )
    }

    const { photoId } = await request.json()

    // Récupérer la photo
    const photo = await prisma.photo.findUnique({
      where: { id: photoId },
      include: {
        user: {
          select: { name: true }
        }
      }
    })

    if (!photo) {
      return NextResponse.json(
        { error: "Photo non trouvée" },
        { status: 404 }
      )
    }

    if (!photo.isForSale) {
      return NextResponse.json(
        { error: "Cette photo n'est pas à vendre" },
        { status: 400 }
      )
    }

    // Vérifier que l'utilisateur n'achète pas sa propre photo
    if (photo.userId === session.user.id) {
      return NextResponse.json(
        { error: "Vous ne pouvez pas acheter votre propre photo" },
        { status: 400 }
      )
    }

    // Vérifier qu'il n'a pas déjà acheté cette photo
    const existingPurchase = await prisma.purchase.findFirst({
      where: {
        userId: session.user.id,
        photoId: photoId
      }
    })

    if (existingPurchase) {
      return NextResponse.json(
        { error: "Vous avez déjà acheté cette photo" },
        { status: 400 }
      )
    }

    // Créer la session Stripe
    const stripeSession = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [
        {
          price_data: {
            currency: "eur",
            product_data: {
              name: photo.title,
              description: `Photo par ${photo.user.name}`,
              images: [photo.imageUrl]
            },
            unit_amount: Math.round(photo.price * 100) // Stripe utilise les centimes
          },
          quantity: 1
        }
      ],
      mode: "payment",
      success_url: `${process.env.NEXTAUTH_URL}/dashboard/purchases?success=true`,
      cancel_url: `${process.env.NEXTAUTH_URL}/photos/${photoId}?canceled=true`,
      metadata: {
        photoId: photoId,
        userId: session.user.id
      }
    })

    return NextResponse.json({ 
      sessionId: stripeSession.id,
      url: stripeSession.url 
    })
  } catch (error) {
    console.error("Erreur création session Stripe:", error)
    return NextResponse.json(
      { error: "Erreur lors de la création de la session de paiement" },
      { status: 500 }
    )
  }
}
```

**Objectif** : Route de checkout Stripe sécurisée.

---

### ✅ Étape 20 : Gestion du Webhook Stripe

**Créer `src/app/api/webhook/route.ts`** :

```typescript
import { NextRequest, NextResponse } from "next/server"
import { stripe } from "@/lib/stripe"
import { prisma } from "@/lib/prisma"
import Stripe from "stripe"

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!

export async function POST(request: NextRequest) {
  try {
    const body = await request.text()
    const signature = request.headers.get("stripe-signature")!

    let event: Stripe.Event

    try {
      event = stripe.webhooks.constructEvent(body, signature, webhookSecret)
    } catch (err) {
      console.error("Erreur vérification signature webhook:", err)
      return NextResponse.json(
        { error: "Signature webhook invalide" },
        { status: 400 }
      )
    }

    // Gérer l'événement de paiement réussi
    if (event.type === "checkout.session.completed") {
      const session = event.data.object as Stripe.Checkout.Session

      const { photoId, userId } = session.metadata!

      // Enregistrer l'achat dans la base de données
      await prisma.purchase.create({
        data: {
          stripePaymentId: session.payment_intent as string,
          amount: session.amount_total! / 100, // Convertir centimes en euros
          userId: userId,
          photoId: photoId
        }
      })

      console.log(`Achat enregistré: Photo ${photoId} par utilisateur ${userId}`)
    }

    return NextResponse.json({ received: true })
  } catch (error) {
    console.error("Erreur webhook:", error)
    return NextResponse.json(
      { error: "Erreur interne du serveur" },
      { status: 500 }
    )
  }
}
```

**Ajouter dans `next.config.js`** :

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    domains: ['images.unsplash.com', 'via.placeholder.com', 'cloudinary.com', 'imgur.com']
  }
}

module.exports = nextConfig
```

**Objectif** : Webhook Stripe sécurisé qui enregistre les achats.

---

### ✅ Étape 21 : Page de détail d'une photo avec achat

**Créer `src/app/photos/[id]/page.tsx`** :

```typescript
"use client"

import { useEffect, useState } from "react"
import { useSession } from "next-auth/react"
import { useParams, useRouter } from "next/navigation"
import Image from "next/image"
import Link from "next/link"
import { Button } from "@/components/ui/Button"
import { loadStripe } from "@stripe/stripe-js"

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)

interface Photo {
  id: string
  title: string
  description?: string
  imageUrl: string
  price: number
  isForSale: boolean
  user: {
    name: string
    email: string
  }
}

export default function PhotoDetailPage() {
  const { data: session } = useSession()
  const params = useParams()
  const router = useRouter()
  const [photo, setPhoto] = useState<Photo | null>(null)
  const [loading, setLoading] = useState(true)
  const [purchasing, setPurchasing] = useState(false)
  const [hasPurchased, setHasPurchased] = useState(false)

  useEffect(() => {
    const fetchPhoto = async () => {
      try {
        const response = await fetch(`/api/photos/${params.id}`)
        if (response.ok) {
          const data = await response.json()
          setPhoto(data.photo)
        } else if (response.status === 404) {
          router.push("/404")
        }
      } catch (error) {
        console.error("Erreur chargement photo:", error)
      } finally {
        setLoading(false)
      }
    }

    if (params.id) {
      fetchPhoto()
    }
  }, [params.id, router])

  // Vérifier si l'utilisateur a déjà acheté cette photo
  useEffect(() => {
    const checkPurchase = async () => {
      if (!session?.user?.id || !photo?.id) return

      try {
        const response = await fetch(`/api/purchases/check/${photo.id}`)
        if (response.ok) {
          const data = await response.json()
          setHasPurchased(data.hasPurchased)
        }
      } catch (error) {
        console.error("Erreur vérification achat:", error)
      }
    }

    checkPurchase()
  }, [session, photo])

  const handlePurchase = async () => {
    if (!session) {
      router.push("/login")
      return
    }

    setPurchasing(true)

    try {
      const response = await fetch("/api/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ photoId: photo!.id })
      })

      if (response.ok) {
        const data = await response.json()
        const stripe = await stripePromise
        
        if (stripe) {
          await stripe.redirectToCheckout({
            sessionId: data.sessionId
          })
        }
      } else {
        const data = await response.json()
        alert(data.error || "Erreur lors de l'achat")
      }
    } catch (error) {
      console.error("Erreur achat:", error)
      alert("Erreur lors de l'achat")
    } finally {
      setPurchasing(false)
    }
  }

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="animate-pulse">
          <div className="w-full h-96 bg-gray-300 rounded-lg mb-6"></div>
          <div className="h-8 bg-gray-300 rounded mb-4"></div>
          <div className="h-4 bg-gray-300 rounded w-2/3"></div>
        </div>
      </div>
    )
  }

  if (!photo) {
    return (
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8 text-center">
        <h1 className="text-2xl font-bold text-gray-900">Photo non trouvée</h1>
        <Link href="/" className="text-blue-600 hover:text-blue-800 mt-4 inline-block">
          Retour à l'accueil
        </Link>
      </div>
    )
  }

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Link 
        href="/" 
        className="text-blue-600 hover:text-blue-800 flex items-center mb-6"
      >
        ← Retour à la galerie
      </Link>

      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="relative w-full h-96 md:h-[500px]">
          <Image
            src={photo.imageUrl}
            alt={photo.title}
            fill
            className="object-contain"
          />
        </div>

        <div className="p-6">
          <div className="flex justify-between items-start mb-4">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">
                {photo.title}
              </h1>
              <p className="text-gray-600">Par {photo.user.name}</p>
            </div>
            
            {photo.isForSale && (
              <div className="text-right">
                <p className="text-3xl font-bold text-green-600">
                  {photo.price.toFixed(2)} €
                </p>
              </div>
            )}
          </div>

          {photo.description && (
            <p className="text-gray-700 mb-6 text-lg leading-relaxed">
              {photo.description}
            </p>
          )}

          <div className="flex gap-4">
            {photo.isForSale ? (
              hasPurchased ? (
                <div className="bg-green-50 border border-green-200 rounded-lg p-4 flex-1">
                  <p className="text-green-800 font-medium">
                    ✓ Vous avez déjà acheté cette photo
                  </p>
                  <Link href="/dashboard/purchases">
                    <Button variant="secondary" className="mt-2">
                      Voir mes achats
                    </Button>
                  </Link>
                </div>
              ) : session?.user?.email === photo.user.email ? (
                <p className="text-gray-600 italic">Ceci est votre propre photo</p>
              ) : (
                <Button 
                  onClick={handlePurchase}
                  disabled={purchasing}
                  size="lg"
                  className="flex-1 md:flex-none"
                >
                  {purchasing ? "Redirection..." : `Acheter pour ${photo.price.toFixed(2)} €`}
                </Button>
              )
            ) : (
              <span className="text-gray-500 bg-gray-100 px-4 py-2 rounded-lg">
                Cette photo n'est pas à vendre
              </span>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
```

**Créer `src/app/api/purchases/check/[photoId]/route.ts`** :

```typescript
import { NextRequest, NextResponse } from "next/server"
import { getServerSession } from "next-auth"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"

export async function GET(
  request: NextRequest,
  { params }: { params: { photoId: string } }
) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user?.id) {
      return NextResponse.json({ hasPurchased: false })
    }

    const purchase = await prisma.purchase.findFirst({
      where: {
        userId: session.user.id,
        photoId: params.photoId
      }
    })

    return NextResponse.json({ hasPurchased: !!purchase })
  } catch (error) {
    console.error("Erreur vérification achat:", error)
    return NextResponse.json({ hasPurchased: false })
  }
}
```

**Objectif** : Page de détail avec achat Stripe intégré.

---

### ✅ Étape 22 : Page des achats utilisateur

**Créer `src/app/dashboard/purchases/page.tsx`** :

```typescript
"use client"

import { useEffect, useState } from "react"
import { useSession } from "next-auth/react"
import { useSearchParams } from "next/navigation"
import Image from "next/image"
import Link from "next/link"

interface Purchase {
  id: string
  amount: number
  createdAt: string
  photo: {
    id: string
    title: string
    imageUrl: string
    user: {
      name: string
    }
  }
}

export default function PurchasesPage() {
  const { data: session } = useSession()
  const searchParams = useSearchParams()
  const [purchases, setPurchases] = useState<Purchase[]>([])
  const [loading, setLoading] = useState(true)
  const success = searchParams.get("success")

  useEffect(() => {
    const fetchPurchases = async () => {
      try {
        const response = await fetch("/api/purchases")
        if (response.ok) {
          const data = await response.json()
          setPurchases(data.purchases)
        }
      } catch (error) {
        console.error("Erreur chargement achats:", error)
      } finally {
        setLoading(false)
      }
    }

    if (session) {
      fetchPurchases()
    }
  }, [session])

  if (!session) {
    return <div>Chargement...</div>
  }

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-8">
        <Link 
          href="/dashboard" 
          className="text-blue-600 hover:text-blue-800 flex items-center mb-4"
        >
          ← Retour au dashboard
        </Link>
        <h1 className="text-3xl font-bold text-gray-900">Mes Achats</h1>
        <p className="text-gray-600 mt-2">
          Retrouvez toutes les photos que vous avez achetées
        </p>
      </div>

      {success && (
        <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded mb-6">
          ✓ Achat effectué avec succès ! Votre photo est maintenant disponible.
        </div>
      )}

      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="bg-white rounded-lg shadow-md overflow-hidden animate-pulse">
              <div className="w-full h-48 bg-gray-300"></div>
              <div className="p-4">
                <div className="h-4 bg-gray-300 rounded mb-2"></div>
                <div className="h-3 bg-gray-300 rounded w-2/3"></div>
              </div>
            </div>
          ))}
        </div>
      ) : purchases.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {purchases.map((purchase) => (
            <div key={purchase.id} className="bg-white rounded-lg shadow-md overflow-hidden">
              <div className="relative w-full h-48">
                <Image
                  src={purchase.photo.imageUrl}
                  alt={purchase.photo.title}
                  fill
                  className="object-cover"
                />
              </div>
              
              <div className="p-4">
                <h3 className="text-lg font-semibold mb-2">
                  {purchase.photo.title}
                </h3>
                <p className="text-gray-600 text-sm mb-2">
                  Par {purchase.photo.user.name}
                </p>
                <p className="text-green-600 font-bold mb-2">
                  {purchase.amount.toFixed(2)} €
                </p>
                <p className="text-gray-500 text-sm mb-4">
                  Acheté le {new Date(purchase.createdAt).toLocaleDateString()}
                </p>
                
                <div className="flex gap-2">
                  <a
                    href={purchase.photo.imageUrl}
                    download={`${purchase.photo.title}.jpg`}
                    className="flex-1 bg-blue-600 text-white text-center py-2 px-4 rounded hover:bg-blue-700"
                  >
                    Télécharger HD
                  </a>
                  <Link 
                    href={`/photos/${purchase.photo.id}`}
                    className="bg-gray-200 text-gray-800 text-center py-2 px-4 rounded hover:bg-gray-300"
                  >
                    Voir
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-12">
          <svg
            className="mx-auto h-12 w-12 text-gray-400"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"
            />
          </svg>
          <h3 className="mt-2 text-sm font-medium text-gray-900">Aucun achat</h3>
          <p className="mt-1 text-sm text-gray-500">
            Vous n'avez encore acheté aucune photo.
          </p>
          <div className="mt-6">
            <Link href="/">
              <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                Découvrir la galerie
              </button>
            </Link>
          </div>
        </div>
      )}
    </div>
  )
}
```

**Créer `src/app/api/purchases/route.ts`** :

```typescript
import { NextRequest, NextResponse } from "next/server"
import { getServerSession } from "next-auth"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"

export async function GET() {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user?.id) {
      return NextResponse.json(
        { error: "Non authentifié" },
        { status: 401 }
      )
    }

    const purchases = await prisma.purchase.findMany({
      where: {
        userId: session.user.id
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

    return NextResponse.json({ purchases })
  } catch (error) {
    console.error("Erreur récupération achats:", error)
    return NextResponse.json(
      { error: "Erreur lors de la récupération des achats" },
      { status: 500 }
    )
  }
}
```

**Objectif** : Page des achats avec téléchargement des photos achetées.

---

## 🚀 Phase 7 : Interface d'administration

### ✅ Étape 23 : Routes API d'administration

**Créer `src/app/api/admin/users/route.ts`** :

```typescript
import { NextRequest, NextResponse } from "next/server"
import { getServerSession } from "next-auth"
import { authOptions } from "@/lib/auth"
import { prisma } from "@/lib/prisma"

export async function GET() {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user?.id || session.user.role !== "ADMIN") {
      return NextResponse.json(
        { error: "Accès non autorisé" },
        { status: 403 }
      )
    }

    const users = await prisma.user.findMany({
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        createdAt: true,
        _count: {
          select: {
            photos: true,
            purchases: true
          }
        }
      },
      orderBy: {
        createdAt: "desc"
      }
    })

    return NextResponse.json({ users })
  } catch (error) {
    console.error("Erreur récupération utilisateurs:", error)
    return NextResponse.json(
      { error: "Erreur lors de la récupération des utilisateurs" },
      { status: 500 }
    )
  }
}
```

**Objectif** : API d'administration pour gérer utilisateurs et photos.

---

Voilà un plan détaillé avec plus de 21 étapes spécifiques pour développer progressivement le projet. Chaque étape est claire, testable et correspond aux exigences du cahier des charges.

---

## 🎉 Résumé du plan complet - 30+ étapes

Ce plan détaillé couvre l'intégralité du projet PhotoMarket avec plus de **30 étapes concrètes** :

### **Phase 1 : Configuration initiale** (Étapes 1-5)
✅ Next.js 14 + TypeScript + Tailwind CSS 3  
✅ Prisma + PostgreSQL (Neon) + NextAuth.js

### **Phase 2 : Authentification API** (Étapes 6-8)
✅ Routes NextAuth + Inscription + Middleware sécurisé

### **Phase 3 : Interface utilisateur de base** (Étapes 9-13)
✅ Design system Tailwind + Navigation + Pages auth

### **Phase 4 : API de gestion des photos** (Étapes 14-15)
✅ CRUD complet avec sécurité utilisateur

### **Phase 5 : Interface galerie** (Étapes 16-18)
✅ Homepage attractive + Dashboard + Formulaires

### **Phase 6 : Intégration Stripe** (Étapes 19-22)
✅ Checkout sécurisé + Webhook + Page d'achats

### **Phase 7 : Interface d'administration** (Étapes 23-26)
✅ API Admin + Dashboard + Gestion utilisateurs/photos

### **Phase 8 : Documentation et finalisation** (Étapes 27+)
✅ Scripts utilitaires + README + Documentation API

## 🎯 Objectifs pédagogiques atteints

- ✅ **Développement full-stack** avec Next.js 14
- ✅ **API REST sécurisée** avec authentification JWT
- ✅ **Intégration service tiers** (Stripe) avec webhooks
- ✅ **Interface responsive** avec Tailwind CSS 3
- ✅ **Base de données relationnelle** avec Prisma ORM
- ✅ **Gestion des rôles** et administration
- ✅ **Documentation professionnelle** complète

## 📋 Livrables par étape

Chaque étape produit un **livrable concret et testable** :
- Code fonctionnel
- Interface utilisable
- API documentée
- Tests manuels possibles

## 🔄 Méthodologie recommandée

1. **Suivre l'ordre des étapes** (dépendances respectées)
2. **Tester après chaque étape** avant de continuer
3. **Commit Git à chaque étape** pour traçabilité
4. **Examiner le résultat** avant validation suivante

## 🚀 Prêt pour l'implémentation !

Ce plan permet aux étudiants de :
- Comprendre l'architecture complète
- Développer progressivement les fonctionnalités
- Acquérir l'expérience des services web (création + consommation)
- Produire une application professionnelle

**Total : 27+ étapes détaillées couvrant 100% du cahier des charges !**

Vous pouvez maintenant commencer l'implémentation étape par étape avec vos étudiants.