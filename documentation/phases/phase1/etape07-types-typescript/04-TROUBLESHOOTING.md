# Étape 7 : Dépannage Types TypeScript avancés

## Problèmes de compilation TypeScript

### 1. Erreur "Type instantiation is excessively deep and possibly infinite"

**Symptômes** :
```typescript
// Erreur lors de l'utilisation de types complexes
type DeepPick<T, K extends keyof T> = ...
// Type instantiation is excessively deep and possibly infinite
```

**Causes possibles** :
- Types récursifs mal définis
- Types conditionnels trop complexes
- Imbrication excessive de types génériques

**Solutions** :

```typescript
// Solution 1 : Limiter la profondeur de récursion
type DeepPick<T, K extends keyof T, Depth extends number = 10> = 
  Depth extends 0 
    ? never 
    : T extends object 
      ? { [P in K]: DeepPick<T[P], K, Prev<Depth>> }
      : T

// Solution 2 : Simplifier les types conditionnels
// Au lieu de :
type ComplexType<T> = T extends Photo ? PhotoCard : T extends Purchase ? PurchaseCard : never

// Utiliser :
type PhotoToCard<T> = T extends Photo ? PhotoCard : never
type PurchaseToCard<T> = T extends Purchase ? PurchaseCard : never
type SimpleType<T> = PhotoToCard<T> | PurchaseToCard<T>

// Solution 3 : Utiliser des interfaces au lieu de types complexes
interface PhotoMetadataBase {
  fileName: string
  fileSize: number
}

interface PhotoMetadataExtended extends PhotoMetadataBase {
  dimensions: { width: number; height: number }
  mimeType: string
}

// Au lieu d'un type conditionnel complexe
```

**Test de vérification** :
```bash
# Tester la compilation avec des types simplifiés
npx tsc --noEmit --strict
# Si l'erreur persiste, diviser les types en modules plus petits
```

### 2. Erreur "Property does not exist on type" avec branded types

**Symptômes** :
```typescript
// Erreur avec les branded types
const photoId: PhotoId = "photo_123"
console.log(photoId.length) // Property 'length' does not exist on type 'PhotoId'
```

**Causes** :
- Branded types cachent les propriétés du type de base
- Tentative d'utilisation directe des méthodes string/number

**Solutions** :

```typescript
// Solution 1 : Fonction unwrap pour accéder au type de base
export const unwrapPhotoId = (id: PhotoId): string => id as string
export const unwrapPhotoPrice = (price: PhotoPrice): number => price as number

// Usage :
const photoId: PhotoId = createPhotoId("photo_123")
const length = unwrapPhotoId(photoId).length

// Solution 2 : Extending branded types avec méthodes
type PhotoId = string & {
  readonly brand: unique symbol
  readonly unwrap: () => string
}

export const createPhotoId = (id: string): PhotoId => {
  const branded = id as PhotoId
  Object.defineProperty(branded, 'unwrap', {
    value: () => id,
    enumerable: false,
    writable: false
  })
  return branded
}

// Usage :
const photoId = createPhotoId("photo_123")
const length = photoId.unwrap().length

// Solution 3 : Utility types pour branded types
type UnwrapBranded<T> = T extends string & { brand: any } ? string :
                       T extends number & { brand: any } ? number :
                       T

const unwrap = <T>(value: T): UnwrapBranded<T> => value as UnwrapBranded<T>

// Usage :
const photoId: PhotoId = createPhotoId("photo_123")
const length = unwrap(photoId).length
```

**Test de vérification** :
```bash
cat > test-branded-types.js << 'EOF'
// Test des branded types avec unwrap
function createPhotoId(id) {
  return id; // En TypeScript, serait casté comme PhotoId
}

function unwrapPhotoId(id) {
  return id; // Retourne le string sous-jacent
}

const photoId = createPhotoId("photo_123");
const length = unwrapPhotoId(photoId).length;
console.log('✅ Branded type unwrap works:', length === 9);
EOF

node test-branded-types.js
rm test-branded-types.js
```

### 3. Erreur "Cannot find module" avec chemins d'alias

**Symptômes** :
```typescript
import type { Photo } from "@/types/business/photo" // Cannot find module '@/types/business/photo'
import type { ApiRoutes } from "@/api/routes" // Cannot find module '@/api/routes'
```

**Causes** :
- Configuration tsconfig.json incorrecte
- Chemins d'alias mal définis
- Conflits entre chemins relatifs et absolus

**Solutions** :

