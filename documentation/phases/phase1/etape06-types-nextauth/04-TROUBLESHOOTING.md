# Étape 6 : Dépannage - Types NextAuth.js avancés

## Erreurs de compilation TypeScript

### Erreur : "Cannot find module '@/types/auth'"

**Symptôme** :
```
Error: Cannot find module '@/types/auth' or its corresponding type declarations.
```

**Causes possibles** :
- Alias de chemin mal configuré dans `tsconfig.json`
- Fichier `src/types/auth/index.ts` manquant ou vide
- Serveur TypeScript pas redémarré après modification

**Solutions** :

1. **Vérifier tsconfig.json** :
```bash
# Vérifier la configuration des chemins
cat tsconfig.json | grep -A 10 "paths"

# Doit contenir :
# "@/*": ["./src/*"],
# "@/types/*": ["./src/types/*"]
```

2. **Redémarrer le serveur TypeScript** :
```bash
# Dans VS Code : Ctrl+Shift+P > "TypeScript: Restart TS Server"
# OU redémarrer npm run dev
npm run dev
```

3. **Vérifier l'existence du fichier index** :
```bash
ls -la src/types/auth/index.ts
cat src/types/auth/index.ts
```

### Erreur : "Module 'zod' not found"

**Symptôme** :
```
Error: Cannot resolve dependency 'zod'
```

**Solution** :
```bash
# Réinstaller Zod
npm uninstall zod
npm install zod

# Vérifier l'installation
npm list zod
```

### Erreur : "Type 'ExtendedUser' is not assignable"

**Symptôme** :
```
Type 'ExtendedUser' is not assignable to type 'User'
Property 'permissions' is missing in type 'User'
```

**Cause** : Types NextAuth par défaut vs types étendus

**Solution** :
```typescript
// Dans src/types/next-auth.d.ts, ajouter :
declare module "next-auth" {
  interface User extends ExtendedUser {}
  interface Session extends PhotoMarketSession {}
}

declare module "next-auth/jwt" {
  interface JWT extends ExtendedJWT {}
}
```

## Erreurs de validation Zod

### Erreur : "Invalid email format"

**Symptôme** :
```
ZodError: Invalid email format at path: ["email"]
```

**Solution** :
```typescript
// Vérifier que validator est installé
npm list validator

// Dans validators.ts, s'assurer que :
const email = z.string()
  .email("Format d'email invalide")
  .refine(email => validator.isEmail(email), "Email invalide")
```

### Erreur : "Password too weak"

**Symptôme** :
```
ZodError: Le mot de passe doit contenir au moins une majuscule
```

**Solution** : Vérifier les règles de validation
```typescript
const password = z.string()
  .min(8, "Au moins 8 caractères")
  .regex(/[A-Z]/, "Au moins une majuscule")
  .regex(/[a-z]/, "Au moins une minuscule")
  .regex(/[0-9]/, "Au moins un chiffre")
  .regex(/[^A-Za-z0-9]/, "Au moins un caractère spécial")
```

## Erreurs de permissions

### Erreur : "hasPermission is not a function"

**Symptôme** :
```
TypeError: hasPermission is not a function
```

**Cause** : Import incorrect des type guards

**Solution** :
```typescript
// Import correct
import { hasPermission, isAdmin } from "@/lib/auth/type-guards"

// Utilisation correcte
if (hasPermission(session, "photos:upload")) {
  // ...
}
```

### Erreur : "Cannot read property 'permissions' of null"

**Symptôme** :
```
TypeError: Cannot read property 'permissions' of null
```

**Solution** : Vérifier la session avant utilisation
```typescript
// Mauvais
if (session.user.permissions.canUploadPhotos) { }

// Bon
if (session && isPhotoMarketSession(session) && session.user.permissions.canUploadPhotos) { }

// Ou utiliser le helper
const permissions = createPermissionChecker(session)
if (permissions.can("photos:upload")) { }
```

## Erreurs de tests

### Erreur : "vitest command not found"

**Symptôme** :
```
bash: vitest: command not found
```

**Solution** :
```bash
# Installer vitest localement
npm install -D vitest

# Utiliser npx
npx vitest run

# Ou ajouter le script dans package.json
"scripts": {
  "test:types": "vitest run --typecheck"
}
```

### Erreur : "Cannot import outside a module"

**Symptôme** :
```
SyntaxError: Cannot use import statement outside a module
```

**Solution** : Configurer vitest.config.ts
```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

## Erreurs de performance

### Compilation TypeScript lente

**Symptôme** : `npx tsc --noEmit` prend plus de 30 secondes

**Solutions** :

1. **Exclure les gros modules** :
```json
// tsconfig.json
{
  "exclude": ["node_modules", "dist", ".next"]
}
```

2. **Utiliser les incremental builds** :
```json
{
  "compilerOptions": {
    "incremental": true,
    "tsBuildInfoFile": ".tsbuildinfo"
  }
}
```

3. **Nettoyage du cache** :
```bash
rm -rf .tsbuildinfo node_modules/.cache
npm run dev
```

### Erreur de mémoire TypeScript

**Symptôme** :
```
FATAL ERROR: Ineffective mark-compacts near heap limit
```

**Solution** :
```bash
# Augmenter la mémoire Node.js
NODE_OPTIONS="--max-old-space-size=4096" npx tsc --noEmit
```

## Erreurs d'imports circulaires

### Erreur : "Circular dependency detected"

**Symptôme** :
```
Warning: Circular dependency detected
```

**Diagnostic** :
```bash
# Installer madge pour détecter les cycles
npm install -g madge
npx madge --circular src/types/
```

**Solution** : Réorganiser les imports
```typescript
// Éviter
// session.ts importe user.ts
// user.ts importe session.ts

