# Dépannage - Étape 2 : Configuration Prisma + Neon PostgreSQL

## Problèmes fréquents et solutions

### 1. Erreurs d'installation Prisma

#### Problème : "npm ERR! Could not resolve dependency"

**Cause** : Conflit de versions ou cache npm corrompu

**Solution** :
```bash
# Nettoyer le cache npm
npm cache clean --force

# Supprimer node_modules et package-lock.json
rm -rf node_modules
rm package-lock.json

# Réinstaller
npm install

# Installer Prisma spécifiquement
npm install prisma @prisma/client
npm install -D prisma
```

#### Problème : "npx prisma init failed"

**Cause** : Permissions insuffisantes ou projet déjà initialisé

**Solution** :
```bash
# Vérifier les permissions
ls -la

# Supprimer les fichiers Prisma existants si nécessaire
rm -rf prisma/
rm .env

# Réinitialiser
npx prisma init

# Windows PowerShell
Remove-Item -Recurse -Force prisma -ErrorAction SilentlyContinue
Remove-Item .env -ErrorAction SilentlyContinue
npx prisma init
```

### 2. Erreurs de connexion Neon

#### Problème : "Can't reach database server"

**Symptômes** :
- `npx prisma db pull` échoue
- Timeout lors de la connexion
- Erreur "ENOTFOUND" ou "ETIMEDOUT"

**Solutions** :

**Solution A : Vérifier l'URL de connexion**
```bash
# Vérifier le format de l'URL
echo $DATABASE_URL

# L'URL doit ressembler à :
# postgresql://username:password@ep-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require
```

**Solution B : Régénérer la chaîne de connexion**
1. Aller sur le dashboard Neon
2. Sélectionner votre projet
3. Onglet "Connection string"
4. Copier la nouvelle chaîne
5. Remplacer dans `.env`

**Solution C : Vérifier le statut de la base**
```bash
# Tester avec curl
curl -I https://console.neon.tech

# Vérifier le ping vers l'host Neon
ping ep-your-endpoint.us-east-1.aws.neon.tech
```

#### Problème : "SSL connection required"

**Symptômes** :
- Erreur "SSL required"
- Connexion refusée sans SSL

**Solution** :
```bash
# Ajouter le paramètre SSL à l'URL
DATABASE_URL="postgresql://user:pass@host/db?sslmode=require"

# Ou version complète
DATABASE_URL="postgresql://user:pass@host/db?sslmode=require&connect_timeout=10"
```

#### Problème : "Database neondb does not exist"

**Cause** : Nom de base de données incorrect dans l'URL

**Solution** :
1. Vérifier le nom de la base dans le dashboard Neon
2. Modifier l'URL avec le bon nom :
```env
# Remplacer 'neondb' par le vrai nom
DATABASE_URL="postgresql://user:pass@host/VRAI_NOM_DB?sslmode=require"
```

### 3. Erreurs de variables d'environnement

#### Problème : "Environment variable not found: DATABASE_URL"

**Cause** : Fichier `.env` non lu ou mal placé

**Solutions** :

**Solution A : Vérifier l'emplacement**
```bash
# Le fichier .env doit être à la racine du projet
ls -la .env

# Structure correcte :
# photo-marketplace/
# ├── .env          ← ICI
# ├── package.json
# └── prisma/
```

**Solution B : Vérifier le contenu**
```bash
# Voir le contenu sans afficher les valeurs sensibles
grep "DATABASE_URL" .env

# Résultat attendu :
# DATABASE_URL="postgresql://..."
```

**Solution C : Redémarrer le processus**
```bash
# Arrêter tous les processus Node.js
taskkill /f /im node.exe  # Windows
pkill node                # Linux/macOS

# Redémarrer
npm run dev
```

#### Problème : "Invalid DATABASE_URL"

**Cause** : Format d'URL incorrect

**Format correct** :
```env
DATABASE_URL="postgresql://username:password@hostname:port/database?sslmode=require"
```

**Exemples de corrections** :
```bash
# Incorrect
DATABASE_URL=postgresql://user:pass@host/db

# Correct
DATABASE_URL="postgresql://user:pass@host/db?sslmode=require"

# Incorrect (manque les guillemets)
DATABASE_URL=postgresql://user:pass@host/db?sslmode=require

# Correct
DATABASE_URL="postgresql://user:pass@host/db?sslmode=require"
```

