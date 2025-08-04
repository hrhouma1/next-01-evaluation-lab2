# Étape 7 : Types TypeScript avancés pour toute l'application PhotoMarket

## Phase 1 - Système de types complet pour l'application

### RAPPEL : Objectif du projet PhotoMarket

Nous développons une **application web complète de galerie de photos** permettant à des utilisateurs de :

- **Vendre leurs photos** : Upload, description, prix, gestion de catalogue
- **Acheter des photos** d'autres utilisateurs via Stripe avec système de panier
- **Gérer leur galerie personnelle** avec filtres, recherche et organisation
- **Administrer le système** avec analytics, modération et gestion utilisateurs

### Progression du projet

**ETAPE 1 TERMINEE** : Configuration Next.js + TypeScript + Tailwind CSS 3  
**ETAPE 2 TERMINEE** : Configuration Prisma + Neon PostgreSQL  
**ETAPE 3 TERMINEE** : Configuration et maîtrise Prisma ORM  
**ETAPE 4 TERMINEE** : Analyse du schéma et relations Prisma  
**ETAPE 5 TERMINEE** : Configuration NextAuth.js avec authentification complète  
**ETAPE 6 TERMINEE** : Types NextAuth.js avancés et sécurité TypeScript  
**ETAPE 7 EN COURS** : Types TypeScript avancés pour toute l'application  
**ETAPES RESTANTES** : 20+ étapes jusqu'au projet complet

### Objectif de cette étape

**Créer un écosystème de types TypeScript complet** pour toute l'application PhotoMarket :

- **Types métier avancés** : Photos, Achats, Panier, Catalogue
- **Types API REST** : Requêtes, Réponses, Pagination, Filtres
- **Types React avancés** : Composants, Props, Hooks, Context
- **Types pour uploads** : Fichiers, Images, Validation, Progress
- **Types Stripe intégrés** : Payments, Webhooks, Sessions, Products
- **Types de state management** : Redux/Zustand, Actions, Selectors
- **Types de formulaires complexes** : Multi-étapes, Validation, Soumission
- **Types d'interface utilisateur** : Modals, Tables, Filtres, Search
- **Types de performance** : Lazy loading, Pagination, Cache
- **Types d'analytics** : Tracking, Events, Metrics, Reporting

### Technologies utilisées dans cette étape

- **TypeScript 5+** : Types avancés, inférence, conditional types
- **React 18** : Hooks, Context, Suspense, Server Components
- **Next.js 14** : App Router, API Routes, Server Actions
- **Prisma** : Types générés, relations, requêtes complexes
- **Stripe** : Types SDK, Webhooks, Products, Subscriptions
- **React Hook Form** : Types de formulaires, validation
- **TanStack Query** : Types de requêtes, cache, mutations
- **Zustand/Redux** : Types de state, actions, selectors
- **React Table** : Types de colonnes, données, filtres
- **React Dropzone** : Types d'upload, fichiers, validation

### Prérequis

- Étapes 1-6 terminées (Types NextAuth.js fonctionnels)
- TypeScript configuré en mode strict
- Compréhension des types avancés et branded types
- Zod et validation configurés

## Architecture complète des types

### 1. Organisation globale des types

**Arborescence complète des types** :
```
src/
├── types/
│   ├── auth/                         ← Types d'authentification (déjà fait)
│   │   ├── index.ts
│   │   ├── session.ts
│   │   ├── user.ts
│   │   └── ...
│   ├── business/                     ← Types métier principaux
│   │   ├── index.ts                  ← Export principal métier
│   │   ├── photo.ts                  ← Types de photos et galerie
│   │   ├── purchase.ts               ← Types d'achats et transactions
│   │   ├── cart.ts                   ← Types de panier et commandes
│   │   ├── catalog.ts                ← Types de catalogue et recherche
│   │   ├── analytics.ts              ← Types d'analytics et métriques
│   │   └── admin.ts                  ← Types d'administration
│   ├── api/                          ← Types API et communication
│   │   ├── index.ts                  ← Export principal API
│   │   ├── routes.ts                 ← Types de routes API
│   │   ├── requests.ts               ← Types de requêtes
│   │   ├── responses.ts              ← Types de réponses
│   │   ├── pagination.ts             ← Types de pagination
│   │   ├── filters.ts                ← Types de filtres et recherche
│   │   ├── errors.ts                 ← Types d'erreurs API
│   │   └── webhooks.ts               ← Types de webhooks
│   ├── ui/                           ← Types d'interface utilisateur
│   │   ├── index.ts                  ← Export principal UI
│   │   ├── components.ts             ← Types de composants React
│   │   ├── forms.ts                  ← Types de formulaires avancés
│   │   ├── tables.ts                 ← Types de tables et listes
│   │   ├── modals.ts                 ← Types de modales et overlays
│   │   ├── navigation.ts             ← Types de navigation
│   │   ├── layouts.ts                ← Types de layouts
│   │   └── themes.ts                 ← Types de thèmes et styles
│   ├── data/                         ← Types de données et state
│   │   ├── index.ts                  ← Export principal data
│   │   ├── store.ts                  ← Types de store global
│   │   ├── cache.ts                  ← Types de cache et queries
│   │   ├── mutations.ts              ← Types de mutations
│   │   ├── selectors.ts              ← Types de selectors
│   │   └── subscriptions.ts          ← Types de subscriptions
│   ├── files/                        ← Types de gestion de fichiers
│   │   ├── index.ts                  ← Export principal files
│   │   ├── upload.ts                 ← Types d'upload
│   │   ├── images.ts                 ← Types d'images et processing
│   │   ├── validation.ts             ← Types de validation fichiers
│   │   └── storage.ts                ← Types de storage et CDN
│   ├── payments/                     ← Types de paiements
│   │   ├── index.ts                  ← Export principal payments
│   │   ├── stripe.ts                 ← Types Stripe spécialisés
│   │   ├── products.ts               ← Types de produits
│   │   ├── sessions.ts               ← Types de sessions de paiement
│   │   ├── webhooks.ts               ← Types de webhooks Stripe
│   │   └── billing.ts                ← Types de facturation
│   ├── utils/                        ← Types utilitaires (déjà fait + extensions)
│   │   ├── branded-types.ts          ← Types nominaux (étendu)
│   │   ├── conditional-types.ts      ← Types conditionnels avancés
│   │   ├── utility-types.ts          ← Types utilitaires personnalisés
│   │   ├── mapped-types.ts           ← Types mappés complexes
│   │   ├── template-literal.ts       ← Template literal types
│   │   └── type-helpers.ts           ← Helpers de manipulation de types
│   └── generated/                    ← Types générés automatiquement
│       ├── prisma.ts                 ← Types Prisma étendus
│       ├── api-client.ts             ← Types client API générés
│       └── schema-validators.ts      ← Validators Zod générés
├── lib/
│   ├── types/                        ← Logique de types et runtime
│   │   ├── guards/                   ← Type guards spécialisés
│   │   │   ├── business.ts           ← Guards métier
│   │   │   ├── api.ts                ← Guards API
│   │   │   ├── ui.ts                 ← Guards UI
│   │   │   └── files.ts              ← Guards fichiers
│   │   ├── validators/               ← Validateurs spécialisés
│   │   │   ├── business.ts           ← Validateurs métier
│   │   │   ├── api.ts                ← Validateurs API
│   │   │   ├── files.ts              ← Validateurs fichiers
│   │   │   └── forms.ts              ← Validateurs formulaires
│   │   ├── transformers/             ← Transformateurs de types
│   │   │   ├── prisma-to-api.ts      ← Prisma vers API
│   │   │   ├── api-to-ui.ts          ← API vers UI
│   │   │   └── form-to-api.ts        ← Formulaire vers API
│   │   └── type-factories.ts         ← Factories de types
│   └── utils/
│       ├── type-utils.ts             ← Utilitaires de manipulation de types
│       └── runtime-validation.ts     ← Validation runtime
```

### 2. Types métier avancés pour les photos

