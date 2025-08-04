# Étape 5 : Dépannage NextAuth.js - Configuration et authentification

## Problèmes d'installation et de configuration

### 1. Erreur "Cannot find module 'next-auth'"

**Symptômes** :
```
Module not found: Can't resolve 'next-auth'
Error: Cannot find module 'next-auth'
```

**Causes possibles** :
- NextAuth.js pas installé
- Version incompatible avec Next.js App Router
- Cache npm corrompu

**Solutions** :

```bash
# Solution 1 : Installation NextAuth.js v5 (App Router)
npm uninstall next-auth
npm install next-auth@beta

# Vérifier la version installée
npm list next-auth
# Doit afficher next-auth@5.0.0-beta.x

# Solution 2 : Nettoyer le cache
npm cache clean --force
rm -rf node_modules package-lock.json
npm install

# Solution 3 : Vérifier la compatibilité Next.js
npm list next
# Next.js doit être version 13+ pour App Router
```

**Test de vérification** :
```bash
node -e "try { require('next-auth'); console.log('✅ NextAuth importable'); } catch (e) { console.log('❌ Erreur:', e.message); }"
```

### 2. Erreur "PrismaAdapter is not a function"

**Symptômes** :
```
TypeError: PrismaAdapter is not a function
Error: adapter.createUser is not a function
```

**Causes possibles** :
- @auth/prisma-adapter pas installé
- Import incorrect du PrismaAdapter
- Version incompatible

**Solutions** :

```bash
# Solution 1 : Installer le bon adapter
npm install @auth/prisma-adapter

# Solution 2 : Vérifier l'import
```

```typescript
// ❌ Incorrect (ancien)
import { PrismaAdapter } from "@next-auth/prisma-adapter"

// ✅ Correct (nouveau)
import { PrismaAdapter } from "@auth/prisma-adapter"
```

```bash
# Solution 3 : Vérifier les versions
npm list @auth/prisma-adapter @prisma/client
# Les versions doivent être compatibles

# Solution 4 : Réinstallation complète
npm uninstall @auth/prisma-adapter
npm install @auth/prisma-adapter
```

### 3. Erreur "NEXTAUTH_SECRET not found"

**Symptômes** :
```
Error: Please define a `NEXTAUTH_SECRET` environment variable
MissingSecret: Please define a `NEXTAUTH_SECRET`
```

**Causes** :
- Variable NEXTAUTH_SECRET manquante
- Fichier .env non lu
- Variable mal formatée

**Solutions** :

```bash
# Solution 1 : Générer et ajouter NEXTAUTH_SECRET
node -e "console.log('NEXTAUTH_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"

# Copier le résultat dans .env
echo "NEXTAUTH_SECRET=your-generated-secret-here" >> .env

# Solution 2 : Vérifier que .env est lu
node -e "console.log('NEXTAUTH_SECRET présente:', !!process.env.NEXTAUTH_SECRET)"

# Solution 3 : Vérifier le format du .env
grep "NEXTAUTH_SECRET" .env
# Doit être : NEXTAUTH_SECRET="votre-clé-sans-espaces"

# Solution 4 : Redémarrer le serveur
# Ctrl+C puis npm run dev
```

**Format correct dans .env** :
```env
# ✅ Correct
NEXTAUTH_SECRET="abc123def456..."

# ❌ Incorrect (espaces, quotes)
NEXTAUTH_SECRET = "abc123..."
NEXTAUTH_SECRET='abc123...'
```

## Problèmes d'authentification

### 4. Erreur "Invalid credentials" lors de la connexion

**Symptômes** :
- Connexion échoue même avec bons identifiants
- Message "Credentials are invalid"
- Redirection vers page d'erreur

**Diagnostic** :