### 4. Erreurs de génération Prisma

#### Problème : "npx prisma generate failed"

**Symptômes** :
- Erreur lors de la génération du client
- Types TypeScript manquants
- Import `@prisma/client` échoue

**Solutions** :

**Solution A : Nettoyer et régénérer**
```bash
# Supprimer le client généré
rm -rf node_modules/.prisma
rm -rf node_modules/@prisma

# Réinstaller
npm install @prisma/client

# Régénérer
npx prisma generate
```

**Solution B : Vérifier le schéma**
```bash
# Vérifier la syntaxe du schéma
npx prisma validate

# Voir le contenu
cat prisma/schema.prisma
```

**Solution C : Version de Node.js**
```bash
# Vérifier la version (doit être >= 16)
node --version

# Si trop ancienne, mettre à jour Node.js
```

#### Problème : "Cannot find module '@prisma/client'"

**Cause** : Client non généré ou mal installé

**Solution complète** :
```bash
# 1. Vérifier l'installation
npm list @prisma/client

# 2. Si non installé
npm install @prisma/client

# 3. Générer le client
npx prisma generate

# 4. Vérifier la génération
ls -la node_modules/.prisma/

# 5. Test d'import
node -e "console.log(require('@prisma/client'))"
```

### 5. Erreurs de configuration TypeScript

#### Problème : Types Prisma non reconnus

**Symptômes** :
- Erreurs TypeScript sur `PrismaClient`
- Auto-complétion manquante
- Erreurs dans `src/lib/prisma.ts`

**Solution** :
```bash
# 1. Régénérer les types
npx prisma generate

# 2. Redémarrer TypeScript dans l'IDE
# VS Code : Ctrl+Shift+P > "TypeScript: Restart TS Server"

# 3. Vérifier tsconfig.json
cat tsconfig.json

# 4. Forcer la compilation
npx tsc --noEmit
```

#### Problème : "Module not found" pour `src/lib/prisma`

**Cause** : Fichier `prisma.ts` mal configuré ou imports incorrects

**Vérifier le fichier `src/lib/prisma.ts`** :
```typescript
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

**Test d'import** :
```bash
node -e "
try {
  const { prisma } = require('./src/lib/prisma.ts');
  console.log('Import réussi');
} catch (err) {
  console.error('Erreur import:', err.message);
}
"
```

### 6. Problèmes spécifiques Neon

#### Problème : "Database connection pool exhausted"

**Cause** : Trop de connexions simultanées (limite Neon plan gratuit)

**Solution** :
```typescript
// Dans src/lib/prisma.ts
export const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
})

// Fermer les connexions explicitement
process.on('beforeExit', async () => {
  await prisma.$disconnect()
})
```

#### Problème : "Database suspended" (Neon)

**Cause** : Base de données mise en veille (plan gratuit)

**Solution** :
1. Aller sur le dashboard Neon
2. Cliquer sur "Wake up" ou attendre la reconnexion automatique
3. Relancer la commande après quelques secondes

#### Problème : "Quota exceeded" (Neon)

**Cause** : Limites du plan gratuit dépassées

**Solutions** :
- Vérifier l'usage dans le dashboard Neon
- Nettoyer les données de test inutiles
- Optimiser les requêtes
- Considérer un upgrade de plan

### 7. Erreurs réseau et connectivité

#### Problème : Timeout de connexion

**Symptômes** :
- `npx prisma db pull` très lent puis timeout
- Connexions intermittentes

**Solutions** :

**Solution A : Augmenter le timeout**
```env
DATABASE_URL="postgresql://user:pass@host/db?sslmode=require&connect_timeout=60"
```

**Solution B : Vérifier le réseau**
```bash
# Test de connectivité
ping google.com

# Test DNS
nslookup ep-your-endpoint.us-east-1.aws.neon.tech

# Test port PostgreSQL
telnet ep-your-endpoint.us-east-1.aws.neon.tech 5432
```

**Solution C : Firewall/VPN**
- Vérifier les règles de firewall
- Tester sans VPN si applicable
- Vérifier les proxy d'entreprise

### 8. Erreurs de permissions

#### Problème : "Permission denied" lors de l'écriture

**Cause** : Permissions insuffisantes sur les fichiers/dossiers

**Solution Linux/macOS** :
```bash
# Vérifier les permissions
ls -la

