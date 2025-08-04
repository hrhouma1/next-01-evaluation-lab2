# Étape 6 : Commandes Types NextAuth.js avancés

## Commandes d'installation et configuration

### Installation des dépendances TypeScript

```bash
# Naviguer dans le projet
cd photo-marketplace

# Installer Zod pour la validation avec types
npm install zod
npm install @types/zod -D

# Installer validator pour validations avancées
npm install validator
npm install @types/validator -D

# Installer les utilitaires de test TypeScript
npm install -D vitest @vitest/ui
npm install -D @types/node

# Vérifier les versions installées
npm list zod validator vitest
```

### Configuration TypeScript avancée

```bash
# Sauvegarder la configuration actuelle
cp tsconfig.json tsconfig.json.backup

# Créer la configuration TypeScript stricte
cat > tsconfig.json << 'EOF'
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
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"],
      "@/types/*": ["./src/types/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/components/*": ["./src/components/*"],
      "@/hooks/*": ["./src/hooks/*"]
    },
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noPropertyAccessFromIndexSignature": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

# Vérifier la configuration TypeScript
npx tsc --noEmit
```

## Commandes de création de la structure de types

### Création de la structure de dossiers

```bash
# Créer l'arborescence complète des types
mkdir -p src/types/auth
mkdir -p src/types/database
mkdir -p src/types/api
mkdir -p src/types/utils
mkdir -p src/lib/auth
mkdir -p src/lib/types
mkdir -p src/types/__tests__

# Vérifier la structure créée
find src/types -type d | sort
tree src/types 2>/dev/null || find src/types -type d
```

### Création des fichiers de types de base

```bash
# Créer tous les fichiers de types principaux
touch src/types/auth/index.ts
touch src/types/auth/session.ts
touch src/types/auth/user.ts
touch src/types/auth/providers.ts
touch src/types/auth/callbacks.ts
touch src/types/auth/middleware.ts
touch src/types/auth/forms.ts

# Créer les fichiers utilitaires
touch src/types/utils/branded-types.ts
touch src/types/utils/validation.ts
touch src/types/utils/permissions.ts

# Créer les fichiers de base de données
touch src/types/database/prisma-extended.ts
touch src/types/database/relations.ts

# Créer les fichiers API
touch src/types/api/auth-responses.ts
touch src/types/api/errors.ts

# Créer les fichiers de bibliothèque
touch src/lib/auth/validators.ts
touch src/lib/auth/type-guards.ts
touch src/lib/auth/permissions-utils.ts
touch src/lib/types/type-helpers.ts

# Vérifier que tous les fichiers sont créés
find src/types src/lib -name "*.ts" | wc -l
ls -la src/types/auth/
ls -la src/lib/auth/
```

## Commandes de validation et test des types

### Tests de compilation TypeScript

```bash
# Test 1 : Compilation TypeScript stricte
npx tsc --noEmit --strict

# Test 2 : Vérification des types sans émission
npx tsc --noEmit --skipLibCheck false

# Test 3 : Analyse des erreurs TypeScript
npx tsc --noEmit 2>&1 | head -20

# Test 4 : Vérification des imports
node -e "
try {
  const types = require('./src/types/auth/index.ts');
  console.log('✅ Types importables');
} catch (error) {
  console.log('❌ Erreur import types:', error.message);
}
"
```

### Tests de validation Zod

```bash
# Créer un script de test Zod rapide
cat > test-zod-validation.js << 'EOF'
const { z } = require('zod');

// Test des schémas de validation de base
const emailSchema = z.string().email();
const passwordSchema = z.string().min(8);

console.log('=== TESTS VALIDATION ZOD ===');

// Test email valide
try {
  emailSchema.parse('test@photomarket.com');
  console.log('✅ Email valide accepté');
} catch (error) {
  console.log('❌ Email valide rejeté:', error.message);
}

// Test email invalide
try {
  emailSchema.parse('email-invalide');
  console.log('❌ Email invalide accepté');
} catch (error) {
  console.log('✅ Email invalide rejeté');
}

// Test mot de passe valide
try {
  passwordSchema.parse('motdepasse123');
  console.log('✅ Mot de passe valide accepté');
} catch (error) {
  console.log('❌ Mot de passe valide rejeté:', error.message);
}

// Test mot de passe invalide
try {
  passwordSchema.parse('123');
  console.log('❌ Mot de passe invalide accepté');
} catch (error) {
  console.log('✅ Mot de passe invalide rejeté');
}

console.log('=== TESTS ZOD TERMINÉS ===');
EOF

# Exécuter les tests
node test-zod-validation.js

# Nettoyer
rm test-zod-validation.js
```

