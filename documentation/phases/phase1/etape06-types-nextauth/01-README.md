# Étape 6 : Types NextAuth.js avancés - Gestion TypeScript complète

## Phase 1 - Types et interfaces pour l'authentification

### RAPPEL : Objectif du projet PhotoMarket

Nous développons une **application web complète de galerie de photos** permettant à des utilisateurs de :

- **Vendre leurs photos** : Upload, description, prix
- **Acheter des photos** d'autres utilisateurs via Stripe
- **Gérer leur galerie personnelle** avec authentification sécurisée TypeScript
- **Administrer le système** (rôles utilisateur/admin) avec types sécurisés

### Progression du projet

**ETAPE 1 TERMINEE** : Configuration Next.js + TypeScript + Tailwind CSS 3  
**ETAPE 2 TERMINEE** : Configuration Prisma + Neon PostgreSQL  
**ETAPE 3 TERMINEE** : Configuration et maîtrise Prisma ORM  
**ETAPE 4 TERMINEE** : Analyse du schéma et relations Prisma  
**ETAPE 5 TERMINEE** : Configuration NextAuth.js avec authentification complète  
**ETAPE 6 EN COURS** : Types NextAuth.js avancés et sécurité TypeScript  
**ETAPES RESTANTES** : 20+ étapes jusqu'au projet complet

### Objectif de cette étape

**Créer un système de types TypeScript robuste** pour NextAuth.js dans PhotoMarket :

- **Types avancés de session** et données utilisateur
- **Interfaces personnalisées** pour les providers
- **Types de rôles et permissions** stricts
- **Validation TypeScript** des formulaires d'authentification
- **Types pour middleware** et protection des routes
- **Utilitaires de types** réutilisables
- **Types pour les callbacks** NextAuth.js
- **Validation côté serveur** avec Zod

### Technologies utilisées dans cette étape

- **TypeScript 5+** : Types avancés et inférence
- **Zod** : Validation de schémas avec types
- **NextAuth.js Types** : Extension des interfaces
- **Utility Types** : Omit, Pick, Partial, Required
- **Branded Types** : Types nominaux pour la sécurité
- **Template Literal Types** : Types dynamiques
- **Conditional Types** : Logique conditionnelle de types

### Prérequis

- Étapes 1-5 terminées (NextAuth.js configuré et fonctionnel)
- TypeScript configuré dans le projet
- Compréhension des types de base NextAuth.js

## Structure des types NextAuth.js avancés

### 1. Architecture des types du projet

**Arborescence des fichiers de types** :
```
src/
├── types/
│   ├── auth/
│   │   ├── index.ts                  ← Export principal des types auth
│   │   ├── session.ts                ← Types de session avancés
│   │   ├── user.ts                   ← Types utilisateur étendus
│   │   ├── providers.ts              ← Types pour providers OAuth
│   │   ├── callbacks.ts              ← Types pour callbacks NextAuth
│   │   ├── middleware.ts             ← Types pour middleware de protection
│   │   └── forms.ts                  ← Types pour formulaires d'auth
│   ├── database/
│   │   ├── prisma-extended.ts        ← Types Prisma étendus
│   │   └── relations.ts              ← Types de relations DB
│   ├── api/
│   │   ├── auth-responses.ts         ← Types de réponses API auth
│   │   └── errors.ts                 ← Types d'erreurs personnalisés
│   ├── utils/
│   │   ├── branded-types.ts          ← Types nominaux sécurisés
│   │   ├── validation.ts             ← Types de validation Zod
│   │   └── permissions.ts            ← Types de permissions et rôles
│   └── next-auth.d.ts                ← Extension NextAuth (déjà créé)
├── lib/
│   ├── auth/
│   │   ├── type-guards.ts            ← Guards de types runtime
│   │   ├── validators.ts             ← Validateurs Zod
│   │   └── permissions-utils.ts      ← Utilitaires de permissions
│   └── types/
│       └── type-helpers.ts           ← Helpers et utilitaires de types
```

### 2. Types de session avancés

**Créer `src/types/auth/session.ts`** :
```typescript
import type { DefaultSession, Session as NextAuthSession } from "next-auth"
import type { JWT } from "next-auth/jwt"

// Types de rôles stricts
export type UserRole = "USER" | "ADMIN"

// Types de statut utilisateur
export type UserStatus = "ACTIVE" | "SUSPENDED" | "PENDING_VERIFICATION" | "INACTIVE"

// Types de préférences utilisateur
export interface UserPreferences {
  theme: "light" | "dark" | "system"
  language: "fr" | "en" | "es"
  emailNotifications: boolean
  pushNotifications: boolean
  photoQuality: "original" | "compressed"
  privacy: {
    showEmail: boolean
    showPurchases: boolean
    allowMessages: boolean
  }
}

// Type de session étendue avec toutes les données nécessaires
export interface ExtendedUser {
  id: string
  email: string
  name: string | null
  image: string | null
  role: UserRole
  status: UserStatus
  emailVerified: Date | null
  createdAt: Date
  updatedAt: Date
  preferences?: UserPreferences
  // Statistiques utilisateur
  stats: {
    photosCount: number
    purchasesCount: number
    salesCount: number
    totalEarnings: number
    totalSpent: number
  }
  // Permissions calculées
  permissions: {
    canUploadPhotos: boolean
    canPurchasePhotos: boolean
    canManageUsers: boolean
    canAccessAdmin: boolean
    canModerateContent: boolean
  }
}

// Session PhotoMarket avec données complètes
export interface PhotoMarketSession extends NextAuthSession {
  user: ExtendedUser
  accessToken?: string
  refreshToken?: string
  expiresAt: number
}

// Types pour les callbacks de session
export interface SessionCallbackParams {
  session: PhotoMarketSession
  token: ExtendedJWT
  user?: ExtendedUser
}

// JWT étendu avec toutes les données nécessaires
export interface ExtendedJWT extends JWT {
  id: string
  role: UserRole
  status: UserStatus
  permissions: ExtendedUser["permissions"]
  stats: ExtendedUser["stats"]
  preferences?: UserPreferences
  lastActivity: number
  sessionId: string
}

// Types pour la gestion de session côté client
export interface ClientSession {
  user: Pick<ExtendedUser, "id" | "name" | "email" | "image" | "role">
  isLoading: boolean
  isAuthenticated: boolean
  isAdmin: boolean
  permissions: ExtendedUser["permissions"]
}

// Types d'événements de session
export type SessionEvent = 
  | { type: "SIGN_IN"; user: ExtendedUser }
  | { type: "SIGN_OUT"; userId: string }
  | { type: "SESSION_UPDATE"; changes: Partial<ExtendedUser> }
  | { type: "PERMISSION_CHANGE"; userId: string; permissions: ExtendedUser["permissions"] }
  | { type: "ROLE_CHANGE"; userId: string; oldRole: UserRole; newRole: UserRole }

// Hook useSession personnalisé avec types étendus
export interface UsePhotoMarketSession {
  (): {
    data: PhotoMarketSession | null
    status: "loading" | "authenticated" | "unauthenticated"
    update: (data?: Partial<PhotoMarketSession>) => Promise<PhotoMarketSession | null>
  }
}
```