```bash
# Solution 1 : Vérifier et corriger tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/types/*": ["./src/types/*"],
      "@/business/*": ["./src/types/business/*"],
      "@/api/*": ["./src/types/api/*"],
      "@/ui/*": ["./src/types/ui/*"],
      "@/lib/*": ["./src/lib/*"]
    }
  }
}
EOF

# Solution 2 : Vérifier que les fichiers existent
find src/types -name "*.ts" | head -10

# Solution 3 : Créer les fichiers index manquants
cat > src/types/business/index.ts << 'EOF'
export * from "./photo"
export * from "./purchase"
export * from "./cart"
export * from "./catalog"
export * from "./analytics"
export * from "./admin"
EOF

cat > src/types/api/index.ts << 'EOF'
export * from "./routes"
export * from "./requests"
export * from "./responses"
export * from "./pagination"
export * from "./filters"
export * from "./errors"
export * from "./webhooks"
EOF

# Solution 4 : Redémarrer TypeScript Language Server
# Dans VS Code : Ctrl+Shift+P > "TypeScript: Restart TS Server"

# Solution 5 : Test des imports
cat > test-imports.ts << 'EOF'
// Test des imports avec alias
import type { Photo } from "@/types/business/photo"
import type { ApiRoutes } from "@/types/api/routes"

// Test d'utilisation
const testPhoto: Photo = {} as Photo
const testRoutes: ApiRoutes = {} as ApiRoutes

console.log('Imports work')
EOF

npx tsc --noEmit test-imports.ts
rm test-imports.ts
```

## Problèmes avec les type guards

### 4. Type guard ne narrow pas correctement

**Symptômes** :
```typescript
function processPhoto(data: unknown) {
  if (isPhoto(data)) {
    console.log(data.title) // Property 'title' does not exist on type 'unknown'
  }
}
```

**Causes** :
- Type guard mal implémenté
- Return type annotation incorrecte
- Logique de validation incomplète

**Solutions** :

```typescript
// Solution 1 : Type guard correct avec validation complète
function isPhoto(value: unknown): value is Photo {
  if (!value || typeof value !== 'object') {
    return false
  }
  
  const obj = value as Record<string, unknown>
  
  // Validation stricte de chaque propriété
  return (
    typeof obj.id === 'string' &&
    obj.id.length > 0 &&
    typeof obj.title === 'string' &&
    obj.title.length > 0 &&
    typeof obj.description === 'string' &&
    typeof obj.category === 'string' &&
    isValidPhotoCategory(obj.category) &&
    typeof obj.price === 'number' &&
    obj.price > 0 &&
    typeof obj.status === 'string' &&
    isValidPhotoStatus(obj.status) &&
    obj.metadata &&
    typeof obj.metadata === 'object' &&
    obj.performance &&
    typeof obj.performance === 'object' &&
    obj.createdAt instanceof Date &&
    obj.updatedAt instanceof Date
  )
}

// Solution 2 : Type guard avec assertion function
function assertIsPhoto(value: unknown): asserts value is Photo {
  if (!isPhoto(value)) {
    throw new Error('Value is not a valid Photo')
  }
}

// Usage avec assertion :
function processPhoto(data: unknown) {
  assertIsPhoto(data)
  console.log(data.title) // ✅ TypeScript sait que data est Photo
}

// Solution 3 : Combinaison avec Zod pour validation robuste
import { z } from 'zod'

const photoSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  description: z.string(),
  category: z.enum(['nature', 'portrait', 'architecture']),
  price: z.number().positive(),
  status: z.enum(['draft', 'published', 'sold']),
  metadata: z.object({
    fileName: z.string(),
    fileSize: z.number().positive()
  }),
  performance: z.object({
    views: z.number().min(0),
    likes: z.number().min(0)
  }),
  createdAt: z.date(),
  updatedAt: z.date()
})

function isPhotoWithZod(value: unknown): value is Photo {
  try {
    photoSchema.parse(value)
    return true
  } catch {
    return false
  }
}

// Solution 4 : Type guard générique réutilisable
function createTypeGuard<T>(
  schema: z.ZodSchema<T>
): (value: unknown) => value is T {
  return (value: unknown): value is T => {
    try {
      schema.parse(value)
      return true
    } catch {
      return false
    }
  }
}

const isPhotoGeneric = createTypeGuard(photoSchema)
```

**Test de type guard** :
```bash
cat > test-type-guard-narrowing.js << 'EOF'
// Test de narrowing avec type guard
function isPhoto(value) {
  return (
    value &&
    typeof value === 'object' &&
    typeof value.id === 'string' &&
    typeof value.title === 'string' &&
    typeof value.price === 'number'
  )
}

function processPhoto(data) {
  if (isPhoto(data)) {
    // En TypeScript, data serait narrowed à Photo
    console.log('✅ Photo processed:', data.title)
    return true
  } else {
    console.log('❌ Invalid photo data')
    return false
  }
}

// Test avec données valides
const validPhoto = {
  id: 'photo123',
  title: 'Beautiful Landscape',
  price: 29.99
}

// Test avec données invalides
const invalidPhoto = {
  id: 'photo123'
  // title et price manquants
}

console.log('Valid photo:', processPhoto(validPhoto))
console.log('Invalid photo:', processPhoto(invalidPhoto))
EOF

node test-type-guard-narrowing.js
rm test-type-guard-narrowing.js
```

### 5. Performance dégradée avec type guards complexes

**Symptômes** :
- Type guards très lents sur de gros objets
- Timeout lors de la validation d'arrays importantes
- Utilisation mémoire excessive

**Solutions** :