# Ajuster les permissions
chmod 755 .
chmod 644 .env
chmod -R 755 prisma/

# Si nécessaire, changer le propriétaire
sudo chown -R $USER:$USER .
```

**Solution Windows** :
```powershell
# Vérifier les permissions
Get-Acl .

# Exécuter PowerShell en tant qu'administrateur si nécessaire
```

### 9. Diagnostic complet

#### Script de diagnostic automatique

**Créer `diagnostic.js`** :
```javascript
const fs = require('fs')
const { exec } = require('child_process')

console.log('=== DIAGNOSTIC PRISMA + NEON ===\n')

// 1. Vérifier les fichiers
console.log('1. Fichiers:')
console.log('   .env existe:', fs.existsSync('.env'))
console.log('   prisma/schema.prisma existe:', fs.existsSync('prisma/schema.prisma'))
console.log('   src/lib/prisma.ts existe:', fs.existsSync('src/lib/prisma.ts'))

// 2. Variables d'environnement
console.log('\n2. Variables d\'environnement:')
console.log('   DATABASE_URL définie:', !!process.env.DATABASE_URL)
console.log('   NEXTAUTH_SECRET définie:', !!process.env.NEXTAUTH_SECRET)

// 3. Packages npm
console.log('\n3. Packages installés:')
exec('npm list prisma @prisma/client --depth=0', (err, stdout, stderr) => {
  if (err) {
    console.log('   Erreur:', err.message)
  } else {
    console.log(stdout)
  }
})

// 4. Test de connexion
console.log('\n4. Test de connexion:')
try {
  const { PrismaClient } = require('@prisma/client')
  const prisma = new PrismaClient()
  
  prisma.$connect()
    .then(() => {
      console.log('   ✅ Connexion Prisma réussie')
      return prisma.$queryRaw`SELECT NOW() as time`
    })
    .then(result => {
      console.log('   ✅ Requête test réussie:', result[0].time)
    })
    .catch(err => {
      console.log('   ❌ Erreur connexion:', err.message)
    })
    .finally(() => {
      prisma.$disconnect()
    })
} catch (err) {
  console.log('   ❌ Erreur import Prisma:', err.message)
}
```

**Exécution** :
```bash
node diagnostic.js
rm diagnostic.js
```

### 10. Solutions d'urgence

#### Reset complet de la configuration

```bash
# 1. Sauvegarder .env
cp .env .env.backup

# 2. Nettoyer complètement
rm -rf node_modules
rm -rf prisma
rm -rf .next
rm package-lock.json
rm .env

# 3. Réinstaller depuis zéro
npm install
npm install prisma @prisma/client
npm install -D prisma

# 4. Réinitialiser Prisma
npx prisma init

# 5. Restaurer .env
cp .env.backup .env

# 6. Régénérer
npx prisma generate
```

#### Alternative avec Docker (si disponible)

```bash
# Tester avec PostgreSQL local
docker run --name postgres-test -e POSTGRES_PASSWORD=test -p 5432:5432 -d postgres

# Modifier temporairement .env
DATABASE_URL="postgresql://postgres:test@localhost:5432/postgres"

# Tester la configuration
npx prisma db pull
```

## Ressources de support

### Documentation officielle
- [Prisma Troubleshooting](https://www.prisma.io/docs/reference/api-reference/error-reference)
- [Neon Documentation](https://neon.tech/docs/introduction)
- [PostgreSQL Connection Strings](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)

### Communautés
- [Prisma Discord](https://discord.gg/prisma)
- [Neon Discord](https://discord.gg/neon)
- [Stack Overflow Prisma](https://stackoverflow.com/questions/tagged/prisma)

### Outils de diagnostic
- [Prisma Error Reference](https://www.prisma.io/docs/reference/api-reference/error-reference)
- [PostgreSQL Connection Tester](https://www.postgresql.org/docs/current/app-psql.html)
- [Online SSL Checker](https://www.sslshopper.com/ssl-checker.html)

### Logs utiles

**Activer les logs Prisma** :
```typescript
const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
})
```

**Variables de debug** :
```bash
DEBUG=prisma:* npm run dev
DEBUG=prisma:client npm run dev
```

Si aucune de ces solutions ne fonctionne, documenter l'erreur exacte avec les logs complets pour obtenir de l'aide supplémentaire.