### 3. Types utilisateur étendus

**Créer `src/types/auth/user.ts`** :
```typescript
import type { User as PrismaUser } from "@prisma/client"

// Types de base utilisateur
export type UserId = string & { readonly brand: unique symbol }
export type Email = string & { readonly brand: unique symbol }
export type HashedPassword = string & { readonly brand: unique symbol }

// Types de validation pour création d'utilisateur
export interface CreateUserInput {
  email: Email
  password: string
  name: string
  role?: UserRole
  emailVerified?: boolean
}

export interface CreateUserWithOAuthInput {
  email: Email
  name: string
  image?: string
  provider: OAuthProvider
  providerAccountId: string
}

// Types pour mise à jour utilisateur
export interface UpdateUserInput {
  name?: string
  image?: string
  preferences?: Partial<UserPreferences>
  status?: UserStatus
}

// Types pour administration utilisateur
export interface AdminUpdateUserInput extends UpdateUserInput {
  role?: UserRole
  status?: UserStatus
  emailVerified?: boolean
}

// Types de filtres et recherche utilisateur
export interface UserSearchFilters {
  role?: UserRole
  status?: UserStatus
  createdAfter?: Date
  createdBefore?: Date
  hasPhotos?: boolean
  hasPurchases?: boolean
  search?: string // Recherche par nom ou email
}

export interface UserSortOptions {
  field: "name" | "email" | "createdAt" | "lastActivity" | "photosCount" | "salesCount"
  direction: "asc" | "desc"
}

// Types pour pagination
export interface PaginatedUsers {
  users: ExtendedUser[]
  total: number
  page: number
  pageSize: number
  totalPages: number
  hasNext: boolean
  hasPrevious: boolean
}

// Types pour statistiques utilisateur
export interface UserStatistics {
  totalUsers: number
  activeUsers: number
  newUsersThisMonth: number
  usersByRole: Record<UserRole, number>
  usersByStatus: Record<UserStatus, number>
  topSellers: Array<{
    user: Pick<ExtendedUser, "id" | "name" | "image">
    salesCount: number
    totalEarnings: number
  }>
  topBuyers: Array<{
    user: Pick<ExtendedUser, "id" | "name" | "image">
    purchasesCount: number
    totalSpent: number
  }>
}

// Types de profil public et privé
export interface PublicUserProfile {
  id: UserId
  name: string
  image: string | null
  createdAt: Date
  photosCount: number
  // Données conditionnelles selon les préférences de confidentialité
  email?: Email
  salesCount?: number
  purchasesCount?: number
}

export interface PrivateUserProfile extends ExtendedUser {
  // Données sensibles visibles seulement par l'utilisateur lui-même
  email: Email
  emailVerified: Date | null
  accounts: OAuthAccount[]
  sessions: UserSession[]
  purchases: UserPurchase[]
  uploadedPhotos: UserPhoto[]
}

// Types pour les relations utilisateur
export interface OAuthAccount {
  id: string
  provider: OAuthProvider
  providerAccountId: string
  type: "oauth"
  scope?: string
  id_token?: string
  session_state?: string
  refresh_token?: string
  access_token?: string
  expires_at?: number
  token_type?: string
}

export interface UserSession {
  id: string
  sessionToken: string
  expires: Date
  createdAt: Date
  lastActivity: Date
  userAgent?: string
  ipAddress?: string
}

export interface UserPurchase {
  id: string
  photoId: string
  amount: number
  currency: string
  status: "pending" | "completed" | "failed" | "refunded"
  stripeSessionId: string
  createdAt: Date
  photo: {
    id: string
    title: string
    imageUrl: string
    sellerId: string
    sellerName: string
  }
}

export interface UserPhoto {
  id: string
  title: string
  description: string
  imageUrl: string
  price: number
  status: "draft" | "published" | "sold" | "archived"
  tags: string[]
  purchasesCount: number
  totalEarnings: number
  createdAt: Date
  updatedAt: Date
}
```

### 4. Types pour providers OAuth