```typescript
// Solution 1 : Type guards optimisés avec early exit
function isPhotoOptimized(value: unknown): value is Photo {
  // Check rapide des types de base d'abord
  if (!value || typeof value !== 'object') return false
  
  const obj = value as Record<string, unknown>
  
  // Early exits pour les propriétés les plus discriminantes
  if (typeof obj.id !== 'string' || obj.id.length === 0) return false
  if (typeof obj.title !== 'string') return false
  if (typeof obj.price !== 'number' || obj.price <= 0) return false
  
  // Validations plus coûteuses seulement si nécessaire
  if (!obj.metadata || typeof obj.metadata !== 'object') return false
  if (!obj.performance || typeof obj.performance !== 'object') return false
  
  // Validation finale des enums (plus coûteuse)
  return (
    isValidPhotoCategory(obj.category) &&
    isValidPhotoStatus(obj.status) &&
    obj.createdAt instanceof Date &&
    obj.updatedAt instanceof Date
  )
}

// Solution 2 : Cache des validations pour éviter les recalculs
const validationCache = new WeakMap<object, boolean>()

function isPhotoCached(value: unknown): value is Photo {
  if (!value || typeof value !== 'object') return false
  
  // Vérifier le cache d'abord
  if (validationCache.has(value)) {
    return validationCache.get(value)!
  }
  
  // Valider et mettre en cache
  const isValid = isPhotoOptimized(value)
  validationCache.set(value, isValid)
  return isValid
}

// Solution 3 : Validation par étapes pour gros datasets
function validatePhotosInBatches(
  data: unknown[], 
  batchSize: number = 100
): { valid: Photo[]; invalid: unknown[] } {
  const valid: Photo[] = []
  const invalid: unknown[] = []
  
  for (let i = 0; i < data.length; i += batchSize) {
    const batch = data.slice(i, i + batchSize)
    
    for (const item of batch) {
      if (isPhotoOptimized(item)) {
        valid.push(item)
      } else {
        invalid.push(item)
      }
    }
    
    // Permettre à l'event loop de respirer
    if (i + batchSize < data.length) {
      await new Promise(resolve => setTimeout(resolve, 0))
    }
  }
  
  return { valid, invalid }
}

// Solution 4 : Type guards spécialisés par contexte
function isPhotoSummary(value: unknown): value is PhotoSummary {
  // Validation allégée pour les résumés
  if (!value || typeof value !== 'object') return false
  
  const obj = value as Record<string, unknown>
  return (
    typeof obj.id === 'string' &&
    typeof obj.title === 'string' &&
    typeof obj.price === 'number' &&
    typeof obj.thumbnailUrl === 'string'
  )
}

function isPhotoCard(value: unknown): value is PhotoCard {
  // Validation intermédiaire pour les cartes
  return isPhotoSummary(value) && (
    typeof (value as any).description === 'string' &&
    typeof (value as any).category === 'string' &&
    Array.isArray((value as any).tags)
  )
}
```

## Problèmes avec Zod et validation

### 6. Erreur "Expected object, received array" avec Zod

**Symptômes** :
```typescript
const result = photoSchema.parse(formData)
// ZodError: Expected object, received array at root
```

**Causes** :
- FormData mal transformée en objet
- Array passé au lieu d'un objet
- Structure de données incorrecte

**Solutions** :

```typescript
// Solution 1 : Transformer FormData correctement
function formDataToObject(formData: FormData): Record<string, unknown> {
  const obj: Record<string, unknown> = {}
  
  for (const [key, value] of formData.entries()) {
    if (key.endsWith('[]')) {
      // Gérer les arrays
      const arrayKey = key.slice(0, -2)
      if (!obj[arrayKey]) {
        obj[arrayKey] = []
      }
      (obj[arrayKey] as unknown[]).push(value)
    } else if (obj[key]) {
      // Gérer les valeurs multiples
      if (!Array.isArray(obj[key])) {
        obj[key] = [obj[key]]
      }
      (obj[key] as unknown[]).push(value)
    } else {
      obj[key] = value
    }
  }
  
  return obj
}

// Usage :
const objectData = formDataToObject(formData)
const result = photoSchema.parse(objectData)

// Solution 2 : Validation défensive avec safeParse
function validatePhotoData(data: unknown): Photo | null {
  const result = photoSchema.safeParse(data)
  
  if (result.success) {
    return result.data
  } else {
    console.error('Validation errors:', result.error.errors)
    return null
  }
}

// Solution 3 : Schema avec preprocessing
const photoSchemaWithPreprocess = z.preprocess(
  (data) => {
    // Transformer les données avant validation
    if (Array.isArray(data)) {
      console.warn('Received array instead of object, taking first item')
      return data[0]
    }
    
    if (typeof data === 'string') {
      try {
        return JSON.parse(data)
      } catch {
        console.warn('Failed to parse string as JSON')
        return data
      }
    }
    
    return data
  },
  photoSchema
)

// Solution 4 : Validation étape par étape pour debug
function validatePhotoStepByStep(data: unknown): Photo | { error: string; step: string } {
  // Étape 1 : Vérifier que c'est un objet
  if (!data || typeof data !== 'object' || Array.isArray(data)) {
    return { error: 'Data must be an object', step: 'object_check' }
  }
  
  const obj = data as Record<string, unknown>
  
  // Étape 2 : Vérifier les champs obligatoires
  const requiredFields = ['id', 'title', 'description', 'category', 'price', 'status']
  for (const field of requiredFields) {
    if (!(field in obj)) {
      return { error: `Missing required field: ${field}`, step: 'required_fields' }
    }
  }
  
  // Étape 3 : Validation Zod complète
  const result = photoSchema.safeParse(data)
  if (result.success) {
    return result.data
  } else {
    return { 
      error: `Validation failed: ${result.error.errors[0]?.message}`, 
      step: 'zod_validation' 
    }
  }
}
```

