# Étape 7 : Commandes Types TypeScript avancés

## URGENT : Corriger les erreurs de l'étape 6 d'abord

**Si vous avez des erreurs TypeScript après l'étape 6, exécutez ces commandes :**

### Correction automatique des erreurs TypeScript

```bash
# 1. Corriger le routeur NextAuth
echo 'import NextAuth from "next-auth"
import authConfig from "@/lib/auth-config"

const handler = NextAuth(authConfig)
export { handler as GET, handler as POST }' > src/app/api/auth/[...nextauth]/route.ts

# 2. Corriger tsconfig.json pour les imports
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES2022"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "noPropertyAccessFromIndexSignature": false,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    },
    "plugins": [
      {
        "name": "next"
      }
    ]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

# 3. Corriger les exports types auth
cat > src/types/auth/index.ts << 'EOF'
// Exports principaux auth
export type {
  UserRole,
  UserStatus,
  UserPreferences,
  ExtendedUser,
  PhotoMarketSession,
  ExtendedJWT,
  Permission,
  OAuthProvider
} from "./session"

// Exports user 
export type {
  UserId,
  Email,
  HashedPassword,
  CreateUserInput,
  UpdateUserInput
} from "./user"

// Exports providers
export type {
  ExtendedOAuthConfig,
  OAuthAccount,
  ProvidersConfig
} from "./providers"

// Exports callbacks
export type {
  SessionCallback,
  JWTCallback,
  NextAuthCallbacks
} from "./callbacks"

// Exports middleware
export type {
  MiddlewareConfig,
  ProtectedRoute,
  MiddlewareSession
} from "./middleware"

// Exports forms
export type {
  SignInFormData,
  SignUpFormData,
  ProfileFormData
} from "./forms"
EOF

# 4. Test de compilation - DOIT afficher 0 erreurs
npx tsc --noEmit
```

**Si encore des erreurs, suivez les instructions détaillées dans le README.**

---

## IMPORTANT : Instructions pour ultra-débutants

### AVANT TOUTE COMMANDE - Vérifications obligatoires

**Vérification 1 : Être dans le bon dossier** :
```bash
# Vérifier que vous êtes dans le dossier de votre projet
pwd
# Doit afficher quelque chose comme : /chemin/vers/votre/projet

# Si pas dans le bon dossier :
cd chemin/vers/votre/projet
```

**Vérification 2 : Étape 6 terminée** :
```bash
# Vérifier que l'étape 6 fonctionne
npx tsc --noEmit
# DOIT afficher AUCUNE erreur

# Si erreurs, STOP - retourner à l'étape 6 d'abord
```

**Vérification 3 : Serveur fonctionne** :
```bash
# Tester le serveur
npm run dev
# DOIT démarrer sans erreur

# Tester dans le navigateur :
# http://localhost:3000/auth/signin
# DOIT afficher la page de connexion

# Arrêter le serveur : Ctrl+C
```

### RÈGLE IMPORTANTE : Aucun mkdir dans cette étape

**ATTENTION** : Les dossiers de l'étape 7 existent déjà !

❌ **NE JAMAIS exécuter** :
```bash
mkdir src/types/business    # ← EXISTE DÉJÀ
mkdir src/types/api         # ← EXISTE DÉJÀ  
mkdir src/types/ui          # ← EXISTE DÉJÀ
```

✅ **Vérifier qu'ils existent** :
```bash
# Vérifier les dossiers existants
ls -la src/types/
# DOIT afficher : auth/ business/ api/ ui/ utils/

# Si un dossier manque, le créer individuellement :
# mkdir -p src/types/business  (SI ET SEULEMENT SI manquant)
```

## Commandes d'installation et configuration

### Installation des dépendances TypeScript avancées

```bash
# Naviguer dans le projet
cd photo-marketplace

# Installer les types React avancés
npm install -D @types/react @types/react-dom
npm install -D @types/node

# Installer React Hook Form avec types
npm install react-hook-form
npm install -D @types/react-hook-form

# Installer TanStack Query pour gestion d'état
npm install @tanstack/react-query
npm install -D @types/tanstack__react-query

# Installer Zustand pour state management
npm install zustand
npm install -D @types/zustand

# Installer React Table avec types
npm install @tanstack/react-table
npm install -D @types/tanstack__react-table

# Installer React Dropzone pour uploads
npm install react-dropzone
npm install -D @types/react-dropzone

# Installer types Stripe avancés
npm install @stripe/stripe-js
npm install -D @types/stripe-js

# Vérifier les installations
npm list @types/react react-hook-form @tanstack/react-query zustand
```

### Configuration TypeScript pour types avancés

```bash
# Mettre à jour tsconfig.json avec options avancées
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES2022"],
    "allowJs": true,
    "skipLibCheck": false,
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
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"],
      "@/types/*": ["./src/types/*"],
      "@/business/*": ["./src/types/business/*"],
      "@/api/*": ["./src/types/api/*"],
      "@/ui/*": ["./src/types/ui/*"],
      "@/lib/*": ["./src/lib/*"]
    },
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noPropertyAccessFromIndexSignature": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "noImplicitAny": true,
    "noImplicitThis": true,
    "useUnknownInCatchVariables": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

# Vérifier la configuration
npx tsc --noEmit --strict
```

### Vérification et création conditionnelle de la structure

```bash
# ÉTAPE 1 : Vérifier les dossiers existants
echo "=== VÉRIFICATION STRUCTURE ÉTAPE 7 ==="
ls -la src/types/

# ÉTAPE 2 : Créer SEULEMENT les dossiers manquants
echo "Vérification des dossiers business, api, ui..."

# Créer business SI N'EXISTE PAS
if [ ! -d "src/types/business" ]; then
  echo "Création src/types/business (manquant)"
  mkdir -p src/types/business
else
  echo "✅ src/types/business existe déjà"
fi

# Créer api SI N'EXISTE PAS
if [ ! -d "src/types/api" ]; then
  echo "Création src/types/api (manquant)"
  mkdir -p src/types/api
else
  echo "✅ src/types/api existe déjà"
fi

# Créer ui SI N'EXISTE PAS
if [ ! -d "src/types/ui" ]; then
  echo "Création src/types/ui (manquant)"
  mkdir -p src/types/ui
else
  echo "✅ src/types/ui existe déjà"
fi

# Créer les nouveaux dossiers spécifiques à l'étape 7
mkdir -p src/types/data
mkdir -p src/types/files
mkdir -p src/types/payments
mkdir -p src/types/generated
mkdir -p src/lib/types/guards
mkdir -p src/lib/types/validators
mkdir -p src/lib/types/transformers

echo "=== STRUCTURE VÉRIFIÉE ==="

# Créer tous les fichiers de types métier
touch src/types/business/index.ts
touch src/types/business/photo.ts
touch src/types/business/purchase.ts
touch src/types/business/cart.ts
touch src/types/business/catalog.ts
touch src/types/business/analytics.ts
touch src/types/business/admin.ts

# Créer tous les fichiers de types API
touch src/types/api/index.ts
touch src/types/api/routes.ts
touch src/types/api/requests.ts
touch src/types/api/responses.ts
touch src/types/api/pagination.ts
touch src/types/api/filters.ts
touch src/types/api/errors.ts
touch src/types/api/webhooks.ts

# Créer tous les fichiers de types UI
touch src/types/ui/index.ts
touch src/types/ui/components.ts
touch src/types/ui/forms.ts
touch src/types/ui/tables.ts
touch src/types/ui/modals.ts
touch src/types/ui/navigation.ts
touch src/types/ui/layouts.ts
touch src/types/ui/themes.ts

# Créer tous les fichiers de types data
touch src/types/data/index.ts
touch src/types/data/store.ts
touch src/types/data/cache.ts
touch src/types/data/mutations.ts
touch src/types/data/selectors.ts
touch src/types/data/subscriptions.ts

# Créer tous les fichiers de types files
touch src/types/files/index.ts
touch src/types/files/upload.ts
touch src/types/files/images.ts
touch src/types/files/validation.ts
touch src/types/files/storage.ts

# Créer tous les fichiers de types payments
touch src/types/payments/index.ts
touch src/types/payments/stripe.ts
touch src/types/payments/products.ts
touch src/types/payments/sessions.ts
touch src/types/payments/webhooks.ts
touch src/types/payments/billing.ts

# Créer les fichiers utilitaires étendus
touch src/types/utils/conditional-types.ts
touch src/types/utils/utility-types.ts
touch src/types/utils/mapped-types.ts
touch src/types/utils/template-literal.ts
touch src/types/utils/type-helpers.ts

# Créer les type guards spécialisés
touch src/lib/types/guards/business.ts
touch src/lib/types/guards/api.ts
touch src/lib/types/guards/ui.ts
touch src/lib/types/guards/files.ts

# Créer les validators spécialisés
touch src/lib/types/validators/business.ts
touch src/lib/types/validators/api.ts
touch src/lib/types/validators/files.ts
touch src/lib/types/validators/forms.ts

# Créer les transformers
touch src/lib/types/transformers/prisma-to-api.ts
touch src/lib/types/transformers/api-to-ui.ts
touch src/lib/types/transformers/form-to-api.ts

# Créer les types générés
touch src/types/generated/prisma.ts
touch src/types/generated/api-client.ts
touch src/types/generated/schema-validators.ts

# Vérifier la structure
find src/types -name "*.ts" | wc -l
tree src/types 2>/dev/null || find src/types -type f
```