**Créer `src/types/business/photo.ts`** :
```typescript
import type { z } from "zod"
import type { UserId, CreatedAt, UpdatedAt } from "../utils/branded-types"

// Types de base pour les photos
export type PhotoId = string & { readonly brand: unique symbol }
export type ImageUrl = string & { readonly brand: unique symbol }
export type PhotoTitle = string & { readonly brand: unique symbol }
export type PhotoDescription = string & { readonly brand: unique symbol }
export type PhotoPrice = number & { readonly brand: unique symbol }

// Status avancés des photos
export type PhotoStatus = "draft" | "pending_review" | "published" | "sold" | "archived" | "rejected"

// Catégories et tags
export type PhotoCategory = 
  | "nature"
  | "portrait" 
  | "architecture"
  | "street"
  | "landscape"
  | "abstract"
  | "macro"
  | "wildlife"
  | "travel"
  | "event"
  | "commercial"
  | "artistic"

export type PhotoTag = string & { readonly brand: unique symbol }
export type PhotoTags = readonly PhotoTag[]

// Métadonnées techniques des photos
export interface PhotoMetadata {
  readonly fileName: string
  readonly originalFileName: string
  readonly mimeType: string
  readonly fileSize: number
  readonly dimensions: {
    readonly width: number
    readonly height: number
    readonly aspectRatio: number
  }
  readonly exif?: {
    readonly camera?: string
    readonly lens?: string
    readonly settings?: {
      readonly aperture?: string
      readonly shutterSpeed?: string
      readonly iso?: number
      readonly focalLength?: string
    }
    readonly location?: {
      readonly latitude?: number
      readonly longitude?: number
      readonly address?: string
    }
    readonly dateTaken?: Date
  }
  readonly processing: {
    readonly thumbnailUrl: ImageUrl
    readonly previewUrl: ImageUrl
    readonly watermarkUrl?: ImageUrl
    readonly originalUrl: ImageUrl
  }
  readonly hash: string
  readonly uploadedAt: Date
}

// Données de performance des photos
export interface PhotoPerformance {
  readonly views: number
  readonly likes: number
  readonly downloads: number
  readonly purchases: number
  readonly revenue: PhotoPrice
  readonly conversionRate: number
  readonly averageRating?: number
  readonly totalRatings: number
  readonly comments: number
  readonly shares: number
  readonly lastViewedAt?: Date
  readonly trending: boolean
  readonly trendingScore?: number
}

// Informations de licence et droits
export type LicenseType = "standard" | "extended" | "exclusive" | "creative_commons" | "editorial"

export interface PhotoLicense {
  readonly type: LicenseType
  readonly commercialUse: boolean
  readonly exclusivity: boolean
  readonly duration?: {
    readonly startDate: Date
    readonly endDate?: Date
  }
  readonly restrictions?: readonly string[]
  readonly attribution?: {
    readonly required: boolean
    readonly format?: string
  }
  readonly resaleAllowed: boolean
  readonly printAllowed: boolean
  readonly webUseAllowed: boolean
}

// Photo complète avec toutes les données
export interface Photo {
  readonly id: PhotoId
  readonly title: PhotoTitle
  readonly description: PhotoDescription
  readonly category: PhotoCategory
  readonly tags: PhotoTags
  readonly price: PhotoPrice
  readonly status: PhotoStatus
  readonly ownerId: UserId
  readonly metadata: PhotoMetadata
  readonly performance: PhotoPerformance
  readonly license: PhotoLicense
  readonly createdAt: CreatedAt
  readonly updatedAt: UpdatedAt
  readonly publishedAt?: Date
  readonly soldAt?: Date
  readonly approvedAt?: Date
  readonly rejectedAt?: Date
  readonly rejectionReason?: string
}

// Versions simplifiées pour différents contextes
export interface PhotoSummary {
  readonly id: PhotoId
  readonly title: PhotoTitle
  readonly thumbnailUrl: ImageUrl
  readonly price: PhotoPrice
  readonly category: PhotoCategory
  readonly status: PhotoStatus
  readonly ownerId: UserId
  readonly createdAt: CreatedAt
}

export interface PhotoCard {
  readonly id: PhotoId
  readonly title: PhotoTitle
  readonly description: PhotoDescription
  readonly thumbnailUrl: ImageUrl
  readonly previewUrl: ImageUrl
  readonly price: PhotoPrice
  readonly category: PhotoCategory
  readonly tags: PhotoTags
  readonly ownerName: string
  readonly ownerAvatar?: ImageUrl
  readonly performance: Pick<PhotoPerformance, "views" | "likes" | "purchases">
  readonly createdAt: CreatedAt
}

export interface PhotoDetail extends Photo {
  readonly owner: {
    readonly id: UserId
    readonly name: string
    readonly avatar?: ImageUrl
    readonly totalPhotos: number
    readonly totalSales: number
    readonly joinedAt: Date
    readonly verified: boolean
  }
  readonly related: readonly PhotoSummary[]
  readonly reviews?: readonly PhotoReview[]
  readonly collections?: readonly PhotoCollection[]
}

// Types pour les avis et évaluations
export interface PhotoReview {
  readonly id: string
  readonly photoId: PhotoId
  readonly reviewerId: UserId
  readonly rating: number
  readonly comment?: string
  readonly helpful: number
  readonly reported: boolean
  readonly createdAt: CreatedAt
}

// Types pour les collections
export interface PhotoCollection {
  readonly id: string
  readonly name: string
  readonly description?: string
  readonly ownerId: UserId
  readonly photoIds: readonly PhotoId[]
  readonly isPublic: boolean
  readonly createdAt: CreatedAt
  readonly updatedAt: UpdatedAt
}

// Types pour l'upload et la création
export interface CreatePhotoInput {
  readonly title: PhotoTitle
  readonly description: PhotoDescription
  readonly category: PhotoCategory
  readonly tags: PhotoTags
  readonly price: PhotoPrice
  readonly licenseType: LicenseType
  readonly file: File
}

export interface UpdatePhotoInput {
  readonly title?: PhotoTitle
  readonly description?: PhotoDescription
  readonly category?: PhotoCategory
  readonly tags?: PhotoTags
  readonly price?: PhotoPrice
  readonly status?: PhotoStatus
  readonly licenseType?: LicenseType
}

// Types pour la recherche et filtrage
export interface PhotoSearchFilters {
  readonly query?: string
  readonly category?: PhotoCategory
  readonly tags?: readonly PhotoTag[]
  readonly priceRange?: {
    readonly min: PhotoPrice
    readonly max: PhotoPrice
  }
  readonly license?: LicenseType
  readonly orientation?: "landscape" | "portrait" | "square"
  readonly resolution?: "low" | "medium" | "high"
  readonly dateRange?: {
    readonly start: Date
    readonly end: Date
  }
  readonly ownerId?: UserId
  readonly status?: PhotoStatus
  readonly minRating?: number
  readonly trending?: boolean
  readonly hasExif?: boolean
  readonly commercialUse?: boolean
}

export interface PhotoSearchSort {
  readonly field: "createdAt" | "price" | "views" | "likes" | "purchases" | "rating" | "trending"
  readonly direction: "asc" | "desc"
}

export interface PhotoSearchResult {
  readonly photos: readonly PhotoCard[]
  readonly total: number
  readonly page: number
  readonly pageSize: number
  readonly totalPages: number
  readonly hasNext: boolean
  readonly hasPrevious: boolean
  readonly filters: PhotoSearchFilters
  readonly sort: PhotoSearchSort
  readonly facets?: {
    readonly categories: ReadonlyMap<PhotoCategory, number>
    readonly priceRanges: readonly { range: string; count: number }[]
    readonly tags: ReadonlyMap<PhotoTag, number>
  }
}

// Types pour la modération
export interface PhotoModerationAction {
  readonly photoId: PhotoId
  readonly action: "approve" | "reject" | "request_changes"
  readonly reason?: string
  readonly feedback?: string
  readonly moderatorId: UserId
  readonly timestamp: Date
}

export interface PhotoModerationQueue {
  readonly photos: readonly (Photo & {
    readonly submittedAt: Date
    readonly priority: "low" | "normal" | "high"
    readonly autoFlags?: readonly string[]
  })[]
  readonly total: number
  readonly averageReviewTime: number
}

// Types pour l'analytique des photos
export interface PhotoAnalytics {
  readonly photoId: PhotoId
  readonly period: {
    readonly start: Date
    readonly end: Date
  }
  readonly metrics: {
    readonly views: number
    readonly uniqueViews: number
    readonly likes: number
    readonly downloads: number
    readonly purchases: number
    readonly revenue: PhotoPrice
    readonly conversionRate: number
    readonly bounceRate: number
    readonly averageViewDuration: number
  }
  readonly demographics?: {
    readonly countries: ReadonlyMap<string, number>
    readonly ageGroups: ReadonlyMap<string, number>
    readonly devices: ReadonlyMap<string, number>
  }
  readonly trends: {
    readonly daily: readonly { date: Date; views: number; purchases: number }[]
    readonly hourly: readonly { hour: number; views: number }[]
  }
}

// Types pour les recommandations
export interface PhotoRecommendation {
  readonly photoId: PhotoId
  readonly score: number
  readonly reasons: readonly ("similar_style" | "same_category" | "popular_with_similar_users" | "trending" | "price_match")[]
  readonly photo: PhotoCard
}

export interface PhotoRecommendationRequest {
  readonly userId?: UserId
  readonly photoId?: PhotoId
  readonly category?: PhotoCategory
  readonly priceRange?: { min: PhotoPrice; max: PhotoPrice }
  readonly limit: number
  readonly excludeOwned?: boolean
  readonly excludePurchased?: boolean
}

// Types pour les fonctionnalités avancées
export interface PhotoWatermark {
  readonly type: "text" | "image" | "logo"
  readonly position: "center" | "bottom-right" | "bottom-left" | "top-right" | "top-left"
  readonly opacity: number
  readonly content: string | ImageUrl
  readonly size: "small" | "medium" | "large"
}

export interface PhotoProcessingJob {
  readonly id: string
  readonly photoId: PhotoId
  readonly type: "thumbnail" | "watermark" | "resize" | "compress" | "format_conversion"
  readonly status: "pending" | "processing" | "completed" | "failed"
  readonly progress: number
  readonly startedAt?: Date
  readonly completedAt?: Date
  readonly error?: string
  readonly result?: {
    readonly url: ImageUrl
    readonly size: number
    readonly format: string
  }
}

// Factories pour créer des instances typées
export const createPhotoId = (id: string): PhotoId => id as PhotoId
export const createImageUrl = (url: string): ImageUrl => url as ImageUrl
export const createPhotoTitle = (title: string): PhotoTitle => title as PhotoTitle
export const createPhotoDescription = (description: string): PhotoDescription => description as PhotoDescription
export const createPhotoPrice = (price: number): PhotoPrice => price as PhotoPrice
export const createPhotoTag = (tag: string): PhotoTag => tag as PhotoTag

// Utilitaires de validation
export const isValidPhotoCategory = (category: string): category is PhotoCategory => {
  const validCategories: readonly PhotoCategory[] = [
    "nature", "portrait", "architecture", "street", "landscape", 
    "abstract", "macro", "wildlife", "travel", "event", "commercial", "artistic"
  ]
  return validCategories.includes(category as PhotoCategory)
}

export const isValidPhotoStatus = (status: string): status is PhotoStatus => {
  const validStatuses: readonly PhotoStatus[] = [
    "draft", "pending_review", "published", "sold", "archived", "rejected"
  ]
  return validStatuses.includes(status as PhotoStatus)
}

export const isValidLicenseType = (license: string): license is LicenseType => {
  const validLicenses: readonly LicenseType[] = [
    "standard", "extended", "exclusive", "creative_commons", "editorial"
  ]
  return validLicenses.includes(license as LicenseType)
}

// Helpers pour les calculs
export const calculatePhotoRevenue = (photo: Photo): PhotoPrice => {
  return createPhotoPrice(photo.performance.purchases * photo.price)
}

export const calculateConversionRate = (views: number, purchases: number): number => {
  return views > 0 ? (purchases / views) * 100 : 0
}

export const isPhotoTrending = (performance: PhotoPerformance, timeframe: number = 7): boolean => {
  // Logique pour déterminer si une photo est trending
  return performance.trending || performance.trendingScore > 0.8
}
```