### Tests des type guards

```bash
# Créer un script de test des type guards
cat > test-type-guards.js << 'EOF'
// Import simulé des type guards (adaptation pour Node.js)
function isValidUserRole(role) {
  return ["USER", "ADMIN"].includes(role);
}

function isValidUserStatus(status) {
  return ["ACTIVE", "SUSPENDED", "PENDING_VERIFICATION", "INACTIVE"].includes(status);
}

function isValidOAuthProvider(provider) {
  return ["google", "github", "facebook", "twitter", "linkedin"].includes(provider);
}

console.log('=== TESTS TYPE GUARDS ===');

// Test rôles utilisateur
console.log('Rôle USER valide:', isValidUserRole('USER'));
console.log('Rôle ADMIN valide:', isValidUserRole('ADMIN'));
console.log('Rôle INVALID invalide:', !isValidUserRole('INVALID'));

// Test statuts utilisateur
console.log('Statut ACTIVE valide:', isValidUserStatus('ACTIVE'));
console.log('Statut SUSPENDED valide:', isValidUserStatus('SUSPENDED'));
console.log('Statut INVALID invalide:', !isValidUserStatus('INVALID'));

// Test providers OAuth
console.log('Provider google valide:', isValidOAuthProvider('google'));
console.log('Provider github valide:', isValidOAuthProvider('github'));
console.log('Provider invalid invalide:', !isValidOAuthProvider('invalid'));

console.log('=== TESTS TYPE GUARDS TERMINÉS ===');
EOF

node test-type-guards.js
rm test-type-guards.js
```

## Commandes de test avec Vitest

### Configuration Vitest

```bash
# Créer la configuration Vitest
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@/types': resolve(__dirname, './src/types'),
      '@/lib': resolve(__dirname, './src/lib'),
    },
  },
})
EOF

# Ajouter les scripts de test dans package.json
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts = pkg.scripts || {};
pkg.scripts['test:types'] = 'vitest run src/types/__tests__';
pkg.scripts['test:types:watch'] = 'vitest src/types/__tests__';
pkg.scripts['test:types:ui'] = 'vitest --ui src/types/__tests__';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
console.log('✅ Scripts de test ajoutés');
"
```

### Création des tests TypeScript

```bash
# Créer le fichier de test principal
cat > src/types/__tests__/auth-types.test.ts << 'EOF'
import { describe, it, expect, expectTypeOf } from 'vitest'

// Types simulés pour les tests
type UserRole = "USER" | "ADMIN"
type UserStatus = "ACTIVE" | "SUSPENDED" | "PENDING_VERIFICATION" | "INACTIVE"

interface ExtendedUser {
  id: string
  email: string
  name: string
  role: UserRole
  status: UserStatus
  permissions: {
    canUploadPhotos: boolean
    canPurchasePhotos: boolean
    canManageUsers: boolean
    canAccessAdmin: boolean
    canModerateContent: boolean
  }
}

// Type guards simulés
function isValidUserRole(role: string): role is UserRole {
  return ["USER", "ADMIN"].includes(role)
}

function isExtendedUser(user: any): user is ExtendedUser {
  return (
    user &&
    typeof user.id === 'string' &&
    typeof user.email === 'string' &&
    isValidUserRole(user.role) &&
    user.permissions &&
    typeof user.permissions === 'object'
  )
}

describe('Types d\'authentification', () => {
  it('devrait valider les rôles utilisateur', () => {
    expect(isValidUserRole('USER')).toBe(true)
    expect(isValidUserRole('ADMIN')).toBe(true)
    expect(isValidUserRole('INVALID')).toBe(false)
  })

  it('devrait valider un ExtendedUser', () => {
    const validUser: ExtendedUser = {
      id: 'user123',
      email: 'test@example.com',
      name: 'Test User',
      role: 'USER',
      status: 'ACTIVE',
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

  it('devrait avoir les types corrects', () => {
    expectTypeOf<UserRole>().toEqualTypeOf<'USER' | 'ADMIN'>()
    expectTypeOf<ExtendedUser>().toHaveProperty('id').toEqualTypeOf<string>()
    expectTypeOf<ExtendedUser>().toHaveProperty('role').toEqualTypeOf<UserRole>()
  })
})
EOF

# Exécuter les tests
npm run test:types
```