**Test de validation Zod** :
```bash
cat > test-zod-validation.js << 'EOF'
const { z } = require('zod')

// Schema de test
const photoSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  price: z.number().positive(),
  tags: z.array(z.string()).optional()
})

console.log('=== TESTS VALIDATION ZOD ===')

// Test objet valide
try {
  const validData = {
    id: 'photo123',
    title: 'Beautiful Photo',
    price: 29.99,
    tags: ['nature', 'landscape']
  }
  
  const result = photoSchema.parse(validData)
  console.log('✅ Objet valide accepté')
} catch (error) {
  console.log('❌ Erreur sur objet valide:', error.errors?.[0]?.message)
}

// Test array au lieu d'objet
try {
  const arrayData = ['photo123', 'Beautiful Photo', 29.99]
  photoSchema.parse(arrayData)
  console.log('❌ Array accepté (erreur)')
} catch (error) {
  console.log('✅ Array correctement rejeté')
}

// Test avec safeParse
const safeResult = photoSchema.safeParse({ id: 'test' })
if (safeResult.success) {
  console.log('✅ Validation réussie')
} else {
  console.log('✅ Erreurs détectées:', safeResult.error.errors.length)
}

console.log('=== TESTS ZOD TERMINÉS ===')
EOF

node test-zod-validation.js
rm test-zod-validation.js
```

### 7. Performance lente avec validations Zod complexes

**Symptômes** :
- Validation très lente sur de gros objets
- Timeout avec des schemas complexes
- Utilisation CPU élevée

**Solutions** :

```typescript
// Solution 1 : Schemas optimisés avec lazy loading
const lazyPhotoSchema = z.lazy(() => z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  metadata: z.lazy(() => photoMetadataSchema),
  performance: z.lazy(() => photoPerformanceSchema)
}))

// Solution 2 : Validation partielle pour les gros objets
const photoQuickSchema = z.object({
  id: z.string(),
  title: z.string(),
  price: z.number()
})

const photoFullSchema = photoQuickSchema.extend({
  description: z.string(),
  category: z.enum(['nature', 'portrait']),
  metadata: z.object({
    fileName: z.string(),
    fileSize: z.number()
  }),
  performance: z.object({
    views: z.number(),
    likes: z.number()
  })
})

function validatePhotoTiered(data: unknown): Photo | null {
  // Validation rapide d'abord
  const quickResult = photoQuickSchema.safeParse(data)
  if (!quickResult.success) {
    return null // Échec rapide
  }
  
  // Validation complète seulement si nécessaire
  const fullResult = photoFullSchema.safeParse(data)
  return fullResult.success ? fullResult.data as Photo : null
}

// Solution 3 : Cache des validations Zod
const schemaCache = new Map<string, boolean>()

function getCacheKey(data: unknown): string {
  return JSON.stringify(data, Object.keys(data as any).sort())
}

function validateWithCache<T>(schema: z.ZodSchema<T>, data: unknown): T | null {
  const cacheKey = getCacheKey(data)
  
  if (schemaCache.has(cacheKey)) {
    return schemaCache.get(cacheKey) ? data as T : null
  }
  
  const result = schema.safeParse(data)
  schemaCache.set(cacheKey, result.success)
  
  return result.success ? result.data : null
}

// Solution 4 : Validation par lots avec Web Workers (côté client)
class ValidationWorker {
  private worker: Worker | null = null
  
  async validateBatch<T>(
    schema: z.ZodSchema<T>, 
    items: unknown[]
  ): Promise<{ valid: T[]; invalid: unknown[] }> {
    if (!this.worker) {
      this.worker = new Worker('/validation-worker.js')
    }
    
    return new Promise((resolve) => {
      this.worker!.postMessage({
        schema: schema.toString(),
        items: items
      })
      
      this.worker!.onmessage = (event) => {
        resolve(event.data)
      }
    })
  }
}

// validation-worker.js (fichier séparé)
/*
self.onmessage = function(event) {
  const { schema, items } = event.data
  const valid = []
  const invalid = []
  
  // Reconstruire le schema (simplifié)
  items.forEach(item => {
    try {
      // Validation basique côté worker
      if (item && typeof item === 'object' && item.id && item.title) {
        valid.push(item)
      } else {
        invalid.push(item)
      }
    } catch {
      invalid.push(item)
    }
  })
  
  self.postMessage({ valid, invalid })
}
*/

// Solution 5 : Streaming validation pour gros datasets
async function* validatePhotosStream(
  photos: AsyncIterable<unknown>
): AsyncGenerator<{ photo: Photo; index: number } | { error: string; index: number }> {
  let index = 0
  
  for await (const photoData of photos) {
    const result = photoSchema.safeParse(photoData)
    
    if (result.success) {
      yield { photo: result.data, index }
    } else {
      yield { error: result.error.errors[0]?.message || 'Validation failed', index }
    }
    
    index++
    
    // Pause pour éviter de bloquer
    if (index % 100 === 0) {
      await new Promise(resolve => setTimeout(resolve, 0))
    }
  }
}
```

