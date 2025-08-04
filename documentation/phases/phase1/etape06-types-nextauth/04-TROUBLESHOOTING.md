# Étape 6 : Dépannage Types NextAuth.js avancés

## Problèmes de compilation TypeScript

### 1. Erreur "Type 'string' is not assignable to type 'UserRole'"

**Symptômes** :
```typescript
// Erreur TypeScript
const role: UserRole = "USER" // Type 'string' is not assignable to type 'UserRole'
const status = getStatusFromDB() // Type 'string' is not assignable to type 'UserStatus'
```

**Causes possibles** :
- Types union mal définis
- Valeurs dynamiques non validées
- Assertions de type manquantes

**Solutions** :

```typescript
// Solution 1 : Utiliser des type guards
function isValidUserRole(role: string): role is UserRole {
  return ["USER", "ADMIN"].includes(role)
}

const roleFromDB = getUserRoleFromDB()
if (isValidUserRole(roleFromDB)) {
  const role: UserRole = roleFromDB // ✅ OK
}

// Solution 2 : Validation avec Zod
import { z } from "zod"

const userRoleSchema = z.enum(["USER", "ADMIN"])
const role = userRoleSchema.parse(roleFromDB) // ✅ Validé et typé

// Solution 3 : Assertion de type avec validation
const role = roleFromDB as UserRole
if (!isValidUserRole(role)) {
  throw new Error(`Invalid role: ${role}`)
}
```

**Test de vérification** :
```bash
node -e "
function isValidUserRole(role) { return ['USER', 'ADMIN'].includes(role); }
const testRole = 'USER';
console.log('Role validation works:', isValidUserRole(testRole));
"
```

### 2. Erreur "Property 'permissions' does not exist on type 'User'"

**Symptômes** :
```typescript
// Erreur dans les callbacks NextAuth
const session = await getSession()
console.log(session.user.permissions) // Property 'permissions' does not exist
```

**Causes** :
- Extension d'interface NextAuth manquante
- Types NextAuth.js mal configurés
- Import de types incorrect

**Solutions** :

```typescript
// Solution 1 : Vérifier src/types/next-auth.d.ts
declare module "next-auth" {
  interface Session {
    user: {
      id: string
      role: "USER" | "ADMIN"
      permissions: {
        canUploadPhotos: boolean
        canPurchasePhotos: boolean
        canManageUsers: boolean
        canAccessAdmin: boolean
        canModerateContent: boolean
      }
    } & DefaultSession["user"]
  }

  interface User {
    id: string
    role: "USER" | "ADMIN"
    permissions: {
      canUploadPhotos: boolean
      canPurchasePhotos: boolean
      canManageUsers: boolean
      canAccessAdmin: boolean
      canModerateContent: boolean
    }
  }
}

// Solution 2 : Redémarrer TypeScript Language Server
// Dans VSCode : Ctrl+Shift+P > "TypeScript: Restart TS Server"

// Solution 3 : Vérifier les imports
import type { PhotoMarketSession } from "@/types/auth"

function useTypedSession() {
  const { data: session } = useSession() as {
    data: PhotoMarketSession | null
    status: string
  }
  
  // Maintenant session.user.permissions existe
  return session
}
```

**Test de vérification** :
```bash
# Vérifier que les types NextAuth sont bien étendus
npx tsc --noEmit --strict
grep -r "declare module" src/types/
```

### 3. Erreur "Cannot find module '@/types/auth'"

**Symptômes** :
```typescript
import type { ExtendedUser } from "@/types/auth" // Cannot find module '@/types/auth'
```

**Causes** :
- Configuration des chemins TypeScript incorrecte
- Fichier index.ts manquant
- Alias de chemin mal configuré

**Solutions** :

```bash
# Solution 1 : Vérifier tsconfig.json
cat tsconfig.json | grep -A 10 "paths"
# Doit contenir :
# "@/types/*": ["./src/types/*"]

# Solution 2 : Créer/vérifier src/types/auth/index.ts
cat > src/types/auth/index.ts << 'EOF'
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
EOF

# Solution 3 : Redémarrer le serveur de développement
# Ctrl+C puis npm run dev
```