## Commandes de validation des permissions

### Test du système de permissions

```bash
# Créer un script de test des permissions
cat > test-permissions.js << 'EOF'
// Simulation du système de permissions
function calculateUserPermissions(role, status) {
  const basePermissions = {
    canUploadPhotos: false,
    canPurchasePhotos: false,
    canManageUsers: false,
    canAccessAdmin: false,
    canModerateContent: false,
  }
  
  if (status !== 'ACTIVE') {
    return basePermissions
  }
  
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

function hasPermission(session, permission) {
  if (!session || !session.user) return false
  
  const permissionMap = {
    'photos:upload': 'canUploadPhotos',
    'photos:purchase': 'canPurchasePhotos',
    'users:manage': 'canManageUsers',
    'admin:access': 'canAccessAdmin',
    'admin:moderate': 'canModerateContent',
  }
  
  const permissionKey = permissionMap[permission]
  return session.user.permissions[permissionKey] || false
}

console.log('=== TESTS SYSTÈME DE PERMISSIONS ===')

// Test utilisateur normal
const userSession = {
  user: {
    id: 'user1',
    role: 'USER',
    status: 'ACTIVE',
    permissions: calculateUserPermissions('USER', 'ACTIVE')
  }
}

console.log('Utilisateur USER peut uploader:', hasPermission(userSession, 'photos:upload'))
console.log('Utilisateur USER peut acheter:', hasPermission(userSession, 'photos:purchase'))
console.log('Utilisateur USER peut administrer:', hasPermission(userSession, 'admin:access'))

// Test administrateur
const adminSession = {
  user: {
    id: 'admin1',
    role: 'ADMIN',
    status: 'ACTIVE',
    permissions: calculateUserPermissions('ADMIN', 'ACTIVE')
  }
}

console.log('Admin peut uploader:', hasPermission(adminSession, 'photos:upload'))
console.log('Admin peut administrer:', hasPermission(adminSession, 'admin:access'))
console.log('Admin peut modérer:', hasPermission(adminSession, 'admin:moderate'))

// Test utilisateur suspendu
const suspendedSession = {
  user: {
    id: 'suspended1',
    role: 'USER',
    status: 'SUSPENDED',
    permissions: calculateUserPermissions('USER', 'SUSPENDED')
  }
}

console.log('Utilisateur suspendu peut uploader:', hasPermission(suspendedSession, 'photos:upload'))
console.log('Utilisateur suspendu peut acheter:', hasPermission(suspendedSession, 'photos:purchase'))

console.log('=== TESTS PERMISSIONS TERMINÉS ===')
EOF

node test-permissions.js
rm test-permissions.js
```

### Test des branded types

```bash
# Créer un script de test des branded types
cat > test-branded-types.js << 'EOF'
// Simulation des branded types pour Node.js
function createUserId(id) {
  if (typeof id !== 'string' || id.length === 0) {
    throw new Error('UserId invalide')
  }
  return id // En TypeScript, ce serait castée comme UserId
}

function createEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(email)) {
    throw new Error('Email invalide')
  }
  return email.toLowerCase() // En TypeScript, ce serait castée comme Email
}

function createAmount(amount) {
  if (typeof amount !== 'number' || amount < 0) {
    throw new Error('Montant invalide')
  }
  return amount // En TypeScript, ce serait castée comme Amount
}

function createPrice(price) {
  if (typeof price !== 'number' || price <= 0) {
    throw new Error('Prix invalide')
  }
  return price // En TypeScript, ce serait castée comme Price
}

console.log('=== TESTS BRANDED TYPES ===')

// Test UserId
try {
  const userId = createUserId('user123')
  console.log('✅ UserId valide créé:', userId)
} catch (error) {
  console.log('❌ Erreur UserId:', error.message)
}

try {
  createUserId('')
  console.log('❌ UserId vide accepté')
} catch (error) {
  console.log('✅ UserId vide rejeté')
}

// Test Email
try {
  const email = createEmail('test@photomarket.com')
  console.log('✅ Email valide créé:', email)
} catch (error) {
  console.log('❌ Erreur Email:', error.message)
}

try {
  createEmail('email-invalide')
  console.log('❌ Email invalide accepté')
} catch (error) {
  console.log('✅ Email invalide rejeté')
}

// Test Amount
try {
  const amount = createAmount(99.99)
  console.log('✅ Montant valide créé:', amount)
} catch (error) {
  console.log('❌ Erreur Amount:', error.message)
}

try {
  createAmount(-10)
  console.log('❌ Montant négatif accepté')
} catch (error) {
  console.log('✅ Montant négatif rejeté')
}

// Test Price
try {
  const price = createPrice(29.99)
  console.log('✅ Prix valide créé:', price)
} catch (error) {
  console.log('❌ Erreur Price:', error.message)
}

try {
  createPrice(0)
  console.log('❌ Prix zéro accepté')
} catch (error) {
  console.log('✅ Prix zéro rejeté')
}

console.log('=== TESTS BRANDED TYPES TERMINÉS ===')
EOF

node test-branded-types.js
rm test-branded-types.js
```