### 3. Types pour les achats et transactions

**Créer `src/types/business/purchase.ts`** :
```typescript
import type { UserId, Amount, CreatedAt, UpdatedAt } from "../utils/branded-types"
import type { PhotoId, PhotoPrice } from "./photo"

// Types de base pour les achats
export type PurchaseId = string & { readonly brand: unique symbol }
export type TransactionId = string & { readonly brand: unique symbol }
export type InvoiceId = string & { readonly brand: unique symbol }

// Statuts des achats
export type PurchaseStatus = 
  | "pending" 
  | "processing" 
  | "completed" 
  | "failed" 
  | "cancelled" 
  | "refunded" 
  | "disputed"

// Types de paiement
export type PaymentMethod = "card" | "paypal" | "bank_transfer" | "wallet" | "crypto"
export type Currency = "EUR" | "USD" | "GBP" | "CAD" | "JPY"

// Types Stripe spécialisés
export type StripeSessionId = string & { readonly brand: unique symbol }
export type StripePaymentIntentId = string & { readonly brand: unique symbol }
export type StripeCustomerId = string & { readonly brand: unique symbol }
export type StripeProductId = string & { readonly brand: unique symbol }

// Informations de paiement
export interface PaymentDetails {
  readonly method: PaymentMethod
  readonly currency: Currency
  readonly amount: Amount
  readonly fee: Amount
  readonly netAmount: Amount
  readonly exchangeRate?: number
  readonly originalCurrency?: Currency
  readonly originalAmount?: Amount
  readonly provider: {
    readonly name: "stripe" | "paypal" | "square"
    readonly transactionId: TransactionId
    readonly paymentIntentId?: StripePaymentIntentId
    readonly sessionId?: StripeSessionId
  }
  readonly billing?: {
    readonly name: string
    readonly email: string
    readonly address: {
      readonly line1: string
      readonly line2?: string
      readonly city: string
      readonly state?: string
      readonly postalCode: string
      readonly country: string
    }
  }
  readonly processedAt: Date
}

// Achat individuel d'une photo
export interface PhotoPurchase {
  readonly id: PurchaseId
  readonly photoId: PhotoId
  readonly buyerId: UserId
  readonly sellerId: UserId
  readonly status: PurchaseStatus
  readonly amount: PhotoPrice
  readonly currency: Currency
  readonly payment: PaymentDetails
  readonly license: {
    readonly type: "standard" | "extended" | "exclusive"
    readonly duration?: {
      readonly startDate: Date
      readonly endDate?: Date
    }
    readonly usage: readonly string[]
    readonly territories: readonly string[]
  }
  readonly downloadInfo?: {
    readonly downloadUrl: string
    readonly downloadToken: string
    readonly expiresAt: Date
    readonly downloadCount: number
    readonly maxDownloads: number
  }
  readonly createdAt: CreatedAt
  readonly updatedAt: UpdatedAt
  readonly completedAt?: Date
  readonly refundedAt?: Date
}

// Panier et commandes groupées
export interface CartItem {
  readonly photoId: PhotoId
  readonly quantity: number
  readonly licenseType: "standard" | "extended" | "exclusive"
  readonly price: PhotoPrice
  readonly addedAt: Date
}

export interface ShoppingCart {
  readonly id: string
  readonly userId: UserId
  readonly items: readonly CartItem[]
  readonly subtotal: Amount
  readonly taxes: Amount
  readonly fees: Amount
  readonly discount?: {
    readonly code: string
    readonly amount: Amount
    readonly percentage?: number
  }
  readonly total: Amount
  readonly currency: Currency
  readonly createdAt: CreatedAt
  readonly updatedAt: UpdatedAt
  readonly expiresAt: Date
}

// Commande complète
export interface Order {
  readonly id: string
  readonly userId: UserId
  readonly cart: ShoppingCart
  readonly status: PurchaseStatus
  readonly payment: PaymentDetails
  readonly purchases: readonly PhotoPurchase[]
  readonly invoice: {
    readonly id: InvoiceId
    readonly number: string
    readonly url: string
    readonly pdfUrl?: string
  }
  readonly fulfillment: {
    readonly status: "pending" | "processing" | "completed" | "failed"
    readonly downloadPackageUrl?: string
    readonly individualDownloads: ReadonlyMap<PhotoId, string>
    readonly completedAt?: Date
  }
  readonly createdAt: CreatedAt
  readonly updatedAt: UpdatedAt
}

// Types pour les remboursements
export interface RefundRequest {
  readonly id: string
  readonly purchaseId: PurchaseId
  readonly requesterId: UserId
  readonly reason: "accidental" | "quality_issue" | "licensing_dispute" | "technical_issue" | "other"
  readonly description: string
  readonly amount: Amount
  readonly status: "pending" | "approved" | "rejected" | "processed"
  readonly evidence?: readonly string[]
  readonly processedBy?: UserId
  readonly processedAt?: Date
  readonly refundMethod?: PaymentMethod
  readonly refundTransactionId?: TransactionId
  readonly createdAt: CreatedAt
}

// Analytics des achats
export interface PurchaseAnalytics {
  readonly period: {
    readonly start: Date
    readonly end: Date
  }
  readonly metrics: {
    readonly totalPurchases: number
    readonly totalRevenue: Amount
    readonly averageOrderValue: Amount
    readonly conversionRate: number
    readonly refundRate: number
    readonly repeatCustomerRate: number
  }
  readonly breakdown: {
    readonly byCategory: ReadonlyMap<string, { count: number; revenue: Amount }>
    readonly byLicense: ReadonlyMap<string, { count: number; revenue: Amount }>
    readonly byPaymentMethod: ReadonlyMap<PaymentMethod, { count: number; revenue: Amount }>
    readonly byCurrency: ReadonlyMap<Currency, { count: number; revenue: Amount }>
  }
  readonly trends: {
    readonly daily: readonly { date: Date; purchases: number; revenue: Amount }[]
    readonly monthly: readonly { month: string; purchases: number; revenue: Amount }[]
  }
  readonly topBuyers: readonly {
    readonly userId: UserId
    readonly purchaseCount: number
    readonly totalSpent: Amount
    readonly averageOrderValue: Amount
  }[]
}

// Types pour les disputes et litiges
export interface Dispute {
  readonly id: string
  readonly purchaseId: PurchaseId
  readonly disputerId: UserId
  readonly respondentId: UserId
  readonly type: "chargeback" | "quality_claim" | "licensing_issue" | "fraud_claim"
  readonly status: "open" | "under_review" | "resolved" | "escalated" | "closed"
  readonly amount: Amount
  readonly description: string
  readonly evidence: readonly {
    readonly type: "document" | "image" | "email" | "screenshot"
    readonly url: string
    readonly description: string
    readonly uploadedAt: Date
  }[]
  readonly resolution?: {
    readonly type: "buyer_wins" | "seller_wins" | "partial_refund" | "replacement"
    readonly amount?: Amount
    readonly description: string
    readonly resolvedBy: UserId
    readonly resolvedAt: Date
  }
  readonly messages: readonly {
    readonly id: string
    readonly senderId: UserId
    readonly message: string
    readonly sentAt: Date
  }[]
  readonly createdAt: CreatedAt
  readonly updatedAt: UpdatedAt
}

// Types pour les notifications d'achat
export interface PurchaseNotification {
  readonly id: string
  readonly userId: UserId
  readonly type: "purchase_completed" | "download_ready" | "refund_processed" | "dispute_opened"
  readonly purchaseId: PurchaseId
  readonly title: string
  readonly message: string
  readonly read: boolean
  readonly actionUrl?: string
  readonly data?: Record<string, unknown>
  readonly createdAt: CreatedAt
}

// Types pour l'historique des achats
export interface PurchaseHistory {
  readonly purchases: readonly PhotoPurchase[]
  readonly total: number
  readonly page: number
  readonly pageSize: number
  readonly filters: {
    readonly status?: PurchaseStatus
    readonly dateRange?: { start: Date; end: Date }
    readonly priceRange?: { min: Amount; max: Amount }
    readonly sellerId?: UserId
  }
  readonly summary: {
    readonly totalSpent: Amount
    readonly totalPurchases: number
    readonly averageOrderValue: Amount
    readonly favoriteCategory?: string
    readonly mostRecentPurchase?: Date
  }
}

// Types pour les rapports de vente
export interface SalesReport {
  readonly sellerId: UserId
  readonly period: {
    readonly start: Date
    readonly end: Date
  }
  readonly sales: readonly PhotoPurchase[]
  readonly metrics: {
    readonly totalSales: number
    readonly totalRevenue: Amount
    readonly averageSalePrice: Amount
    readonly commission: Amount
    readonly netRevenue: Amount
    readonly topPerformingPhoto?: PhotoId
    readonly conversionRate: number
  }
  readonly trends: {
    readonly daily: readonly { date: Date; sales: number; revenue: Amount }[]
    readonly photoPerformance: readonly {
      readonly photoId: PhotoId
      readonly sales: number
      readonly revenue: Amount
      readonly views: number
      readonly conversionRate: number
    }[]
  }
  readonly payouts: readonly {
    readonly id: string
    readonly amount: Amount
    readonly status: "pending" | "processing" | "completed" | "failed"
    readonly method: "bank_transfer" | "paypal" | "stripe"
    readonly scheduledAt: Date
    readonly processedAt?: Date
  }[]
}

// Factories et utilitaires
export const createPurchaseId = (id: string): PurchaseId => id as PurchaseId
export const createTransactionId = (id: string): TransactionId => id as TransactionId
export const createInvoiceId = (id: string): InvoiceId => id as InvoiceId
export const createStripeSessionId = (id: string): StripeSessionId => id as StripeSessionId
export const createStripePaymentIntentId = (id: string): StripePaymentIntentId => id as StripePaymentIntentId
export const createStripeCustomerId = (id: string): StripeCustomerId => id as StripeCustomerId

export const isValidPurchaseStatus = (status: string): status is PurchaseStatus => {
  const validStatuses: readonly PurchaseStatus[] = [
    "pending", "processing", "completed", "failed", "cancelled", "refunded", "disputed"
  ]
  return validStatuses.includes(status as PurchaseStatus)
}

export const isValidPaymentMethod = (method: string): method is PaymentMethod => {
  const validMethods: readonly PaymentMethod[] = ["card", "paypal", "bank_transfer", "wallet", "crypto"]
  return validMethods.includes(method as PaymentMethod)
}

export const isValidCurrency = (currency: string): currency is Currency => {
  const validCurrencies: readonly Currency[] = ["EUR", "USD", "GBP", "CAD", "JPY"]
  return validCurrencies.includes(currency as Currency)
}

// Helpers pour les calculs
export const calculateOrderTotal = (cart: ShoppingCart): Amount => {
  return cart.total
}

export const calculateCommission = (amount: Amount, rate: number = 0.15): Amount => {
  return (amount * rate) as Amount
}

export const calculateNetRevenue = (amount: Amount, commission: Amount): Amount => {
  return (amount - commission) as Amount
}

export const isPurchaseRefundable = (purchase: PhotoPurchase, timeLimit: number = 30): boolean => {
  const daysSincePurchase = Math.floor(
    (Date.now() - purchase.createdAt.getTime()) / (1000 * 60 * 60 * 24)
  )
  return daysSincePurchase <= timeLimit && purchase.status === "completed"
}
```