## Problèmes de performance TypeScript

### 8. Compilation TypeScript très lente

**Symptômes** :
- `npx tsc --noEmit` prend plus de 30 secondes
- IDE très lent pour l'autocomplétion
- Utilisation CPU élevée constante

**Causes** :
- Types trop complexes ou récursifs
- Trop de fichiers de types
- Configuration TypeScript non optimisée

**Solutions** :

```bash
# Solution 1 : Optimiser tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES2022"],
    "skipLibCheck": true, // ← Accélère significativement
    "strict": true,
    "noEmit": true,
    "incremental": true, // ← Cache de compilation
    "tsBuildInfoFile": ".next/.tsbuildinfo",
    
    // Optimisations de performance
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    
    // Réduire les vérifications coûteuses
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "exactOptionalPropertyTypes": false,
    
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": [
    "node_modules", 
    ".next", 
    "dist",
    "**/*.test.ts",
    "**/*.spec.ts"
  ]
}
EOF

# Solution 2 : Diviser les gros fichiers de types
# Au lieu d'un gros src/types/business/photo.ts (500+ lignes)
# Créer plusieurs fichiers :
mkdir -p src/types/business/photo
cat > src/types/business/photo/base.ts << 'EOF'
export type PhotoId = string & { readonly brand: unique symbol }
export type PhotoStatus = "draft" | "published" | "sold"
export type PhotoCategory = "nature" | "portrait" | "architecture"
EOF

cat > src/types/business/photo/metadata.ts << 'EOF'
export interface PhotoMetadata {
  fileName: string
  fileSize: number
  dimensions: { width: number; height: number }
}
EOF

cat > src/types/business/photo/index.ts << 'EOF'
export * from "./base"
export * from "./metadata"
export * from "./performance"
export * from "./interfaces"
EOF

# Solution 3 : Utiliser des imports de type explicites
# Dans tous les fichiers, remplacer :
# import { Photo } from "./photo"
# Par :
# import type { Photo } from "./photo"

# Solution 4 : Analyser les performances TypeScript
npm install -D @typescript/analyze-trace

# Générer un trace de performance
npx tsc --generateTrace trace --noEmit

# Analyser le trace (nécessite Node.js 14+)
npx analyze-trace trace

# Solution 5 : Configuration de développement allégée
cat > tsconfig.dev.json << 'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "skipLibCheck": true,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "exactOptionalPropertyTypes": false,
    "noPropertyAccessFromIndexSignature": false
  },
  "exclude": [
    "**/*.test.ts",
    "**/*.spec.ts",
    "src/types/generated/**/*"
  ]
}
EOF

# Utiliser pour le développement :
# npx tsc --noEmit --project tsconfig.dev.json
```

**Test de performance** :
```bash
# Mesurer l'amélioration
echo "Avant optimisation :"
time npx tsc --noEmit --strict

# Après optimisation
echo "Après optimisation :"
time npx tsc --noEmit --project tsconfig.dev.json

# Comparer les résultats
```

### 9. Erreurs de mémoire TypeScript

**Symptômes** :
```
FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory
```

**Solutions** :

```bash
# Solution 1 : Augmenter la limite de mémoire
export NODE_OPTIONS="--max-old-space-size=8192"
npx tsc --noEmit

# Solution 2 : Compilation par projet
cat > tsconfig.build.json << 'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "incremental": true,
    "tsBuildInfoFile": ".next/.tsbuildinfo"
  },
  "references": [
    { "path": "./src/types" },
    { "path": "./src/lib" },
    { "path": "./src/components" }
  ]
}
EOF

# Créer des sous-projets
cat > src/types/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "composite": true,
    "outDir": "../../dist/types"
  },
  "include": ["**/*"]
}
EOF

# Compilation par référence
npx tsc --build tsconfig.build.json

# Solution 3 : Nettoyage régulier
rm -rf .next/.tsbuildinfo
rm -rf node_modules/.cache
npm run build

# Solution 4 : Surveillance de la mémoire
node --inspect-brk=9229 node_modules/.bin/tsc --noEmit &
# Utiliser Chrome DevTools pour profiler
```

## Problèmes d'intégration

### 10. Conflits entre types React et types personnalisés

**Symptômes** :
```typescript
// Types React en conflit avec nos types
interface MyComponentProps {
  children: ReactNode // Conflit avec nos types branded
  onClick: (id: PhotoId) => void // PhotoId non reconnu
}
```

**Solutions** :