## Commandes de validation des formulaires

### Test des schémas de validation

```bash
# Créer un script de test des schémas de formulaire
cat > test-form-schemas.js << 'EOF'
const { z } = require('zod')

// Définition des schémas de validation
const emailSchema = z.string()
  .min(1, "L'email est obligatoire")
  .email("Format d'email invalide")
  .transform(email => email.toLowerCase().trim())

const passwordSchema = z.string()
  .min(8, "Le mot de passe doit contenir au moins 8 caractères")
  .regex(/[A-Z]/, "Le mot de passe doit contenir au moins une majuscule")
  .regex(/[a-z]/, "Le mot de passe doit contenir au moins une minuscule")
  .regex(/[0-9]/, "Le mot de passe doit contenir au moins un chiffre")
  .regex(/[^A-Za-z0-9]/, "Le mot de passe doit contenir au moins un caractère spécial")

const nameSchema = z.string()
  .min(2, "Le nom doit contenir au moins 2 caractères")
  .max(50, "Le nom ne peut pas dépasser 50 caractères")
  .regex(/^[a-zA-ZÀ-ÿ\s-']+$/, "Le nom ne peut contenir que des lettres, espaces, tirets et apostrophes")
  .transform(name => name.trim())

const signInSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, "Le mot de passe est obligatoire"),
  remember: z.boolean().optional(),
})

const signUpSchema = z.object({
  name: nameSchema,
  email: emailSchema,
  password: passwordSchema,
  confirmPassword: z.string(),
  terms: z.boolean().refine(val => val === true, "Vous devez accepter les conditions d'utilisation"),
}).refine(data => data.password === data.confirmPassword, {
  message: "Les mots de passe ne correspondent pas",
  path: ["confirmPassword"],
})

console.log('=== TESTS SCHÉMAS DE VALIDATION ===')

// Test connexion valide
try {
  const signInData = signInSchema.parse({
    email: 'test@photomarket.com',
    password: 'motdepasse123',
    remember: true
  })
  console.log('✅ Données de connexion valides:', signInData.email)
} catch (error) {
  console.log('❌ Erreur connexion valide:', error.errors?.[0]?.message || error.message)
}

// Test connexion invalide
try {
  signInSchema.parse({
    email: 'email-invalide',
    password: ''
  })
  console.log('❌ Données de connexion invalides acceptées')
} catch (error) {
  console.log('✅ Données de connexion invalides rejetées')
}

// Test inscription valide
try {
  const signUpData = signUpSchema.parse({
    name: 'Jean Dupont',
    email: 'jean@photomarket.com',
    password: 'MotDePasse123!',
    confirmPassword: 'MotDePasse123!',
    terms: true
  })
  console.log('✅ Données d\'inscription valides:', signUpData.name)
} catch (error) {
  console.log('❌ Erreur inscription valide:', error.errors?.[0]?.message || error.message)
}

// Test inscription - mots de passe différents
try {
  signUpSchema.parse({
    name: 'Jean Dupont',
    email: 'jean@photomarket.com',
    password: 'MotDePasse123!',
    confirmPassword: 'AutreMotDePasse123!',
    terms: true
  })
  console.log('❌ Mots de passe différents acceptés')
} catch (error) {
  console.log('✅ Mots de passe différents rejetés')
}

// Test inscription - conditions non acceptées
try {
  signUpSchema.parse({
    name: 'Jean Dupont',
    email: 'jean@photomarket.com',
    password: 'MotDePasse123!',
    confirmPassword: 'MotDePasse123!',
    terms: false
  })
  console.log('❌ Conditions non acceptées mais données acceptées')
} catch (error) {
  console.log('✅ Conditions non acceptées rejetées')
}

// Test mot de passe faible
try {
  passwordSchema.parse('123')
  console.log('❌ Mot de passe faible accepté')
} catch (error) {
  console.log('✅ Mot de passe faible rejeté:', error.errors?.[0]?.message || error.message)
}

console.log('=== TESTS SCHÉMAS TERMINÉS ===')
EOF

node test-form-schemas.js
rm test-form-schemas.js
```