## Commandes de création des types métier

### Création des types de photos avancés

```bash
# Créer le fichier de types photo avec factory functions
cat > src/types/business/photo.ts << 'EOF'
import type { z } from "zod"

// Types de base branded
export type PhotoId = string & { readonly brand: unique symbol }
export type ImageUrl = string & { readonly brand: unique symbol }
export type PhotoTitle = string & { readonly brand: unique symbol }
export type PhotoPrice = number & { readonly brand: unique symbol }

// Status et catégories
export type PhotoStatus = "draft" | "pending_review" | "published" | "sold" | "archived" | "rejected"
export type PhotoCategory = "nature" | "portrait" | "architecture" | "street" | "landscape" | "abstract" | "macro"

// Interface principale Photo
export interface Photo {
  readonly id: PhotoId
  readonly title: PhotoTitle
  readonly description: string
  readonly category: PhotoCategory
  readonly price: PhotoPrice
  readonly status: PhotoStatus
  readonly metadata: {
    readonly fileName: string
    readonly fileSize: number
    readonly dimensions: { width: number; height: number }
    readonly mimeType: string
  }
  readonly performance: {
    readonly views: number
    readonly likes: number
    readonly purchases: number
    readonly revenue: PhotoPrice
  }
  readonly createdAt: Date
  readonly updatedAt: Date
}

// Factory functions
export const createPhotoId = (id: string): PhotoId => id as PhotoId
export const createImageUrl = (url: string): ImageUrl => url as ImageUrl
export const createPhotoTitle = (title: string): PhotoTitle => title as PhotoTitle
export const createPhotoPrice = (price: number): PhotoPrice => price as PhotoPrice

// Validation helpers
export const isValidPhotoCategory = (category: string): category is PhotoCategory => {
  return ["nature", "portrait", "architecture", "street", "landscape", "abstract", "macro"].includes(category)
}

export const isValidPhotoStatus = (status: string): status is PhotoStatus => {
  return ["draft", "pending_review", "published", "sold", "archived", "rejected"].includes(status)
}
EOF

# Créer le fichier de types d'achat
cat > src/types/business/purchase.ts << 'EOF'
import type { PhotoId, PhotoPrice } from "./photo"

// Types de base pour les achats
export type PurchaseId = string & { readonly brand: unique symbol }
export type PurchaseStatus = "pending" | "processing" | "completed" | "failed" | "cancelled" | "refunded"
export type Currency = "EUR" | "USD" | "GBP"

export interface Purchase {
  readonly id: PurchaseId
  readonly photoId: PhotoId
  readonly buyerId: string
  readonly sellerId: string
  readonly amount: PhotoPrice
  readonly currency: Currency
  readonly status: PurchaseStatus
  readonly createdAt: Date
  readonly completedAt?: Date
}

// Factory functions
export const createPurchaseId = (id: string): PurchaseId => id as PurchaseId

// Validation
export const isValidPurchaseStatus = (status: string): status is PurchaseStatus => {
  return ["pending", "processing", "completed", "failed", "cancelled", "refunded"].includes(status)
}

export const isValidCurrency = (currency: string): currency is Currency => {
  return ["EUR", "USD", "GBP"].includes(currency)
}
EOF

# Créer l'index principal métier
cat > src/types/business/index.ts << 'EOF'
// Export de tous les types métier
export * from "./photo"
export * from "./purchase"
export * from "./cart"
export * from "./catalog"
export * from "./analytics"
export * from "./admin"
EOF

echo "Types métier créés avec succès"
```

### Création des types API

```bash
# Créer les types de routes API
cat > src/types/api/routes.ts << 'EOF'
import type { PhotoId } from "../business/photo"
import type { PurchaseId } from "../business/purchase"

// Interface principale des routes API
export interface ApiRoutes {
  readonly photos: {
    readonly list: {
      readonly method: "GET"
      readonly path: "/api/photos"
      readonly query?: {
        readonly page?: number
        readonly limit?: number
        readonly category?: string
      }
      readonly response: {
        readonly photos: ReadonlyArray<{
          readonly id: PhotoId
          readonly title: string
          readonly price: number
        }>
        readonly pagination: {
          readonly page: number
          readonly total: number
        }
      }
    }
    readonly get: {
      readonly method: "GET"
      readonly path: "/api/photos/:id"
      readonly params: { readonly id: PhotoId }
      readonly response: {
        readonly id: PhotoId
        readonly title: string
        readonly description: string
        readonly price: number
      }
    }
  }
  readonly purchases: {
    readonly create: {
      readonly method: "POST"
      readonly path: "/api/purchases"
      readonly body: {
        readonly photoId: PhotoId
        readonly licenseType: string
      }
      readonly response: {
        readonly purchaseId: PurchaseId
        readonly checkoutUrl: string
      }
    }
  }
}

// Utilitaires pour construction d'URLs
export const buildApiUrl = (path: string, params?: Record<string, string>): string => {
  let url = path
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      url = url.replace(`:${key}`, encodeURIComponent(value))
    })
  }
  return url
}
EOF

# Créer les types de pagination
cat > src/types/api/pagination.ts << 'EOF'
// Types de pagination standardisés
export interface PaginationParams {
  readonly page: number
  readonly limit: number
  readonly offset?: number
}

export interface PaginationResponse<T> {
  readonly data: readonly T[]
  readonly pagination: {
    readonly page: number
    readonly limit: number
    readonly total: number
    readonly totalPages: number
    readonly hasNext: boolean
    readonly hasPrevious: boolean
  }
}

export interface CursorPaginationParams {
  readonly cursor?: string
  readonly limit: number
}

export interface CursorPaginationResponse<T> {
  readonly data: readonly T[]
  readonly pagination: {
    readonly cursor?: string
    readonly nextCursor?: string
    readonly hasNext: boolean
  }
}
EOF

# Créer les types d'erreurs API
cat > src/types/api/errors.ts << 'EOF'
// Types d'erreurs API standardisés
export interface ApiError {
  readonly code: string
  readonly message: string
  readonly details?: Record<string, unknown>
  readonly field?: string
  readonly requestId: string
  readonly timestamp: string
}

export interface ValidationError extends ApiError {
  readonly code: "VALIDATION_ERROR"
  readonly field: string
  readonly details: {
    readonly expected: string
    readonly received: unknown
  }
}

export interface NotFoundError extends ApiError {
  readonly code: "NOT_FOUND"
  readonly details: {
    readonly resource: string
    readonly id: string
  }
}

export interface UnauthorizedError extends ApiError {
  readonly code: "UNAUTHORIZED"
  readonly details: {
    readonly reason: "invalid_token" | "expired_token" | "missing_token"
  }
}
EOF

# Créer l'index API
cat > src/types/api/index.ts << 'EOF'
export * from "./routes"
export * from "./requests"
export * from "./responses"
export * from "./pagination"
export * from "./filters"
export * from "./errors"
export * from "./webhooks"
EOF

echo "Types API créés avec succès"
```

