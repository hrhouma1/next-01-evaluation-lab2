# Étape 6 : Checklist - Types NextAuth.js avancés

## Checklist d'installation et configuration

### Installation des dépendances TypeScript

- [ ] **Zod installé pour la validation**
```bash
npm list zod
# Doit afficher zod@latest
```

- [ ] **Validator installé pour validations avancées**
```bash
npm list validator @types/validator
# Doit afficher validator@latest et @types/validator
```

- [ ] **Vitest installé pour les tests de types**
```bash
npm list vitest @vitest/ui @types/node
# Doit afficher tous les packages de test
```

- [ ] **TypeScript configuré en mode strict**
  - [ ] `strict: true` dans tsconfig.json
  - [ ] `noUncheckedIndexedAccess: true`
  - [ ] `exactOptionalPropertyTypes: true`
  - [ ] `noImplicitReturns: true`
  - [ ] `noFallthroughCasesInSwitch: true`

### Structure des fichiers de types créée

- [ ] **Dossiers de types créés**
  - [ ] `src/types/auth/` (types d'authentification)
  - [ ] `src/types/database/` (types de base de données)
  - [ ] `src/types/api/` (types de réponses API)
  - [ ] `src/types/utils/` (types utilitaires)
  - [ ] `src/lib/auth/` (logique d'authentification)
  - [ ] `src/lib/types/` (helpers de types)
  - [ ] `src/types/__tests__/` (tests de types)

- [ ] **Fichiers de types d'authentification**
  - [ ] `src/types/auth/index.ts` (export principal)
  - [ ] `src/types/auth/session.ts` (types de session)
  - [ ] `src/types/auth/user.ts` (types utilisateur)
  - [ ] `src/types/auth/providers.ts` (types OAuth)
  - [ ] `src/types/auth/callbacks.ts` (types callbacks)
  - [ ] `src/types/auth/middleware.ts` (types middleware)
  - [ ] `src/types/auth/forms.ts` (types formulaires)

- [ ] **Fichiers utilitaires**
  - [ ] `src/types/utils/branded-types.ts` (types nominaux)
  - [ ] `src/lib/auth/validators.ts` (validateurs Zod)
  - [ ] `src/lib/auth/type-guards.ts` (guards de types)
  - [ ] `src/lib/auth/permissions-utils.ts` (utilitaires permissions)

## Checklist des types de base

### Types de session PhotoMarket

- [ ] **Interface ExtendedUser définie**
  - [ ] Propriétés de base (id, email, name, role, status)
  - [ ] Propriétés étendues (preferences, stats, permissions)
  - [ ] Types stricts pour role et status
  - [ ] Interface de permissions granulaires

- [ ] **Interface PhotoMarketSession définie**
  - [ ] Extension de NextAuthSession
  - [ ] User de type ExtendedUser
  - [ ] Propriétés supplémentaires (accessToken, expiresAt)
  - [ ] Types cohérents avec NextAuth.js

- [ ] **Interface ExtendedJWT définie**
  - [ ] Extension du JWT NextAuth
  - [ ] Inclusion des permissions et stats
  - [ ] Propriétés de tracking (lastActivity, sessionId)
  - [ ] Types compatibles avec les callbacks

### Types utilisateur avancés

- [ ] **Types de base utilisateur**
  - [ ] UserId comme branded type
  - [ ] Email comme branded type avec validation
  - [ ] HashedPassword comme branded type
  - [ ] UserRole comme union type strict

- [ ] **Interfaces de gestion utilisateur**
  - [ ] CreateUserInput pour création
  - [ ] UpdateUserInput pour mise à jour
  - [ ] AdminUpdateUserInput pour admin
  - [ ] UserSearchFilters pour recherche

- [ ] **Types de profil et statistiques**
  - [ ] PublicUserProfile pour affichage public
  - [ ] PrivateUserProfile pour données sensibles
  - [ ] UserStatistics pour analytics
  - [ ] UserPreferences pour personnalisation

### Types OAuth et providers

- [ ] **Configuration des providers**
  - [ ] OAuthProvider comme union type
  - [ ] ExtendedOAuthConfig pour configuration
  - [ ] Interfaces de profil par provider (Google, GitHub, Facebook)
  - [ ] Types de tokens OAuth

- [ ] **Gestion des erreurs OAuth**
  - [ ] OAuthError comme union type
  - [ ] OAuthErrorResponse interface
  - [ ] Types de callbacks OAuth
  - [ ] ProfileMappers pour chaque provider

## Checklist de validation avec Zod

### Schémas de validation de base

- [ ] **Validateurs de champs individuels**
  - [ ] Email avec transformation et validation
  - [ ] Password avec règles de sécurité
  - [ ] Name avec regex et normalisation
  - [ ] UserRole et UserStatus validation

- [ ] **Schémas de formulaires**
  - [ ] signInSchema pour connexion
  - [ ] signUpSchema pour inscription avec confirmation
  - [ ] forgotPasswordSchema pour reset
  - [ ] resetPasswordSchema pour nouveau mot de passe
  - [ ] profileSchema pour profil utilisateur

- [ ] **Schémas d'API**
  - [ ] updateUserSchema pour mise à jour
  - [ ] adminUpdateUserSchema pour admin
  - [ ] Validation des paramètres de recherche
  - [ ] Validation des filtres et tri

### Types inférés des schémas

- [ ] **Types de données formulaire**
```typescript
type SignInData = z.infer<typeof signInSchema>
type SignUpData = z.infer<typeof signUpSchema>
// Etc.
```

- [ ] **Validation runtime fonctionnelle**
```bash
node -e "const{z}=require('zod');const schema=z.string().email();console.log('Email valid:',schema.safeParse('test@test.com').success)"
```

## Checklist des type guards

### Guards de validation runtime

- [ ] **Guards de types de base**
```typescript
isValidUserRole(role: string): role is UserRole
isValidUserStatus(status: string): status is UserStatus
isValidOAuthProvider(provider: string): provider is OAuthProvider
```

- [ ] **Guards d'objets complexes**
```typescript
isExtendedUser(user: any): user is ExtendedUser
isPhotoMarketSession(session: any): session is PhotoMarketSession
isExtendedJWT(token: any): token is ExtendedJWT
```

- [ ] **Guards de permissions**
```typescript
hasPermission(session: PhotoMarketSession | null, permission: Permission): boolean
hasRole(session: PhotoMarketSession | null, role: UserRole): boolean
isAdmin(session: PhotoMarketSession | null): boolean
```

### Tests des type guards

- [ ] **Test validation des rôles**
```bash
node -e "function isValidUserRole(r){return['USER','ADMIN'].includes(r)};console.log('USER valid:',isValidUserRole('USER'));console.log('INVALID invalid:',!isValidUserRole('INVALID'))"
```

- [ ] **Test validation des objets**
```bash
# Test qu'un objet ExtendedUser valide est reconnu
# Test qu'un objet invalide est rejeté
```

## Checklist du système de permissions

### Configuration des permissions

- [ ] **Permission comme union type définie**
```typescript
type Permission = 
  | "photos:upload"
  | "photos:purchase" 
  | "users:manage"
  | "admin:access"
  // etc.
```

- [ ] **Interface de vérification des permissions**
```typescript
interface PermissionCheck {
  hasPermission(session: PhotoMarketSession, permission: Permission): boolean
  hasRole(session: PhotoMarketSession, role: UserRole): boolean
  hasAnyPermission(session: PhotoMarketSession, permissions: Permission[]): boolean
}
```

- [ ] **Calcul automatique des permissions**
```typescript
calculateUserPermissions(role: UserRole, status: UserStatus): ExtendedUser["permissions"]
```

### PermissionChecker classe

- [ ] **Classe PermissionChecker implémentée**
  - [ ] Méthodes can(), canAny(), canAll()
  - [ ] Méthodes spécifiques au domaine (canUploadPhoto, canPurchasePhoto)
  - [ ] Logique de validation contextuelle
  - [ ] Factory createPermissionChecker()

- [ ] **Hook usePermissions React**
```typescript
export function usePermissions(): PermissionChecker
```

- [ ] **Décorateurs de permissions**
```typescript
@requirePermission(permission: Permission)
@requireRole(role: UserRole)
```

### Tests du système de permissions

- [ ] **Test permissions utilisateur normal**
```bash
# USER peut uploader et acheter
# USER ne peut pas administrer
```

- [ ] **Test permissions administrateur**
```bash
# ADMIN peut tout faire
# ADMIN a accès aux fonctions d'administration
```

- [ ] **Test utilisateur suspendu**
```bash
# SUSPENDED n'a aucune permission active
```

## Checklist des branded types

### Types nominaux de sécurité

- [ ] **Branded types principaux définis**
```typescript
type UserId = Brand<string, "UserId">
type PhotoId = Brand<string, "PhotoId">
type Email = Brand<string, "Email">
type Amount = Brand<number, "Amount">
type Price = Brand<number, "Price">
```

- [ ] **Fonctions de création typées**
```typescript
createUserId(id: string): UserId
createEmail(email: string): Email
createAmount(amount: number): Amount
createPrice(price: number): Price
```

- [ ] **Validation dans les fonctions de création**
  - [ ] createUserId rejette les chaînes vides
  - [ ] createEmail valide le format email
  - [ ] createAmount rejette les montants négatifs
  - [ ] createPrice rejette les prix <= 0

- [ ] **Fonctions d'extraction**
```typescript
unwrapUserId(userId: UserId): string
unwrapEmail(email: Email): string
unwrapAmount(amount: Amount): number
```

### Tests des branded types

- [ ] **Test création valide**
```bash
node -e "function createUserId(id){if(!id)throw new Error('Invalid');return id;}console.log('✅ UserId:',createUserId('user123'))"
```

- [ ] **Test rejet valeurs invalides**
```bash
node -e "function createAmount(a){if(a<0)throw new Error('Negative');return a;}try{createAmount(-5);console.log('❌')}catch{console.log('✅ Negative rejected')}"
```

## Checklist des types de formulaires

### Interfaces de formulaires

- [ ] **Types de données de formulaire**
  - [ ] SignInFormData avec callbackUrl optionnel
  - [ ] SignUpFormData avec confirmation de mot de passe
  - [ ] ForgotPasswordFormData minimal
  - [ ] ResetPasswordFormData avec token
  - [ ] ProfileFormData avec préférences

- [ ] **Types d'état de formulaire**
  - [ ] SignInFormState avec erreurs et loading
  - [ ] SignUpFormState avec validation
  - [ ] États de soumission avec isLoading, isValid
  - [ ] États de champs avec isDirty

- [ ] **Types de validation de champs**
```typescript
interface FieldValidator<T> {
  validate: (value: T) => string[] | null
  isRequired?: boolean
  debounceMs?: number
}
```

### Hooks de formulaires typés

- [ ] **Interface UseFormOptions**
```typescript
interface UseFormOptions<T> {
  initialData: T
  validators?: Partial<Record<keyof T, FieldValidator<any>>>
  onSubmit: (data: T) => Promise<void>
}
```

- [ ] **Return type UseFormReturn**
```typescript
interface UseFormReturn<T> {
  data: T
  errors: Record<keyof T, string[]>
  isLoading: boolean
  handleChange: (field: keyof T, value: any) => void
  handleSubmit: (e: React.FormEvent) => Promise<void>
}
```

### Validation asynchrone

- [ ] **AsyncValidationResult interface**
```typescript
interface AsyncValidationResult {
  isValid: boolean
  errors: string[]
  suggestions?: string[]
}
```

- [ ] **AsyncValidators pour vérifications serveur**
  - [ ] checkEmailAvailability
  - [ ] validatePasswordStrength
  - [ ] verifyResetToken

## Checklist des types de middleware

### Configuration du middleware

- [ ] **MiddlewareConfig interface complète**
  - [ ] protectedRoutes avec permissions requises
  - [ ] adminRoutes avec niveaux d'administration
  - [ ] redirects avec conditions
  - [ ] rateLimit avec configuration

- [ ] **Types de routes protégées**
```typescript
interface ProtectedRoute {
  path: string
  requiredRole?: UserRole
  requiredPermissions?: Permission[]
  customCheck?: (session: PhotoMarketSession) => boolean
}
```

- [ ] **Types de résultats middleware**
```typescript
type MiddlewareResult = 
  | { type: "allow" }
  | { type: "redirect"; url: string }
  | { type: "forbidden"; reason: string }
  | { type: "unauthorized"; redirectTo: string }
```

### Context et audit

- [ ] **MiddlewareContext complet**
  - [ ] request, session, device, geolocation
  - [ ] rateLimitData avec limites
  - [ ] Types de device et geolocation

- [ ] **MiddlewareAuditLog pour traçabilité**
  - [ ] timestamp, path, userId, action
  - [ ] reason, ip, userAgent
  - [ ] Types d'actions strictes

### Hooks du middleware

- [ ] **MiddlewareHooks interface**
```typescript
interface MiddlewareHooks {
  beforeAuth?: (req: NextRequest) => Promise<void>
  afterAuth?: (req: NextRequest, session: MiddlewareSession | null) => Promise<void>
  onForbidden?: (req: NextRequest, reason: string) => Promise<void>
}
```

## Checklist des tests TypeScript

### Configuration des tests

- [ ] **Vitest configuré pour TypeScript**
  - [ ] vite.config.ts avec configuration test
  - [ ] Scripts package.json pour tests
  - [ ] Alias de chemins configurés (@/types, @/lib)

- [ ] **Tests de types de base**
```typescript
expectTypeOf<UserRole>().toEqualTypeOf<"USER" | "ADMIN">()
expectTypeOf<ExtendedUser>().toHaveProperty("role").toEqualTypeOf<UserRole>()
```

- [ ] **Tests de validation runtime**
```typescript
expect(isValidUserRole("USER")).toBe(true)
expect(isValidUserRole("INVALID")).toBe(false)
expect(isExtendedUser(validUserObject)).toBe(true)
```

### Tests des schémas Zod

- [ ] **Tests de validation réussie**
```typescript
expect(signInSchema.safeParse(validSignInData).success).toBe(true)
expect(signUpSchema.safeParse(validSignUpData).success).toBe(true)
```

- [ ] **Tests de validation échouée**
```typescript
expect(signInSchema.safeParse(invalidSignInData).success).toBe(false)
expect(passwordSchema.safeParse("weak").success).toBe(false)
```

### Exécution des tests

- [ ] **Tests passent en mode run**
```bash
npm run test:types
# Tous les tests doivent passer
```

- [ ] **Tests passent en mode watch**
```bash
npm run test:types:watch
# Doit surveiller les changements
```

- [ ] **Interface de test fonctionne**
```bash
npm run test:types:ui
# Doit ouvrir l'interface web
```

## Checklist de qualité et performance

### Configuration ESLint TypeScript

- [ ] **ESLint configuré avec règles TypeScript**
  - [ ] @typescript-eslint/parser installé
  - [ ] @typescript-eslint/eslint-plugin installé
  - [ ] Règles strictes activées
  - [ ] Projet tsconfig.json référencé

- [ ] **Règles de qualité configurées**
  - [ ] no-unused-vars pour TypeScript
  - [ ] no-explicit-any en warning
  - [ ] explicit-function-return-type en warning
  - [ ] prefer-nullish-coalescing en erreur

- [ ] **Analyse ESLint sans erreurs**
```bash
npx eslint src/types/**/*.ts src/lib/**/*.ts
# Aucune erreur critique
```

### Documentation des types

- [ ] **TypeDoc configuré**
  - [ ] typedoc.json avec configuration
  - [ ] Entry points sur les index principaux
  - [ ] Plugin markdown si nécessaire

- [ ] **Documentation générée**
```bash
npx typedoc
ls docs/types/
# Documentation HTML/Markdown générée
```

### Performance de compilation

- [ ] **Compilation TypeScript rapide**
```bash
time npx tsc --noEmit
# Doit compiler en moins de 10 secondes
```

- [ ] **Build Next.js réussi**
```bash
npm run build
# Build doit réussir avec les nouveaux types
```

## Checklist d'intégration

### Intégration avec NextAuth.js existant

- [ ] **Types NextAuth étendus correctement**
  - [ ] src/types/next-auth.d.ts mis à jour
  - [ ] Session interface étendue
  - [ ] User interface étendue
  - [ ] JWT interface étendue

- [ ] **Callbacks NextAuth typés**
  - [ ] jwt callback avec ExtendedJWT
  - [ ] session callback avec PhotoMarketSession
  - [ ] Tous les callbacks typés correctement

- [ ] **Middleware NextAuth typé**
  - [ ] auth() function avec types corrects
  - [ ] MiddlewareContext utilisé
  - [ ] Protection des routes typée

### Intégration avec Prisma

- [ ] **Types Prisma étendus**
  - [ ] ExtendedUser compatible avec Prisma User
  - [ ] Relations typées correctement
  - [ ] Énumérations synchronisées

- [ ] **Requêtes Prisma typées**
  - [ ] findUnique avec types corrects
  - [ ] create/update avec validation
  - [ ] Relations incluses typées

### Intégration avec React

- [ ] **Hooks personnalisés typés**
```typescript
const { session, permissions } = usePhotoMarketAuth()
// session est de type PhotoMarketSession | null
// permissions est de type PermissionChecker
```

- [ ] **Composants React typés**
```tsx
interface UserProfileProps {
  user: ExtendedUser
  onUpdate: (data: UpdateUserData) => Promise<void>
}
```

## Validation finale

### Tests d'intégration complets

- [ ] **Test 1 : Compilation complète sans erreurs**
```bash
npx tsc --noEmit --strict
# Aucune erreur TypeScript
```

- [ ] **Test 2 : Tous les tests unitaires passent**
```bash
npm run test:types
# 100% de réussite
```

- [ ] **Test 3 : Build Next.js réussi**
```bash
npm run build
# Build complet sans erreurs de types
```

- [ ] **Test 4 : ESLint sans erreurs critiques**
```bash
npx eslint src/types/**/*.ts src/lib/**/*.ts --max-warnings 0
# Aucune erreur critique
```

### Tests de validation runtime

- [ ] **Test validation des données utilisateur**
```bash
node -e "
const user = { id: 'test', email: 'test@test.com', role: 'USER', status: 'ACTIVE', permissions: {}, stats: {} };
console.log('Valid user:', typeof user.id === 'string' && user.email.includes('@'));
"
```

- [ ] **Test système de permissions**
```bash
node -e "
function hasPermission(session, perm) { return session?.user?.permissions?.[perm] || false; }
const session = { user: { permissions: { canUploadPhotos: true } } };
console.log('Permission check:', hasPermission(session, 'canUploadPhotos'));
"
```

### Critères de réussite

✅ **L'étape 6 est RÉUSSIE si :**

1. **Installation complète** : Zod, Validator, Vitest installés et configurés
2. **Structure de types** : Tous les fichiers de types créés et organisés
3. **Types de base** : ExtendedUser, PhotoMarketSession, ExtendedJWT définis
4. **Validation Zod** : Schémas de validation fonctionnels avec types inférés
5. **Type guards** : Validation runtime des types fonctionnelle
6. **Branded types** : Types nominaux sécurisés implémentés
7. **Système de permissions** : PermissionChecker et utilitaires fonctionnels
8. **Tests TypeScript** : Suite de tests complète qui passe
9. **Intégration** : Types compatibles avec NextAuth.js, Prisma et React
10. **Qualité** : ESLint configuré, documentation générée, build réussi

### Validation finale avec script

```bash
# Script de validation finale complet
node -e "
console.log('=== VALIDATION FINALE ÉTAPE 6 ===');

const tests = [
  { name: 'TypeScript strict compilation', cmd: 'npx tsc --noEmit --strict' },
  { name: 'Tests de types', cmd: 'npm run test:types' },
  { name: 'ESLint sans erreurs', cmd: 'npx eslint src/types --max-warnings 0' },
  { name: 'Build Next.js', cmd: 'npm run build' }
];

console.log('Tests à exécuter manuellement:');
tests.forEach((test, i) => {
  console.log(\`\${i+1}. \${test.name}: \${test.cmd}\`);
});

console.log('\\n✅ Si tous les tests passent, l\\'étape 6 est TERMINÉE !');
"
```

## Prêt pour l'étape suivante

- [ ] **Étape 7 préparée** : Types TypeScript avancés pour toute l'application
  - [ ] Types NextAuth.js maîtrisés et fonctionnels
  - [ ] Système de validation Zod opérationnel
  - [ ] Branded types et type guards en place
  - [ ] Système de permissions typé et testé

Une fois cette checklist complètement validée, vous pouvez passer à l'**Étape 7 : Types TypeScript avancés pour l'application** en toute confiance !

## Annexe 1 : Checklist PowerShell (Windows)

### Validation PowerShell

```powershell
# Fonction de validation complète
function Test-TypeScriptStep6 {
    Write-Host "=== VALIDATION ÉTAPE 6 POWERSHELL ===" -ForegroundColor Blue
    
    # Test compilation TypeScript
    Write-Host "1. Test compilation TypeScript..." -ForegroundColor Yellow
    try {
        $result = npx tsc --noEmit --strict 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Compilation TypeScript OK" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Erreurs de compilation" -ForegroundColor Red
            Write-Host $result -ForegroundColor Gray
        }
    } catch {
        Write-Host "   ❌ Erreur: $_" -ForegroundColor Red
    }
    
    # Test structure des fichiers
    Write-Host "`n2. Test structure des fichiers..." -ForegroundColor Yellow
    $requiredFiles = @(
        "src\types\auth\index.ts",
        "src\types\auth\session.ts",
        "src\types\auth\user.ts",
        "src\lib\auth\validators.ts",
        "src\lib\auth\type-guards.ts"
    )
    
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Host "   ✅ $file" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $file manquant" -ForegroundColor Red
        }
    }
    
    # Test dépendances
    Write-Host "`n3. Test dépendances..." -ForegroundColor Yellow
    $deps = @("zod", "validator", "vitest")
    foreach ($dep in $deps) {
        try {
            $version = npm list $dep --depth=0 2>$null
            if ($version) {
                Write-Host "   ✅ $dep installé" -ForegroundColor Green
            } else {
                Write-Host "   ❌ $dep manquant" -ForegroundColor Red
            }
        } catch {
            Write-Host "   ❌ Erreur vérification $dep" -ForegroundColor Red
        }
    }
}
```

## Annexe 2 : Checklist CMD (Command Prompt)

### Script de validation CMD

```cmd
REM validate-step6.bat
@echo off
echo === VALIDATION ÉTAPE 6 CMD ===