## Commandes de développement et maintenance

### Surveillance des types en temps réel

```bash
# Démarrer la surveillance TypeScript
npx tsc --noEmit --watch &
TSC_PID=$!

# Démarrer les tests en mode watch
npm run test:types:watch &
TEST_PID=$!

echo "TypeScript compiler PID: $TSC_PID"
echo "Tests PID: $TEST_PID"

# Pour arrêter plus tard
# kill $TSC_PID $TEST_PID
```

### Analyse de qualité du code TypeScript

```bash
# Installer ESLint avec règles TypeScript
npm install -D @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Créer la configuration ESLint
cat > .eslintrc.js << 'EOF'
module.exports = {
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
    '@typescript-eslint/recommended-requiring-type-checking'
  ],
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    project: './tsconfig.json'
  },
  rules: {
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/explicit-function-return-type': 'warn',
    '@typescript-eslint/no-non-null-assertion': 'error',
    '@typescript-eslint/prefer-nullish-coalescing': 'error',
    '@typescript-eslint/prefer-optional-chain': 'error'
  }
}
EOF

# Lancer l'analyse ESLint
npx eslint src/types/**/*.ts src/lib/**/*.ts
```

### Génération de documentation des types

```bash
# Installer TypeDoc pour générer la documentation
npm install -D typedoc

# Créer la configuration TypeDoc
cat > typedoc.json << 'EOF'
{
  "entryPoints": ["src/types/auth/index.ts"],
  "out": "docs/types",
  "plugin": ["typedoc-plugin-markdown"],
  "theme": "markdown",
  "readme": "none",
  "githubPages": false
}
EOF

# Générer la documentation
npx typedoc

# Voir la documentation générée
ls -la docs/types/
```

## Commandes de diagnostic et debug

### Diagnostic complet des types

```bash
# Créer un script de diagnostic complet
cat > diagnostic-types.js << 'EOF'
const fs = require('fs')
const path = require('path')

console.log('=== DIAGNOSTIC COMPLET DES TYPES ===\n')

// 1. Vérifier la présence des fichiers de types
const typeFiles = [
  'src/types/auth/index.ts',
  'src/types/auth/session.ts',
  'src/types/auth/user.ts',
  'src/types/auth/providers.ts',
  'src/types/auth/callbacks.ts',
  'src/types/auth/middleware.ts',
  'src/types/auth/forms.ts',
  'src/types/utils/branded-types.ts',
  'src/lib/auth/validators.ts',
  'src/lib/auth/type-guards.ts',
  'src/lib/auth/permissions-utils.ts'
]

console.log('1. Fichiers de types:')
typeFiles.forEach(file => {
  const exists = fs.existsSync(file)
  console.log(`   ${exists ? '✅' : '❌'} ${file}`)
})

// 2. Vérifier la configuration TypeScript
console.log('\n2. Configuration TypeScript:')
const tsconfigExists = fs.existsSync('tsconfig.json')
console.log(`   ${tsconfigExists ? '✅' : '❌'} tsconfig.json`)

if (tsconfigExists) {
  try {
    const tsconfig = JSON.parse(fs.readFileSync('tsconfig.json', 'utf8'))
    console.log(`   ✅ strict: ${tsconfig.compilerOptions?.strict}`)
    console.log(`   ✅ noUncheckedIndexedAccess: ${tsconfig.compilerOptions?.noUncheckedIndexedAccess}`)
    console.log(`   ✅ exactOptionalPropertyTypes: ${tsconfig.compilerOptions?.exactOptionalPropertyTypes}`)
  } catch (error) {
    console.log(`   ❌ Erreur lecture tsconfig: ${error.message}`)
  }
}

// 3. Vérifier les dépendances
console.log('\n3. Dépendances:')
try {
  const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'))
  const deps = { ...packageJson.dependencies, ...packageJson.devDependencies }
  
  const requiredDeps = ['zod', 'validator', 'vitest', '@types/node']
  requiredDeps.forEach(dep => {
    console.log(`   ${deps[dep] ? '✅' : '❌'} ${dep}: ${deps[dep] || 'non installé'}`)
  })
} catch (error) {
  console.log(`   ❌ Erreur lecture package.json: ${error.message}`)
}

// 4. Vérifier les tests
console.log('\n4. Tests:')
const testFiles = [
  'src/types/__tests__/auth-types.test.ts',
  'vite.config.ts'
]

testFiles.forEach(file => {
  const exists = fs.existsSync(file)
  console.log(`   ${exists ? '✅' : '❌'} ${file}`)
})

// 5. Statistiques des fichiers
console.log('\n5. Statistiques:')
const countLinesInFile = (filePath) => {
  try {
    const content = fs.readFileSync(filePath, 'utf8')
    return content.split('\n').length
  } catch {
    return 0
  }
}

const existingFiles = typeFiles.filter(f => fs.existsSync(f))
const totalLines = existingFiles.reduce((sum, file) => sum + countLinesInFile(file), 0)

console.log(`   📁 Fichiers de types: ${existingFiles.length}/${typeFiles.length}`)
console.log(`   📄 Lignes de code total: ${totalLines}`)

console.log('\n=== DIAGNOSTIC TERMINÉ ===')
EOF

node diagnostic-types.js
rm diagnostic-types.js
```