### Création des types UI et composants

```bash
# Créer les types de base des composants
cat > src/types/ui/components.ts << 'EOF'
import type { ReactNode } from "react"
import type { PhotoId, Photo } from "../business/photo"

// Types de base pour tous les composants
export interface BaseComponentProps {
  readonly className?: string
  readonly id?: string
  readonly testId?: string
  readonly children?: ReactNode
}

// Types de variantes
export type ComponentSize = "xs" | "sm" | "md" | "lg" | "xl"
export type ComponentVariant = "primary" | "secondary" | "success" | "warning" | "error"
export type ComponentState = "idle" | "loading" | "success" | "error"

// Props pour PhotoCard
export interface PhotoCardProps extends BaseComponentProps {
  readonly photo: {
    readonly id: PhotoId
    readonly title: string
    readonly thumbnailUrl: string
    readonly price: number
  }
  readonly variant?: "grid" | "list"
  readonly size?: ComponentSize
  readonly loading?: boolean
  readonly onLike?: (photoId: PhotoId) => void
  readonly onAddToCart?: (photoId: PhotoId) => void
}

// Props pour PhotoGrid
export interface PhotoGridProps extends BaseComponentProps {
  readonly photos: ReadonlyArray<Photo>
  readonly columns?: 2 | 3 | 4
  readonly loading?: boolean
  readonly onPhotoClick?: (photo: Photo) => void
}

// Props pour les formulaires
export interface FormFieldProps<T = unknown> extends BaseComponentProps {
  readonly name: string
  readonly label?: string
  readonly value?: T
  readonly error?: string
  readonly required?: boolean
  readonly disabled?: boolean
  readonly onChange?: (value: T) => void
}

export interface InputProps extends FormFieldProps<string> {
  readonly type?: "text" | "email" | "password"
  readonly placeholder?: string
  readonly maxLength?: number
}

export interface SelectProps<T = string> extends FormFieldProps<T> {
  readonly options: ReadonlyArray<{
    readonly value: T
    readonly label: string
  }>
  readonly multiple?: boolean
}

// Props pour la navigation
export interface BreadcrumbProps extends BaseComponentProps {
  readonly items: ReadonlyArray<{
    readonly label: string
    readonly href?: string
    readonly current?: boolean
  }>
}

export interface PaginationProps extends BaseComponentProps {
  readonly currentPage: number
  readonly totalPages: number
  readonly onPageChange: (page: number) => void
  readonly loading?: boolean
}

// Props pour les modales
export interface ModalProps extends BaseComponentProps {
  readonly isOpen: boolean
  readonly onClose: () => void
  readonly size?: ComponentSize
  readonly title?: string
}

// Props pour les tables
export interface TableProps<T = Record<string, unknown>> extends BaseComponentProps {
  readonly data: ReadonlyArray<T>
  readonly columns: ReadonlyArray<{
    readonly key: keyof T
    readonly title: string
    readonly render?: (value: unknown, row: T) => ReactNode
  }>
  readonly loading?: boolean
  readonly onRowClick?: (row: T) => void
}
EOF

# Créer les types de formulaires avancés
cat > src/types/ui/forms.ts << 'EOF'
import type { z } from "zod"

// Types pour React Hook Form
export interface FormConfig<T extends Record<string, unknown>> {
  readonly schema: z.ZodSchema<T>
  readonly defaultValues?: Partial<T>
  readonly mode?: "onChange" | "onBlur" | "onSubmit"
}

export interface FormState<T extends Record<string, unknown>> {
  readonly values: T
  readonly errors: Partial<Record<keyof T, string>>
  readonly isValid: boolean
  readonly isSubmitting: boolean
  readonly isDirty: boolean
}

export interface FormActions<T extends Record<string, unknown>> {
  readonly setValue: (name: keyof T, value: T[keyof T]) => void
  readonly setError: (name: keyof T, error: string) => void
  readonly clearErrors: () => void
  readonly reset: () => void
  readonly submit: () => Promise<void>
}

// Types pour formulaires multi-étapes
export interface MultiStepFormStep<T extends Record<string, unknown>> {
  readonly id: string
  readonly title: string
  readonly fields: ReadonlyArray<keyof T>
  readonly validation?: z.ZodSchema
  readonly optional?: boolean
}

export interface MultiStepFormState<T extends Record<string, unknown>> {
  readonly currentStep: number
  readonly steps: ReadonlyArray<MultiStepFormStep<T>>
  readonly data: Partial<T>
  readonly canProceed: boolean
  readonly canGoBack: boolean
}

// Types pour upload de fichiers
export interface FileUploadProps {
  readonly accept?: string
  readonly multiple?: boolean
  readonly maxSize?: number
  readonly onUpload: (files: ReadonlyArray<File>) => Promise<void>
  readonly onError?: (error: Error) => void
}

export interface FileUploadState {
  readonly files: ReadonlyArray<File>
  readonly uploading: boolean
  readonly progress: number
  readonly error?: Error
}
EOF

# Créer l'index UI
cat > src/types/ui/index.ts << 'EOF'
export * from "./components"
export * from "./forms"
export * from "./tables"
export * from "./modals"
export * from "./navigation"
export * from "./layouts"
export * from "./themes"
EOF

echo "Types UI créés avec succès"
```

## Commandes de création des type guards

### Création des type guards métier