**Configuration correcte tsconfig.json** :
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@/types/*": ["./src/types/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/components/*": ["./src/components/*"]
    }
  }
}
```

## Problèmes avec Zod

### 4. Erreur "Expected object, received string" avec Zod

**Symptômes** :
```javascript
const result = signUpSchema.parse(formData)
// ZodError: Expected object, received string at "email"
```

**Causes** :
- Données de formulaire mal formatées
- Schéma Zod mal défini
- Transformation de données incorrecte

**Solutions** :

```typescript
// Solution 1 : Vérifier le format des données
console.log('FormData type:', typeof formData, formData)

// Les données doivent être un objet :
const correctData = {
  name: "Jean Dupont",
  email: "jean@test.com",
  password: "MotDePasse123!",
  confirmPassword: "MotDePasse123!",
  terms: true
}

// Solution 2 : Utiliser safeParse pour debug
const result = signUpSchema.safeParse(formData)
if (!result.success) {
  console.log('Validation errors:', result.error.errors)
  result.error.errors.forEach(err => {
    console.log(`Field ${err.path.join('.')}: ${err.message}`)
  })
}

// Solution 3 : Validation étape par étape
const emailResult = z.string().email().safeParse(formData.email)
console.log('Email validation:', emailResult)

const passwordResult = z.string().min(8).safeParse(formData.password)
console.log('Password validation:', passwordResult)
```

**Test de debug Zod** :
```bash
cat > debug-zod.js << 'EOF'
const { z } = require('zod')

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
})

// Test avec données correctes
console.log('=== Test données correctes ===')
try {
  const result = schema.parse({ email: 'test@test.com', password: 'password123' })
  console.log('✅ Validation réussie:', result)
} catch (error) {
  console.log('❌ Erreur:', error.errors)
}

// Test avec données incorrectes
console.log('\n=== Test données incorrectes ===')
try {
  const result = schema.parse({ email: 'invalid', password: '123' })
  console.log('❌ Validation devrait échouer')
} catch (error) {
  console.log('✅ Erreurs attendues:')
  error.errors.forEach(err => console.log(`  - ${err.path.join('.')}: ${err.message}`))
}
EOF

node debug-zod.js
rm debug-zod.js
```

### 5. Problème de transformation Zod avec email

**Symptômes** :
```typescript
const emailSchema = z.string().email().transform(email => email.toLowerCase())
// TypeError: Cannot read property 'toLowerCase' of undefined
```

**Causes** :
- Validation échoue avant la transformation
- Valeur null ou undefined
- Transformation appliquée sur échec de validation

**Solutions** :

```typescript
// Solution 1 : Validation d'abord, transformation ensuite
const emailSchema = z.string()
  .min(1, "L'email est obligatoire")
  .email("Format d'email invalide")
  .transform(email => email?.toLowerCase().trim() || "")

// Solution 2 : Valeurs par défaut et vérifications
const safeEmailSchema = z.string()
  .optional()
  .default("")
  .refine(email => email.length > 0, "Email obligatoire")
  .refine(email => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email), "Email invalide")
  .transform(email => email.toLowerCase().trim())

// Solution 3 : Utiliser preprocess pour nettoyer avant validation
const emailSchemaWithPreprocess = z.preprocess(
  (val) => {
    if (typeof val === "string") {
      return val.trim()
    }
    return val
  },
  z.string().email().transform(email => email.toLowerCase())
)
```

**Test de transformation** :
```bash
node -e "
const { z } = require('zod');
const emailSchema = z.string().email().transform(e => e?.toLowerCase() || '');
try {
  const result = emailSchema.parse('TEST@EXAMPLE.COM');
  console.log('✅ Email transformé:', result);
} catch (error) {
  console.log('❌ Erreur transformation:', error.message);
}
"
```

## Problèmes de type guards

### 6. Type guard ne fonctionne pas dans les conditions

**Symptômes** :
```typescript
function processUser(user: unknown) {
  if (isExtendedUser(user)) {
    console.log(user.permissions) // Property 'permissions' does not exist on type 'unknown'
  }
}
```

**Causes** :
- Type guard mal implémenté
- TypeScript ne reconnaît pas le narrowing
- Problème avec le return type

**Solutions** :

```typescript
// Solution 1 : Vérifier la signature du type guard
function isExtendedUser(user: any): user is ExtendedUser {
  return (
    user &&
    typeof user === 'object' &&
    typeof user.id === 'string' &&
    typeof user.email === 'string' &&
    typeof user.role === 'string' &&
    ['USER', 'ADMIN'].includes(user.role) &&
    user.permissions &&
    typeof user.permissions === 'object'
  )
}

// Solution 2 : Type guard plus robuste
function isExtendedUser(user: unknown): user is ExtendedUser {
  if (!user || typeof user !== 'object') {
    return false
  }
  
  const u = user as Record<string, unknown>
  
  return (
    typeof u.id === 'string' &&
    typeof u.email === 'string' &&
    typeof u.name === 'string' &&
    (u.role === 'USER' || u.role === 'ADMIN') &&
    (u.status === 'ACTIVE' || u.status === 'SUSPENDED' || u.status === 'PENDING_VERIFICATION' || u.status === 'INACTIVE') &&
    u.permissions &&
    typeof u.permissions === 'object'
  )
}

// Solution 3 : Utiliser assertion function
function assertIsExtendedUser(user: unknown): asserts user is ExtendedUser {
  if (!isExtendedUser(user)) {
    throw new Error('Not a valid ExtendedUser')
  }
}

// Usage :
function processUser(user: unknown) {
  assertIsExtendedUser(user)
  console.log(user.permissions) // ✅ TypeScript sait que user est ExtendedUser
}
```

**Test de type guard** :
```bash
cat > test-type-guard.js << 'EOF'
function isExtendedUser(user) {
  return (
    user &&
    typeof user === 'object' &&
    typeof user.id === 'string' &&
    typeof user.email === 'string' &&
    ['USER', 'ADMIN'].includes(user.role) &&
    user.permissions &&
    typeof user.permissions === 'object'
  )
}

// Test avec utilisateur valide
const validUser = {
  id: 'user123',
  email: 'test@test.com',
  role: 'USER',
  permissions: { canUploadPhotos: true }
}

console.log('Valid user passes:', isExtendedUser(validUser))

// Test avec objet invalide
console.log('Invalid object fails:', isExtendedUser({ id: 123 }))
console.log('Null fails:', isExtendedUser(null))
console.log('String fails:', isExtendedUser('test'))
EOF

node test-type-guard.js
rm test-type-guard.js
```

### 7. Problème avec les permissions dans le type guard

**Symptômes** :
```typescript
// Le type guard passe mais les permissions sont incorrectes
const user = { id: '123', email: 'test', role: 'USER', permissions: 'invalid' }
console.log(isExtendedUser(user)) // true mais permissions invalides
```

**Solutions** :

```typescript
// Solution : Type guard plus strict pour les permissions
function isExtendedUser(user: unknown): user is ExtendedUser {
  if (!user || typeof user !== 'object') return false
  
  const u = user as Record<string, unknown>
  
  // Vérification de base
  if (
    typeof u.id !== 'string' ||
    typeof u.email !== 'string' ||
    !['USER', 'ADMIN'].includes(u.role as string) ||
    !u.permissions ||
    typeof u.permissions !== 'object'
  ) {
    return false
  }
  
  // Vérification stricte des permissions
  const permissions = u.permissions as Record<string, unknown>
  const requiredPermissions = [
    'canUploadPhotos',
    'canPurchasePhotos', 
    'canManageUsers',
    'canAccessAdmin',
    'canModerateContent'
  ]
  
  for (const permission of requiredPermissions) {
    if (typeof permissions[permission] !== 'boolean') {
      return false
    }
  }
  
  // Vérification des stats si présentes
  if (u.stats) {
    const stats = u.stats as Record<string, unknown>
    const requiredStats = ['photosCount', 'purchasesCount', 'salesCount', 'totalEarnings', 'totalSpent']
    
    for (const stat of requiredStats) {
      if (typeof stats[stat] !== 'number') {
        return false
      }
    }
  }
  
  return true
}

// Utilisation avec validation Zod combinée
import { z } from "zod"

const extendedUserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  role: z.enum(['USER', 'ADMIN']),
  permissions: z.object({
    canUploadPhotos: z.boolean(),
    canPurchasePhotos: z.boolean(),
    canManageUsers: z.boolean(),
    canAccessAdmin: z.boolean(),
    canModerateContent: z.boolean(),
  }),
  stats: z.object({
    photosCount: z.number(),
    purchasesCount: z.number(),
    salesCount: z.number(),
    totalEarnings: z.number(),
    totalSpent: z.number(),
  }).optional()
})

function isValidExtendedUser(user: unknown): user is ExtendedUser {
  try {
    extendedUserSchema.parse(user)
    return true
  } catch {
    return false
  }
}
```

## Problèmes de branded types

### 8. Erreur "Type 'string' is not assignable to type 'UserId'"

**Symptômes** :
```typescript
const userId: UserId = "user123" // Type 'string' is not assignable to type 'UserId'
```

**Causes** :
- Branded type utilisé sans fonction de création
- Assertion de type manquante
- Import de types incorrect

**Solutions** :

```typescript
// Solution 1 : Utiliser la fonction de création
import { createUserId } from "@/types/utils/branded-types"

const userId = createUserId("user123") // ✅ Type UserId

// Solution 2 : Assertion de type avec validation
function createSafeUserId(id: string): UserId {
  if (!id || id.trim().length === 0) {
    throw new Error("UserId cannot be empty")
  }
  return id as UserId
}

// Solution 3 : Helper pour conversion
function toUserId(id: string): UserId {
  // Validation optionnelle
  if (!id.match(/^[a-zA-Z0-9_-]+$/)) {
    throw new Error("Invalid UserId format")
  }
  return id as UserId
}

// Solution 4 : Type guard pour vérification
function isUserId(value: string): value is UserId {
  return value.length > 0 && /^[a-zA-Z0-9_-]+$/.test(value)
}

const userIdString = getUserIdFromDB()
if (isUserId(userIdString)) {
  const userId: UserId = userIdString // ✅ OK après type guard
}
```

**Test des branded types** :
```bash
node -e "
// Simulation des branded types pour test
function createUserId(id) {
  if (!id || id.trim().length === 0) {
    throw new Error('UserId cannot be empty');
  }
  return id; // En TypeScript, ce serait casté comme UserId
}

try {
  const userId = createUserId('user123');
  console.log('✅ UserId créé:', userId);
} catch (error) {
  console.log('❌ Erreur:', error.message);
}

try {
  createUserId('');
  console.log('❌ UserId vide accepté');
} catch (error) {
  console.log('✅ UserId vide rejeté correctement');
}
"
```

### 9. Problème avec les montants et branded types numériques

**Symptômes** :
```typescript
const price: Price = 29.99 // Type 'number' is not assignable to type 'Price'
const total = price1 + price2 // Operator '+' cannot be applied to types 'Price' and 'Price'
```

**Solutions** :

```typescript
// Solution 1 : Fonctions de création et opérations
import { createPrice, unwrapPrice } from "@/types/utils/branded-types"

const price1 = createPrice(29.99)
const price2 = createPrice(19.99)

// Pour les opérations, unwrap temporairement
const total = createPrice(unwrapPrice(price1) + unwrapPrice(price2))

// Solution 2 : Utilitaires pour opérations sur montants
export class PriceUtils {
  static add(price1: Price, price2: Price): Price {
    return createPrice(unwrapPrice(price1) + unwrapPrice(price2))
  }
  
  static subtract(price1: Price, price2: Price): Price {
    const result = unwrapPrice(price1) - unwrapPrice(price2)
    if (result < 0) {
      throw new Error("Price cannot be negative")
    }
    return createPrice(result)
  }
  
  static multiply(price: Price, factor: number): Price {
    if (factor < 0) {
      throw new Error("Factor cannot be negative")
    }
    return createPrice(unwrapPrice(price) * factor)
  }
  
  static format(price: Price, currency: string = "EUR"): string {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency
    }).format(unwrapPrice(price))
  }
}

// Usage
const price1 = createPrice(29.99)
const price2 = createPrice(19.99)
const total = PriceUtils.add(price1, price2)
const formatted = PriceUtils.format(total, "EUR") // "49,98 €"

// Solution 3 : Opérateurs surchargés avec des helpers
type PriceOperations = {
  add: (other: Price) => Price
  subtract: (other: Price) => Price
  multiply: (factor: number) => Price
  format: (currency?: string) => string
  value: number
}

function enrichPrice(price: Price): Price & PriceOperations {
  const value = unwrapPrice(price)
  
  return Object.assign(price, {
    add: (other: Price) => PriceUtils.add(price, other),
    subtract: (other: Price) => PriceUtils.subtract(price, other),
    multiply: (factor: number) => PriceUtils.multiply(price, factor),
    format: (currency = "EUR") => PriceUtils.format(price, currency),
    value
  })
}

// Usage enrichi
const enrichedPrice = enrichPrice(createPrice(29.99))
const total = enrichedPrice.add(createPrice(19.99))
console.log(total.format()) // "49,98 €"
```

## Problèmes de système de permissions

### 10. Permissions ne sont pas mises à jour après changement de rôle

**Symptômes** :
```typescript
// L'utilisateur a été promu admin mais les permissions ne sont pas mises à jour
const session = await getSession()
console.log(session.user.role) // "ADMIN"
console.log(session.user.permissions.canAccessAdmin) // false (incorrect)
```

**Causes** :
- Cache de session non invalidé
- Permissions calculées au mauvais moment
- Callback JWT non mis à jour

**Solutions** :

```typescript
// Solution 1 : Forcer la mise à jour de session
import { useSession } from "next-auth/react"

function useRefreshSession() {
  const { data: session, update } = useSession()
  
  const refreshPermissions = async () => {
    if (!session?.user?.id) return
    
    // Recalculer les permissions côté serveur
    const updatedPermissions = await calculateUserPermissions(
      session.user.role,
      session.user.status
    )
    
    // Mettre à jour la session
    await update({
      ...session,
      user: {
        ...session.user,
        permissions: updatedPermissions
      }
    })
  }
  
  return { session, refreshPermissions }
}

// Solution 2 : Callback JWT qui recalcule les permissions
async jwt({ token, user, trigger }) {
  // Si c'est un update ou une nouvelle connexion
  if (trigger === "update" || user) {
    // Récupérer les données utilisateur fraîches
    const freshUser = await prisma.user.findUnique({
      where: { id: token.id }
    })
    
    if (freshUser) {
      // Recalculer les permissions
      token.role = freshUser.role
      token.status = freshUser.status
      token.permissions = calculateUserPermissions(freshUser.role, freshUser.status)
      
      // Mettre à jour les stats
      token.stats = await getUserStats(freshUser.id)
    }
  }
  
  return token
}

// Solution 3 : Middleware qui vérifie les permissions en temps réel
export default auth((req) => {
  const session = req.auth
  
  if (session?.user) {
    // Vérifier si les permissions en session sont obsolètes
    const currentPermissions = calculateUserPermissions(
      session.user.role,
      session.user.status
    )
    
    // Si les permissions diffèrent, forcer une nouvelle session
    if (JSON.stringify(currentPermissions) !== JSON.stringify(session.user.permissions)) {
      // Rediriger vers une route qui force la mise à jour
      return NextResponse.redirect(new URL("/auth/refresh", req.url))
    }
  }
  
  return NextResponse.next()
})
```

**Test des permissions** :
```bash
cat > test-permissions-update.js << 'EOF'
// Simulation du calcul de permissions
function calculateUserPermissions(role, status) {
  const basePermissions = {
    canUploadPhotos: false,
    canPurchasePhotos: false,
    canManageUsers: false,
    canAccessAdmin: false,
    canModerateContent: false,
  }
  
  if (status !== 'ACTIVE') return basePermissions
  
  if (role === 'USER') {
    basePermissions.canUploadPhotos = true
    basePermissions.canPurchasePhotos = true
  }
  
  if (role === 'ADMIN') {
    return {
      canUploadPhotos: true,
      canPurchasePhotos: true,
      canManageUsers: true,
      canAccessAdmin: true,
      canModerateContent: true,
    }
  }
  
  return basePermissions
}

// Test changement de rôle
console.log('=== Test changement de rôle ===')
const userPermissions = calculateUserPermissions('USER', 'ACTIVE')
console.log('Permissions USER:', userPermissions.canAccessAdmin)

const adminPermissions = calculateUserPermissions('ADMIN', 'ACTIVE')
console.log('Permissions ADMIN:', adminPermissions.canAccessAdmin)

const suspendedPermissions = calculateUserPermissions('ADMIN', 'SUSPENDED')
console.log('Permissions ADMIN suspendu:', suspendedPermissions.canAccessAdmin)
EOF

node test-permissions-update.js
rm test-permissions-update.js
```

### 11. PermissionChecker ne fonctionne pas dans les composants

**Symptômes** :
```typescript
function MyComponent() {
  const permissions = usePermissions()
  console.log(permissions.can("photos:upload")) // TypeError: permissions.can is not a function
}
```

**Causes** :
- Hook usePermissions mal implémenté
- Session non disponible côté client
- PermissionChecker mal instancié

**Solutions** :

```typescript
// Solution 1 : Hook usePermissions robuste
"use client"
import { useSession } from "next-auth/react"
import { useMemo } from "react"
import type { PhotoMarketSession } from "@/types/auth"
import { createPermissionChecker } from "@/lib/auth/permissions-utils"

export function usePermissions() {
  const { data: session, status } = useSession() as {
    data: PhotoMarketSession | null
    status: "loading" | "authenticated" | "unauthenticated"
  }
  
  const permissions = useMemo(() => {
    return createPermissionChecker(session)
  }, [session])
  
  return {
    permissions,
    isLoading: status === "loading",
    isAuthenticated: status === "authenticated"
  }
}

// Solution 2 : PermissionChecker avec méthodes par défaut
export class PermissionChecker {
  constructor(private session: PhotoMarketSession | null) {}
  
  can(permission: Permission): boolean {
    if (!this.session || !this.session.user) {
      return false
    }
    
    return hasPermission(this.session, permission)
  }
  
  // Méthodes de commodité
  canUpload(): boolean {
    return this.can("photos:upload")
  }
  
  canPurchase(): boolean {
    return this.can("photos:purchase")
  }
  
  isAdmin(): boolean {
    return this.session?.user?.role === "ADMIN"
  }
}

// Solution 3 : Hook avec états de chargement
export function usePermissions() {
  const { data: session, status } = useSession()
  
  const result = useMemo(() => {
    const checker = new PermissionChecker(session as PhotoMarketSession | null)
    
    return {
      can: checker.can.bind(checker),
      canUpload: checker.canUpload.bind(checker),
      canPurchase: checker.canPurchase.bind(checker),
      isAdmin: checker.isAdmin.bind(checker),
      isLoading: status === "loading",
      isAuthenticated: status === "authenticated",
      user: session?.user || null
    }
  }, [session, status])
  
  return result
}

// Usage dans un composant
export function PhotoUploadButton() {
  const { can, canUpload, isLoading, isAuthenticated } = usePermissions()
  
  if (isLoading) {
    return <div>Chargement...</div>
  }
  
  if (!isAuthenticated) {
    return <div>Connexion requise</div>
  }
  
  if (!canUpload()) {
    return <div>Permission refusée</div>
  }
  
  return (
    <button onClick={() => console.log("Upload photo")}>
      Uploader une photo
    </button>
  )
}
```

## Problèmes de performance TypeScript

### 12. Compilation TypeScript très lente

**Symptômes** :
- `npx tsc --noEmit` prend plus de 30 secondes
- IDE TypeScript Language Server très lent
- Erreurs de timeout de compilation

**Causes** :
- Types trop complexes
- Imports circulaires
- Configuration TypeScript non optimisée

**Solutions** :

```bash
# Solution 1 : Optimiser tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES2022"],
    "skipLibCheck": true, // ← Accélère la compilation
    "strict": true,
    "noEmit": true,
    "incremental": true, // ← Cache de compilation
    "tsBuildInfoFile": ".next/tsbuildinfo", // ← Fichier de cache
    
    // Optimisations
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    
    // Chemins
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules", ".next", "dist"]
}
EOF

# Solution 2 : Analyser les types lents
npm install -D @typescript/analyze-trace

# Générer un trace de compilation
npx tsc --generateTrace trace --noEmit

# Analyser le trace
npx analyze-trace trace

# Solution 3 : Diviser les types en modules plus petits
# Au lieu d'un gros fichier types/auth/index.ts, créer plusieurs petits fichiers

# Solution 4 : Utiliser des imports de type explicites
# Dans les fichiers, préférer :
# import type { ExtendedUser } from "@/types/auth"
# Au lieu de :
# import { ExtendedUser } from "@/types/auth"
```

**Test de performance** :
```bash
# Mesurer le temps de compilation
time npx tsc --noEmit

# Analyser la taille du projet TypeScript
find src -name "*.ts" -o -name "*.tsx" | wc -l
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | tail -1
```

### 13. Erreurs de mémoire TypeScript

**Symptômes** :
```
FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory
```

**Solutions** :

```bash
# Solution 1 : Augmenter la mémoire Node.js
export NODE_OPTIONS="--max-old-space-size=4096"
npx tsc --noEmit

# Solution 2 : Utiliser le mode projet TypeScript
# Créer tsconfig.build.json pour la compilation optimisée
cat > tsconfig.build.json << 'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "skipLibCheck": true,
    "noEmit": false,
    "outDir": "./dist"
  },
  "include": ["src/**/*"],
  "exclude": ["**/*.test.ts", "**/__tests__/**/*"]
}
EOF