```bash
# Test 1 : Vérifier l'utilisateur en base
node -e "
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  const user = await prisma.user.findUnique({
    where: { email: 'test@photomarket.com' }
  });
  console.log('Utilisateur trouvé:', !!user);
  if (user) {
    console.log('Email:', user.email);
    console.log('A un mot de passe:', !!user.password);
    console.log('Rôle:', user.role);
  }
  await prisma.\$disconnect();
})();
"

# Test 2 : Vérifier bcrypt
node -e "
const bcrypt = require('bcryptjs');
(async () => {
  const password = 'TestPassword123!';
  const hash = await bcrypt.hash(password, 12);
  const isValid = await bcrypt.compare(password, hash);
  console.log('bcrypt fonctionne:', isValid);
})();
"
```

**Solutions** :

```typescript
// Vérifier la fonction authorize dans auth-config.ts
async authorize(credentials) {
  console.log('Tentative connexion pour:', credentials?.email); // Debug
  
  if (!credentials?.email || !credentials?.password) {
    console.log('Credentials manquantes'); // Debug
    throw new Error("Email et mot de passe requis")
  }

  const user = await prisma.user.findUnique({
    where: { email: credentials.email as string }
  })

  console.log('Utilisateur trouvé:', !!user); // Debug

  if (!user || !user.password) {
    console.log('Utilisateur non trouvé ou pas de mot de passe'); // Debug
    throw new Error("Utilisateur non trouvé")
  }

  const isValidPassword = await bcrypt.compare(
    credentials.password as string,
    user.password
  )

  console.log('Mot de passe valide:', isValidPassword); // Debug

  if (!isValidPassword) {
    throw new Error("Mot de passe incorrect")
  }

  return {
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role,
  }
}
```

### 5. Sessions perdues après redémarrage

**Symptômes** :
- Utilisateur déconnecté après redémarrage serveur
- Session null même après connexion réussie
- Cookies non persistants

**Causes** :
- Configuration JWT incorrecte
- NEXTAUTH_SECRET change
- Configuration des cookies

**Solutions** :

```typescript
// Dans auth-config.ts, vérifier la configuration session
session: {
  strategy: "jwt", // Important pour la persistance
  maxAge: 30 * 24 * 60 * 60, // 30 jours
},

// Vérifier les cookies (optionnel)
cookies: {
  sessionToken: {
    name: "next-auth.session-token",
    options: {
      httpOnly: true,
      sameSite: "lax",
      path: "/",
      secure: process.env.NODE_ENV === "production"
    }
  }
}
```

```bash
# Vérifier que NEXTAUTH_SECRET est stable
grep "NEXTAUTH_SECRET" .env
# Doit être la même à chaque démarrage

# Test de persistance des sessions
node -e "
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  const sessionCount = await prisma.session.count();
  console.log('Sessions actives:', sessionCount);
  await prisma.\$disconnect();
})();
"
```

### 6. Erreur "OAuth provider configuration"

**Symptômes** :
```
Error: Missing clientId or clientSecret for Google provider
GitHub OAuth callback error
```

**Solutions** :

```bash
# Vérifier les variables OAuth
node -e "
console.log('GOOGLE_CLIENT_ID:', !!process.env.GOOGLE_CLIENT_ID);
console.log('GOOGLE_CLIENT_SECRET:', !!process.env.GOOGLE_CLIENT_SECRET);
console.log('GITHUB_CLIENT_ID:', !!process.env.GITHUB_CLIENT_ID);
console.log('GITHUB_CLIENT_SECRET:', !!process.env.GITHUB_CLIENT_SECRET);
"

# Vérifier le format des URLs de callback
echo "Google callback: http://localhost:3000/api/auth/callback/google"
echo "GitHub callback: http://localhost:3000/api/auth/callback/github"
```

**Configuration OAuth correcte** :

```typescript
// Rendre les providers OAuth optionnels
providers: [
  Credentials({
    // Configuration credentials...
  }),
  
  // Ajouter Google seulement si configuré
  ...(process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET ? [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    })
  ] : []),
  
  // Ajouter GitHub seulement si configuré
  ...(process.env.GITHUB_CLIENT_ID && process.env.GITHUB_CLIENT_SECRET ? [
    GitHub({
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET,
    })
  ] : []),
]
```

## Problèmes de middleware et protection des routes

### 7. Middleware ne protège pas les routes

**Symptômes** :
- Accès aux routes protégées sans authentification
- Pas de redirection vers login
- Middleware ignoré