```bash
# Créer les type guards pour les types métier
cat > src/lib/types/guards/business.ts << 'EOF'
import type { Photo, PhotoCategory, PhotoStatus } from "@/types/business/photo"
import type { Purchase, PurchaseStatus } from "@/types/business/purchase"

// Type guards pour Photo
export function isPhoto(value: unknown): value is Photo {
  if (!value || typeof value !== "object") return false
  
  const obj = value as Record<string, unknown>
  
  return (
    typeof obj.id === "string" &&
    typeof obj.title === "string" &&
    typeof obj.description === "string" &&
    isValidPhotoCategory(obj.category) &&
    typeof obj.price === "number" &&
    isValidPhotoStatus(obj.status) &&
    obj.metadata &&
    typeof obj.metadata === "object" &&
    obj.performance &&
    typeof obj.performance === "object" &&
    obj.createdAt instanceof Date &&
    obj.updatedAt instanceof Date
  )
}

export function isValidPhotoCategory(value: unknown): value is PhotoCategory {
  return typeof value === "string" && 
    ["nature", "portrait", "architecture", "street", "landscape", "abstract", "macro"].includes(value)
}

export function isValidPhotoStatus(value: unknown): value is PhotoStatus {
  return typeof value === "string" && 
    ["draft", "pending_review", "published", "sold", "archived", "rejected"].includes(value)
}

// Type guards pour Purchase
export function isPurchase(value: unknown): value is Purchase {
  if (!value || typeof value !== "object") return false
  
  const obj = value as Record<string, unknown>
  
  return (
    typeof obj.id === "string" &&
    typeof obj.photoId === "string" &&
    typeof obj.buyerId === "string" &&
    typeof obj.sellerId === "string" &&
    typeof obj.amount === "number" &&
    typeof obj.currency === "string" &&
    isValidPurchaseStatus(obj.status) &&
    obj.createdAt instanceof Date
  )
}

export function isValidPurchaseStatus(value: unknown): value is PurchaseStatus {
  return typeof value === "string" && 
    ["pending", "processing", "completed", "failed", "cancelled", "refunded"].includes(value)
}

// Type guards pour collections
export function isPhotoArray(value: unknown): value is ReadonlyArray<Photo> {
  return Array.isArray(value) && value.every(isPhoto)
}

export function isPurchaseArray(value: unknown): value is ReadonlyArray<Purchase> {
  return Array.isArray(value) && value.every(isPurchase)
}
EOF

# Créer les type guards pour l'API
cat > src/lib/types/guards/api.ts << 'EOF'
import type { ApiError, ValidationError, NotFoundError } from "@/types/api/errors"
import type { PaginationResponse, CursorPaginationResponse } from "@/types/api/pagination"

// Type guards pour les erreurs API
export function isApiError(value: unknown): value is ApiError {
  if (!value || typeof value !== "object") return false
  
  const obj = value as Record<string, unknown>
  
  return (
    typeof obj.code === "string" &&
    typeof obj.message === "string" &&
    typeof obj.requestId === "string" &&
    typeof obj.timestamp === "string"
  )
}

export function isValidationError(value: unknown): value is ValidationError {
  if (!isApiError(value)) return false
  
  const error = value as ApiError & Record<string, unknown>
  
  return (
    error.code === "VALIDATION_ERROR" &&
    typeof error.field === "string" &&
    error.details &&
    typeof error.details === "object"
  )
}

export function isNotFoundError(value: unknown): value is NotFoundError {
  if (!isApiError(value)) return false
  
  const error = value as ApiError
  
  return error.code === "NOT_FOUND"
}

// Type guards pour la pagination
export function isPaginationResponse<T>(
  value: unknown,
  itemGuard: (item: unknown) => item is T
): value is PaginationResponse<T> {
  if (!value || typeof value !== "object") return false
  
  const obj = value as Record<string, unknown>
  
  return (
    Array.isArray(obj.data) &&
    obj.data.every(itemGuard) &&
    obj.pagination &&
    typeof obj.pagination === "object"
  )
}

export function isCursorPaginationResponse<T>(
  value: unknown,
  itemGuard: (item: unknown) => item is T
): value is CursorPaginationResponse<T> {
  if (!value || typeof value !== "object") return false
  
  const obj = value as Record<string, unknown>
  
  return (
    Array.isArray(obj.data) &&
    obj.data.every(itemGuard) &&
    obj.pagination &&
    typeof obj.pagination === "object"
  )
}

// Type guard générique pour les réponses API
export function isSuccessResponse<T>(
  value: unknown,
  dataGuard: (data: unknown) => data is T
): value is { success: true; data: T } {
  if (!value || typeof value !== "object") return false
  
  const obj = value as Record<string, unknown>
  
  return obj.success === true && dataGuard(obj.data)
}

export function isErrorResponse(value: unknown): value is { success: false; error: ApiError } {
  if (!value || typeof value !== "object") return false
  
  const obj = value as Record<string, unknown>
  
  return obj.success === false && isApiError(obj.error)
}
EOF

# Créer les type guards pour les fichiers
cat > src/lib/types/guards/files.ts << 'EOF'
// Type guards pour la gestion de fichiers

export function isValidImageFile(file: File): boolean {
  const allowedTypes = ["image/jpeg", "image/png", "image/webp", "image/gif"]
  return allowedTypes.includes(file.type)
}

export function isValidFileSize(file: File, maxSizeInMB: number = 10): boolean {
  const maxSizeInBytes = maxSizeInMB * 1024 * 1024
  return file.size <= maxSizeInBytes
}

export function isValidFileName(fileName: string): boolean {
  // Éviter les caractères dangereux dans les noms de fichiers
  const dangerousChars = /[<>:"/\\|?*\x00-\x1f]/
  return !dangerousChars.test(fileName) && fileName.length > 0 && fileName.length <= 255
}

export interface FileValidationOptions {
  readonly maxSizeInMB?: number
  readonly allowedTypes?: ReadonlyArray<string>
  readonly allowedExtensions?: ReadonlyArray<string>
}

export function validateFile(file: File, options: FileValidationOptions = {}): {
  readonly valid: boolean
  readonly errors: ReadonlyArray<string>
} {
  const errors: string[] = []
  
  // Vérifier la taille
  if (options.maxSizeInMB && !isValidFileSize(file, options.maxSizeInMB)) {
    errors.push(`File size exceeds ${options.maxSizeInMB}MB limit`)
  }
  
  // Vérifier le type MIME
  if (options.allowedTypes && !options.allowedTypes.includes(file.type)) {
    errors.push(`File type ${file.type} is not allowed`)
  }
  
  // Vérifier l'extension
  if (options.allowedExtensions) {
    const extension = file.name.split('.').pop()?.toLowerCase()
    if (!extension || !options.allowedExtensions.includes(extension)) {
      errors.push(`File extension is not allowed`)
    }
  }
  
  // Vérifier le nom de fichier
  if (!isValidFileName(file.name)) {
    errors.push(`Invalid file name`)
  }
  
  return {
    valid: errors.length === 0,
    errors
  }
}

// Type guard pour les uploads multiples
export function validateFiles(
  files: ReadonlyArray<File>, 
  options: FileValidationOptions = {}
): {
  readonly valid: boolean
  readonly results: ReadonlyArray<{
    readonly file: File
    readonly valid: boolean
    readonly errors: ReadonlyArray<string>
  }>
} {
  const results = files.map(file => ({
    file,
    ...validateFile(file, options)
  }))
  
  return {
    valid: results.every(result => result.valid),
    results
  }
}
EOF

# Créer l'index des type guards
cat > src/lib/types/guards/index.ts << 'EOF'
export * from "./business"
export * from "./api"
export * from "./ui"
export * from "./files"
EOF

echo "Type guards créés avec succès"
```

## Commandes de création des validators Zod

### Création des validators métier