**Créer `src/types/auth/providers.ts`** :
```typescript
import type { OAuthConfig, OAuthUserConfig } from "next-auth/providers"

// Types de providers supportés
export type OAuthProvider = "google" | "github" | "facebook" | "twitter" | "linkedin"

// Configuration étendue pour chaque provider
export interface ExtendedOAuthConfig<T = any> extends OAuthConfig<T> {
  id: OAuthProvider
  name: string
  type: "oauth"
  version?: string
  scope?: string
  params?: Record<string, string>
  headers?: Record<string, string>
  checks?: Array<"pkce" | "state" | "nonce">
  clientId: string
  clientSecret: string
  issuer?: string
  wellKnown?: string
  authorization?: string | { url: string; params?: Record<string, string> }
  token?: string | { url: string; params?: Record<string, string> }
  userinfo?: string | { url: string; params?: Record<string, string> }
  // Mapping personnalisé des champs utilisateur
  profile?: (profile: T, tokens: any) => Promise<ExtendedUser | null>
}

// Types de profils pour chaque provider
export interface GoogleProfile {
  sub: string
  email: string
  email_verified: boolean
  name: string
  given_name?: string
  family_name?: string
  picture?: string
  locale?: string
}

export interface GitHubProfile {
  id: number
  login: string
  avatar_url: string
  name: string | null
  email: string | null
  bio: string | null
  company: string | null
  location: string | null
  blog: string | null
  twitter_username: string | null
  public_repos: number
  followers: number
  following: number
  created_at: string
  updated_at: string
}

export interface FacebookProfile {
  id: string
  email?: string
  name: string
  first_name?: string
  last_name?: string
  picture?: {
    data: {
      height: number
      is_silhouette: boolean
      url: string
      width: number
    }
  }
}

// Types pour la configuration des providers
export interface ProvidersConfig {
  google?: {
    enabled: boolean
    clientId: string
    clientSecret: string
    scope?: string[]
  }
  github?: {
    enabled: boolean
    clientId: string
    clientSecret: string
    scope?: string[]
  }
  facebook?: {
    enabled: boolean
    clientId: string
    clientSecret: string
    scope?: string[]
  }
}

// Types pour la gestion des tokens OAuth
export interface OAuthTokens {
  access_token: string
  refresh_token?: string
  expires_at?: number
  expires_in?: number
  token_type: string
  scope?: string
  id_token?: string
}

// Types pour les erreurs OAuth
export type OAuthError = 
  | "access_denied"
  | "invalid_request" 
  | "unauthorized_client"
  | "unsupported_response_type"
  | "invalid_scope"
  | "server_error"
  | "temporarily_unavailable"
  | "invalid_client"
  | "invalid_grant"
  | "unsupported_grant_type"

export interface OAuthErrorResponse {
  error: OAuthError
  error_description?: string
  error_uri?: string
  state?: string
}

// Types pour les callbacks OAuth
export interface OAuthCallbackParams {
  user: ExtendedUser
  account: OAuthAccount
  profile: GoogleProfile | GitHubProfile | FacebookProfile
  email?: { verificationRequest?: boolean }
  credentials?: any
}

// Types pour le mapping des profils OAuth vers notre modèle utilisateur
export type ProfileMapper<T = any> = (
  profile: T,
  account: OAuthAccount
) => Promise<{
  id: string
  email: string
  name: string
  image?: string
  emailVerified?: Date
}>

// Configuration des mappers par provider
export interface ProfileMappers {
  google: ProfileMapper<GoogleProfile>
  github: ProfileMapper<GitHubProfile>
  facebook: ProfileMapper<FacebookProfile>
}
```

### 5. Types pour callbacks NextAuth.js

**Créer `src/types/auth/callbacks.ts`** :
```typescript
import type { User, Account, Profile } from "next-auth"

// Types pour tous les callbacks NextAuth.js
export interface NextAuthCallbacks {
  signIn: SignInCallback
  redirect: RedirectCallback
  session: SessionCallback
  jwt: JWTCallback
}

// Types pour le callback de connexion
export interface SignInCallbackParams {
  user: User
  account: Account | null
  profile?: Profile
  email?: { verificationRequest?: boolean }
  credentials?: Record<string, any>
}

export type SignInCallback = (params: SignInCallbackParams) => Promise<boolean> | boolean

// Types pour le callback de redirection
export interface RedirectCallbackParams {
  url: string
  baseUrl: string
}

export type RedirectCallback = (params: RedirectCallbackParams) => Promise<string> | string

// Types pour le callback de session
export interface SessionCallbackParams {
  session: PhotoMarketSession
  token: ExtendedJWT
  user?: ExtendedUser
}

export type SessionCallback = (params: SessionCallbackParams) => Promise<PhotoMarketSession> | PhotoMarketSession

// Types pour le callback JWT
export interface JWTCallbackParams {
  token: ExtendedJWT
  user?: ExtendedUser
  account?: Account | null
  profile?: Profile
  trigger?: "signIn" | "signUp" | "update"
  isNewUser?: boolean
  session?: any
}

export type JWTCallback = (params: JWTCallbackParams) => Promise<ExtendedJWT> | ExtendedJWT

// Types pour les événements NextAuth.js
export interface NextAuthEvents {
  signIn: (params: { user: ExtendedUser; account: Account | null; profile?: Profile; isNewUser?: boolean }) => Promise<void>
  signOut: (params: { session?: PhotoMarketSession; token?: ExtendedJWT }) => Promise<void>
  createUser: (params: { user: ExtendedUser }) => Promise<void>
  updateUser: (params: { user: ExtendedUser }) => Promise<void>
  linkAccount: (params: { user: ExtendedUser; account: Account; profile: Profile }) => Promise<void>
  session: (params: { session: PhotoMarketSession; token: ExtendedJWT }) => Promise<void>
}

// Types pour la gestion d'erreurs dans les callbacks
export type CallbackError = 
  | "Signin"
  | "OAuthSignin" 
  | "OAuthCallback"
  | "OAuthCreateAccount"
  | "EmailCreateAccount"
  | "Callback"
  | "OAuthAccountNotLinked"
  | "EmailSignin"
  | "CredentialsSignin"
  | "SessionRequired"

export interface CallbackErrorResponse {
  error: CallbackError
  message: string
  stack?: string
}

// Types pour les validations dans les callbacks
export interface CallbackValidation {
  validateUser: (user: User) => Promise<boolean>
  validateAccount: (account: Account) => Promise<boolean>
  validateSession: (session: PhotoMarketSession) => Promise<boolean>
  validateToken: (token: ExtendedJWT) => Promise<boolean>
}

// Types pour la logique métier dans les callbacks
export interface CallbackBusinessLogic {
  onFirstSignIn: (user: ExtendedUser) => Promise<void>
  onRoleChange: (user: ExtendedUser, oldRole: UserRole, newRole: UserRole) => Promise<void>
  onPermissionUpdate: (user: ExtendedUser, permissions: ExtendedUser["permissions"]) => Promise<void>
  updateUserStats: (userId: UserId) => Promise<ExtendedUser["stats"]>
  syncUserPreferences: (userId: UserId) => Promise<UserPreferences>
}
```

### 6. Types pour middleware de protection