### Debug des imports TypeScript

```bash
# Tester les imports TypeScript
node -e "
const { execSync } = require('child_process');

console.log('=== TEST IMPORTS TYPESCRIPT ===');

try {
  // Test compilation simple
  execSync('npx tsc --noEmit --skipLibCheck', { stdio: 'pipe' });
  console.log('✅ Compilation TypeScript réussie');
} catch (error) {
  console.log('❌ Erreurs de compilation TypeScript:');
  console.log(error.stdout?.toString() || error.message);
}

try {
  // Test imports Next.js
  execSync('npx next build --dry-run', { stdio: 'pipe' });
  console.log('✅ Build Next.js réussi');
} catch (error) {
  console.log('⚠️ Avertissement build Next.js (normal en développement)');
}

console.log('=== TEST IMPORTS TERMINÉ ===');
"
```

## Annexe 1 : Commandes PowerShell (Windows)

### Installation PowerShell

```powershell
# Installation des dépendances
npm install zod validator
npm install -D @types/zod @types/validator vitest @vitest/ui @types/node

# Création de la structure de dossiers
$folders = @(
    "src\types\auth",
    "src\types\database", 
    "src\types\api",
    "src\types\utils",
    "src\lib\auth",
    "src\lib\types",
    "src\types\__tests__"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force
    Write-Host "✅ Créé: $folder" -ForegroundColor Green
}

# Création des fichiers de types
$typeFiles = @(
    "src\types\auth\index.ts",
    "src\types\auth\session.ts",
    "src\types\auth\user.ts",
    "src\types\auth\providers.ts",
    "src\types\auth\callbacks.ts",
    "src\types\auth\middleware.ts",
    "src\types\auth\forms.ts",
    "src\types\utils\branded-types.ts",
    "src\lib\auth\validators.ts",
    "src\lib\auth\type-guards.ts",
    "src\lib\auth\permissions-utils.ts"
)

foreach ($file in $typeFiles) {
    New-Item -ItemType File -Path $file -Force
    Write-Host "✅ Créé: $file" -ForegroundColor Green
}
```

### Tests PowerShell