echo 1. Test compilation TypeScript...
npx tsc --noEmit --strict >nul 2>&1
if %errorlevel% == 0 (
    echo    ✅ Compilation TypeScript OK
) else (
    echo    ❌ Erreurs de compilation TypeScript
)

echo.
echo 2. Test fichiers de types...
if exist "src\types\auth\index.ts" (
    echo    ✅ index.ts présent
) else (
    echo    ❌ index.ts manquant
)

if exist "src\types\auth\session.ts" (
    echo    ✅ session.ts présent
) else (
    echo    ❌ session.ts manquant
)

if exist "src\lib\auth\validators.ts" (
    echo    ✅ validators.ts présent
) else (
    echo    ❌ validators.ts manquant
)

echo.
echo 3. Test dépendances...
npm list zod >nul 2>&1
if %errorlevel% == 0 (
    echo    ✅ Zod installé
) else (
    echo    ❌ Zod manquant
)

npm list vitest >nul 2>&1
if %errorlevel% == 0 (
    echo    ✅ Vitest installé
) else (
    echo    ❌ Vitest manquant
)

echo.
echo 4. Test build...
npm run build >nul 2>&1
if %errorlevel% == 0 (
    echo    ✅ Build réussi
) else (
    echo    ❌ Erreurs de build
)

echo.
echo === VALIDATION TERMINÉE ===
echo Si tous les tests sont ✅, l'étape 6 est RÉUSSIE !
pause
```

Cette checklist exhaustive garantit une configuration TypeScript avancée parfaitement fonctionnelle pour NextAuth.js dans PhotoMarket !