### 4. Types pour l'API REST et communication

**Créer `src/types/api/routes.ts`** :
```typescript
import type { PhotoId, PhotoSearchFilters, PhotoSearchSort } from "../business/photo"
import type { PurchaseId, Currency } from "../business/purchase"
import type { UserId } from "../utils/branded-types"

// Types de routes API avec paramètres typés
export interface ApiRoutes {
  // Routes d'authentification
  readonly auth: {
    readonly signin: {
      readonly method: "POST"
      readonly path: "/api/auth/signin"
      readonly body: {
        readonly email: string
        readonly password: string
        readonly remember?: boolean
      }
      readonly response: {
        readonly user: {
          readonly id: UserId
          readonly email: string
          readonly name: string
          readonly role: "USER" | "ADMIN"
        }
        readonly token: string
        readonly expiresAt: string
      }
    }
    readonly signup: {
      readonly method: "POST"
      readonly path: "/api/auth/signup"
      readonly body: {
        readonly email: string
        readonly password: string
        readonly name: string
        readonly terms: boolean
      }
      readonly response: {
        readonly user: {
          readonly id: UserId
          readonly email: string
          readonly name: string
        }
        readonly message: string
      }
    }
    readonly refresh: {
      readonly method: "POST"
      readonly path: "/api/auth/refresh"
      readonly body: {
        readonly refreshToken: string
      }
      readonly response: {
        readonly token: string
        readonly expiresAt: string
      }
    }
  }

  // Routes des photos
  readonly photos: {
    readonly list: {
      readonly method: "GET"
      readonly path: "/api/photos"
      readonly query?: {
        readonly page?: number
        readonly limit?: number
        readonly category?: string
        readonly tags?: string
        readonly priceMin?: number
        readonly priceMax?: number
        readonly sortBy?: string
        readonly sortOrder?: "asc" | "desc"
        readonly search?: string
      }
      readonly response: {
        readonly photos: readonly {
          readonly id: PhotoId
          readonly title: string
          readonly thumbnailUrl: string
          readonly price: number
          readonly category: string
          readonly ownerId: UserId
          readonly createdAt: string
        }[]
        readonly pagination: {
          readonly page: number
          readonly limit: number
          readonly total: number
          readonly totalPages: number
          readonly hasNext: boolean
          readonly hasPrevious: boolean
        }
      }
    }
    readonly get: {
      readonly method: "GET"
      readonly path: "/api/photos/:id"
      readonly params: {
        readonly id: PhotoId
      }
      readonly response: {
        readonly id: PhotoId
        readonly title: string
        readonly description: string
        readonly imageUrl: string
        readonly price: number
        readonly category: string
        readonly tags: readonly string[]
        readonly status: string
        readonly owner: {
          readonly id: UserId
          readonly name: string
          readonly avatar?: string
        }
        readonly metadata: {
          readonly dimensions: {
            readonly width: number
            readonly height: number
          }
          readonly fileSize: number
          readonly format: string
        }
        readonly performance: {
          readonly views: number
          readonly likes: number
          readonly purchases: number
        }
        readonly createdAt: string
        readonly updatedAt: string
      }
    }
    readonly create: {
      readonly method: "POST"
      readonly path: "/api/photos"
      readonly body: FormData | {
        readonly title: string
        readonly description: string
        readonly category: string
        readonly tags: readonly string[]
        readonly price: number
        readonly licenseType: string
        readonly file?: File
      }
      readonly response: {
        readonly id: PhotoId
        readonly title: string
        readonly status: string
        readonly uploadUrl?: string
        readonly message: string
      }
    }
    readonly update: {
      readonly method: "PUT"
      readonly path: "/api/photos/:id"
      readonly params: {
        readonly id: PhotoId
      }
      readonly body: {
        readonly title?: string
        readonly description?: string
        readonly category?: string
        readonly tags?: readonly string[]
        readonly price?: number
        readonly status?: string
      }
      readonly response: {
        readonly id: PhotoId
        readonly title: string
        readonly status: string
        readonly updatedAt: string
        readonly message: string
      }
    }
    readonly delete: {
      readonly method: "DELETE"
      readonly path: "/api/photos/:id"
      readonly params: {
        readonly id: PhotoId
      }
      readonly response: {
        readonly success: boolean
        readonly message: string
      }
    }
    readonly upload: {
      readonly method: "POST"
      readonly path: "/api/photos/upload"
      readonly body: FormData
      readonly response: {
        readonly uploadId: string
        readonly status: "uploading" | "processing" | "completed" | "failed"
        readonly progress: number
        readonly url?: string
        readonly error?: string
      }
    }
  }

  // Routes des achats
  readonly purchases: {
    readonly create: {
      readonly method: "POST"
      readonly path: "/api/purchases"
      readonly body: {
        readonly photoId: PhotoId
        readonly licenseType: "standard" | "extended" | "exclusive"
        readonly currency?: Currency
      }
      readonly response: {
        readonly purchaseId: PurchaseId
        readonly stripeSessionId: string
        readonly checkoutUrl: string
        readonly expiresAt: string
      }
    }
    readonly get: {
      readonly method: "GET"
      readonly path: "/api/purchases/:id"
      readonly params: {
        readonly id: PurchaseId
      }
      readonly response: {
        readonly id: PurchaseId
        readonly photoId: PhotoId
        readonly status: string
        readonly amount: number
        readonly currency: string
        readonly downloadUrl?: string
        readonly createdAt: string
        readonly completedAt?: string
      }
    }
    readonly list: {
      readonly method: "GET"
      readonly path: "/api/purchases"
      readonly query?: {
        readonly page?: number
        readonly limit?: number
        readonly status?: string
        readonly dateFrom?: string
        readonly dateTo?: string
      }
      readonly response: {
        readonly purchases: readonly {
          readonly id: PurchaseId
          readonly photoId: PhotoId
          readonly photoTitle: string
          readonly photoThumbnail: string
          readonly amount: number
          readonly currency: string
          readonly status: string
          readonly createdAt: string
        }[]
        readonly pagination: {
          readonly page: number
          readonly limit: number
          readonly total: number
          readonly totalPages: number
        }
        readonly summary: {
          readonly totalSpent: number
          readonly totalPurchases: number
          readonly currency: string
        }
      }
    }
    readonly download: {
      readonly method: "GET"
      readonly path: "/api/purchases/:id/download"
      readonly params: {
        readonly id: PurchaseId
      }
      readonly query?: {
        readonly token: string
      }
      readonly response: Blob | {
        readonly downloadUrl: string
        readonly expiresAt: string
        readonly remainingDownloads: number
      }
    }
  }

  // Routes du panier
  readonly cart: {
    readonly get: {
      readonly method: "GET"
      readonly path: "/api/cart"
      readonly response: {
        readonly items: readonly {
          readonly photoId: PhotoId
          readonly photoTitle: string
          readonly photoThumbnail: string
          readonly price: number
          readonly licenseType: string
          readonly addedAt: string
        }[]
        readonly subtotal: number
        readonly taxes: number
        readonly total: number
        readonly currency: string
        readonly itemCount: number
      }
    }
    readonly add: {
      readonly method: "POST"
      readonly path: "/api/cart/items"
      readonly body: {
        readonly photoId: PhotoId
        readonly licenseType: "standard" | "extended" | "exclusive"
      }
      readonly response: {
        readonly success: boolean
        readonly message: string
        readonly itemCount: number
        readonly total: number
      }
    }
    readonly remove: {
      readonly method: "DELETE"
      readonly path: "/api/cart/items/:photoId"
      readonly params: {
        readonly photoId: PhotoId
      }
      readonly response: {
        readonly success: boolean
        readonly message: string
        readonly itemCount: number
        readonly total: number
      }
    }
    readonly checkout: {
      readonly method: "POST"
      readonly path: "/api/cart/checkout"
      readonly body: {
        readonly currency?: Currency
        readonly paymentMethod?: string
      }
      readonly response: {
        readonly sessionId: string
        readonly checkoutUrl: string
        readonly orderId: string
        readonly expiresAt: string
      }
    }
  }

  // Routes d'administration
  readonly admin: {
    readonly users: {
      readonly list: {
        readonly method: "GET"
        readonly path: "/api/admin/users"
        readonly query?: {
          readonly page?: number
          readonly limit?: number
          readonly role?: "USER" | "ADMIN"
          readonly status?: string
          readonly search?: string
        }
        readonly response: {
          readonly users: readonly {
            readonly id: UserId
            readonly email: string
            readonly name: string
            readonly role: "USER" | "ADMIN"
            readonly status: string
            readonly createdAt: string
            readonly lastLoginAt?: string
            readonly photosCount: number
            readonly purchasesCount: number
          }[]
          readonly pagination: {
            readonly page: number
            readonly limit: number
            readonly total: number
            readonly totalPages: number
          }
        }
      }
      readonly update: {
        readonly method: "PUT"
        readonly path: "/api/admin/users/:id"
        readonly params: {
          readonly id: UserId
        }
        readonly body: {
          readonly role?: "USER" | "ADMIN"
          readonly status?: string
          readonly emailVerified?: boolean
        }
        readonly response: {
          readonly success: boolean
          readonly message: string
          readonly user: {
            readonly id: UserId
            readonly role: "USER" | "ADMIN"
            readonly status: string
            readonly updatedAt: string
          }
        }
      }
    }
    readonly analytics: {
      readonly dashboard: {
        readonly method: "GET"
        readonly path: "/api/admin/analytics/dashboard"
        readonly query?: {
          readonly period?: "7d" | "30d" | "90d" | "1y"
        }
        readonly response: {
          readonly overview: {
            readonly totalUsers: number
            readonly totalPhotos: number
            readonly totalRevenue: number
            readonly totalTransactions: number
          }
          readonly trends: {
            readonly users: readonly { date: string; count: number }[]
            readonly photos: readonly { date: string; count: number }[]
            readonly revenue: readonly { date: string; amount: number }[]
          }
          readonly topCategories: readonly {
            readonly category: string
            readonly count: number
            readonly revenue: number
          }[]
        }
      }
    }
  }

  // Routes de recherche avancée
  readonly search: {
    readonly photos: {
      readonly method: "POST"
      readonly path: "/api/search/photos"
      readonly body: {
        readonly query?: string
        readonly filters?: PhotoSearchFilters
        readonly sort?: PhotoSearchSort
        readonly page?: number
        readonly limit?: number
        readonly facets?: boolean
      }
      readonly response: {
        readonly photos: readonly {
          readonly id: PhotoId
          readonly title: string
          readonly description: string
          readonly thumbnailUrl: string
          readonly price: number
          readonly category: string
          readonly tags: readonly string[]
          readonly ownerName: string
          readonly ownerAvatar?: string
          readonly performance: {
            readonly views: number
            readonly likes: number
            readonly purchases: number
          }
          readonly createdAt: string
          readonly relevanceScore?: number
        }[]
        readonly pagination: {
          readonly page: number
          readonly limit: number
          readonly total: number
          readonly totalPages: number
        }
        readonly facets?: {
          readonly categories: readonly { value: string; count: number }[]
          readonly priceRanges: readonly { range: string; count: number }[]
          readonly tags: readonly { value: string; count: number }[]
        }
        readonly suggestions?: readonly string[]
        readonly searchTime: number
      }
    }
    readonly autocomplete: {
      readonly method: "GET"
      readonly path: "/api/search/autocomplete"
      readonly query: {
        readonly q: string
        readonly type?: "photos" | "users" | "tags"
        readonly limit?: number
      }
      readonly response: {
        readonly suggestions: readonly {
          readonly value: string
          readonly type: "photo" | "user" | "tag" | "category"
          readonly count?: number
          readonly thumbnail?: string
        }[]
      }
    }
  }

  // Routes de webhooks
  readonly webhooks: {
    readonly stripe: {
      readonly method: "POST"
      readonly path: "/api/webhooks/stripe"
      readonly body: {
        readonly id: string
        readonly object: string
        readonly type: string
        readonly data: {
          readonly object: Record<string, unknown>
        }
        readonly created: number
        readonly livemode: boolean
      }
      readonly response: {
        readonly received: boolean
      }
    }
  }
}

// Types pour les en-têtes de requête
export interface ApiHeaders {
  readonly "Content-Type"?: "application/json" | "multipart/form-data" | "application/x-www-form-urlencoded"
  readonly "Authorization"?: `Bearer ${string}`
  readonly "X-API-Key"?: string
  readonly "X-Request-ID"?: string
  readonly "X-Client-Version"?: string
  readonly "Accept"?: "application/json"
  readonly "Cache-Control"?: string
  readonly "If-Modified-Since"?: string
  readonly "If-None-Match"?: string
}

// Types pour les réponses d'erreur standardisées
export interface ApiErrorResponse {
  readonly error: {
    readonly code: string
    readonly message: string
    readonly details?: Record<string, unknown>
    readonly field?: string
    readonly requestId: string
    readonly timestamp: string
  }
}

// Types pour les métadonnées de réponse
export interface ApiResponseMetadata {
  readonly requestId: string
  readonly timestamp: string
  readonly version: string
  readonly duration: number
  readonly cached?: boolean
  readonly rateLimit?: {
    readonly limit: number
    readonly remaining: number
    readonly resetAt: string
  }
}

// Type helper pour extraire les types de route
export type ExtractRouteMethod<T> = T extends { readonly method: infer M } ? M : never
export type ExtractRoutePath<T> = T extends { readonly path: infer P } ? P : never
export type ExtractRouteBody<T> = T extends { readonly body: infer B } ? B : never
export type ExtractRouteQuery<T> = T extends { readonly query: infer Q } ? Q : never
export type ExtractRouteParams<T> = T extends { readonly params: infer P } ? P : never
export type ExtractRouteResponse<T> = T extends { readonly response: infer R } ? R : never

// Utilitaires pour la construction d'URLs
export const buildApiUrl = (path: string, params?: Record<string, string>): string => {
  let url = path
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      url = url.replace(`:${key}`, encodeURIComponent(value))
    })
  }
  return url
}

export const buildQueryString = (query?: Record<string, unknown>): string => {
  if (!query) return ""
  const params = new URLSearchParams()
  Object.entries(query).forEach(([key, value]) => {
    if (value !== undefined && value !== null) {
      params.append(key, String(value))
    }
  })
  const queryString = params.toString()
  return queryString ? `?${queryString}` : ""
}

// Type pour les configurations de client API
export interface ApiClientConfig {
  readonly baseUrl: string
  readonly timeout: number
  readonly retries: number
  readonly headers: ApiHeaders
  readonly interceptors?: {
    readonly request?: (config: RequestInit) => RequestInit | Promise<RequestInit>
    readonly response?: (response: Response) => Response | Promise<Response>
    readonly error?: (error: Error) => Error | Promise<Error>
  }
}
```