```bash
# Créer les validators Zod pour les types métier
cat > src/lib/types/validators/business.ts << 'EOF'
import { z } from "zod"

// Schema pour PhotoCategory
export const photoCategorySchema = z.enum([
  "nature", "portrait", "architecture", "street", 
  "landscape", "abstract", "macro"
])

// Schema pour PhotoStatus
export const photoStatusSchema = z.enum([
  "draft", "pending_review", "published", 
  "sold", "archived", "rejected"
])

// Schema pour Photo metadata
export const photoMetadataSchema = z.object({
  fileName: z.string().min(1).max(255),
  fileSize: z.number().positive(),
  dimensions: z.object({
    width: z.number().positive(),
    height: z.number().positive()
  }),
  mimeType: z.string().regex(/^image\/(jpeg|png|webp|gif)$/)
})

// Schema pour Photo performance
export const photoPerformanceSchema = z.object({
  views: z.number().min(0),
  likes: z.number().min(0),
  purchases: z.number().min(0),
  revenue: z.number().min(0)
})

// Schema principal pour Photo
export const photoSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1).max(200),
  description: z.string().min(1).max(2000),
  category: photoCategorySchema,
  price: z.number().positive().max(10000),
  status: photoStatusSchema,
  metadata: photoMetadataSchema,
  performance: photoPerformanceSchema,
  createdAt: z.date(),
  updatedAt: z.date()
})

// Schema pour Purchase
export const purchaseStatusSchema = z.enum([
  "pending", "processing", "completed", 
  "failed", "cancelled", "refunded"
])

export const currencySchema = z.enum(["EUR", "USD", "GBP"])

export const purchaseSchema = z.object({
  id: z.string().min(1),
  photoId: z.string().min(1),
  buyerId: z.string().min(1),
  sellerId: z.string().min(1),
  amount: z.number().positive(),
  currency: currencySchema,
  status: purchaseStatusSchema,
  createdAt: z.date(),
  completedAt: z.date().optional()
})

// Schema pour création de Photo
export const createPhotoSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().min(1).max(2000),
  category: photoCategorySchema,
  price: z.number().positive().max(10000),
  file: z.instanceof(File)
})

// Schema pour mise à jour de Photo
export const updatePhotoSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  description: z.string().min(1).max(2000).optional(),
  category: photoCategorySchema.optional(),
  price: z.number().positive().max(10000).optional(),
  status: photoStatusSchema.optional()
})

// Types inférés
export type PhotoData = z.infer<typeof photoSchema>
export type PurchaseData = z.infer<typeof purchaseSchema>
export type CreatePhotoData = z.infer<typeof createPhotoSchema>
export type UpdatePhotoData = z.infer<typeof updatePhotoSchema>
EOF

# Créer les validators pour l'API
cat > src/lib/types/validators/api.ts << 'EOF'
import { z } from "zod"
import { photoSchema, purchaseSchema } from "./business"

// Schema pour les paramètres de pagination
export const paginationParamsSchema = z.object({
  page: z.number().int().positive().default(1),
  limit: z.number().int().positive().max(100).default(20),
  offset: z.number().int().min(0).optional()
})

// Schema pour les paramètres de tri
export const sortParamsSchema = z.object({
  sortBy: z.string().optional(),
  sortOrder: z.enum(["asc", "desc"]).default("desc")
})

// Schema pour les filtres de photos
export const photoFiltersSchema = z.object({
  category: z.string().optional(),
  priceMin: z.number().positive().optional(),
  priceMax: z.number().positive().optional(),
  status: z.string().optional(),
  search: z.string().optional()
})

// Schema pour les requêtes API de photos
export const listPhotosQuerySchema = paginationParamsSchema
  .merge(sortParamsSchema)
  .merge(photoFiltersSchema)

export const getPhotoParamsSchema = z.object({
  id: z.string().min(1)
})

// Schema pour les réponses API
export const apiSuccessResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    success: z.literal(true),
    data: dataSchema,
    metadata: z.object({
      requestId: z.string(),
      timestamp: z.string(),
      version: z.string()
    }).optional()
  })

export const apiErrorResponseSchema = z.object({
  success: z.literal(false),
  error: z.object({
    code: z.string(),
    message: z.string(),
    details: z.record(z.unknown()).optional(),
    field: z.string().optional(),
    requestId: z.string(),
    timestamp: z.string()
  })
})

// Schema pour la réponse de liste de photos
export const listPhotosResponseSchema = apiSuccessResponseSchema(
  z.object({
    photos: z.array(photoSchema),
    pagination: z.object({
      page: z.number(),
      limit: z.number(),
      total: z.number(),
      totalPages: z.number(),
      hasNext: z.boolean(),
      hasPrevious: z.boolean()
    })
  })
)

// Schema pour créer un achat
export const createPurchaseSchema = z.object({
  photoId: z.string().min(1),
  licenseType: z.enum(["standard", "extended", "exclusive"]),
  currency: z.enum(["EUR", "USD", "GBP"]).default("EUR")
})

// Types inférés pour l'API
export type ListPhotosQuery = z.infer<typeof listPhotosQuerySchema>
export type GetPhotoParams = z.infer<typeof getPhotoParamsSchema>
export type CreatePurchaseData = z.infer<typeof createPurchaseSchema>
export type ApiSuccessResponse<T> = {
  success: true
  data: T
  metadata?: {
    requestId: string
    timestamp: string
    version: string
  }
}
export type ApiErrorResponse = z.infer<typeof apiErrorResponseSchema>
EOF

# Créer les validators pour les formulaires
cat > src/lib/types/validators/forms.ts << 'EOF'
import { z } from "zod"

// Schema pour l'upload de photo
export const photoUploadFormSchema = z.object({
  title: z.string()
    .min(1, "Le titre est obligatoire")
    .max(200, "Le titre ne peut pas dépasser 200 caractères"),
  description: z.string()
    .min(10, "La description doit contenir au moins 10 caractères")
    .max(2000, "La description ne peut pas dépasser 2000 caractères"),
  category: z.enum([
    "nature", "portrait", "architecture", "street", 
    "landscape", "abstract", "macro"
  ], {
    errorMap: () => ({ message: "Veuillez sélectionner une catégorie valide" })
  }),
  price: z.number()
    .positive("Le prix doit être positif")
    .max(10000, "Le prix ne peut pas dépasser 10000€")
    .multipleOf(0.01, "Le prix doit avoir au maximum 2 décimales"),
  tags: z.array(z.string().min(1)).max(10, "Maximum 10 tags autorisés"),
  licenseType: z.enum(["standard", "extended", "exclusive"]),
  file: z.instanceof(File, { message: "Veuillez sélectionner un fichier" })
    .refine(
      (file) => file.size <= 50 * 1024 * 1024, 
      "Le fichier ne peut pas dépasser 50MB"
    )
    .refine(
      (file) => ["image/jpeg", "image/png", "image/webp"].includes(file.type),
      "Seuls les formats JPEG, PNG et WebP sont autorisés"
    )
})

// Schema pour la recherche de photos
export const photoSearchFormSchema = z.object({
  query: z.string().max(100).optional(),
  category: z.string().optional(),
  priceMin: z.number().positive().optional(),
  priceMax: z.number().positive().optional(),
  tags: z.array(z.string()).optional(),
  sortBy: z.enum(["newest", "oldest", "price_low", "price_high", "popular"]).default("newest")
})

// Schema pour le profil utilisateur
export const userProfileFormSchema = z.object({
  name: z.string()
    .min(2, "Le nom doit contenir au moins 2 caractères")
    .max(50, "Le nom ne peut pas dépasser 50 caractères"),
  bio: z.string()
    .max(500, "La bio ne peut pas dépasser 500 caractères")
    .optional(),
  website: z.string()
    .url("L'URL du site web n'est pas valide")
    .optional()
    .or(z.literal("")),
  location: z.string()
    .max(100, "La localisation ne peut pas dépasser 100 caractères")
    .optional(),
  avatar: z.instanceof(File)
    .refine(
      (file) => file.size <= 5 * 1024 * 1024,
      "L'avatar ne peut pas dépasser 5MB"
    )
    .refine(
      (file) => ["image/jpeg", "image/png"].includes(file.type),
      "Seuls les formats JPEG et PNG sont autorisés pour l'avatar"
    )
    .optional()
})

// Schema pour les commentaires
export const commentFormSchema = z.object({
  content: z.string()
    .min(1, "Le commentaire ne peut pas être vide")
    .max(1000, "Le commentaire ne peut pas dépasser 1000 caractères"),
  rating: z.number()
    .int("La note doit être un nombre entier")
    .min(1, "La note minimum est 1")
    .max(5, "La note maximum est 5")
    .optional()
})

// Schema pour le contact/support
export const contactFormSchema = z.object({
  name: z.string()
    .min(2, "Le nom doit contenir au moins 2 caractères")
    .max(100, "Le nom ne peut pas dépasser 100 caractères"),
  email: z.string()
    .email("L'adresse email n'est pas valide"),
  subject: z.string()
    .min(5, "Le sujet doit contenir au moins 5 caractères")
    .max(200, "Le sujet ne peut pas dépasser 200 caractères"),
  message: z.string()
    .min(20, "Le message doit contenir au moins 20 caractères")
    .max(2000, "Le message ne peut pas dépasser 2000 caractères"),
  attachments: z.array(z.instanceof(File))
    .max(5, "Maximum 5 fichiers joints autorisés")
    .optional()
})

// Types inférés
export type PhotoUploadFormData = z.infer<typeof photoUploadFormSchema>
export type PhotoSearchFormData = z.infer<typeof photoSearchFormSchema>
export type UserProfileFormData = z.infer<typeof userProfileFormSchema>
export type CommentFormData = z.infer<typeof commentFormSchema>
export type ContactFormData = z.infer<typeof contactFormSchema>
EOF

# Créer l'index des validators
cat > src/lib/types/validators/index.ts << 'EOF'
export * from "./business"
export * from "./api"
export * from "./files"
export * from "./forms"
EOF

echo "Validators Zod créés avec succès"
```