**Créer `src/types/auth/middleware.ts`** :
```typescript
import type { NextRequest, NextResponse } from "next/server"

// Types pour la configuration du middleware
export interface MiddlewareConfig {
  protectedRoutes: ProtectedRoute[]
  publicRoutes: string[]
  adminRoutes: AdminRoute[]
  redirects: RedirectRule[]
  rateLimit?: RateLimitConfig
}

// Types pour les routes protégées
export interface ProtectedRoute {
  path: string
  requiredRole?: UserRole
  requiredPermissions?: Permission[]
  allowedStatuses?: UserStatus[]
  redirectTo?: string
  customCheck?: (session: PhotoMarketSession) => boolean
}

// Types pour les routes admin
export interface AdminRoute extends ProtectedRoute {
  requiredRole: "ADMIN"
  adminLevel?: "basic" | "super"
}

// Types pour les règles de redirection
export interface RedirectRule {
  from: string
  to: string
  condition?: "authenticated" | "unauthenticated" | "admin" | "user"
  permanent?: boolean
}

// Types pour la limitation de débit
export interface RateLimitConfig {
  windowMs: number
  max: number
  skipSuccessfulRequests?: boolean
  keyGenerator?: (req: NextRequest) => string
}

// Types pour les permissions granulaires
export type Permission = 
  | "photos:upload"
  | "photos:purchase" 
  | "photos:manage"
  | "photos:moderate"
  | "users:view"
  | "users:edit"
  | "users:delete"
  | "users:manage-roles"
  | "admin:access"
  | "admin:analytics"
  | "admin:settings"
  | "admin:moderate-content"

// Types pour la vérification des permissions
export interface PermissionCheck {
  hasPermission(session: PhotoMarketSession, permission: Permission): boolean
  hasRole(session: PhotoMarketSession, role: UserRole): boolean
  hasAnyPermission(session: PhotoMarketSession, permissions: Permission[]): boolean
  hasAllPermissions(session: PhotoMarketSession, permissions: Permission[]): boolean
}

// Types pour les résultats du middleware
export type MiddlewareResult = 
  | { type: "allow" }
  | { type: "redirect"; url: string; permanent?: boolean }
  | { type: "forbidden"; reason: string }
  | { type: "unauthorized"; redirectTo: string }

// Types pour l'audit et les logs du middleware
export interface MiddlewareAuditLog {
  timestamp: Date
  path: string
  method: string
  userId?: UserId
  userRole?: UserRole
  action: "allow" | "redirect" | "forbidden" | "unauthorized"
  reason?: string
  ip: string
  userAgent: string
}

// Types pour la session dans le middleware
export interface MiddlewareSession extends PhotoMarketSession {
  ipAddress: string
  userAgent: string
  requestedPath: string
  referer?: string
}

// Types pour les hooks du middleware
export interface MiddlewareHooks {
  beforeAuth?: (req: NextRequest) => Promise<void>
  afterAuth?: (req: NextRequest, session: MiddlewareSession | null) => Promise<void>
  onForbidden?: (req: NextRequest, reason: string) => Promise<void>
  onUnauthorized?: (req: NextRequest) => Promise<void>
  onRedirect?: (req: NextRequest, redirectUrl: string) => Promise<void>
}

// Types pour la géolocalisation (optionnel)
export interface GeolocationData {
  country: string
  region: string
  city: string
  timezone: string
  coordinates?: {
    latitude: number
    longitude: number
  }
}

// Types pour la détection d'appareil
export interface DeviceInfo {
  type: "desktop" | "mobile" | "tablet"
  os: string
  browser: string
  version: string
  isMobile: boolean
  isBot: boolean
}

// Context complet du middleware
export interface MiddlewareContext {
  request: NextRequest
  session: MiddlewareSession | null
  device: DeviceInfo
  geolocation?: GeolocationData
  rateLimitData?: {
    remaining: number
    resetTime: Date
  }
}
```

### 7. Types pour formulaires d'authentification