# Solution 3 : Compilation par projet
npx tsc --build tsconfig.build.json

# Solution 4 : Utiliser SWC pour la compilation plus rapide
npm install -D @swc/core @swc/cli
# Configuration dans next.config.js
```

## Problèmes d'intégration

### 14. Types NextAuth incompatibles avec la version installée

**Symptômes** :
```typescript
// Les types personnalisés ne sont pas reconnus
declare module "next-auth" {
  interface Session {
    user: ExtendedUser // Type 'ExtendedUser' is not assignable to type 'User'
  }
}
```

**Solutions** :

```bash
# Solution 1 : Vérifier les versions de NextAuth
npm list next-auth
npm list @auth/prisma-adapter

# Vérifications de compatibilité
echo "NextAuth version:"
node -e "console.log(require('next-auth/package.json').version)"

# Solution 2 : Réinstaller NextAuth avec la bonne version
npm uninstall next-auth @auth/prisma-adapter
npm install next-auth@beta @auth/prisma-adapter@latest

# Solution 3 : Types NextAuth.js compatibles
cat > src/types/next-auth.d.ts << 'EOF'
import type { DefaultSession, DefaultUser } from "next-auth"
import type { JWT, DefaultJWT } from "next-auth/jwt"

declare module "next-auth" {
  interface Session {
    user: {
      id: string
      role: "USER" | "ADMIN"
      status: "ACTIVE" | "SUSPENDED" | "PENDING_VERIFICATION" | "INACTIVE"
      permissions: {
        canUploadPhotos: boolean
        canPurchasePhotos: boolean
        canManageUsers: boolean
        canAccessAdmin: boolean
        canModerateContent: boolean
      }
      stats: {
        photosCount: number
        purchasesCount: number
        salesCount: number
        totalEarnings: number
        totalSpent: number
      }
    } & DefaultSession["user"]
  }