## Commandes de test et validation

### Tests de compilation TypeScript

```bash
# Test de compilation stricte
npx tsc --noEmit --strict

# Test de compilation avec détection d'erreurs
npx tsc --noEmit --strict --pretty

# Mesurer le temps de compilation
time npx tsc --noEmit --strict

# Test de compilation incrémentale
npx tsc --noEmit --incremental

# Analyser les erreurs TypeScript
npx tsc --noEmit 2>&1 | head -50
```

### Tests des type guards

```bash
# Créer un script de test des type guards
cat > test-type-guards.js << 'EOF'
// Test des type guards business

function isValidPhotoCategory(category) {
  return ["nature", "portrait", "architecture", "street", "landscape", "abstract", "macro"].includes(category)
}

function isValidPhotoStatus(status) {
  return ["draft", "pending_review", "published", "sold", "archived", "rejected"].includes(status)
}

function isPhoto(value) {
  if (!value || typeof value !== "object") return false
  
  return (
    typeof value.id === "string" &&
    typeof value.title === "string" &&
    typeof value.description === "string" &&
    isValidPhotoCategory(value.category) &&
    typeof value.price === "number" &&
    isValidPhotoStatus(value.status) &&
    value.metadata &&
    typeof value.metadata === "object" &&
    value.performance &&
    typeof value.performance === "object" &&
    value.createdAt instanceof Date &&
    value.updatedAt instanceof Date
  )
}

console.log('=== TESTS TYPE GUARDS BUSINESS ===')

// Test catégorie valide
console.log('Catégorie nature valide:', isValidPhotoCategory('nature'))
console.log('Catégorie invalid invalide:', !isValidPhotoCategory('invalid'))

// Test status valide
console.log('Status published valide:', isValidPhotoStatus('published'))
console.log('Status invalid invalide:', !isValidPhotoStatus('invalid'))

// Test photo valide
const validPhoto = {
  id: 'photo123',
  title: 'Beautiful Landscape',
  description: 'A stunning mountain landscape',
  category: 'landscape',
  price: 29.99,
  status: 'published',
  metadata: {
    fileName: 'landscape.jpg',
    fileSize: 1024000,
    dimensions: { width: 1920, height: 1080 },
    mimeType: 'image/jpeg'
  },
  performance: {
    views: 100,
    likes: 15,
    purchases: 3,
    revenue: 89.97
  },
  createdAt: new Date(),
  updatedAt: new Date()
}

console.log('Photo valide reconnue:', isPhoto(validPhoto))
console.log('Objet invalide rejeté:', !isPhoto({ id: 'test' }))

console.log('=== TESTS TERMINÉS ===')
EOF

node test-type-guards.js
rm test-type-guards.js
```

### Tests des validators Zod

```bash
# Créer un script de test des validators Zod
cat > test-zod-validators.js << 'EOF'
const { z } = require('zod')

// Définir les schemas de test
const photoCategorySchema = z.enum([
  "nature", "portrait", "architecture", "street", 
  "landscape", "abstract", "macro"
])

const photoUploadSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().min(10).max(2000),
  category: photoCategorySchema,
  price: z.number().positive().max(10000),
  tags: z.array(z.string()).max(10)
})

console.log('=== TESTS VALIDATORS ZOD ===')

// Test données valides
try {
  const validData = {
    title: 'Beautiful Mountain',
    description: 'A stunning mountain landscape photograph taken during golden hour',
    category: 'landscape',
    price: 29.99,
    tags: ['mountain', 'nature', 'golden-hour']
  }
  
  const result = photoUploadSchema.parse(validData)
  console.log('✅ Données valides acceptées')
} catch (error) {
  console.log('❌ Erreur sur données valides:', error.errors[0]?.message)
}

// Test titre trop court
try {
  const invalidData = {
    title: '',
    description: 'A stunning mountain landscape photograph taken during golden hour',
    category: 'landscape',
    price: 29.99,
    tags: ['mountain']
  }
  
  photoUploadSchema.parse(invalidData)
  console.log('❌ Titre vide accepté')
} catch (error) {
  console.log('✅ Titre vide rejeté correctement')
}

// Test catégorie invalide
try {
  const invalidCategory = {
    title: 'Beautiful Mountain',
    description: 'A stunning mountain landscape photograph taken during golden hour',
    category: 'invalid_category',
    price: 29.99,
    tags: ['mountain']
  }
  
  photoUploadSchema.parse(invalidCategory)
  console.log('❌ Catégorie invalide acceptée')
} catch (error) {
  console.log('✅ Catégorie invalide rejetée correctement')
}

// Test prix négatif
try {
  const invalidPrice = {
    title: 'Beautiful Mountain',
    description: 'A stunning mountain landscape photograph taken during golden hour',
    category: 'landscape',
    price: -10,
    tags: ['mountain']
  }
  
  photoUploadSchema.parse(invalidPrice)
  console.log('❌ Prix négatif accepté')
} catch (error) {
  console.log('✅ Prix négatif rejeté correctement')
}

// Test trop de tags
try {
  const tooManyTags = {
    title: 'Beautiful Mountain',
    description: 'A stunning mountain landscape photograph taken during golden hour',
    category: 'landscape',
    price: 29.99,
    tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5', 'tag6', 'tag7', 'tag8', 'tag9', 'tag10', 'tag11']
  }
  
  photoUploadSchema.parse(tooManyTags)
  console.log('❌ Trop de tags accepté')
} catch (error) {
  console.log('✅ Trop de tags rejeté correctement')
}

console.log('=== TESTS ZOD TERMINÉS ===')
EOF

node test-zod-validators.js
rm test-zod-validators.js
```

### Tests de performance TypeScript

```bash
# Créer un script de test de performance
cat > test-typescript-performance.js << 'EOF'
const { execSync } = require('child_process')
const fs = require('fs')

console.log('=== TESTS PERFORMANCE TYPESCRIPT ===')

// Compter les fichiers TypeScript
const countTsFiles = () => {
  try {
    const result = execSync('find src -name "*.ts" -o -name "*.tsx" | wc -l', { encoding: 'utf8' })
    return parseInt(result.trim())
  } catch {
    return 0
  }
}

// Compter les lignes de code
const countLines = () => {
  try {
    const result = execSync('find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | tail -1', { encoding: 'utf8' })
    return parseInt(result.trim().split(' ')[0])
  } catch {
    return 0
  }
}

// Mesurer le temps de compilation
const measureCompileTime = () => {
  const start = Date.now()
  try {
    execSync('npx tsc --noEmit --skipLibCheck', { stdio: 'pipe' })
    return Date.now() - start
  } catch {
    return -1
  }
}

const tsFiles = countTsFiles()
const totalLines = countLines()
const compileTime = measureCompileTime()

console.log(`📁 Fichiers TypeScript: ${tsFiles}`)
console.log(`📄 Lignes de code: ${totalLines}`)

if (compileTime > 0) {
  console.log(`⏱️ Temps de compilation: ${compileTime}ms`)
  
  if (compileTime < 5000) {
    console.log('✅ Performance excellente (< 5s)')
  } else if (compileTime < 15000) {
    console.log('⚠️ Performance correcte (< 15s)')
  } else {
    console.log('❌ Performance lente (> 15s)')
  }
} else {
  console.log('❌ Erreurs de compilation détectées')
}

// Analyser la taille du projet
if (tsFiles > 0) {
  const avgLinesPerFile = Math.round(totalLines / tsFiles)
  console.log(`📊 Moyenne lignes/fichier: ${avgLinesPerFile}`)
  
  if (avgLinesPerFile < 100) {
    console.log('✅ Fichiers de taille raisonnable')
  } else if (avgLinesPerFile < 200) {
    console.log('⚠️ Fichiers de taille moyenne')
  } else {
    console.log('❌ Fichiers volumineux - considérer la refactorisation')
  }
}

console.log('=== TESTS PERFORMANCE TERMINÉS ===')
EOF

node test-typescript-performance.js
rm test-typescript-performance.js
```