### 5. Types pour les composants React avancés

**Créer `src/types/ui/components.ts`** :
```typescript
import type { ReactNode, ComponentProps, ElementType, ForwardedRef } from "react"
import type { PhotoId, Photo, PhotoCard, PhotoSearchFilters } from "../business/photo"
import type { PurchaseId, ShoppingCart } from "../business/purchase"
import type { UserId } from "../utils/branded-types"

// Types de base pour les props des composants
export interface BaseComponentProps {
  readonly className?: string
  readonly id?: string
  readonly testId?: string
  readonly children?: ReactNode
}

// Types pour les variantes de composants
export type ComponentSize = "xs" | "sm" | "md" | "lg" | "xl"
export type ComponentVariant = "primary" | "secondary" | "success" | "warning" | "error" | "info"
export type ComponentState = "idle" | "loading" | "success" | "error"

// Types pour les composants polymorphes
export interface PolymorphicComponentProps<T extends ElementType> extends BaseComponentProps {
  readonly as?: T
}

export type PolymorphicRef<T extends ElementType> = ComponentProps<T>["ref"]

export interface PolymorphicComponentPropsWithRef<
  T extends ElementType,
  Props = {}
> extends PolymorphicComponentProps<T>, Props {
  readonly ref?: PolymorphicRef<T>
}

// Types pour les composants de photo
export interface PhotoCardProps extends BaseComponentProps {
  readonly photo: PhotoCard
  readonly variant?: "grid" | "list" | "featured"
  readonly size?: ComponentSize
  readonly showOwner?: boolean
  readonly showPrice?: boolean
  readonly showStats?: boolean
  readonly interactive?: boolean
  readonly loading?: boolean
  readonly onLike?: (photoId: PhotoId) => void | Promise<void>
  readonly onAddToCart?: (photoId: PhotoId) => void | Promise<void>
  readonly onView?: (photoId: PhotoId) => void | Promise<void>
  readonly onShare?: (photoId: PhotoId) => void | Promise<void>
}

export interface PhotoGridProps extends BaseComponentProps {
  readonly photos: readonly PhotoCard[]
  readonly columns?: 2 | 3 | 4 | 5 | 6
  readonly gap?: ComponentSize
  readonly loading?: boolean
  readonly loadingCount?: number
  readonly variant?: "masonry" | "grid" | "justified"
  readonly aspectRatio?: "auto" | "square" | "portrait" | "landscape"
  readonly onPhotoClick?: (photo: PhotoCard) => void
  readonly onLike?: (photoId: PhotoId) => void | Promise<void>
  readonly onAddToCart?: (photoId: PhotoId) => void | Promise<void>
  readonly renderCard?: (photo: PhotoCard) => ReactNode
  readonly renderEmpty?: () => ReactNode
  readonly renderLoading?: () => ReactNode
}

export interface PhotoDetailProps extends BaseComponentProps {
  readonly photoId: PhotoId
  readonly photo?: Photo
  readonly loading?: boolean
  readonly error?: Error | null
  readonly showMetadata?: boolean
  readonly showRelated?: boolean
  readonly showReviews?: boolean
  readonly allowDownload?: boolean
  readonly onPurchase?: (photoId: PhotoId, licenseType: string) => void | Promise<void>
  readonly onAddToCart?: (photoId: PhotoId, licenseType: string) => void | Promise<void>
  readonly onShare?: (photoId: PhotoId) => void | Promise<void>
  readonly onReport?: (photoId: PhotoId, reason: string) => void | Promise<void>
}

export interface PhotoUploadProps extends BaseComponentProps {
  readonly multiple?: boolean
  readonly maxFiles?: number
  readonly maxSize?: number
  readonly acceptedFormats?: readonly string[]
  readonly requireMetadata?: boolean
  readonly autoProcess?: boolean
  readonly onUploadStart?: (files: readonly File[]) => void
  readonly onUploadProgress?: (progress: number, file: File) => void
  readonly onUploadComplete?: (results: readonly { file: File; photoId?: PhotoId; error?: Error }[]) => void
  readonly onUploadError?: (error: Error, file: File) => void
  readonly renderDropzone?: (isDragActive: boolean, isDragReject: boolean) => ReactNode
  readonly renderProgress?: (progress: number, file: File) => ReactNode
  readonly renderPreview?: (file: File, index: number) => ReactNode
}

// Types pour les composants de formulaire
export interface FormFieldProps<T = unknown> extends BaseComponentProps {
  readonly name: string
  readonly label?: string
  readonly placeholder?: string
  readonly value?: T
  readonly defaultValue?: T
  readonly error?: string | readonly string[]
  readonly required?: boolean
  readonly disabled?: boolean
  readonly loading?: boolean
  readonly size?: ComponentSize
  readonly variant?: ComponentVariant
  readonly onChange?: (value: T) => void
  readonly onBlur?: () => void
  readonly onFocus?: () => void
}

export interface InputProps extends FormFieldProps<string> {
  readonly type?: "text" | "email" | "password" | "url" | "tel" | "search"
  readonly maxLength?: number
  readonly minLength?: number
  readonly pattern?: string
  readonly autoComplete?: string
  readonly autoFocus?: boolean
  readonly readOnly?: boolean
  readonly leftIcon?: ReactNode
  readonly rightIcon?: ReactNode
  readonly leftElement?: ReactNode
  readonly rightElement?: ReactNode
}

export interface TextareaProps extends FormFieldProps<string> {
  readonly rows?: number
  readonly cols?: number
  readonly maxLength?: number
  readonly minLength?: number
  readonly resize?: "none" | "both" | "horizontal" | "vertical"
  readonly autoResize?: boolean
}

export interface SelectProps<T = string> extends FormFieldProps<T> {
  readonly options: readonly {
    readonly value: T
    readonly label: string
    readonly disabled?: boolean
    readonly group?: string
  }[]
  readonly multiple?: boolean
  readonly searchable?: boolean
  readonly clearable?: boolean
  readonly loading?: boolean
  readonly loadingText?: string
  readonly noOptionsText?: string
  readonly renderOption?: (option: { value: T; label: string }) => ReactNode
  readonly renderValue?: (value: T) => ReactNode
  readonly onSearch?: (query: string) => void
}

export interface CheckboxProps extends FormFieldProps<boolean> {
  readonly indeterminate?: boolean
  readonly color?: ComponentVariant
}

export interface RadioGroupProps<T = string> extends FormFieldProps<T> {
  readonly options: readonly {
    readonly value: T
    readonly label: string
    readonly description?: string
    readonly disabled?: boolean
  }[]
  readonly orientation?: "horizontal" | "vertical"
  readonly color?: ComponentVariant
}

// Types pour les composants de navigation
export interface BreadcrumbProps extends BaseComponentProps {
  readonly items: readonly {
    readonly label: string
    readonly href?: string
    readonly current?: boolean
  }[]
  readonly separator?: ReactNode
  readonly maxItems?: number
  readonly renderItem?: (item: { label: string; href?: string; current?: boolean }) => ReactNode
}

export interface PaginationProps extends BaseComponentProps {
  readonly currentPage: number
  readonly totalPages: number
  readonly pageSize: number
  readonly totalItems: number
  readonly showFirstLast?: boolean
  readonly showPrevNext?: boolean
  readonly showPageNumbers?: boolean
  readonly showPageSize?: boolean
  readonly pageSizeOptions?: readonly number[]
  readonly maxVisiblePages?: number
  readonly onPageChange: (page: number) => void
  readonly onPageSizeChange?: (pageSize: number) => void
  readonly loading?: boolean
  readonly disabled?: boolean
}

export interface TabsProps extends BaseComponentProps {
  readonly value?: string
  readonly defaultValue?: string
  readonly orientation?: "horizontal" | "vertical"
  readonly variant?: "line" | "enclosed" | "soft-rounded" | "solid-rounded"
  readonly size?: ComponentSize
  readonly isLazy?: boolean
  readonly onChange?: (value: string) => void
  readonly children: ReactNode
}

export interface TabProps extends BaseComponentProps {
  readonly value: string
  readonly disabled?: boolean
  readonly icon?: ReactNode
  readonly isSelected?: boolean
  readonly children: ReactNode
}

export interface TabPanelProps extends BaseComponentProps {
  readonly value: string
  readonly children: ReactNode
}

// Types pour les composants de feedback
export interface AlertProps extends BaseComponentProps {
  readonly status: ComponentVariant
  readonly title?: string
  readonly description?: string
  readonly icon?: ReactNode
  readonly closable?: boolean
  readonly onClose?: () => void
  readonly action?: ReactNode
}

export interface ToastProps extends BaseComponentProps {
  readonly id: string
  readonly title?: string
  readonly description?: string
  readonly status: ComponentVariant
  readonly duration?: number
  readonly isClosable?: boolean
  readonly position?: "top" | "top-left" | "top-right" | "bottom" | "bottom-left" | "bottom-right"
  readonly onClose?: () => void
  readonly action?: ReactNode
}

export interface ModalProps extends BaseComponentProps {
  readonly isOpen: boolean
  readonly onClose: () => void
  readonly size?: ComponentSize
  readonly variant?: "default" | "alert" | "drawer"
  readonly closeOnOverlayClick?: boolean
  readonly closeOnEsc?: boolean
  readonly trapFocus?: boolean
  readonly finalFocusRef?: React.RefObject<HTMLElement>
  readonly initialFocusRef?: React.RefObject<HTMLElement>
  readonly motionPreset?: "slideInBottom" | "slideInRight" | "scale" | "none"
}

export interface ModalHeaderProps extends BaseComponentProps {
  readonly children: ReactNode
}

export interface ModalBodyProps extends BaseComponentProps {
  readonly children: ReactNode
}

export interface ModalFooterProps extends BaseComponentProps {
  readonly children: ReactNode
}

// Types pour les composants de données
export interface TableProps<T = Record<string, unknown>> extends BaseComponentProps {
  readonly data: readonly T[]
  readonly columns: readonly TableColumn<T>[]
  readonly loading?: boolean
  readonly error?: Error | null
  readonly sortable?: boolean
  readonly selectable?: boolean
  readonly selectedRows?: readonly T[]
  readonly pagination?: {
    readonly currentPage: number
    readonly totalPages: number
    readonly pageSize: number
    readonly totalItems: number
    readonly onPageChange: (page: number) => void
  }
  readonly onSort?: (column: keyof T, direction: "asc" | "desc") => void
  readonly onSelect?: (rows: readonly T[]) => void
  readonly onRowClick?: (row: T, index: number) => void
  readonly renderRow?: (row: T, index: number) => ReactNode
  readonly renderEmpty?: () => ReactNode
  readonly renderLoading?: () => ReactNode
  readonly renderError?: (error: Error) => ReactNode
}

export interface TableColumn<T = Record<string, unknown>> {
  readonly key: keyof T | string
  readonly title: string
  readonly width?: string | number
  readonly minWidth?: string | number
  readonly maxWidth?: string | number
  readonly sortable?: boolean
  readonly filterable?: boolean
  readonly resizable?: boolean
  readonly align?: "left" | "center" | "right"
  readonly render?: (value: unknown, row: T, index: number) => ReactNode
  readonly renderHeader?: () => ReactNode
  readonly getRowValue?: (row: T) => unknown
}

export interface DataListProps<T = Record<string, unknown>> extends BaseComponentProps {
  readonly data: readonly T[]
  readonly loading?: boolean
  readonly error?: Error | null
  readonly hasMore?: boolean
  readonly onLoadMore?: () => void
  readonly renderItem: (item: T, index: number) => ReactNode
  readonly renderLoading?: () => ReactNode
  readonly renderError?: (error: Error) => ReactNode
  readonly renderEmpty?: () => ReactNode
  readonly keyExtractor?: (item: T, index: number) => string
}

// Types pour les composants de panier
export interface CartItemProps extends BaseComponentProps {
  readonly photoId: PhotoId
  readonly photoTitle: string
  readonly photoThumbnail: string
  readonly price: number
  readonly licenseType: string
  readonly addedAt: Date
  readonly loading?: boolean
  readonly onRemove?: (photoId: PhotoId) => void | Promise<void>
  readonly onUpdateLicense?: (photoId: PhotoId, licenseType: string) => void | Promise<void>
}

export interface CartSummaryProps extends BaseComponentProps {
  readonly cart: ShoppingCart
  readonly loading?: boolean
  readonly showBreakdown?: boolean
  readonly showPromoCode?: boolean
  readonly onApplyPromoCode?: (code: string) => void | Promise<void>
  readonly onRemovePromoCode?: () => void | Promise<void>
  readonly onCheckout?: () => void | Promise<void>
}

export interface CartDrawerProps extends BaseComponentProps {
  readonly isOpen: boolean
  readonly onClose: () => void
  readonly cart: ShoppingCart
  readonly loading?: boolean
  readonly onUpdateItem?: (photoId: PhotoId, updates: { licenseType?: string }) => void | Promise<void>
  readonly onRemoveItem?: (photoId: PhotoId) => void | Promise<void>
  readonly onCheckout?: () => void | Promise<void>
}

// Types pour les composants de recherche et filtres
export interface SearchBarProps extends BaseComponentProps {
  readonly value?: string
  readonly placeholder?: string
  readonly loading?: boolean
  readonly suggestions?: readonly string[]
  readonly showSuggestions?: boolean
  readonly showFilters?: boolean
  readonly filters?: PhotoSearchFilters
  readonly onSearch: (query: string) => void
  readonly onFiltersChange?: (filters: PhotoSearchFilters) => void
  readonly onSuggestionSelect?: (suggestion: string) => void
  readonly renderSuggestion?: (suggestion: string, index: number) => ReactNode
  readonly renderFilters?: (filters: PhotoSearchFilters) => ReactNode
}

export interface FilterPanelProps extends BaseComponentProps {
  readonly filters: PhotoSearchFilters
  readonly availableCategories?: readonly string[]
  readonly availableTags?: readonly string[]
  readonly priceRange?: { min: number; max: number }
  readonly loading?: boolean
  readonly onFiltersChange: (filters: PhotoSearchFilters) => void
  readonly onReset?: () => void
  readonly renderCustomFilter?: (key: string, value: unknown) => ReactNode
}

export interface SortSelectProps extends BaseComponentProps {
  readonly value?: { field: string; direction: "asc" | "desc" }
  readonly options: readonly {
    readonly field: string
    readonly label: string
    readonly directions?: readonly ("asc" | "desc")[]
  }[]
  readonly onChange: (sort: { field: string; direction: "asc" | "desc" }) => void
  readonly loading?: boolean
  readonly disabled?: boolean
}

// Types pour les hooks de composants
export interface UseComponentStateOptions {
  readonly initialState?: ComponentState
  readonly onStateChange?: (state: ComponentState) => void
}

export interface UseComponentStateReturn {
  readonly state: ComponentState
  readonly isIdle: boolean
  readonly isLoading: boolean
  readonly isSuccess: boolean
  readonly isError: boolean
  readonly setState: (state: ComponentState) => void
  readonly setLoading: () => void
  readonly setSuccess: () => void
  readonly setError: () => void
  readonly setIdle: () => void
}

// Types pour la gestion d'événements
export interface ComponentEventHandlers {
  readonly onClick?: (event: React.MouseEvent) => void
  readonly onDoubleClick?: (event: React.MouseEvent) => void
  readonly onMouseEnter?: (event: React.MouseEvent) => void
  readonly onMouseLeave?: (event: React.MouseEvent) => void
  readonly onFocus?: (event: React.FocusEvent) => void
  readonly onBlur?: (event: React.FocusEvent) => void
  readonly onKeyDown?: (event: React.KeyboardEvent) => void
  readonly onKeyUp?: (event: React.KeyboardEvent) => void
}

// Types pour les variantes de style
export interface ComponentStyleProps {
  readonly variant?: ComponentVariant
  readonly size?: ComponentSize
  readonly colorScheme?: string
  readonly isDisabled?: boolean
  readonly isLoading?: boolean
  readonly isFocused?: boolean
  readonly isHovered?: boolean
  readonly isActive?: boolean
  readonly isSelected?: boolean
}

// Types pour l'accessibilité
export interface AccessibilityProps {
  readonly "aria-label"?: string
  readonly "aria-labelledby"?: string
  readonly "aria-describedby"?: string
  readonly "aria-expanded"?: boolean
  readonly "aria-hidden"?: boolean
  readonly "aria-disabled"?: boolean
  readonly "aria-selected"?: boolean
  readonly "aria-checked"?: boolean
  readonly role?: string
  readonly tabIndex?: number
}

// Combiner tous les types de props communes
export interface CommonComponentProps 
  extends BaseComponentProps, 
          ComponentEventHandlers, 
          ComponentStyleProps, 
          AccessibilityProps {}
```

