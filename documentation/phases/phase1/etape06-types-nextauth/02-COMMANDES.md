# Étape 6 : Commandes et Scripts - Types NextAuth.js avancés

## Vue d'ensemble

Ce document liste **TOUTES les commandes** nécessaires pour l'Étape 6 : Types NextAuth.js avancés. Chaque commande est expliquée et contextualisée pour les ultra-débutants.

## Prérequis - Vérifications obligatoires

### Vérifier que l'étape 5 est terminée

```bash
# Vérifier que NextAuth.js est configuré
ls -la src/lib/auth*
ls -la src/app/api/auth/
ls -la src/app/auth/
ls -la src/components/auth/

# Doit afficher :
# src/lib/auth-config.ts
# src/lib/auth.ts  
# src/lib/password.ts
# src/app/api/auth/[...nextauth]/
# src/app/auth/signin/
# src/app/auth/signup/
# src/app/auth/error/
# src/components/auth/signin-form.tsx
# src/components/auth/signup-form.tsx
```

### Vérifier la configuration TypeScript

```bash
# Vérifier que TypeScript est configuré
cat tsconfig.json | grep -A 5 -B 5 "strict"

# Vérifier les types NextAuth existants
ls -la src/types/
cat src/types/next-auth.d.ts

# Si le dossier types n'existe pas :
mkdir -p src/types
```

## Installation des dépendances

### 1. Installation de Zod (validation de schémas)

```bash
# Installer Zod pour la validation TypeScript
npm install zod

# Installer les types de développement
npm install @types/zod --save-dev

# Vérifier l'installation
npm list zod
# Doit afficher : zod@X.X.X
```

### 2. Installation de validator (validation avancée)

```bash
# Installer validator pour validations email/password avancées
npm install validator

# Installer les types
npm install @types/validator --save-dev

# Vérifier l'installation
npm list validator
# Doit afficher : validator@X.X.X
```

### 3. Installation de vitest (tests TypeScript)

```bash
# Installer vitest pour tester les types
npm install --save-dev vitest @vitest/ui

# Installer les types Node.js pour les tests
npm install --save-dev @types/node

# Vérifier l'installation
npm list vitest
# Doit afficher : vitest@X.X.X
```

## Création de la structure des dossiers

### 1. Créer l'arborescence des types

```bash
# Créer tous les dossiers nécessaires EN UNE SEULE FOIS
mkdir -p src/types/auth
mkdir -p src/types/database  
mkdir -p src/types/api
mkdir -p src/types/utils
mkdir -p src/lib/auth
mkdir -p src/lib/types
mkdir -p src/types/__tests__

# Vérifier la structure créée
find src/types -type d | sort
# Doit afficher :
# src/types
# src/types/__tests__
# src/types/api
# src/types/auth
# src/types/database
# src/types/utils

find src/lib -type d | sort
# Doit afficher :
# src/lib
# src/lib/auth
# src/lib/types
```

### 2. Créer les fichiers vides (préparation)

```bash
# Types d'authentification
touch src/types/auth/index.ts
touch src/types/auth/session.ts
touch src/types/auth/user.ts
touch src/types/auth/providers.ts
touch src/types/auth/callbacks.ts
touch src/types/auth/middleware.ts
touch src/types/auth/forms.ts

# Types de base de données
touch src/types/database/prisma-extended.ts
touch src/types/database/relations.ts

# Types d'API
touch src/types/api/auth-responses.ts
touch src/types/api/errors.ts

# Types utilitaires
touch src/types/utils/branded-types.ts
touch src/types/utils/validation.ts
touch src/types/utils/permissions.ts

# Utilitaires d'authentification
touch src/lib/auth/type-guards.ts
touch src/lib/auth/validators.ts
touch src/lib/auth/permissions-utils.ts

# Helpers de types
touch src/lib/types/type-helpers.ts

# Tests
touch src/types/__tests__/auth-types.test.ts

# Vérifier que tous les fichiers sont créés
find src/types -name "*.ts" | wc -l
# Doit afficher : 13
find src/lib -name "*.ts" | wc -l  
# Doit afficher : 4 (+ les fichiers existants de l'étape 5)
```

## Commandes de développement pour chaque fichier