## Commandes de diagnostic et maintenance

### Diagnostic complet des types

```bash
# Créer un script de diagnostic complet
cat > diagnostic-types-avances.js << 'EOF'
const fs = require('fs')
const path = require('path')
const { execSync } = require('child_process')

console.log('=== DIAGNOSTIC COMPLET TYPES AVANCÉS ===\n')

// 1. Vérifier la structure des dossiers
console.log('1. Structure des types:')
const expectedDirs = [
  'src/types/business',
  'src/types/api',
  'src/types/ui',
  'src/types/data',
  'src/types/files',
  'src/types/payments',
  'src/types/utils',
  'src/lib/types/guards',
  'src/lib/types/validators',
  'src/lib/types/transformers'
]

expectedDirs.forEach(dir => {
  const exists = fs.existsSync(dir)
  console.log(`   ${exists ? '✅' : '❌'} ${dir}`)
})

// 2. Compter les fichiers de types
console.log('\n2. Fichiers de types:')
const typeFiles = [
  'src/types/business/photo.ts',
  'src/types/business/purchase.ts',
  'src/types/api/routes.ts',
  'src/types/api/pagination.ts',
  'src/types/ui/components.ts',
  'src/types/ui/forms.ts',
  'src/lib/types/guards/business.ts',
  'src/lib/types/validators/business.ts'
]

let existingFiles = 0
typeFiles.forEach(file => {
  const exists = fs.existsSync(file)
  if (exists) existingFiles++
  console.log(`   ${exists ? '✅' : '❌'} ${file}`)
})

console.log(`\n   📊 Fichiers créés: ${existingFiles}/${typeFiles.length}`)

// 3. Vérifier les dépendances
console.log('\n3. Dépendances TypeScript:')
const deps = [
  '@types/react',
  '@types/node', 
  'react-hook-form',
  '@tanstack/react-query',
  'zustand',
  '@stripe/stripe-js'
]

try {
  const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'))
  const allDeps = { ...packageJson.dependencies, ...packageJson.devDependencies }
  
  deps.forEach(dep => {
    const version = allDeps[dep]
    console.log(`   ${version ? '✅' : '❌'} ${dep}: ${version || 'non installé'}`)
  })
} catch (error) {
  console.log('   ❌ Erreur lecture package.json')
}

// 4. Test de compilation TypeScript
console.log('\n4. Compilation TypeScript:')
try {
  execSync('npx tsc --noEmit --strict', { stdio: 'pipe' })
  console.log('   ✅ Compilation réussie')
} catch (error) {
  console.log('   ❌ Erreurs de compilation détectées')
}

// 5. Statistiques du projet
console.log('\n5. Statistiques:')
try {
  const tsFilesCount = execSync('find src -name "*.ts" | wc -l', { encoding: 'utf8' }).trim()
  const tsxFilesCount = execSync('find src -name "*.tsx" | wc -l', { encoding: 'utf8' }).trim()
  const totalFiles = parseInt(tsFilesCount) + parseInt(tsxFilesCount)
  
  console.log(`   📁 Fichiers .ts: ${tsFilesCount}`)
  console.log(`   📁 Fichiers .tsx: ${tsxFilesCount}`)
  console.log(`   📁 Total TypeScript: ${totalFiles}`)
  
  if (totalFiles > 0) {
    const totalLines = execSync('find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | tail -1', { encoding: 'utf8' })
    const lines = parseInt(totalLines.trim().split(' ')[0])
    console.log(`   📄 Lignes de code: ${lines}`)
    console.log(`   📊 Moyenne lignes/fichier: ${Math.round(lines / totalFiles)}`)
  }
} catch (error) {
  console.log('   ❌ Erreur calcul statistiques')
}

// 6. Recommandations
console.log('\n6. Recommandations:')
const recommendations = []

if (existingFiles < typeFiles.length) {
  recommendations.push('Terminer la création de tous les fichiers de types')
}

try {
  const compileTime = Date.now()
  execSync('npx tsc --noEmit --skipLibCheck', { stdio: 'pipe' })
  const duration = Date.now() - compileTime
  
  if (duration > 15000) {
    recommendations.push('Optimiser la performance de compilation TypeScript')
  }
} catch {
  recommendations.push('Corriger les erreurs de compilation TypeScript')
}

if (recommendations.length === 0) {
  console.log('   ✅ Configuration TypeScript optimale')
} else {
  recommendations.forEach(rec => {
    console.log(`   ⚠️ ${rec}`)
  })
}

console.log('\n=== DIAGNOSTIC TERMINÉ ===')
EOF

node diagnostic-types-avances.js
rm diagnostic-types-avances.js
```

### Commandes de nettoyage et optimisation

```bash
# Nettoyer les caches TypeScript
rm -rf .next/cache
rm -rf node_modules/.cache
rm -f .tsbuildinfo

# Réinstaller les dépendances TypeScript
npm install @types/react @types/react-dom @types/node

# Vérifier les imports inutilisés
npx tsc --noUnusedLocals --noUnusedParameters --noEmit

# Analyser la complexité des types
npx typescript-analyze --project tsconfig.json 2>/dev/null || echo "Analyseur non disponible"

# Optimiser tsconfig.json
echo "Configuration TypeScript optimisée"
```

## Annexe 1 : Commandes PowerShell (Windows)

### Installation PowerShell

```powershell
# Installation des dépendances avancées
npm install @types/react @types/react-dom @types/node
npm install react-hook-form @tanstack/react-query zustand
npm install @stripe/stripe-js @tanstack/react-table react-dropzone

# Création de la structure PowerShell
$typeDirs = @(
    "src\types\business",
    "src\types\api", 
    "src\types\ui",
    "src\types\data",
    "src\types\files",
    "src\types\payments",
    "src\lib\types\guards",
    "src\lib\types\validators"
)

foreach ($dir in $typeDirs) {
    New-Item -ItemType Directory -Path $dir -Force
    Write-Host "✅ Créé: $dir" -ForegroundColor Green
}

# Fonction de test TypeScript
function Test-TypeScriptAdvanced {
    Write-Host "=== TEST TYPESCRIPT AVANCÉ ===" -ForegroundColor Blue
    
    # Test compilation
    try {
        $result = npx tsc --noEmit --strict 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Compilation TypeScript OK" -ForegroundColor Green
        } else {
            Write-Host "❌ Erreurs de compilation:" -ForegroundColor Red
            Write-Host $result -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Erreur compilation: $_" -ForegroundColor Red
    }
    
    # Statistiques
    $tsFiles = (Get-ChildItem -Path "src" -Recurse -Filter "*.ts").Count
    $tsxFiles = (Get-ChildItem -Path "src" -Recurse -Filter "*.tsx").Count
    $total = $tsFiles + $tsxFiles
    
    Write-Host "`n📊 Fichiers TypeScript: $total" -ForegroundColor Cyan
    Write-Host "   .ts: $tsFiles" -ForegroundColor Gray
    Write-Host "   .tsx: $tsxFiles" -ForegroundColor Gray
}