**Créer `src/types/auth/forms.ts`** :
```typescript
import type { z } from "zod"

// Types pour le formulaire de connexion
export interface SignInFormData {
  email: string
  password: string
  remember?: boolean
  callbackUrl?: string
}

export interface SignInFormErrors {
  email?: string[]
  password?: string[]
  root?: string[]
}

export interface SignInFormState {
  data: SignInFormData
  errors: SignInFormErrors
  isLoading: boolean
  isValid: boolean
}

// Types pour le formulaire d'inscription
export interface SignUpFormData {
  name: string
  email: string
  password: string
  confirmPassword: string
  terms: boolean
  newsletter?: boolean
}

export interface SignUpFormErrors {
  name?: string[]
  email?: string[]
  password?: string[]
  confirmPassword?: string[]
  terms?: string[]
  root?: string[]
}

export interface SignUpFormState {
  data: SignUpFormData
  errors: SignUpFormErrors
  isLoading: boolean
  isValid: boolean
}

// Types pour le formulaire de mot de passe oublié
export interface ForgotPasswordFormData {
  email: string
}

export interface ForgotPasswordFormState {
  data: ForgotPasswordFormData
  errors: { email?: string[]; root?: string[] }
  isLoading: boolean
  isValid: boolean
  isSubmitted: boolean
}

// Types pour le formulaire de réinitialisation de mot de passe
export interface ResetPasswordFormData {
  password: string
  confirmPassword: string
  token: string
}

export interface ResetPasswordFormState {
  data: ResetPasswordFormData
  errors: { 
    password?: string[]
    confirmPassword?: string[]
    token?: string[]
    root?: string[] 
  }
  isLoading: boolean
  isValid: boolean
}

// Types pour le formulaire de profil utilisateur
export interface ProfileFormData {
  name: string
  email: string
  image?: string
  bio?: string
  preferences: UserPreferences
}

export interface ProfileFormState {
  data: ProfileFormData
  errors: Record<keyof ProfileFormData, string[]>
  isLoading: boolean
  isValid: boolean
  isDirty: boolean
}

// Types pour les validateurs de champs
export interface FieldValidator<T> {
  validate: (value: T) => string[] | null
  isRequired?: boolean
  debounceMs?: number
}

export interface FormFieldValidators {
  email: FieldValidator<string>
  password: FieldValidator<string>
  name: FieldValidator<string>
  confirmPassword: FieldValidator<string>
}

// Types pour les hooks de formulaire
export interface UseFormOptions<T> {
  initialData: T
  validators?: Partial<Record<keyof T, FieldValidator<any>>>
  onSubmit: (data: T) => Promise<void>
  onError?: (errors: Record<keyof T, string[]>) => void
  onSuccess?: () => void
}

export interface UseFormReturn<T> {
  data: T
  errors: Record<keyof T, string[]>
  isLoading: boolean
  isValid: boolean
  isDirty: boolean
  handleChange: (field: keyof T, value: any) => void
  handleSubmit: (e: React.FormEvent) => Promise<void>
  reset: () => void
  setFieldError: (field: keyof T, error: string[]) => void
  clearErrors: () => void
}

// Types pour la validation asynchrone
export interface AsyncValidationResult {
  isValid: boolean
  errors: string[]
  suggestions?: string[]
}

export interface AsyncValidators {
  checkEmailAvailability: (email: string) => Promise<AsyncValidationResult>
  validatePasswordStrength: (password: string) => Promise<AsyncValidationResult>
  verifyResetToken: (token: string) => Promise<AsyncValidationResult>
}

// Types pour les schémas Zod
export type SignInSchema = z.ZodType<SignInFormData>
export type SignUpSchema = z.ZodType<SignUpFormData>
export type ForgotPasswordSchema = z.ZodType<ForgotPasswordFormData>
export type ResetPasswordSchema = z.ZodType<ResetPasswordFormData>
export type ProfileSchema = z.ZodType<ProfileFormData>

// Types pour la soumission de formulaires
export interface FormSubmissionResult<T = any> {
  success: boolean
  data?: T
  errors?: Record<string, string[]>
  message?: string
  redirectTo?: string
}

// Types pour les étapes de formulaire multi-étapes
export interface MultiStepFormStep<T = any> {
  id: string
  title: string
  description?: string
  fields: (keyof T)[]
  validation?: z.ZodSchema
  isOptional?: boolean
}

export interface MultiStepFormState<T> {
  currentStep: number
  steps: MultiStepFormStep<T>[]
  data: Partial<T>
  errors: Record<keyof T, string[]>
  completedSteps: number[]
  isValid: boolean
  canProceed: boolean
  canGoBack: boolean
}
```

## Validation avec Zod

### 8. Installation et configuration de Zod

```bash
# Installation de Zod pour la validation
npm install zod
npm install @types/zod -D

# Installation des utilitaires de validation
npm install validator
npm install @types/validator -D
```

**Créer `src/lib/auth/validators.ts`** :
```typescript
import { z } from "zod"
import validator from "validator"

// Validateurs de base personnalisés
const email = z.string()
  .min(1, "L'email est obligatoire")
  .email("Format d'email invalide")
  .refine(email => validator.isEmail(email), "Email invalide")
  .transform(email => email.toLowerCase().trim())

const password = z.string()
  .min(8, "Le mot de passe doit contenir au moins 8 caractères")
  .regex(/[A-Z]/, "Le mot de passe doit contenir au moins une majuscule")
  .regex(/[a-z]/, "Le mot de passe doit contenir au moins une minuscule")
  .regex(/[0-9]/, "Le mot de passe doit contenir au moins un chiffre")
  .regex(/[^A-Za-z0-9]/, "Le mot de passe doit contenir au moins un caractère spécial")

const name = z.string()
  .min(2, "Le nom doit contenir au moins 2 caractères")
  .max(50, "Le nom ne peut pas dépasser 50 caractères")
  .regex(/^[a-zA-ZÀ-ÿ\s-']+$/, "Le nom ne peut contenir que des lettres, espaces, tirets et apostrophes")
  .transform(name => name.trim())

// Schémas de validation pour les formulaires
export const signInSchema = z.object({
  email,
  password: z.string().min(1, "Le mot de passe est obligatoire"),
  remember: z.boolean().optional(),
  callbackUrl: z.string().url().optional(),
})

export const signUpSchema = z.object({
  name,
  email,
  password,
  confirmPassword: z.string(),
  terms: z.boolean().refine(val => val === true, "Vous devez accepter les conditions d'utilisation"),
  newsletter: z.boolean().optional(),
}).refine(data => data.password === data.confirmPassword, {
  message: "Les mots de passe ne correspondent pas",
  path: ["confirmPassword"],
})

export const forgotPasswordSchema = z.object({
  email,
})

export const resetPasswordSchema = z.object({
  password,
  confirmPassword: z.string(),
  token: z.string().min(1, "Token de réinitialisation manquant"),
}).refine(data => data.password === data.confirmPassword, {
  message: "Les mots de passe ne correspondent pas",
  path: ["confirmPassword"],
})

export const profileSchema = z.object({
  name,
  email,
  image: z.string().url().optional(),
  bio: z.string().max(500, "La bio ne peut pas dépasser 500 caractères").optional(),
  preferences: z.object({
    theme: z.enum(["light", "dark", "system"]),
    language: z.enum(["fr", "en", "es"]),
    emailNotifications: z.boolean(),
    pushNotifications: z.boolean(),
    photoQuality: z.enum(["original", "compressed"]),
    privacy: z.object({
      showEmail: z.boolean(),
      showPurchases: z.boolean(),
      allowMessages: z.boolean(),
    }),
  }),
})

// Validateurs pour l'API
export const userRoleSchema = z.enum(["USER", "ADMIN"])
export const userStatusSchema = z.enum(["ACTIVE", "SUSPENDED", "PENDING_VERIFICATION", "INACTIVE"])

export const updateUserSchema = z.object({
  name: name.optional(),
  image: z.string().url().optional(),
  preferences: profileSchema.shape.preferences.partial().optional(),
})

export const adminUpdateUserSchema = updateUserSchema.extend({
  role: userRoleSchema.optional(),
  status: userStatusSchema.optional(),
  emailVerified: z.boolean().optional(),
})

// Types inférés des schémas
export type SignInData = z.infer<typeof signInSchema>
export type SignUpData = z.infer<typeof signUpSchema>
export type ForgotPasswordData = z.infer<typeof forgotPasswordSchema>
export type ResetPasswordData = z.infer<typeof resetPasswordSchema>
export type ProfileData = z.infer<typeof profileSchema>
export type UpdateUserData = z.infer<typeof updateUserSchema>
export type AdminUpdateUserData = z.infer<typeof adminUpdateUserSchema>
```