**Diagnostic** :

```bash
# Vérifier que middleware.ts existe
ls -la src/middleware.ts

# Vérifier le contenu du fichier
grep -n "export default" src/middleware.ts

# Tester une route protégée
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/dashboard
# Doit retourner 307 (redirection) si pas connecté
```

**Solutions** :

```typescript
// Vérifier que le middleware est correctement exporté
export default auth((req) => {
  // Logique du middleware...
})

// Vérifier la configuration du matcher
export const config = {
  matcher: [
    "/((?!api|_next/static|_next/image|favicon.ico|public).*)",
  ],
}

// Ajouter des logs pour debug
export default auth((req) => {
  console.log('Middleware appelé pour:', req.nextUrl.pathname);
  console.log('Session présente:', !!req.auth);
  
  // Rest of middleware logic...
})
```

```bash
# Redémarrer le serveur après modification
# Ctrl+C puis npm run dev
```

### 8. Erreur "Redirect loop" ou redirections infinies

**Symptômes** :
- Page qui redirige indéfiniment
- Erreur "Too many redirects"
- Application inaccessible

**Causes** :
- Middleware mal configuré
- Routes publiques mal définies
- Callback redirect incorrect

**Solutions** :

```typescript
// Vérifier les routes publiques dans middleware.ts
const publicRoutes = [
  "/",
  "/gallery",
  "/photos",
  "/auth/signin",  // Important !
  "/auth/signup",  // Important !
  "/auth/error",   // Important !
  "/api/auth"      // Important !
]

// Vérifier la logique de redirection
if (isPublicRoute) {
  return NextResponse.next() // Pas de redirection !
}

// Éviter la redirection des utilisateurs connectés vers signin
if (session && pathname.startsWith("/auth/signin")) {
  return NextResponse.redirect(new URL("/dashboard", req.url))
}
```

**Debug des redirections** :

```typescript
// Ajouter des logs détaillés
export default auth((req) => {
  const { pathname } = req.nextUrl
  const session = req.auth

  console.log(`[MIDDLEWARE] ${pathname} - Session: ${!!session}`)

  const isPublicRoute = publicRoutes.some(route => 
    pathname.startsWith(route)
  )
  
  console.log(`[MIDDLEWARE] Public route: ${isPublicRoute}`)

  if (isPublicRoute) {
    console.log('[MIDDLEWARE] Allowing public access')
    return NextResponse.next()
  }

  // ... rest of logic
})
```

## Problèmes de types TypeScript

### 9. Erreurs de types NextAuth

**Symptômes** :
```
Property 'role' does not exist on type 'User'
Property 'id' does not exist on type 'Session.user'
```

**Solutions** :

```typescript
// Vérifier que src/types/next-auth.d.ts existe et contient :
declare module "next-auth" {
  interface Session {
    user: {
      id: string
      role: "USER" | "ADMIN"
    } & DefaultSession["user"]
  }

  interface User {
    role: "USER" | "ADMIN"
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    role: "USER" | "ADMIN"
    id: string
  }
}

// Redémarrer TypeScript Language Server dans VSCode
// Ctrl+Shift+P > "TypeScript: Restart TS Server"
```

```bash
# Vérifier que TypeScript trouve les types
npx tsc --noEmit

# Forcer la régénération des types
rm -rf .next
npm run dev
```

### 10. Erreurs "useSession" côté client

**Symptômes** :
```
Error: useSession must be wrapped in a <SessionProvider />
React Hook "useSession" is called in a function that is neither a React function component nor a custom React Hook
```

**Solutions** :

```tsx
// Créer un Provider au niveau app (src/app/layout.tsx)
import { SessionProvider } from "next-auth/react"

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body>
        <SessionProvider>
          {children}
        </SessionProvider>
      </body>
    </html>
  )
}

// Utiliser useSession dans les composants clients
"use client"
import { useSession } from "next-auth/react"

export function UserProfile() {
  const { data: session, status } = useSession()
  
  if (status === "loading") return <p>Chargement...</p>
  if (status === "unauthenticated") return <p>Non connecté</p>
  
  return <p>Connecté en tant que {session?.user?.email}</p>
}
```