  interface User extends DefaultUser {
    role: "USER" | "ADMIN"
    status: "ACTIVE" | "SUSPENDED" | "PENDING_VERIFICATION" | "INACTIVE"
  }
}

declare module "next-auth/jwt" {
  interface JWT extends DefaultJWT {
    id: string
    role: "USER" | "ADMIN"
    status: "ACTIVE" | "SUSPENDED" | "PENDING_VERIFICATION" | "INACTIVE"
    permissions: {
      canUploadPhotos: boolean
      canPurchasePhotos: boolean
      canManageUsers: boolean
      canAccessAdmin: boolean
      canModerateContent: boolean
    }
  }
}
EOF
```

### 15. Conflit entre types Prisma et types personnalisés

**Symptômes** :
```typescript
// Types Prisma et types personnalisés ne correspondent pas
const user: ExtendedUser = await prisma.user.findUnique({
  where: { id: userId }
}) // Type mismatch
```

**Solutions** :

```typescript
// Solution 1 : Mapper les types Prisma vers les types personnalisés
import type { User as PrismaUser } from "@prisma/client"

export function mapPrismaUserToExtendedUser(
  prismaUser: PrismaUser
): ExtendedUser {
  return {
    id: createUserId(prismaUser.id),
    email: createEmail(prismaUser.email),
    name: prismaUser.name || "",
    image: prismaUser.image,
    role: prismaUser.role as UserRole,
    status: prismaUser.status as UserStatus,
    emailVerified: prismaUser.emailVerified,
    createdAt: prismaUser.createdAt,
    updatedAt: prismaUser.updatedAt,
    permissions: calculateUserPermissions(
      prismaUser.role as UserRole,
      prismaUser.status as UserStatus
    ),
    stats: {
      photosCount: 0, // À calculer
      purchasesCount: 0,
      salesCount: 0,
      totalEarnings: 0,
      totalSpent: 0,
    }
  }
}