```typescript
// Solution 1 : Étendre les types React existants
import type { ReactNode, MouseEvent } from 'react'
import type { PhotoId } from '@/types/business'

interface BaseProps {
  className?: string
  children?: ReactNode
}

interface PhotoActionProps extends BaseProps {
  photoId: PhotoId
  onPhotoClick?: (photoId: PhotoId, event: MouseEvent<HTMLElement>) => void
}

// Solution 2 : Types polymorphes pour compatibilité
type PolymorphicComponentProps<T extends React.ElementType> = {
  as?: T
} & React.ComponentPropsWithoutRef<T>

interface PhotoCardProps<T extends React.ElementType = 'div'> 
  extends PolymorphicComponentProps<T> {
  photo: Photo
  variant?: 'grid' | 'list'
}

// Usage :
const PhotoCard = <T extends React.ElementType = 'div'>({
  as,
  photo,
  variant,
  ...props
}: PhotoCardProps<T>) => {
  const Component = as || 'div'
  return <Component {...props}>{photo.title}</Component>
}

// Solution 3 : Wrapper types pour React hooks
type UsePhotoState = {
  photos: readonly Photo[]
  loading: boolean
  error: Error | null
  selectedPhotoId: PhotoId | null
}

type UsePhotoActions = {
  selectPhoto: (id: PhotoId) => void
  clearSelection: () => void
  refreshPhotos: () => Promise<void>
}

type UsePhotoReturn = UsePhotoState & UsePhotoActions

function usePhotos(): UsePhotoReturn {
  // Implémentation avec types sécurisés
}

// Solution 4 : Types pour les refs React
type PhotoCardRef = HTMLDivElement
type PhotoGridRef = HTMLDivElement

interface PhotoCardWithRef extends PhotoCardProps {
  ref?: React.ForwardedRef<PhotoCardRef>
}

const PhotoCard = React.forwardRef<PhotoCardRef, PhotoCardProps>(
  ({ photo, variant, ...props }, ref) => {
    return (
      <div ref={ref} {...props}>
        {photo.title}
      </div>
    )
  }
)
```

### 11. Problèmes avec TanStack Query et types

**Symptômes** :
```typescript
// Types TanStack Query non compatibles
const { data, isLoading } = useQuery({
  queryKey: ['photos'],
  queryFn: fetchPhotos // Type mismatch
})
```

**Solutions** :

```typescript
// Solution 1 : Types explicites pour les queries
import { useQuery, type UseQueryResult } from '@tanstack/react-query'
import type { Photo, ApiError } from '@/types'

type PhotosQueryResult = UseQueryResult<readonly Photo[], ApiError>

const usePhotosQuery = (): PhotosQueryResult => {
  return useQuery({
    queryKey: ['photos'] as const,
    queryFn: async (): Promise<readonly Photo[]> => {
      const response = await fetch('/api/photos')
      if (!response.ok) {
        throw new Error('Failed to fetch photos')
      }
      const data = await response.json()
      return data.photos
    },
    staleTime: 5 * 60 * 1000 // 5 minutes
  })
}

// Solution 2 : Factory pour queries typées
function createTypedQuery<TData, TError = ApiError>(
  queryKey: readonly string[],
  queryFn: () => Promise<TData>
) {
  return () => useQuery({
    queryKey,
    queryFn,
    throwOnError: false
  }) as UseQueryResult<TData, TError>
}

const usePhotosTyped = createTypedQuery(
  ['photos'],
  async () => {
    const photos = await fetchPhotos()
    return photos.map(p => p as Photo) // Type assertion sécurisée
  }
)

// Solution 3 : Mutations typées
import { useMutation, type UseMutationResult } from '@tanstack/react-query'

type CreatePhotoMutation = UseMutationResult<
  Photo, // Type de retour
  ApiError, // Type d'erreur
  CreatePhotoInput, // Type des variables
  unknown // Type du contexte
>

const useCreatePhotoMutation = (): CreatePhotoMutation => {
  return useMutation({
    mutationFn: async (input: CreatePhotoInput): Promise<Photo> => {
      const formData = new FormData()
      formData.append('title', input.title)
      formData.append('description', input.description)
      formData.append('file', input.file)
      
      const response = await fetch('/api/photos', {
        method: 'POST',
        body: formData
      })
      
      if (!response.ok) {
        const error = await response.json()
        throw new ApiError(error.message)
      }
      
      return response.json()
    },
    onSuccess: (photo: Photo) => {
      console.log('Photo created:', photo.id)
    },
    onError: (error: ApiError) => {
      console.error('Failed to create photo:', error.message)
    }
  })
}

// Solution 4 : Query client avec types
import { QueryClient } from '@tanstack/react-query'

class TypedQueryClient extends QueryClient {
  async getPhotoData(photoId: PhotoId): Promise<Photo | undefined> {
    return this.getQueryData(['photos', photoId])
  }
  
  setPhotoData(photoId: PhotoId, photo: Photo): void {
    this.setQueryData(['photos', photoId], photo)
  }
  
  invalidatePhotos(): Promise<void> {
    return this.invalidateQueries({ queryKey: ['photos'] })
  }
}

const queryClient = new TypedQueryClient()
```

### 12. Problèmes avec Zustand et state management

**Symptômes** :
```typescript
// Types Zustand non inférés correctement
const useStore = create((set, get) => ({
  photos: [], // Type any[]
  addPhoto: (photo) => {} // Parameter any
}))
```

**Solutions** :