### 9. Type guards et validation runtime

**Créer `src/lib/auth/type-guards.ts`** :
```typescript
// Type guards pour vérifier les types à l'exécution
export function isValidUserRole(role: string): role is UserRole {
  return ["USER", "ADMIN"].includes(role)
}

export function isValidUserStatus(status: string): status is UserStatus {
  return ["ACTIVE", "SUSPENDED", "PENDING_VERIFICATION", "INACTIVE"].includes(status)
}

export function isValidOAuthProvider(provider: string): provider is OAuthProvider {
  return ["google", "github", "facebook", "twitter", "linkedin"].includes(provider)
}

export function isExtendedUser(user: any): user is ExtendedUser {
  return (
    user &&
    typeof user.id === "string" &&
    typeof user.email === "string" &&
    isValidUserRole(user.role) &&
    isValidUserStatus(user.status) &&
    user.permissions &&
    user.stats
  )
}

export function isPhotoMarketSession(session: any): session is PhotoMarketSession {
  return (
    session &&
    session.user &&
    isExtendedUser(session.user) &&
    typeof session.expiresAt === "number"
  )
}

export function isExtendedJWT(token: any): token is ExtendedJWT {
  return (
    token &&
    typeof token.id === "string" &&
    isValidUserRole(token.role) &&
    isValidUserStatus(token.status) &&
    token.permissions &&
    token.stats &&
    typeof token.lastActivity === "number"
  )
}

// Guards pour les permissions
export function hasPermission(
  session: PhotoMarketSession | null,
  permission: Permission
): boolean {
  if (!session || !isPhotoMarketSession(session)) {
    return false
  }
  
  return session.user.permissions[getPermissionKey(permission)] ?? false
}

export function hasRole(
  session: PhotoMarketSession | null,
  role: UserRole
): boolean {
  if (!session || !isPhotoMarketSession(session)) {
    return false
  }
  
  return session.user.role === role
}

export function isAdmin(session: PhotoMarketSession | null): boolean {
  return hasRole(session, "ADMIN")
}

export function isActiveUser(session: PhotoMarketSession | null): boolean {
  if (!session || !isPhotoMarketSession(session)) {
    return false
  }
  
  return session.user.status === "ACTIVE"
}

// Utilitaire pour mapper les permissions aux clés de l'objet permissions
function getPermissionKey(permission: Permission): keyof ExtendedUser["permissions"] {
  const permissionMap: Record<Permission, keyof ExtendedUser["permissions"]> = {
    "photos:upload": "canUploadPhotos",
    "photos:purchase": "canPurchasePhotos",
    "photos:manage": "canUploadPhotos", // Simplification
    "photos:moderate": "canModerateContent",
    "users:view": "canAccessAdmin",
    "users:edit": "canManageUsers",
    "users:delete": "canManageUsers",
    "users:manage-roles": "canManageUsers",
    "admin:access": "canAccessAdmin",
    "admin:analytics": "canAccessAdmin",
    "admin:settings": "canAccessAdmin",
    "admin:moderate-content": "canModerateContent",
  }
  
  return permissionMap[permission] || "canAccessAdmin"
}

// Validation d'email avancée
export function isValidEmail(email: string): email is Email {
  try {
    signInSchema.pick({ email: true }).parse({ email })
    return true
  } catch {
    return false
  }
}

// Validation de mot de passe avancée
export function isStrongPassword(password: string): boolean {
  try {
    signUpSchema.pick({ password: true }).parse({ password })
    return true
  } catch {
    return false
  }
}
```

### 10. Utilitaires de permissions avancés