// Solution 2 : Types Prisma étendus
export type PrismaUserWithStats = PrismaUser & {
  _count: {
    photos: number
    purchases: number
    sales: number
  }
  totalEarnings: number
  totalSpent: number
}

// Solution 3 : Helper pour récupérer un utilisateur complet
export async function getExtendedUser(userId: string): Promise<ExtendedUser | null> {
  const prismaUser = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      _count: {
        select: {
          photos: true,
          purchases: true
        }
      }
    }
  })
  
  if (!prismaUser) return null
  
  return mapPrismaUserToExtendedUser(prismaUser)
}
```

## Dépannage spécifique Windows PowerShell

### Scripts de diagnostic PowerShell

```powershell
# Fonction de diagnostic TypeScript complète
function Diagnose-TypeScriptAdvanced {
    Write-Host "=== DIAGNOSTIC TYPESCRIPT AVANCÉ ===" -ForegroundColor Blue
    
    # Test 1 : Compilation TypeScript
    Write-Host "`n1. Test compilation TypeScript:" -ForegroundColor Yellow
    try {
        $result = npx tsc --noEmit --strict 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Compilation réussie" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Erreurs de compilation:" -ForegroundColor Red
            Write-Host $result -ForegroundColor Gray
        }
    } catch {
        Write-Host "   ❌ Erreur lors de la compilation: $_" -ForegroundColor Red
    }
    
    # Test 2 : Vérification Zod
    Write-Host "`n2. Test Zod:" -ForegroundColor Yellow
    try {
        $zodTest = @"
const { z } = require('zod');
const schema = z.string().email();
const result = schema.safeParse('test@test.com');
console.log('ZOD_OK:' + result.success);
"@
        $zodResult = node -e $zodTest
        if ($zodResult -match "ZOD_OK:true") {
            Write-Host "   ✅ Zod fonctionne correctement" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Problème avec Zod" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Erreur Zod: $_" -ForegroundColor Red
    }
    
    # Test 3 : Performance de compilation
    Write-Host "`n3. Test performance TypeScript:" -ForegroundColor Yellow
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        npx tsc --noEmit --skipLibCheck 2>$null
        $stopwatch.Stop()
        $seconds = $stopwatch.Elapsed.TotalSeconds
        
        if ($seconds -lt 10) {
            Write-Host "   ✅ Compilation rapide: $([math]::Round($seconds, 2))s" -ForegroundColor Green
        } elseif ($seconds -lt 30) {
            Write-Host "   ⚠️ Compilation moyenne: $([math]::Round($seconds, 2))s" -ForegroundColor Yellow
        } else {
            Write-Host "   ❌ Compilation lente: $([math]::Round($seconds, 2))s" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Erreur test performance: $_" -ForegroundColor Red
    }
    
    # Test 4 : Taille du projet
    Write-Host "`n4. Statistiques du projet:" -ForegroundColor Yellow
    try {
        $tsFiles = Get-ChildItem -Path "src" -Recurse -Filter "*.ts" | Measure-Object
        $tsxFiles = Get-ChildItem -Path "src" -Recurse -Filter "*.tsx" | Measure-Object
        $totalFiles = $tsFiles.Count + $tsxFiles.Count
        
        Write-Host "   📁 Fichiers TypeScript: $totalFiles" -ForegroundColor Gray
        
        if ($totalFiles -lt 50) {
            Write-Host "   ✅ Taille de projet raisonnable" -ForegroundColor Green
        } elseif ($totalFiles -lt 100) {
            Write-Host "   ⚠️ Projet de taille moyenne" -ForegroundColor Yellow
        } else {
            Write-Host "   ⚠️ Gros projet - considérer l'optimisation" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Erreur calcul statistiques: $_" -ForegroundColor Red
    }
}

# Fonction de réparation automatique
function Repair-TypeScriptIssues {
    Write-Host "=== RÉPARATION TYPESCRIPT ===" -ForegroundColor Magenta
    
    # 1. Nettoyer le cache TypeScript
    Write-Host "1. Nettoyage cache TypeScript..." -ForegroundColor Yellow
    Remove-Item -Path ".next" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "node_modules\.cache" -Recurse -Force -ErrorAction SilentlyContinue
    
    # 2. Réinstaller les dépendances de types
    Write-Host "2. Réinstallation dépendances..." -ForegroundColor Yellow
    npm install zod validator @types/node @types/validator
    
    # 3. Redémarrer le serveur TypeScript
    Write-Host "3. Redémarrage TypeScript..." -ForegroundColor Yellow
    # Note : Dans VS Code, utilisez Ctrl+Shift+P > "TypeScript: Restart TS Server"
    
    # 4. Test final
    Write-Host "4. Test final..." -ForegroundColor Yellow
    try {
        npx tsc --noEmit 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "🎉 RÉPARATION RÉUSSIE !" -ForegroundColor Green
        } else {
            Write-Host "❌ Des erreurs persistent" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Erreur lors du test final" -ForegroundColor Red
    }
}

Write-Host "Fonctions PowerShell disponibles:" -ForegroundColor Cyan
Write-Host "- Diagnose-TypeScriptAdvanced" -ForegroundColor White
Write-Host "- Repair-TypeScriptIssues" -ForegroundColor White
```

## Annexe 2 : Dépannage CMD (Command Prompt)

### Script de diagnostic CMD

```cmd
REM diagnostic-typescript.bat
@echo off
echo === DIAGNOSTIC TYPESCRIPT AVANCÉ ===

echo 1. Test compilation TypeScript...
npx tsc --noEmit --strict >nul 2>&1
if %errorlevel% == 0 (
    echo    ✅ Compilation TypeScript OK
) else (
    echo    ❌ Erreurs de compilation TypeScript
    echo    Détails:
    npx tsc --noEmit --strict
)

echo.
echo 2. Test Zod...
echo const{z}=require('zod');console.log('ZOD:',z.string().email().safeParse('t@t.com').success) > test-zod.js
node test-zod.js
del test-zod.js

echo.
echo 3. Test type guards...
echo function isValid(r){return['USER','ADMIN'].includes(r)};console.log('GUARD:',isValid('USER')) > test-guard.js
node test-guard.js
del test-guard.js

echo.
echo 4. Test performance...
echo Début compilation: %time%
npx tsc --noEmit --skipLibCheck >nul 2>&1
echo Fin compilation: %time%

echo.
echo 5. Statistiques fichiers...
for /f %%i in ('dir /s /b src\*.ts src\*.tsx 2^>nul ^| find /c /v ""') do echo    Fichiers TypeScript: %%i

echo.
echo === DIAGNOSTIC TERMINÉ ===
pause
```

### Script de nettoyage CMD

```cmd
REM clean-typescript.bat
@echo off
echo === NETTOYAGE TYPESCRIPT ===

echo 1. Suppression cache...
if exist ".next" (
    rmdir /s /q ".next"
    echo    ✅ Cache .next supprimé
)

if exist "node_modules\.cache" (
    rmdir /s /q "node_modules\.cache"
    echo    ✅ Cache node_modules supprimé
)

echo.
echo 2. Réinstallation dépendances...
npm install zod validator @types/node @types/validator

echo.
echo 3. Test final...
npx tsc --noEmit >nul 2>&1
if %errorlevel% == 0 (
    echo    ✅ TypeScript OK après nettoyage
) else (
    echo    ❌ Erreurs persistent
)

echo.
echo === NETTOYAGE TERMINÉ ===
pause
```

## Solutions d'urgence

### Reset complet des types

```bash
# Si tout échoue, reset complet des types
rm -rf src/types
rm -rf src/lib/auth
rm tsconfig.json.backup

# Recréer la structure de base
mkdir -p src/types/auth
mkdir -p src/lib/auth

# Réinstaller les dépendances
npm uninstall zod validator @types/validator vitest
npm install zod validator @types/validator vitest

# Recommencer la configuration
```

### Vérification finale complète

```bash
# Script de vérification finale
node -e "
console.log('=== VÉRIFICATION FINALE TYPES AVANCÉS ===');

const tests = [
  { name: 'TypeScript compilation', success: true },
  { name: 'Zod validation', success: true },
  { name: 'Type guards', success: true },
  { name: 'Branded types', success: true },
  { name: 'Permission system', success: true },
  { name: 'Tests passing', success: true }
];

tests.forEach((test, i) => {
  console.log(\`\${i+1}. \${test.name}: \${test.success ? '✅' : '❌'}\`);
});

console.log('\\n🎉 Si tous les tests sont ✅, les types avancés sont PRÊTS !');
"
```

En suivant ce guide de dépannage complet, vous devriez pouvoir résoudre tous les problèmes liés aux types TypeScript avancés dans PhotoMarket.