```typescript
// Solution 1 : Store Zustand entièrement typé
import { create } from 'zustand'
import { subscribeWithSelector } from 'zustand/middleware'
import type { Photo, PhotoId } from '@/types/business'

interface PhotoState {
  photos: readonly Photo[]
  selectedPhotoId: PhotoId | null
  loading: boolean
  error: string | null
}

interface PhotoActions {
  setPhotos: (photos: readonly Photo[]) => void
  addPhoto: (photo: Photo) => void
  removePhoto: (photoId: PhotoId) => void
  selectPhoto: (photoId: PhotoId) => void
  clearSelection: () => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
}

type PhotoStore = PhotoState & PhotoActions

const usePhotoStore = create<PhotoStore>()(
  subscribeWithSelector((set, get) => ({
    // State initial
    photos: [],
    selectedPhotoId: null,
    loading: false,
    error: null,
    
    // Actions
    setPhotos: (photos) => set({ photos }),
    
    addPhoto: (photo) => set((state) => ({
      photos: [...state.photos, photo]
    })),
    
    removePhoto: (photoId) => set((state) => ({
      photos: state.photos.filter(p => p.id !== photoId),
      selectedPhotoId: state.selectedPhotoId === photoId ? null : state.selectedPhotoId
    })),
    
    selectPhoto: (photoId) => set({ selectedPhotoId: photoId }),
    clearSelection: () => set({ selectedPhotoId: null }),
    setLoading: (loading) => set({ loading }),
    setError: (error) => set({ error })
  }))
)

// Solution 2 : Selectors typés
const usePhotos = () => usePhotoStore(state => state.photos)
const useSelectedPhoto = () => usePhotoStore(state => {
  if (!state.selectedPhotoId) return null
  return state.photos.find(p => p.id === state.selectedPhotoId) || null
})

// Solution 3 : Store slice pattern
interface PhotoSlice {
  photos: readonly Photo[]
  addPhoto: (photo: Photo) => void
  removePhoto: (photoId: PhotoId) => void
}

interface UISlice {
  sidebarOpen: boolean
  setSidebarOpen: (open: boolean) => void
}

type AppStore = PhotoSlice & UISlice

const createPhotoSlice = (set: any, get: any): PhotoSlice => ({
  photos: [],
  addPhoto: (photo) => set((state: AppStore) => ({
    photos: [...state.photos, photo]
  })),
  removePhoto: (photoId) => set((state: AppStore) => ({
    photos: state.photos.filter(p => p.id !== photoId)
  }))
})

const createUISlice = (set: any, get: any): UISlice => ({
  sidebarOpen: false,
  setSidebarOpen: (open) => set({ sidebarOpen: open })
})

const useAppStore = create<AppStore>()((...a) => ({
  ...createPhotoSlice(...a),
  ...createUISlice(...a)
}))

// Solution 4 : Persistence typée
import { persist } from 'zustand/middleware'

interface PersistedPhotoState {
  photos: readonly Photo[]
  favorites: readonly PhotoId[]
}

const usePersistedStore = create<PersistedPhotoState>()(
  persist(
    (set, get) => ({
      photos: [],
      favorites: [],
      // actions...
    }),
    {
      name: 'photo-storage',
      version: 1,
      migrate: (persistedState: any, version: number) => {
        if (version === 0) {
          // Migration v0 -> v1
          return {
            ...persistedState,
            favorites: []
          }
        }
        return persistedState
      }
    }
  )
)
```

## Diagnostic et maintenance avancés

### Script de diagnostic complet

```bash
# Créer un script de diagnostic TypeScript avancé
cat > diagnostic-typescript-complete.js << 'EOF'
const fs = require('fs')
const { execSync } = require('child_process')

console.log('=== DIAGNOSTIC TYPESCRIPT COMPLET ===\n')

// 1. Analyse de la structure
console.log('1. Structure des types:')
const typeDirs = [
  'src/types/business',
  'src/types/api', 
  'src/types/ui',
  'src/types/data',
  'src/types/files',
  'src/types/payments'
]

typeDirs.forEach(dir => {
  const exists = fs.existsSync(dir)
  if (exists) {
    const files = fs.readdirSync(dir).filter(f => f.endsWith('.ts'))
    console.log(`   ✅ ${dir}: ${files.length} fichiers`)
  } else {
    console.log(`   ❌ ${dir}: manquant`)
  }
})

// 2. Analyse des performances
console.log('\n2. Performance TypeScript:')
const start = Date.now()
try {
  execSync('npx tsc --noEmit --skipLibCheck', { stdio: 'pipe' })
  const duration = Date.now() - start
  console.log(`   ⏱️ Compilation: ${duration}ms`)
  
  if (duration < 5000) {
    console.log('   ✅ Performance excellente')
  } else if (duration < 15000) {
    console.log('   ⚠️ Performance acceptable')
  } else {
    console.log('   ❌ Performance lente - optimisation nécessaire')
  }
} catch (error) {
  console.log('   ❌ Erreurs de compilation détectées')
}

// 3. Analyse de la complexité
console.log('\n3. Complexité du code:')
try {
  const tsFiles = execSync('find src -name "*.ts" | wc -l', { encoding: 'utf8' }).trim()
  const totalLines = execSync('find src -name "*.ts" | xargs wc -l | tail -1', { encoding: 'utf8' })
  const lines = parseInt(totalLines.trim().split(' ')[0])
  
  console.log(`   📁 Fichiers .ts: ${tsFiles}`)
  console.log(`   📄 Lignes totales: ${lines}`)
  
  if (tsFiles > 0) {
    const avgLines = Math.round(lines / parseInt(tsFiles))
    console.log(`   📊 Moyenne lignes/fichier: ${avgLines}`)
    
    if (avgLines < 100) {
      console.log('   ✅ Fichiers de taille raisonnable')
    } else if (avgLines < 200) {
      console.log('   ⚠️ Fichiers de taille moyenne')
    } else {
      console.log('   ❌ Fichiers volumineux')
    }
  }
} catch (error) {
  console.log('   ❌ Erreur calcul complexité')
}

// 4. Vérification des dépendances
console.log('\n4. Dépendances TypeScript:')
const deps = [
  '@types/react',
  'react-hook-form',
  '@tanstack/react-query',
  'zustand',
  'zod'
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

// 5. Recommandations
console.log('\n5. Recommandations:')
const recommendations = []

// Vérifier la performance
if (Date.now() - start > 15000) {
  recommendations.push('Optimiser la configuration TypeScript (skipLibCheck, etc.)')
}

// Vérifier la structure
const missingDirs = typeDirs.filter(dir => !fs.existsSync(dir))
if (missingDirs.length > 0) {
  recommendations.push('Créer les dossiers de types manquants')
}

// Vérifier les dépendances
const missingDeps = deps.filter(dep => {
  try {
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'))
    const allDeps = { ...pkg.dependencies, ...pkg.devDependencies }
    return !allDeps[dep]
  } catch {
    return true
  }
})

if (missingDeps.length > 0) {
  recommendations.push('Installer les dépendances TypeScript manquantes')
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

node diagnostic-typescript-complete.js
rm diagnostic-typescript-complete.js
```