## Problèmes de base de données

### 11. Erreur "Table 'users' doesn't exist"

**Symptômes** :
```
PrismaClientKnownRequestError: Table 'photomarket.users' doesn't exist
```

**Solutions** :

```bash
# Vérifier que les tables NextAuth existent
npx prisma studio
# Ou
node -e "
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  try {
    await prisma.user.count();
    await prisma.account.count();
    await prisma.session.count();
    console.log('✅ Tables NextAuth existent');
  } catch (error) {
    console.log('❌ Tables manquantes:', error.message);
  } finally {
    await prisma.\$disconnect();
  }
})();
"

# Si tables manquantes, pousser le schéma
npx prisma db push

# Vérifier le schéma contient les modèles NextAuth
grep -A 10 "model User" prisma/schema.prisma
grep -A 10 "model Account" prisma/schema.prisma
grep -A 10 "model Session" prisma/schema.prisma
```

### 12. Erreur de contraintes base de données

**Symptômes** :
```
Unique constraint failed on the fields: (`email`)
Foreign key constraint failed
```

**Solutions** :

```bash
# Nettoyer les données de test en conflit
node -e "
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  
  // Supprimer les sessions expirées
  await prisma.session.deleteMany({
    where: { expires: { lt: new Date() } }
  });
  
  // Supprimer les doublons d'email
  const duplicates = await prisma.user.groupBy({
    by: ['email'],
    _count: { id: true },
    having: { id: { _count: { gt: 1 } } }
  });
  
  for (const duplicate of duplicates) {
    const users = await prisma.user.findMany({
      where: { email: duplicate.email },
      orderBy: { createdAt: 'asc' }
    });
    
    // Garder le premier, supprimer les autres
    for (let i = 1; i < users.length; i++) {
      await prisma.user.delete({ where: { id: users[i].id } });
    }
  }
  
  console.log('✅ Base nettoyée');
  await prisma.\$disconnect();
})();
"
```

## Problèmes de production

### 13. NextAuth ne fonctionne pas en production

**Symptômes** :
- Fonctionne en dev mais pas en production
- Erreurs 500 en production
- OAuth callbacks échouent

**Solutions** :

```bash
# Vérifier les variables de production
node -e "
console.log('Production env check:');
console.log('NEXTAUTH_SECRET:', !!process.env.NEXTAUTH_SECRET);
console.log('NEXTAUTH_URL:', process.env.NEXTAUTH_URL);
console.log('DATABASE_URL:', !!process.env.DATABASE_URL);
"

# Vérifier que NEXTAUTH_URL utilise HTTPS en production
# ❌ Incorrect
NEXTAUTH_URL="http://monsite.com"

# ✅ Correct
NEXTAUTH_URL="https://monsite.com"

# Vérifier les callbacks OAuth en production
echo "Google callback prod: https://monsite.com/api/auth/callback/google"
echo "GitHub callback prod: https://monsite.com/api/auth/callback/github"
```

**Configuration production** :

```env
# Production .env
NEXTAUTH_SECRET="super-long-production-secret-32-chars-minimum"
NEXTAUTH_URL="https://photomarket.vercel.app"
DATABASE_URL="postgresql://user:pass@prod.neon.tech/photomarket"

# OAuth production
GOOGLE_CLIENT_ID="prod-client-id.googleusercontent.com"
GOOGLE_CLIENT_SECRET="prod-client-secret"
GITHUB_CLIENT_ID="prod-github-client-id"  
GITHUB_CLIENT_SECRET="prod-github-client-secret"
```

### 14. Problèmes de CORS et CSP

**Symptômes** :
```
CORS policy error
Content Security Policy violation
```

**Solutions** :

```typescript
// Dans next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  async headers() {
    return [
      {
        source: '/api/auth/:path*',
        headers: [
          {
            key: 'Access-Control-Allow-Origin',
            value: process.env.NEXTAUTH_URL || 'http://localhost:3000'
          },
          {
            key: 'Access-Control-Allow-Methods',
            value: 'GET, POST, OPTIONS'
          },
          {
            key: 'Access-Control-Allow-Headers',
            value: 'Content-Type, Authorization'
          }
        ]
      }
    ]
  }
}

module.exports = nextConfig
```