**Créer `src/lib/auth/permissions-utils.ts`** :
```typescript
// Calcul des permissions basé sur le rôle et le statut
export function calculateUserPermissions(
  role: UserRole,
  status: UserStatus,
  userStats?: ExtendedUser["stats"]
): ExtendedUser["permissions"] {
  const basePermissions: ExtendedUser["permissions"] = {
    canUploadPhotos: false,
    canPurchasePhotos: false,
    canManageUsers: false,
    canAccessAdmin: false,
    canModerateContent: false,
  }
  
  // Utilisateur inactif = aucune permission
  if (status !== "ACTIVE") {
    return basePermissions
  }
  
  // Permissions de base pour les utilisateurs actifs
  if (role === "USER") {
    basePermissions.canUploadPhotos = true
    basePermissions.canPurchasePhotos = true
  }
  
  // Permissions admin
  if (role === "ADMIN") {
    return {
      canUploadPhotos: true,
      canPurchasePhotos: true,
      canManageUsers: true,
      canAccessAdmin: true,
      canModerateContent: true,
    }
  }
  
  // Permissions avancées basées sur les statistiques (exemple)
  if (userStats) {
    // Utilisateurs expérimentés peuvent modérer
    if (userStats.photosCount >= 50 && userStats.salesCount >= 20) {
      basePermissions.canModerateContent = true
    }
  }
  
  return basePermissions
}

// Vérification des permissions granulaires
export class PermissionChecker {
  constructor(private session: PhotoMarketSession | null) {}
  
  can(permission: Permission): boolean {
    return hasPermission(this.session, permission)
  }
  
  canAny(permissions: Permission[]): boolean {
    return permissions.some(permission => this.can(permission))
  }
  
  canAll(permissions: Permission[]): boolean {
    return permissions.every(permission => this.can(permission))
  }
  
  // Vérifications spécifiques au domaine métier
  canUploadPhoto(): boolean {
    return this.can("photos:upload") && isActiveUser(this.session)
  }
  
  canPurchasePhoto(photoId: string, sellerId: string): boolean {
    if (!this.can("photos:purchase")) return false
    if (!isActiveUser(this.session)) return false
    
    // L'utilisateur ne peut pas acheter ses propres photos
    if (this.session?.user.id === sellerId) return false
    
    return true
  }
  
  canManageUser(targetUserId: string): boolean {
    if (!this.can("users:edit")) return false
    
    // Un admin ne peut pas se gérer lui-même
    if (this.session?.user.id === targetUserId) return false
    
    return true
  }
  
  canAccessAdminRoute(route: string): boolean {
    if (!this.can("admin:access")) return false
    
    // Vérifications spécifiques par route
    if (route.startsWith("/admin/users") && !this.can("users:view")) {
      return false
    }
    
    if (route.startsWith("/admin/moderate") && !this.can("admin:moderate-content")) {
      return false
    }
    
    return true
  }
}

// Factory pour créer un checker de permissions
export function createPermissionChecker(session: PhotoMarketSession | null): PermissionChecker {
  return new PermissionChecker(session)
}

// Hook React pour les permissions
export function usePermissions() {
  const { data: session } = useSession() as { data: PhotoMarketSession | null }
  
  return useMemo(() => createPermissionChecker(session), [session])
}

// Décorateur pour les fonctions nécessitant des permissions
export function requirePermission(permission: Permission) {
  return function <T extends (...args: any[]) => any>(
    target: any,
    propertyKey: string,
    descriptor: TypedPropertyDescriptor<T>
  ) {
    const originalMethod = descriptor.value!
    
    descriptor.value = function (this: any, ...args: any[]) {
      const session = this.session as PhotoMarketSession | null
      
      if (!hasPermission(session, permission)) {
        throw new Error(`Permission manquante: ${permission}`)
      }
      
      return originalMethod.apply(this, args)
    } as T
    
    return descriptor
  }
}

// Décorateur pour les rôles
export function requireRole(role: UserRole) {
  return function <T extends (...args: any[]) => any>(
    target: any,
    propertyKey: string,
    descriptor: TypedPropertyDescriptor<T>
  ) {
    const originalMethod = descriptor.value!
    
    descriptor.value = function (this: any, ...args: any[]) {
      const session = this.session as PhotoMarketSession | null
      
      if (!hasRole(session, role)) {
        throw new Error(`Rôle requis: ${role}`)
      }
      
      return originalMethod.apply(this, args)
    } as T
    
    return descriptor
  }
}
```

### 11. Types utilitaires et branded types

**Créer `src/types/utils/branded-types.ts`** :
```typescript
// Types nominaux pour éviter les erreurs de types
declare const brand: unique symbol

export type Brand<T, TBrand> = T & { [brand]: TBrand }

// Types spécifiques à PhotoMarket
export type UserId = Brand<string, "UserId">
export type PhotoId = Brand<string, "PhotoId">
export type PurchaseId = Brand<string, "PurchaseId">
export type SessionId = Brand<string, "SessionId">
export type Email = Brand<string, "Email">
export type HashedPassword = Brand<string, "HashedPassword">
export type JWTToken = Brand<string, "JWTToken">
export type StripeSessionId = Brand<string, "StripeSessionId">

// Fonctions de création des types nominaux
export const createUserId = (id: string): UserId => id as UserId
export const createPhotoId = (id: string): PhotoId => id as PhotoId
export const createPurchaseId = (id: string): PurchaseId => id as PurchaseId
export const createSessionId = (id: string): SessionId => id as SessionId
export const createEmail = (email: string): Email => email as Email
export const createHashedPassword = (password: string): HashedPassword => password as HashedPassword

// Types pour les montants monétaires
export type Amount = Brand<number, "Amount">
export type Price = Brand<number, "Price">

export const createAmount = (amount: number): Amount => {
  if (amount < 0) throw new Error("Le montant ne peut pas être négatif")
  return amount as Amount
}

export const createPrice = (price: number): Price => {
  if (price <= 0) throw new Error("Le prix doit être positif")
  return price as Price
}

// Types pour les dates spécifiques
export type CreatedAt = Brand<Date, "CreatedAt">
export type UpdatedAt = Brand<Date, "UpdatedAt">
export type ExpiresAt = Brand<Date, "ExpiresAt">

export const createCreatedAt = (date: Date): CreatedAt => date as CreatedAt
export const createUpdatedAt = (date: Date): UpdatedAt => date as UpdatedAt
export const createExpiresAt = (date: Date): ExpiresAt => {
  if (date <= new Date()) throw new Error("La date d'expiration doit être dans le futur")
  return date as ExpiresAt
}

// Utilitaires pour extraire les valeurs des types nominaux
export const unwrapUserId = (userId: UserId): string => userId as string
export const unwrapEmail = (email: Email): string => email as string
export const unwrapAmount = (amount: Amount): number => amount as number
```

### 12. Configuration TypeScript avancée

**Mettre à jour `tsconfig.json`** :
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES2022"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"],
      "@/types/*": ["./src/types/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/components/*": ["./src/components/*"],
      "@/hooks/*": ["./src/hooks/*"]
    },
    // Options TypeScript strictes pour la sécurité des types
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "noPropertyAccessFromIndexSignature": true
  },
  "include": [
    "next-env.d.ts", 
    "**/*.ts", 
    "**/*.tsx", 
    ".next/types/**/*.ts"
  ],
  "exclude": ["node_modules"]
}
```

## Export et utilisation des types

### 13. Index principal des types

**Créer `src/types/auth/index.ts`** :
```typescript
// Export de tous les types d'authentification
export * from "./session"
export * from "./user"
export * from "./providers"
export * from "./callbacks"
export * from "./middleware"
export * from "./forms"

// Re-export des types utilitaires
export * from "../utils/branded-types"

// Export des validateurs
export * from "../../lib/auth/validators"
export * from "../../lib/auth/type-guards"
export * from "../../lib/auth/permissions-utils"

// Types de commodité
export type { 
  PhotoMarketSession,
  ExtendedUser,
  ExtendedJWT,
  UserRole,
  UserStatus,
  Permission,
  OAuthProvider
} from "./session"
```

### 14. Utilisation dans les composants

**Exemple d'utilisation dans un composant** :
```tsx
// src/components/auth/user-profile.tsx
"use client"