## Livrables de l'étape 7

### Configuration terminée

- [ ] **Types métier complets** : Photos, Achats, Panier avec toutes les propriétés
- [ ] **Types API REST** : Routes typées, Requêtes, Réponses, Pagination
- [ ] **Types React avancés** : Composants polymorphes, Props typées, Hooks
- [ ] **Types upload fichiers** : Validation, Progress, Processing, Storage
- [ ] **Types Stripe intégrés** : Payments, Sessions, Webhooks, Products
- [ ] **Types state management** : Store, Actions, Selectors, Mutations
- [ ] **Types formulaires complexes** : Multi-étapes, Validation, Soumission
- [ ] **Types UI avancés** : Tables, Modals, Navigation, Feedback
- [ ] **Types performance** : Lazy loading, Pagination, Cache, Optimistic updates
- [ ] **Types analytics** : Tracking, Events, Metrics, Reporting

### Architecture de types mise en place

L'étape 7 établit une **architecture de types TypeScript complète** qui couvre :

1. **Types métier robustes** avec branded types et validation
2. **API typée de bout en bout** avec inférence automatique
3. **Composants React entièrement typés** avec polymorphisme
4. **Système de formulaires type-safe** avec validation Zod
5. **Gestion d'état typée** avec actions et selectors
6. **Upload de fichiers sécurisé** avec validation et progress
7. **Intégration Stripe complète** avec types SDK
8. **Interface utilisateur cohérente** avec design system typé

### Prochaines étapes

Une fois cette étape terminée, vous pourrez passer à :
- **Étape 8** : Composants React d'authentification avec types
- **Étape 9** : API Routes Next.js avec validation TypeScript
- **Étape 10** : Système d'upload et gestion d'images

## Ressources avancées TypeScript

- [TypeScript Advanced Types](https://www.typescriptlang.org/docs/handbook/2/types-from-types.html)
- [Conditional Types Deep Dive](https://www.typescriptlang.org/docs/handbook/2/conditional-types.html)
- [Template Literal Types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html)
- [Mapped Types](https://www.typescriptlang.org/docs/handbook/2/mapped-types.html)
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [Branded Types in TypeScript](https://egghead.io/blog/using-branded-types-in-typescript)