## Dépannage spécifique Windows PowerShell

### Scripts de diagnostic PowerShell

```powershell
# Fonction de diagnostic complète NextAuth
function Diagnose-NextAuth {
    Write-Host "=== DIAGNOSTIC NEXTAUTH COMPLET ===" -ForegroundColor Blue
    
    # Test 1: Variables d'environnement
    Write-Host "`n1. Variables d'environnement:" -ForegroundColor Yellow
    
    if ($env:NEXTAUTH_SECRET) {
        Write-Host "   ✅ NEXTAUTH_SECRET définie" -ForegroundColor Green
    } else {
        Write-Host "   ❌ NEXTAUTH_SECRET manquante" -ForegroundColor Red
        Write-Host "   Solution: node -e `"console.log('NEXTAUTH_SECRET=' + require('crypto').randomBytes(32).toString('hex'))`"" -ForegroundColor Yellow
    }
    
    if ($env:NEXTAUTH_URL) {
        Write-Host "   ✅ NEXTAUTH_URL: $env:NEXTAUTH_URL" -ForegroundColor Green
    } else {
        Write-Host "   ❌ NEXTAUTH_URL manquante" -ForegroundColor Red
    }
    
    # Test 2: Modules npm
    Write-Host "`n2. Modules npm:" -ForegroundColor Yellow
    
    try {
        $nextAuthVersion = npm list next-auth --depth=0 2>$null
        if ($nextAuthVersion -match "next-auth@") {
            Write-Host "   ✅ NextAuth.js installé" -ForegroundColor Green
        } else {
            Write-Host "   ❌ NextAuth.js non installé" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Erreur vérification NextAuth" -ForegroundColor Red
    }
    
    # Test 3: Fichiers de configuration
    Write-Host "`n3. Fichiers de configuration:" -ForegroundColor Yellow
    
    $configFiles = @(
        "src\lib\auth.ts",
        "src\lib\auth-config.ts", 
        "src\middleware.ts",
        "src\types\next-auth.d.ts"
    )
    
    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            Write-Host "   ✅ $file" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $file manquant" -ForegroundColor Red
        }
    }
    
    # Test 4: Base de données
    Write-Host "`n4. Test base de données:" -ForegroundColor Yellow
    
    $dbTest = @"
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  try {
    await prisma.`$connect();
    const userCount = await prisma.user.count();
    console.log('DB_OK:' + userCount);
  } catch (error) {
    console.log('DB_ERROR:' + error.message);
  } finally {
    await prisma.`$disconnect();
  }
})();
"@
    
    $dbTest | Out-File -FilePath "test-db.js" -Encoding UTF8
    $result = node test-db.js
    Remove-Item test-db.js
    
    if ($result -match "DB_OK:") {
        Write-Host "   ✅ Base de données accessible" -ForegroundColor Green
        Write-Host "   Users: $($result -replace 'DB_OK:', '')" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Problème base de données: $result" -ForegroundColor Red
    }
    
    Write-Host "`n=== DIAGNOSTIC TERMINÉ ===" -ForegroundColor Blue
}