import { useSession } from "next-auth/react"
import type { PhotoMarketSession } from "@/types/auth"
import { usePermissions } from "@/lib/auth/permissions-utils"

export function UserProfile() {
  const { data: session, status } = useSession() as {
    data: PhotoMarketSession | null
    status: "loading" | "authenticated" | "unauthenticated"
  }
  
  const permissions = usePermissions()

  if (status === "loading") {
    return <div>Chargement...</div>
  }

  if (!session) {
    return <div>Vous devez être connecté</div>
  }

  return (
    <div className="bg-white shadow rounded-lg p-6">
      <div className="flex items-center space-x-4">
        <img
          src={session.user.image || "/default-avatar.png"}
          alt={session.user.name}
          className="w-16 h-16 rounded-full"
        />
        <div>
          <h2 className="text-xl font-semibold">{session.user.name}</h2>
          <p className="text-gray-600">{session.user.email}</p>
          <span className={`inline-block px-2 py-1 text-xs rounded ${
            session.user.role === "ADMIN" 
              ? "bg-red-100 text-red-800" 
              : "bg-blue-100 text-blue-800"
          }`}>
            {session.user.role}
          </span>
        </div>
      </div>
      
      <div className="mt-6 grid grid-cols-2 gap-4">
        <div className="bg-gray-50 p-4 rounded">
          <h3 className="font-medium">Photos uploadées</h3>
          <p className="text-2xl font-bold">{session.user.stats.photosCount}</p>
        </div>
        <div className="bg-gray-50 p-4 rounded">
          <h3 className="font-medium">Achats réalisés</h3>
          <p className="text-2xl font-bold">{session.user.stats.purchasesCount}</p>
        </div>
      </div>
      
      {permissions.can("photos:upload") && (
        <button className="mt-4 px-4 py-2 bg-blue-600 text-white rounded">
          Uploader une photo
        </button>
      )}
      
      {permissions.can("admin:access") && (
        <button className="mt-4 ml-2 px-4 py-2 bg-red-600 text-white rounded">
          Administration
        </button>
      )}
    </div>
  )
}
```

## Tests des types

### 15. Tests TypeScript avec vitest

```bash
# Installation des outils de test pour TypeScript
npm install -D vitest @vitest/ui
npm install -D @types/node
```

**Créer `src/types/__tests__/auth-types.test.ts`** :
```typescript
import { describe, it, expect, expectTypeOf } from "vitest"
import type { 
  ExtendedUser, 
  PhotoMarketSession, 
  ExtendedJWT,
  UserRole,
  Permission 
} from "../auth"
import { 
  isValidUserRole, 
  isExtendedUser, 
  hasPermission,
  calculateUserPermissions 
} from "../../lib/auth/type-guards"

describe("Types d'authentification", () => {
  it("devrait valider les rôles utilisateur", () => {
    expect(isValidUserRole("USER")).toBe(true)
    expect(isValidUserRole("ADMIN")).toBe(true)
    expect(isValidUserRole("INVALID")).toBe(false)
  })

  it("devrait valider un ExtendedUser", () => {
    const validUser: ExtendedUser = {
      id: "user123",
      email: "test@example.com",
      name: "Test User",
      image: null,
      role: "USER",
      status: "ACTIVE",
      emailVerified: new Date(),
      createdAt: new Date(),
      updatedAt: new Date(),
      stats: {
        photosCount: 0,
        purchasesCount: 0,
        salesCount: 0,
        totalEarnings: 0,
        totalSpent: 0,
      },
      permissions: {
        canUploadPhotos: true,
        canPurchasePhotos: true,
        canManageUsers: false,
        canAccessAdmin: false,
        canModerateContent: false,
      },
    }

    expect(isExtendedUser(validUser)).toBe(true)
    expect(isExtendedUser({})).toBe(false)
  })

  it("devrait calculer les permissions correctement", () => {
    const userPermissions = calculateUserPermissions("USER", "ACTIVE")
    expect(userPermissions.canUploadPhotos).toBe(true)
    expect(userPermissions.canAccessAdmin).toBe(false)

    const adminPermissions = calculateUserPermissions("ADMIN", "ACTIVE")
    expect(adminPermissions.canAccessAdmin).toBe(true)
    expect(adminPermissions.canManageUsers).toBe(true)
  })

  it("devrait avoir les types corrects", () => {
    expectTypeOf<UserRole>().toEqualTypeOf<"USER" | "ADMIN">()
    expectTypeOf<Permission>().toMatchTypeOf<string>()
    
    // Test que ExtendedUser a les propriétés requises
    expectTypeOf<ExtendedUser>().toHaveProperty("id").toEqualTypeOf<string>()
    expectTypeOf<ExtendedUser>().toHaveProperty("role").toEqualTypeOf<UserRole>()
    expectTypeOf<ExtendedUser>().toHaveProperty("permissions")
  })
})
```

## Livrables de l'étape 6

### Configuration terminée

- [ ] **Types avancés NextAuth.js** : Session, User, JWT étendus
- [ ] **Types de permissions** : Système granulaire de permissions
- [ ] **Types de formulaires** : Validation TypeScript complète
- [ ] **Types de middleware** : Protection des routes typée
- [ ] **Types providers OAuth** : Configuration typée des providers
- [ ] **Validation Zod** : Schémas de validation avec types inférés
- [ ] **Type guards** : Validation runtime des types
- [ ] **Branded types** : Types nominaux pour la sécurité
- [ ] **Utilitaires de permissions** : Système de permissions typé
- [ ] **Tests TypeScript** : Validation des types avec vitest

### Prochaines étapes

Une fois cette étape terminée, vous pourrez passer à :
- **Étape 7** : Types TypeScript avancés pour toute l'application
- **Étape 8** : Composants d'authentification avec types

## Ressources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Zod Documentation](https://zod.dev/)
- [NextAuth.js TypeScript](https://next-auth.js.org/getting-started/typescript)
- [Branded Types in TypeScript](https://egghead.io/blog/using-branded-types-in-typescript)
- [Utility Types](https://www.typescriptlang.org/docs/handbook/utility-types.html)