### 1. Commandes pour src/types/auth/session.ts

```bash
# Ouvrir le fichier pour édition
code src/types/auth/session.ts
# OU avec votre éditeur préféré :
nano src/types/auth/session.ts
# OU 
vim src/types/auth/session.ts

# Après avoir collé le code du README :
# Vérifier la syntaxe TypeScript
npx tsc --noEmit src/types/auth/session.ts

# Si erreur de syntaxe, corriger et retester
npx tsc --noEmit src/types/auth/session.ts
```

### 2. Commandes pour src/types/auth/user.ts

```bash
# Ouvrir et éditer
code src/types/auth/user.ts

# Après édition, vérifier la syntaxe
npx tsc --noEmit src/types/auth/user.ts

# Vérifier les imports (après avoir créé session.ts)
npx tsc --noEmit src/types/auth/user.ts
```

### 3. Commandes pour src/types/auth/providers.ts

```bash
# Ouvrir et éditer
code src/types/auth/providers.ts

# Vérifier la syntaxe
npx tsc --noEmit src/types/auth/providers.ts

# Vérifier que les types NextAuth sont disponibles
npm list next-auth
# Doit afficher : next-auth@X.X.X
```

### 4. Commandes pour src/types/auth/callbacks.ts

```bash
# Ouvrir et éditer
code src/types/auth/callbacks.ts

# Vérifier la syntaxe et les imports
npx tsc --noEmit src/types/auth/callbacks.ts
```

### 5. Commandes pour src/types/auth/middleware.ts

```bash
# Ouvrir et éditer
code src/types/auth/middleware.ts

# Vérifier la syntaxe
npx tsc --noEmit src/types/auth/middleware.ts

# Vérifier que les types Next.js sont disponibles
npm list next
# Doit afficher : next@X.X.X
```

### 6. Commandes pour src/types/auth/forms.ts

```bash
# Ouvrir et éditer
code src/types/auth/forms.ts

# Vérifier la syntaxe
npx tsc --noEmit src/types/auth/forms.ts

# Vérifier que Zod est installé
npm list zod
```

## Commandes pour les utilitaires et validateurs

### 1. Créer src/lib/auth/validators.ts

```bash
# Ouvrir pour édition
code src/lib/auth/validators.ts

# Après création, tester les imports Zod
npx tsc --noEmit src/lib/auth/validators.ts

# Tester validator
node -e "const validator = require('validator'); console.log('Validator installé :', typeof validator.isEmail)"
# Doit afficher : Validator installé : function
```

### 2. Créer src/lib/auth/type-guards.ts

```bash
# Ouvrir pour édition
code src/lib/auth/type-guards.ts

# Vérifier la syntaxe et les imports des types
npx tsc --noEmit src/lib/auth/type-guards.ts
```

### 3. Créer src/lib/auth/permissions-utils.ts

```bash
# Ouvrir pour édition
code src/lib/auth/permissions-utils.ts

# Vérifier la syntaxe
npx tsc --noEmit src/lib/auth/permissions-utils.ts
```

### 4. Créer src/types/utils/branded-types.ts

```bash
# Ouvrir pour édition
code src/types/utils/branded-types.ts

# Vérifier la syntaxe
npx tsc --noEmit src/types/utils/branded-types.ts
```

### 5. Créer l'index principal src/types/auth/index.ts

```bash
# Ouvrir pour édition
code src/types/auth/index.ts

# Après création, vérifier tous les exports
npx tsc --noEmit src/types/auth/index.ts
```

## Configuration TypeScript

### 1. Mettre à jour tsconfig.json

```bash
# Faire une sauvegarde du tsconfig.json actuel
cp tsconfig.json tsconfig.json.backup

# Ouvrir pour édition
code tsconfig.json

# Après modification, valider la configuration
npx tsc --showConfig

# Tester la compilation de tout le projet
npx tsc --noEmit

# Si erreurs, restaurer la sauvegarde et corriger :
# cp tsconfig.json.backup tsconfig.json
```

### 2. Vérifier les chemins d'alias

```bash
# Tester que les alias fonctionnent
npx tsc --noEmit --showConfig | grep -A 10 "paths"

# Doit afficher les chemins configurés :
# "@/*": ["./src/*"]
# "@/types/*": ["./src/types/*"]
# etc.
```