# Fonction de réparation automatique
function Repair-NextAuth {
    Write-Host "=== RÉPARATION NEXTAUTH ===" -ForegroundColor Magenta
    
    # 1. Réinstaller les modules
    Write-Host "1. Réinstallation des modules..." -ForegroundColor Yellow
    npm uninstall next-auth @auth/prisma-adapter bcryptjs
    npm install next-auth@beta @auth/prisma-adapter bcryptjs
    
    # 2. Générer nouveau secret si manquant
    if (-not $env:NEXTAUTH_SECRET) {
        Write-Host "2. Génération NEXTAUTH_SECRET..." -ForegroundColor Yellow
        $newSecret = -join ((1..64) | ForEach {'{0:X}' -f (Get-Random -Max 16)})
        Write-Host "Ajoutez à votre .env:" -ForegroundColor Green
        Write-Host "NEXTAUTH_SECRET=$newSecret" -ForegroundColor White
    }
    
    # 3. Test final
    Write-Host "3. Test final..." -ForegroundColor Yellow
    $testScript = @"
try {
  require('next-auth');
  require('@auth/prisma-adapter');
  console.log('REPAIR_SUCCESS');
} catch (error) {
  console.log('REPAIR_FAILED:' + error.message);
}
"@
    
    $testScript | Out-File -FilePath "test-repair.js" -Encoding UTF8
    $result = node test-repair.js
    Remove-Item test-repair.js
    
    if ($result -match "REPAIR_SUCCESS") {
        Write-Host "🎉 RÉPARATION RÉUSSIE !" -ForegroundColor Green
    } else {
        Write-Host "❌ Réparation échouée: $result" -ForegroundColor Red
    }
}