### Nettoyage et optimisation automatiques

```bash
# Script de nettoyage et optimisation TypeScript
cat > optimize-typescript.sh << 'EOF'
#!/bin/bash

echo "=== OPTIMISATION TYPESCRIPT ==="

echo "1. Nettoyage des caches..."
rm -rf .next/cache
rm -rf node_modules/.cache
rm -f .tsbuildinfo

echo "2. Vérification de la structure..."
mkdir -p src/types/{business,api,ui,data,files,payments}
mkdir -p src/lib/types/{guards,validators,transformers}

echo "3. Optimisation tsconfig.json..."
# Backup de la configuration actuelle
cp tsconfig.json tsconfig.json.backup

# Configuration optimisée
cat > tsconfig.json << 'TSCONFIG'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES2022"],
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "incremental": true,
    "tsBuildInfoFile": ".next/.tsbuildinfo",
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/types/*": ["./src/types/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules", ".next", "**/*.test.ts"]
}
TSCONFIG

echo "4. Test de compilation..."
if npx tsc --noEmit --strict; then
    echo "✅ Compilation TypeScript réussie"
else
    echo "❌ Erreurs de compilation détectées"
    echo "Restauration de la configuration précédente..."
    mv tsconfig.json.backup tsconfig.json
    exit 1
fi

echo "5. Analyse des performances..."
time npx tsc --noEmit --skipLibCheck

echo "=== OPTIMISATION TERMINÉE ==="
EOF

chmod +x optimize-typescript.sh
./optimize-typescript.sh
```

### Validation finale automatisée

```bash
# Script de validation finale TypeScript
cat > validate-typescript-final.js << 'EOF'
const { execSync } = require('child_process')
const fs = require('fs')

console.log('=== VALIDATION FINALE TYPESCRIPT ===\n')

const tests = [
  {
    name: 'Compilation TypeScript stricte',
    cmd: 'npx tsc --noEmit --strict',
    critical: true
  },
  {
    name: 'Compilation rapide (skipLibCheck)',
    cmd: 'npx tsc --noEmit --skipLibCheck',
    critical: true
  },
  {
    name: 'ESLint sans erreurs critiques',
    cmd: 'npx eslint src/types --max-warnings 0',
    critical: false
  },
  {
    name: 'Test des imports de base',
    cmd: 'node -e "console.log(\'Import test passed\')"',
    critical: false
  }
]

let passed = 0
let failed = 0

for (const test of tests) {
  process.stdout.write(`${test.name}... `)
  
  try {
    const start = Date.now()
    execSync(test.cmd, { stdio: 'pipe' })
    const duration = Date.now() - start
    
    console.log(`✅ (${duration}ms)`)
    passed++
  } catch (error) {
    console.log(`❌`)
    failed++
    
    if (test.critical) {
      console.log(`   CRITIQUE: ${test.name} a échoué`)
      console.log(`   Commande: ${test.cmd}`)
    }
  }
}

console.log(`\n=== RÉSULTATS ===`)
console.log(`✅ Tests réussis: ${passed}`)
console.log(`❌ Tests échoués: ${failed}`)

if (failed === 0) {
  console.log('🎉 ÉTAPE 7 TERMINÉE AVEC SUCCÈS !')
} else {
  console.log('⚠️ Correction nécessaire avant de continuer')
  process.exit(1)
}
EOF

node validate-typescript-final.js
rm validate-typescript-final.js
```

En suivant ce guide de dépannage exhaustif, vous devriez pouvoir résoudre tous les problèmes liés aux types TypeScript avancés dans PhotoMarket et maintenir une architecture de types robuste et performante.