## Configuration des tests

### 1. Créer le fichier de configuration vitest

```bash
# Créer vitest.config.ts
touch vitest.config.ts
code vitest.config.ts

# Coller la configuration :
cat > vitest.config.ts << 'EOF'
import { defineConfig } from 'vitest/config'
import path from 'path'

export default defineConfig({
  test: {
    environment: 'node',
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@/types': path.resolve(__dirname, './src/types'),
      '@/lib': path.resolve(__dirname, './src/lib'),
    },
  },
})
EOF
```

### 2. Créer les tests TypeScript

```bash
# Ouvrir le fichier de test
code src/types/__tests__/auth-types.test.ts

# Après création, exécuter les tests
npx vitest run src/types/__tests__/auth-types.test.ts

# Exécuter tous les tests TypeScript
npx vitest run --typecheck
```

### 3. Ajouter les scripts npm pour les tests

```bash
# Ouvrir package.json
code package.json

# Ajouter ces scripts dans la section "scripts" :
# "test": "vitest",
# "test:run": "vitest run",
# "test:types": "vitest run --typecheck",
# "test:ui": "vitest --ui"

# Tester les nouveaux scripts
npm run test:types
```

## Commandes de vérification et validation

### 1. Validation complète du projet

```bash
# Vérifier que tout compile sans erreur
npx tsc --noEmit

# Vérifier les imports circulaires
npx madge --circular src/

# Si madge n'est pas installé :
npm install -g madge
npx madge --circular src/
```

### 2. Vérification des types spécifiques

```bash
# Tester l'import principal des types auth
node -e "
const types = require('./src/types/auth/index.ts');
console.log('Types auth chargés avec succès');
"

# Vérifier les validateurs Zod
node -e "
const { signInSchema } = require('./src/lib/auth/validators.ts');
console.log('Validateurs Zod chargés avec succès');
"
```

### 3. Tests de performance des types

```bash
# Mesurer le temps de compilation
time npx tsc --noEmit

# Analyser la taille des types générés
npx tsc --noEmit --extendedDiagnostics
```

## Commandes de nettoyage et maintenance

### 1. Nettoyer les fichiers temporaires

```bash
# Supprimer les fichiers de cache TypeScript
rm -rf .tsbuildinfo
rm -rf tsconfig.tsbuildinfo

# Nettoyer le cache npm
npm cache clean --force

# Nettoyer node_modules si problème
rm -rf node_modules
npm install
```

### 2. Réinitialiser en cas de problème

```bash
# Script de réinitialisation complète des types
echo "Suppression des types créés..."
rm -rf src/types/auth/*.ts
rm -rf src/lib/auth/type-guards.ts
rm -rf src/lib/auth/validators.ts
rm -rf src/lib/auth/permissions-utils.ts

echo "Recréation de la structure..."
mkdir -p src/types/auth
touch src/types/auth/index.ts
# ... puis recréer tous les fichiers
```

## Commandes utiles pour le développement

### 1. Surveillance des changements TypeScript

```bash
# Compiler en mode watch (surveillance)
npx tsc --watch --noEmit

# Exécuter les tests en mode watch
npm run test

# Surveiller les types spécifiquement
npx tsc --watch --noEmit src/types/**/*.ts
```

### 2. Génération de documentation des types

```bash
# Installer typedoc pour la documentation
npm install -D typedoc

# Générer la documentation des types
npx typedoc src/types/auth/index.ts --out docs/types

# Servir la documentation localement
npx http-server docs/types
# Aller sur http://localhost:8080
```

### 3. Analyse statique des types

```bash
# Installer ts-unused-exports
npm install -D ts-unused-exports

# Détecter les types non utilisés
npx ts-unused-exports tsconfig.json

# Analyser la complexité des types
npx tsc --noEmit --extendedDiagnostics
```

## Commandes de débogage

### 1. Déboguer les erreurs de types

```bash
# Voir les détails d'une erreur de type
npx tsc --noEmit --pretty

# Voir les types résolus pour un fichier
npx tsc --noEmit --listFiles src/types/auth/session.ts

# Tracer la résolution des modules
npx tsc --noEmit --traceResolution src/types/auth/index.ts
```