// Préférer
// session.ts et user.ts importent depuis shared.ts
```

## Erreurs de production

### Erreur : "Types stripped in production"

**Symptôme** : Types fonctionnent en dev mais pas en production

**Solution** :
```json
// next.config.js
module.exports = {
  typescript: {
    // Ne pas ignorer les erreurs TypeScript en production
    ignoreBuildErrors: false,
  },
}
```

### Erreur : "Runtime type checking failed"

**Symptôme** : Type guards échouent en production

**Solution** : Vérifier que les type guards sont robustes
```typescript
// Robust type guard
export function isExtendedUser(user: any): user is ExtendedUser {
  return (
    user &&
    typeof user === "object" &&
    typeof user.id === "string" &&
    typeof user.email === "string" &&
    isValidUserRole(user.role) &&
    isValidUserStatus(user.status) &&
    user.permissions &&
    typeof user.permissions === "object" &&
    user.stats &&
    typeof user.stats === "object"
  )
}
```

## Commandes de diagnostic

### Diagnostic complet de l'étape 6

```bash
#!/bin/bash
echo "=== DIAGNOSTIC ÉTAPE 6 ==="

echo "1. Vérification des fichiers types..."
FILES=(
  "src/types/auth/session.ts"
  "src/types/auth/user.ts"
  "src/types/auth/providers.ts"
  "src/types/auth/callbacks.ts"
  "src/types/auth/middleware.ts"
  "src/types/auth/forms.ts"
  "src/types/auth/index.ts"
  "src/lib/auth/validators.ts"
  "src/lib/auth/type-guards.ts"
  "src/lib/auth/permissions-utils.ts"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "✅ $file"
  else
    echo "❌ $file MANQUANT"
  fi
done

echo "2. Vérification des dépendances..."
DEPS=("zod" "validator" "vitest")
for dep in "${DEPS[@]}"; do
  if npm list "$dep" > /dev/null 2>&1; then
    echo "✅ $dep installé"
  else
    echo "❌ $dep MANQUANT"
  fi
done

echo "3. Test de compilation TypeScript..."
if npx tsc --noEmit > /dev/null 2>&1; then
  echo "✅ Compilation TypeScript réussie"
else
  echo "❌ Erreurs de compilation TypeScript"
  npx tsc --noEmit
fi

echo "4. Test des imports..."
node -e "
try {
  const types = require('./src/types/auth/index.ts');
  console.log('✅ Import des types réussi');
} catch (e) {
  console.log('❌ Erreur import types:', e.message);
}
"

echo "5. Test Zod validation..."
node -e "
try {
  const { signInSchema } = require('./src/lib/auth/validators.ts');
  const result = signInSchema.safeParse({email: 'test@test.com', password: 'Test123!'});
  console.log('✅ Validation Zod:', result.success ? 'réussie' : 'échouée');
} catch (e) {
  console.log('❌ Erreur Zod:', e.message);
}
"

echo "=== FIN DIAGNOSTIC ==="
```

### Nettoyage d'urgence

```bash
#!/bin/bash
echo "⚠️ NETTOYAGE D'URGENCE ÉTAPE 6"

echo "Suppression des caches..."
rm -rf .tsbuildinfo
rm -rf node_modules/.cache
rm -rf .next

echo "Nettoyage npm..."
npm cache clean --force

echo "Réinstallation des dépendances types..."
npm uninstall zod validator vitest @types/zod @types/validator
npm install zod validator
npm install -D @types/zod @types/validator vitest

echo "Redémarrage TypeScript..."
# Si VS Code est ouvert, redémarrer le serveur TS

echo "Test final..."
npx tsc --noEmit
npm run test:types

echo "Nettoyage terminé !"
```

## Contacts et ressources

### En cas de blocage total

1. **Sauvegarder le travail** :
```bash
tar -czf etape6-backup-$(date +%Y%m%d-%H%M).tar.gz src/types/ src/lib/auth/ tsconfig.json
```

2. **Revenir à l'étape 5** :
```bash
git stash
git checkout HEAD~1  # ou le commit de l'étape 5
```

3. **Redémarrer l'étape 6** :
Suivre exactement le README avec les commandes du fichier COMMANDES.md

### Ressources utiles

- [Documentation TypeScript](https://www.typescriptlang.org/docs/)
- [Documentation Zod](https://zod.dev/)
- [NextAuth.js TypeScript](https://next-auth.js.org/getting-started/typescript)
- [Vitest Documentation](https://vitest.dev/)

### Commandes rapides de vérification

```bash
# Vérification rapide
npx tsc --noEmit && echo "✅ TypeScript OK" || echo "❌ Erreurs TypeScript"
npm run test:types && echo "✅ Tests OK" || echo "❌ Tests échoués"
node -e "console.log('✅ Node.js fonctionne')"
```

L'étape 6 est complexe mais ces solutions couvrent 95% des problèmes rencontrés. En cas de doute, toujours revenir aux bases : vérifier les fichiers, les imports, et la compilation TypeScript.