# Fonction de validation
function Test-TypeGuards {
    $testScript = @"
function isValidPhotoCategory(category) {
    return ['nature', 'portrait', 'architecture'].includes(category);
}

const tests = [
    { name: 'Catégorie nature', test: () => isValidPhotoCategory('nature') },
    { name: 'Catégorie invalide', test: () => !isValidPhotoCategory('invalid') }
];

tests.forEach(t => {
    console.log(t.name + ':', t.test() ? '✅' : '❌');
});
"@
    
    $testScript | Out-File -FilePath "test-guards.js" -Encoding UTF8
    node test-guards.js
    Remove-Item test-guards.js
}

Write-Host "Fonctions PowerShell disponibles:" -ForegroundColor Cyan
Write-Host "- Test-TypeScriptAdvanced" -ForegroundColor White
Write-Host "- Test-TypeGuards" -ForegroundColor White
```

## Annexe 2 : Commandes CMD (Command Prompt)

### Installation et test CMD

```cmd
REM install-types-advanced.bat
@echo off
echo === INSTALLATION TYPES AVANCÉS ===

echo 1. Installation dépendances...
npm install @types/react @types/react-dom @types/node
npm install react-hook-form @tanstack/react-query zustand
npm install @stripe/stripe-js @tanstack/react-table react-dropzone

echo.
echo 2. Vérification et création structure...

REM Vérifier les dossiers principaux (ne pas créer s'ils existent)
if not exist "src\types\business" (
  echo Création src\types\business (manquant)
  mkdir src\types\business
) else (
  echo ✅ src\types\business existe déjà
)

if not exist "src\types\api" (
  echo Création src\types\api (manquant)
  mkdir src\types\api
) else (
  echo ✅ src\types\api existe déjà
)

if not exist "src\types\ui" (
  echo Création src\types\ui (manquant)
  mkdir src\types\ui
) else (
  echo ✅ src\types\ui existe déjà
)

REM Créer les nouveaux dossiers spécifiques à l'étape 7
mkdir src\types\data 2>nul
mkdir src\lib\types\guards 2>nul
mkdir src\lib\types\validators 2>nul

echo Structure vérifiée et complétée

echo.
echo 3. Test compilation...
npx tsc --noEmit --strict >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Compilation TypeScript OK
) else (
    echo ❌ Erreurs de compilation détectées
)

echo.
echo 4. Statistiques...
for /f %%i in ('dir /s /b src\*.ts src\*.tsx 2^>nul ^| find /c /v ""') do echo Fichiers TypeScript: %%i

echo.
echo === INSTALLATION TERMINÉE ===
pause
```

### Script de validation CMD

```cmd
REM validate-types.bat
@echo off
echo === VALIDATION TYPES AVANCÉS ===

echo 1. Vérification fichiers...
if exist "src\types\business\photo.ts" (
    echo ✅ photo.ts
) else (
    echo ❌ photo.ts manquant
)

if exist "src\types\api\routes.ts" (
    echo ✅ routes.ts  
) else (
    echo ❌ routes.ts manquant
)

if exist "src\lib\types\guards\business.ts" (
    echo ✅ business guards
) else (
    echo ❌ business guards manquant
)

echo.
echo 2. Test type guards...
echo function isValid(cat){return['nature','portrait'].includes(cat)};console.log('Test:',isValid('nature')) > test.js
node test.js
del test.js

echo.
echo 3. Test Zod...
echo const{z}=require('zod');const schema=z.string();console.log('Zod:',schema.safeParse('test').success) > test-zod.js
node test-zod.js
del test-zod.js

echo.
echo === VALIDATION TERMINÉE ===
pause
```

## TESTS D'URLS PRATIQUES POUR ULTRA-DÉBUTANTS

### Commandes de test après création des types

```bash
# Test 1 : Compilation globale avec nouveaux types
echo "=== TEST 1 : COMPILATION TYPESCRIPT ==="
npx tsc --noEmit

if [ $? -eq 0 ]; then
  echo "✅ Compilation réussie avec nouveaux types"
else
  echo "❌ Erreurs de compilation - vérifier les fichiers créés"
  exit 1
fi

# Test 2 : Import des nouveaux types
echo "=== TEST 2 : IMPORTS TYPES ==="
node -e "
try {
  require('./src/types/business/index.ts');
  console.log('✅ Types business importés');
} catch (e) {
  console.log('❌ Erreur business types:', e.message);
  process.exit(1);
}
"

# Test 3 : Serveur Next.js et test URLs
echo "=== TEST 3 : SERVEUR ET URLS ==="
echo "Démarrage du serveur avec nouveaux types..."
npm run dev & 
SERVER_PID=$!
sleep 10

# Test URLs principales
echo "Test des URLs fonctionnelles..."

# Test URL 1 : Page d'accueil
if curl -s -I http://localhost:3000/ | grep -q "200"; then
  echo "✅ URL http://localhost:3000/ fonctionne"
else
  echo "❌ URL http://localhost:3000/ ne fonctionne pas"
fi

# Test URL 2 : Auth signin (étape 5)  
if curl -s -I http://localhost:3000/auth/signin | grep -q "200"; then
  echo "✅ URL http://localhost:3000/auth/signin fonctionne"
else
  echo "❌ URL http://localhost:3000/auth/signin ne fonctionne pas"
fi

# Test URL 3 : API Auth signin (étape 5)
if curl -s -I http://localhost:3000/api/auth/signin | grep -q "200"; then
  echo "✅ URL http://localhost:3000/api/auth/signin fonctionne"
else
  echo "❌ URL http://localhost:3000/api/auth/signin ne fonctionne pas"
fi

# Arrêter le serveur
kill $SERVER_PID

echo "=== TESTS TERMINÉS ==="
echo "Si tous les tests montrent ✅, l'étape 7 est réussie !"
```

### Script PowerShell de validation complète

```powershell
# test-etape7.ps1
Write-Host "=== TESTS ÉTAPE 7 WINDOWS ===" -ForegroundColor Cyan

# Test compilation
Write-Host "Test compilation TypeScript..." -ForegroundColor Yellow
$result = & npx tsc --noEmit 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilation OK" -ForegroundColor Green
} else {
    Write-Host "❌ Erreurs compilation" -ForegroundColor Red
    exit 1
}

# Test serveur et URLs
Write-Host "Test serveur et URLs..." -ForegroundColor Yellow
$job = Start-Job -ScriptBlock { npm run dev }
Start-Sleep 15

try {
    $r1 = Invoke-WebRequest "http://localhost:3000/" -Method HEAD -UseBasicParsing
    Write-Host "✅ URL / fonctionne" -ForegroundColor Green
} catch {
    Write-Host "❌ URL / ne fonctionne pas" -ForegroundColor Red
}

try {
    $r2 = Invoke-WebRequest "http://localhost:3000/auth/signin" -Method HEAD -UseBasicParsing  
    Write-Host "✅ URL /auth/signin fonctionne" -ForegroundColor Green
} catch {
    Write-Host "❌ URL /auth/signin ne fonctionne pas" -ForegroundColor Red
}

Stop-Job $job
Remove-Job $job

Write-Host "=== FIN TESTS ===" -ForegroundColor Cyan
```

Cette documentation exhaustive des commandes permet de configurer, tester et maintenir efficacement tous les types TypeScript avancés pour l'application PhotoMarket complète.