Write-Host "Fonctions disponibles:" -ForegroundColor Cyan
Write-Host "- Diagnose-NextAuth" -ForegroundColor White
Write-Host "- Repair-NextAuth" -ForegroundColor White
```

### Test d'authentification PowerShell

```powershell
# Test complet d'auth avec PowerShell
function Test-Authentication {
    Write-Host "=== TEST AUTHENTIFICATION ===" -ForegroundColor Blue
    
    # Créer utilisateur test
    $createUserScript = @"
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
(async () => {
  const prisma = new PrismaClient();
  try {
    const hash = await bcrypt.hash('TestPassword123!', 12);
    const user = await prisma.user.upsert({
      where: { email: 'test@photomarket.com' },
      update: {},
      create: {
        email: 'test@photomarket.com',
        password: hash,
        name: 'Test User',
        role: 'USER'
      }
    });
    console.log('USER_CREATED:' + user.email);
  } catch (error) {
    console.log('USER_ERROR:' + error.message);
  } finally {
    await prisma.`$disconnect();
  }
})();
"@
    
    $createUserScript | Out-File -FilePath "create-test-user.js" -Encoding UTF8
    $result = node create-test-user.js
    Remove-Item create-test-user.js
    
    if ($result -match "USER_CREATED:") {
        Write-Host "✅ Utilisateur test créé/trouvé" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur création utilisateur: $result" -ForegroundColor Red
        return
    }
    
    # Tester bcrypt
    $bcryptTest = @"
const bcrypt = require('bcryptjs');
(async () => {
  try {
    const hash = await bcrypt.hash('TestPassword123!', 12);
    const isValid = await bcrypt.compare('TestPassword123!', hash);
    console.log('BCRYPT_OK:' + isValid);
  } catch (error) {
    console.log('BCRYPT_ERROR:' + error.message);
  }
})();
"@
    
    $bcryptTest | Out-File -FilePath "test-bcrypt.js" -Encoding UTF8
    $bcryptResult = node test-bcrypt.js
    Remove-Item test-bcrypt.js
    
    if ($bcryptResult -match "BCRYPT_OK:true") {
        Write-Host "✅ Hashage de mot de passe fonctionnel" -ForegroundColor Green
    } else {
        Write-Host "❌ Problème bcrypt: $bcryptResult" -ForegroundColor Red
    }
    
    Write-Host "`nUtilisateur test:" -ForegroundColor Yellow
    Write-Host "  Email: test@photomarket.com" -ForegroundColor White
    Write-Host "  Password: TestPassword123!" -ForegroundColor White
}
```

## Annexe 2 : Dépannage CMD (Command Prompt)

### Scripts de diagnostic CMD

```cmd
REM diagnostic-nextauth.bat
@echo off
echo === DIAGNOSTIC NEXTAUTH ===

echo 1. Test variables d'environnement...
node -e "console.log('NEXTAUTH_SECRET:', !!process.env.NEXTAUTH_SECRET)"
node -e "console.log('NEXTAUTH_URL:', process.env.NEXTAUTH_URL || 'Manquante')"

echo.
echo 2. Test modules npm...
npm list next-auth --depth=0 >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ NextAuth.js installé
) else (
    echo ❌ NextAuth.js manquant
)

npm list @auth/prisma-adapter --depth=0 >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Prisma Adapter installé
) else (
    echo ❌ Prisma Adapter manquant
)

echo.
echo 3. Test fichiers de configuration...
if exist "src\lib\auth.ts" (
    echo ✅ auth.ts présent
) else (
    echo ❌ auth.ts manquant
)

if exist "src\middleware.ts" (
    echo ✅ middleware.ts présent
) else (
    echo ❌ middleware.ts manquant
)

echo.
echo 4. Test base de données...
echo const{PrismaClient}=require('@prisma/client');(async()=>{const p=new PrismaClient();try{await p.$connect();const c=await p.user.count();console.log('✅ DB OK:',c,'users');}catch(e){console.log('❌ DB ERROR:',e.message);}finally{await p.$disconnect();}})(); > test-db.js
node test-db.js
del test-db.js

echo.
echo === DIAGNOSTIC TERMINÉ ===
pause
```

### Script de réparation CMD

```cmd
REM repair-nextauth.bat
@echo off
echo === RÉPARATION NEXTAUTH ===
echo.

echo Étape 1: Nettoyage modules...
npm uninstall next-auth @auth/prisma-adapter bcryptjs

echo.
echo Étape 2: Réinstallation...
npm install next-auth@beta @auth/prisma-adapter bcryptjs

echo.
echo Étape 3: Test installation...
node -e "try{require('next-auth');require('@auth/prisma-adapter');console.log('✅ MODULES OK')}catch(e){console.log('❌ ERREUR:',e.message)}"

echo.
echo Étape 4: Génération secret (si nécessaire)...
node -e "if(!process.env.NEXTAUTH_SECRET){console.log('NEXTAUTH_SECRET=' + require('crypto').randomBytes(32).toString('hex'))}else{console.log('✅ NEXTAUTH_SECRET déjà défini')}"

echo.
echo === RÉPARATION TERMINÉE ===
echo.
echo Si NEXTAUTH_SECRET affiché ci-dessus, ajoutez-le à votre .env
pause
```

## Solutions d'urgence

### Reset complet NextAuth

```bash
# Si tout échoue, reset complet
rm -rf node_modules package-lock.json
rm -rf .next

# Réinstaller tout
npm install
npm install next-auth@beta @auth/prisma-adapter bcryptjs @types/bcryptjs

# Régénérer Prisma
npx prisma generate
npx prisma db push

# Tester
npm run dev
```

### Vérification finale

```bash
# Script de vérification complète
node -e "
console.log('=== VÉRIFICATION FINALE NEXTAUTH ===');

// Test 1: Modules
try {
  require('next-auth');
  require('@auth/prisma-adapter');
  require('bcryptjs');
  console.log('✅ Tous les modules importables');
} catch (error) {
  console.log('❌ Erreur modules:', error.message);
  process.exit(1);
}

// Test 2: Variables
if (!process.env.NEXTAUTH_SECRET) {
  console.log('❌ NEXTAUTH_SECRET manquante');
  process.exit(1);
}

if (!process.env.NEXTAUTH_URL) {
  console.log('❌ NEXTAUTH_URL manquante');
  process.exit(1);
}

console.log('✅ Variables d\'environnement OK');

// Test 3: Base de données
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  try {
    await prisma.\$connect();
    await prisma.user.count();
    await prisma.account.count();
    await prisma.session.count();
    console.log('✅ Base de données NextAuth OK');
    console.log('🎉 NEXTAUTH PRÊT POUR PRODUCTION !');
  } catch (error) {
    console.log('❌ Erreur base de données:', error.message);
  } finally {
    await prisma.\$disconnect();
  }
})();
"
```

### Contacts support

- **Documentation NextAuth.js** : https://next-auth.js.org
- **GitHub NextAuth.js** : https://github.com/nextauthjs/next-auth/issues
- **Discord NextAuth.js** : https://discord.gg/nextauth
- **Stack Overflow** : Tag `next-auth`

En suivant ce guide de dépannage, vous devriez pouvoir résoudre tous les problèmes courants de NextAuth.js dans le projet PhotoMarket.