### 2. Vérifier les dépendances des types

```bash
# Voir les dépendances d'un type
npx madge src/types/auth/session.ts --image deps.png

# Analyser les imports
npx dependency-cruiser --output-type text src/types/
```

## Commandes de validation finale

### 1. Check-list complète avant de passer à l'étape suivante

```bash
# Script de validation complète
echo "=== VALIDATION ÉTAPE 6 ==="

echo "1. Vérification des fichiers..."
for file in "src/types/auth/session.ts" "src/types/auth/user.ts" "src/lib/auth/validators.ts"; do
  if [ -f "$file" ]; then
    echo "✅ $file"
  else
    echo "❌ $file MANQUANT"
  fi
done

echo "2. Vérification compilation TypeScript..."
if npx tsc --noEmit > /dev/null 2>&1; then
  echo "✅ Compilation TypeScript"
else
  echo "❌ Erreurs de compilation TypeScript"
fi

echo "3. Vérification des tests..."
if npm run test:types > /dev/null 2>&1; then
  echo "✅ Tests TypeScript"
else
  echo "❌ Échec des tests TypeScript"
fi

echo "4. Vérification des dépendances..."
for dep in "zod" "validator" "vitest"; do
  if npm list $dep > /dev/null 2>&1; then
    echo "✅ $dep"
  else
    echo "❌ $dep manquant"
  fi
done

echo "=== FIN VALIDATION ==="
```

### 2. Test d'intégration final

```bash
# Créer un fichier de test d'intégration temporaire
cat > test-integration-etape6.ts << 'EOF'
import type { ExtendedUser, PhotoMarketSession } from './src/types/auth'
import { signInSchema, isValidUserRole } from './src/lib/auth/validators'
import { createPermissionChecker } from './src/lib/auth/permissions-utils'

// Test que tous les types sont correctement chargés
console.log('✅ Types chargés avec succès')

// Test des validateurs
const testData = { email: 'test@example.com', password: 'Test123!' }
const result = signInSchema.safeParse(testData)
console.log('✅ Validateurs Zod fonctionnels:', result.success)

// Test des type guards
console.log('✅ Type guards fonctionnels:', isValidUserRole('USER'))

console.log('🎉 Intégration Étape 6 réussie !')
EOF

# Exécuter le test d'intégration
npx ts-node test-integration-etape6.ts

# Nettoyer le fichier temporaire
rm test-integration-etape6.ts
```

## Commandes d'urgence (en cas de problème)

### 1. Restauration rapide

```bash
# Sauvegarder l'état actuel
tar -czf etape6-backup.tar.gz src/types/ src/lib/auth/ tsconfig.json package.json

# En cas de problème, restaurer :
# tar -xzf etape6-backup.tar.gz
```

### 2. Réinitialisation complète de l'étape 6

```bash
# ATTENTION : Ceci supprime TOUT le travail de l'étape 6
echo "⚠️ RÉINITIALISATION COMPLÈTE ÉTAPE 6"
read -p "Êtes-vous sûr ? (oui/non): " confirm

if [ "$confirm" = "oui" ]; then
  rm -rf src/types/auth/
  rm -rf src/lib/auth/type-guards.ts
  rm -rf src/lib/auth/validators.ts  
  rm -rf src/lib/auth/permissions-utils.ts
  echo "Étape 6 réinitialisée. Recommencez depuis le début."
else
  echo "Réinitialisation annulée."
fi
```

## Résumé des commandes essentielles

**Installation** :
```bash
npm install zod validator
npm install -D @types/zod @types/validator vitest @vitest/ui @types/node
```

**Structure** :
```bash
mkdir -p src/types/auth src/lib/auth src/types/__tests__
```

**Validation** :
```bash
npx tsc --noEmit
npm run test:types
```

**Vérification finale** :
```bash
find src/types -name "*.ts" | wc -l  # Doit être 13+
npx tsc --noEmit                      # Aucune erreur
npm run test:types                    # Tests passent
```

Ces commandes couvrent l'intégralité du processus de l'Étape 6. Exécutez-les dans l'ordre pour une installation sans problème.