```powershell
# Fonction de test TypeScript
function Test-TypeScriptSetup {
    Write-Host "=== TEST TYPESCRIPT SETUP ===" -ForegroundColor Blue
    
    # Test compilation TypeScript
    try {
        $result = npx tsc --noEmit 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Compilation TypeScript réussie" -ForegroundColor Green
        } else {
            Write-Host "❌ Erreurs de compilation:" -ForegroundColor Red
            Write-Host $result -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Erreur lors de la compilation: $_" -ForegroundColor Red
    }
    
    # Test Zod
    try {
        $testZod = 'const { z } = require("zod"); console.log("Zod version:", z.version || "OK");'
        $zodResult = node -e $testZod
        Write-Host "✅ Zod: $zodResult" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur Zod: $_" -ForegroundColor Red
    }
    
    # Test structure des fichiers
    Write-Host "`n📁 Structure des types:" -ForegroundColor Yellow
    Get-ChildItem -Path "src\types" -Recurse -File | ForEach-Object {
        Write-Host "   $($_.FullName)" -ForegroundColor Gray
    }
}

# Fonction de test des permissions
function Test-PermissionsSystem {
    $testScript = @"
function calculateUserPermissions(role, status) {
    const base = { canUploadPhotos: false, canPurchasePhotos: false, canAccessAdmin: false };
    if (status !== 'ACTIVE') return base;
    if (role === 'USER') { base.canUploadPhotos = true; base.canPurchasePhotos = true; }
    if (role === 'ADMIN') return { canUploadPhotos: true, canPurchasePhotos: true, canAccessAdmin: true };
    return base;
}

const userPerms = calculateUserPermissions('USER', 'ACTIVE');
const adminPerms = calculateUserPermissions('ADMIN', 'ACTIVE');
const suspendedPerms = calculateUserPermissions('USER', 'SUSPENDED');

console.log('USER peut uploader:', userPerms.canUploadPhotos);
console.log('ADMIN peut administrer:', adminPerms.canAccessAdmin);
console.log('SUSPENDED peut uploader:', suspendedPerms.canUploadPhotos);
"@
    
    $testScript | Out-File -FilePath "test-perms.js" -Encoding UTF8
    node test-perms.js
    Remove-Item test-perms.js
}

Write-Host "Fonctions PowerShell disponibles:" -ForegroundColor Cyan
Write-Host "- Test-TypeScriptSetup" -ForegroundColor White
Write-Host "- Test-PermissionsSystem" -ForegroundColor White
```

## Annexe 2 : Commandes CMD (Command Prompt)

### Installation CMD

```cmd
REM Installation des dépendances
npm install zod validator
npm install -D @types/zod @types/validator vitest @vitest/ui @types/node

REM Vérification des installations
npm list zod validator vitest

REM Création de la structure
mkdir src\types\auth
mkdir src\types\database
mkdir src\types\api
mkdir src\types\utils
mkdir src\lib\auth
mkdir src\lib\types
mkdir src\types\__tests__

echo Structure créée avec succès
```

### Script de test complet CMD

```cmd
REM test-types-complete.bat
@echo off
echo === TEST COMPLET TYPES NEXTAUTH ===

echo 1. Test compilation TypeScript...
npx tsc --noEmit >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Compilation TypeScript OK
) else (
    echo ❌ Erreurs de compilation TypeScript
)

echo.
echo 2. Test Zod...
node -e "try{require('zod');console.log('✅ Zod OK')}catch{console.log('❌ Zod manquant')}"

echo.
echo 3. Test Validator...
node -e "try{require('validator');console.log('✅ Validator OK')}catch{console.log('❌ Validator manquant')}"

echo.
echo 4. Test Vitest...
npm list vitest >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Vitest installé
) else (
    echo ❌ Vitest manquant
)

echo.
echo 5. Structure des types...
if exist "src\types\auth" (
    echo ✅ Dossier auth existant
) else (
    echo ❌ Dossier auth manquant
)

if exist "src\lib\auth" (
    echo ✅ Dossier lib/auth existant
) else (
    echo ❌ Dossier lib/auth manquant
)

echo.
echo 6. Test rapide des types...
echo const role = 'USER'; const isValid = ['USER', 'ADMIN'].includes(role); console.log('Type guard OK:', isValid); > test-quick.js
node test-quick.js
del test-quick.js

echo.
echo === TESTS TERMINÉS ===
pause
```

## Commandes de déploiement

### Préparation pour la production

```bash
# Build avec vérification des types
npm run build

# Vérification finale des types
npx tsc --noEmit --strict

# Génération de la documentation des types
npx typedoc

# Tests finaux
npm run test:types

# Vérification de la taille du bundle
npx next build --debug
```

Cette documentation complète des commandes vous permet de configurer, tester et maintenir efficacement tous les types TypeScript avancés pour NextAuth.js dans PhotoMarket.