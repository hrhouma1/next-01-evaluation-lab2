# Étape 5 : Checklist - Configuration NextAuth.js

## Checklist d'installation et configuration

### Installation des dépendances

- [ ] **NextAuth.js v5 installé**
```bash
npm list next-auth
# Doit afficher next-auth@5.0.0-beta.x
```

- [ ] **Prisma Adapter installé**
```bash
npm list @auth/prisma-adapter
# Doit afficher @auth/prisma-adapter@latest
```

- [ ] **bcryptjs installé**
```bash
npm list bcryptjs @types/bcryptjs
# Doit afficher les deux packages
```

- [ ] **Versions compatibles vérifiées**
  - [ ] next-auth@5.0.0-beta.x (App Router support)
  - [ ] @auth/prisma-adapter (version récente)
  - [ ] bcryptjs@^2.4.3

### Configuration des variables d'environnement

- [ ] **Variables NextAuth.js configurées**
  - [ ] `NEXTAUTH_SECRET` définie (32+ caractères)
  - [ ] `NEXTAUTH_URL` définie (http://localhost:3000 en dev)

- [ ] **Variables OAuth configurées (optionnel)**
  - [ ] `GOOGLE_CLIENT_ID` et `GOOGLE_CLIENT_SECRET` (si Google OAuth)
  - [ ] `GITHUB_CLIENT_ID` et `GITHUB_CLIENT_SECRET` (si GitHub OAuth)

- [ ] **Fichier .env.example mis à jour**
  - [ ] Template des variables NextAuth ajouté
  - [ ] Instructions de génération des secrets

- [ ] **Sécurité des variables**
  - [ ] `.env` dans `.gitignore`
  - [ ] Pas de variables secrètes dans le code source

### Structure des fichiers créée

- [ ] **Configuration NextAuth**
  - [ ] `src/lib/auth.ts` créé
  - [ ] `src/lib/auth-config.ts` créé
  - [ ] `src/lib/password.ts` créé

- [ ] **Route API NextAuth**
  - [ ] `src/app/api/auth/[...nextauth]/route.ts` créé
  - [ ] Dossier `[...nextauth]` correctement nommé

- [ ] **Middleware de protection**
  - [ ] `src/middleware.ts` créé
  - [ ] Configuration `config.matcher` présente

- [ ] **Types TypeScript**
  - [ ] `src/types/next-auth.d.ts` créé
  - [ ] Extension des interfaces Session et User

- [ ] **Pages d'authentification**
  - [ ] `src/app/auth/signin/page.tsx` créé
  - [ ] `src/app/auth/signup/page.tsx` créé
  - [ ] `src/app/auth/error/page.tsx` créé

## Checklist de configuration Prisma

### Intégration Prisma Adapter

- [ ] **Adapter configuré dans auth-config.ts**
```typescript
adapter: PrismaAdapter(prisma)
```

- [ ] **Import Prisma client correct**
```typescript
import { prisma } from "@/lib/prisma"
```

- [ ] **Tables NextAuth disponibles**
  - [ ] Table `users` accessible
  - [ ] Table `accounts` accessible  
  - [ ] Table `sessions` accessible
  - [ ] Table `verificationtokens` accessible

### Test de la base de données

- [ ] **Connexion Prisma fonctionnelle**
```bash
node -e "const{PrismaClient}=require('@prisma/client');new PrismaClient().\$connect().then(()=>console.log('✅')).catch(()=>console.log('❌'))"
```

- [ ] **Tables NextAuth comptées**
```bash
node -e "const{PrismaClient}=require('@prisma/client');(async()=>{const p=new PrismaClient();const [u,a,s]=await Promise.all([p.user.count(),p.account.count(),p.session.count()]);console.log('Users:',u,'Accounts:',a,'Sessions:',s);await p.\$disconnect()})();"
```

## Checklist des providers d'authentification

### Provider Credentials

- [ ] **Configuration du provider credentials**
  - [ ] Champs email et password définis
  - [ ] Fonction `authorize` implémentée
  - [ ] Vérification mot de passe avec bcrypt
  - [ ] Gestion des erreurs appropriée

- [ ] **Test bcrypt fonctionnel**
```bash
node -e "const bcrypt=require('bcryptjs');(async()=>{const h=await bcrypt.hash('test',12);const v=await bcrypt.compare('test',h);console.log('bcrypt OK:',v)})();"
```

### Providers OAuth (optionnel)

- [ ] **Google OAuth configuré (si utilisé)**
  - [ ] Projet Google Cloud créé
  - [ ] OAuth 2.0 credentials générés
  - [ ] URI de redirection configurée
  - [ ] Variables GOOGLE_CLIENT_ID/SECRET définies

- [ ] **GitHub OAuth configuré (si utilisé)**
  - [ ] OAuth App GitHub créée
  - [ ] Authorization callback URL configurée
  - [ ] Variables GITHUB_CLIENT_ID/SECRET définies

## Checklist des callbacks et sessions

### Configuration des callbacks

- [ ] **Callback JWT implémenté**
  - [ ] Ajout du rôle au token
  - [ ] Ajout de l'ID utilisateur au token
  - [ ] Gestion des nouveaux utilisateurs

- [ ] **Callback Session implémenté**
  - [ ] Transfert des données du token vers la session
  - [ ] Rôle utilisateur accessible
  - [ ] ID utilisateur accessible

- [ ] **Callback Redirect configuré**
  - [ ] Redirection vers dashboard après connexion
  - [ ] Validation des URLs de redirection

### Configuration des sessions

- [ ] **Stratégie de session**
  - [ ] JWT sélectionné comme stratégie
  - [ ] Durée de session appropriée (30 jours recommandé)

- [ ] **Sécurité des sessions**
  - [ ] Secret de signature sécurisé
  - [ ] Expiration des sessions configurée

## Checklist du middleware de protection

### Routes protégées

- [ ] **Routes protégées définies**
  - [ ] `/dashboard` protégé
  - [ ] `/profile` protégé
  - [ ] `/upload` protégé
  - [ ] `/photos/manage` protégé
  - [ ] `/purchases` protégé
  - [ ] `/settings` protégé

- [ ] **Routes admin définies**
  - [ ] `/admin` protégé (ADMIN uniquement)
  - [ ] `/admin/users` protégé (ADMIN uniquement)
  - [ ] `/admin/photos` protégé (ADMIN uniquement)
  - [ ] `/admin/analytics` protégé (ADMIN uniquement)

- [ ] **Routes publiques définies**
  - [ ] `/` accessible sans auth
  - [ ] `/gallery` accessible sans auth
  - [ ] `/photos` accessible sans auth
  - [ ] Pages auth accessibles sans auth

### Logique de redirection

- [ ] **Redirection non authentifié**
  - [ ] Redirection vers `/auth/signin`
  - [ ] CallbackUrl preserved

- [ ] **Protection admin**
  - [ ] Non-admin redirigé vers `/`
  - [ ] Vérification du rôle fonctionnelle

- [ ] **Utilisateurs connectés**
  - [ ] Redirection si tentative d'accès aux pages auth
  - [ ] Redirection vers `/dashboard`

## Checklist des tests fonctionnels

### Tests de base

- [ ] **Test 1 : Variables d'environnement**
```bash
node -e "console.log('NEXTAUTH_SECRET:',!!process.env.NEXTAUTH_SECRET,'NEXTAUTH_URL:',!!process.env.NEXTAUTH_URL)"
```

- [ ] **Test 2 : Import des modules**
```bash
node -e "try{require('next-auth');require('@auth/prisma-adapter');console.log('✅ Modules OK')}catch(e){console.log('❌',e.message)}"
```

- [ ] **Test 3 : Connexion Prisma**
```bash
node -e "const{PrismaClient}=require('@prisma/client');new PrismaClient().\$connect().then(()=>console.log('✅ Prisma OK')).catch(()=>console.log('❌ Prisma KO'))"
```

### Tests d'authentification

- [ ] **Utilisateur test créé**
```bash
# Email: test@photomarket.com
# Password: TestPassword123!
# Role: USER
```

- [ ] **Administrateur créé**
```bash
# Email: admin@photomarket.com  
# Password: AdminPassword123!
# Role: ADMIN
```

- [ ] **Test de hashage de mot de passe**
```typescript
const isValid = await bcrypt.compare('TestPassword123!', user.password)
// Doit retourner true
```

### Tests des endpoints API

- [ ] **API NextAuth accessible**
```bash
curl http://localhost:3000/api/auth/providers
# Doit retourner JSON avec les providers
```

- [ ] **Session endpoint accessible**
```bash
curl http://localhost:3000/api/auth/session
# Doit retourner session ou null
```

- [ ] **CSRF endpoint accessible**
```bash
curl http://localhost:3000/api/auth/csrf
# Doit retourner un token CSRF
```

## Checklist des pages d'authentification

### Pages créées et accessibles

- [ ] **Page de connexion**
  - [ ] `/auth/signin` accessible
  - [ ] Formulaire de connexion présent
  - [ ] Boutons OAuth présents (si configurés)
  - [ ] Design cohérent avec l'application

- [ ] **Page d'inscription**
  - [ ] `/auth/signup` accessible
  - [ ] Formulaire d'inscription présent
  - [ ] Validation des mots de passe
  - [ ] Design cohérent

- [ ] **Page d'erreur**
  - [ ] `/auth/error` accessible
  - [ ] Messages d'erreur clairs
  - [ ] Liens de retour présents

### Métadonnées et SEO

- [ ] **Métadonnées configurées**
  - [ ] Titres de page appropriés
  - [ ] Descriptions META
  - [ ] Favicon et icônes

## Checklist de sécurité

### Sécurité des mots de passe

- [ ] **Hashage sécurisé**
  - [ ] bcrypt avec saltRounds >= 12
  - [ ] Mots de passe jamais stockés en clair
  - [ ] Validation de la force des mots de passe

- [ ] **Validation des mots de passe**
  - [ ] Longueur minimum 8 caractères
  - [ ] Au moins une majuscule
  - [ ] Au moins une minuscule  
  - [ ] Au moins un chiffre
  - [ ] Au moins un caractère spécial

### Sécurité des sessions

- [ ] **Configuration JWT sécurisée**
  - [ ] Secret de 32+ caractères
  - [ ] Expiration appropriée
  - [ ] Rotation des tokens

- [ ] **Protection CSRF**
  - [ ] Tokens CSRF générés
  - [ ] Validation côté serveur

### Sécurité des routes

- [ ] **Protection côté serveur**
  - [ ] Middleware appliqué
  - [ ] Validation des rôles en base
  - [ ] Pas de contournement possible

- [ ] **Gestion des erreurs**
  - [ ] Messages d'erreur non informatifs
  - [ ] Pas de fuite d'informations sensibles
  - [ ] Logs appropriés

## Checklist de développement

### Environnement de développement

- [ ] **Serveur de développement**
```bash
npm run dev
# Doit démarrer sans erreurs
```

- [ ] **Hot reload fonctionnel**
  - [ ] Modifications des composants rechargées
  - [ ] Modifications de configuration rechargées

- [ ] **Debug activé (optionnel)**
```env
DEBUG=next-auth*
```

### Tests en développement

- [ ] **Connexion credentials testée**
  - [ ] Login avec test@photomarket.com réussi
  - [ ] Redirection vers dashboard
  - [ ] Session créée correctement

- [ ] **Protection des routes testée**
  - [ ] Accès `/dashboard` sans auth redirige
  - [ ] Accès `/admin` sans rôle admin redirige
  - [ ] CallbackUrl fonctionne

- [ ] **Déconnexion testée**
  - [ ] Bouton logout fonctionne
  - [ ] Session supprimée
  - [ ] Redirection appropriée

## Checklist de production

### Préparation production

- [ ] **Variables de production**
  - [ ] NEXTAUTH_SECRET unique et sécurisé
  - [ ] NEXTAUTH_URL avec domaine de production
  - [ ] DATABASE_URL de production
  - [ ] Variables OAuth avec domaines de production

- [ ] **Build de production**
```bash
npm run build
# Doit réussir sans erreurs
```

- [ ] **Test de production locale**
```bash
npm start
# L'application doit démarrer et NextAuth fonctionner
```

### Sécurité production

- [ ] **HTTPS obligatoire**
  - [ ] Certificat SSL valide
  - [ ] Redirection HTTP vers HTTPS
  - [ ] Headers de sécurité configurés

- [ ] **Domaines autorisés**
  - [ ] OAuth callbacks avec vrais domaines
  - [ ] CORS configuré appropriément
  - [ ] CSP configuré si nécessaire

## Validation finale

### Critères de réussite

✅ **L'étape 5 est RÉUSSIE si :**

1. **Installation complète** : Tous les packages installés et versions correctes
2. **Configuration fonctionnelle** : Variables d'environnement et fichiers de config
3. **Base de données** : Intégration Prisma Adapter réussie
4. **Authentification** : Login/logout avec credentials fonctionne
5. **Protection** : Middleware protège les routes appropriées
6. **Pages** : Pages d'auth accessibles et fonctionnelles
7. **Sécurité** : Mots de passe hashés, sessions sécurisées
8. **Tests** : Tous les tests de validation passent

### Tests de validation finale

```bash
# Test final complet
node -e "
console.log('=== VALIDATION FINALE NEXTAUTH ===');
const tests = {
  'Variables env': !!process.env.NEXTAUTH_SECRET && !!process.env.NEXTAUTH_URL,
  'NextAuth module': (() => { try { require('next-auth'); return true; } catch { return false; } })(),
  'Prisma adapter': (() => { try { require('@auth/prisma-adapter'); return true; } catch { return false; } })(),
  'bcrypt': (() => { try { require('bcryptjs'); return true; } catch { return false; } })()
};
Object.entries(tests).forEach(([test, result]) => {
  console.log(test + ':', result ? '✅' : '❌');
});
"

# Test de la base de données
node -e "
const { PrismaClient } = require('@prisma/client');
(async () => {
  const prisma = new PrismaClient();
  try {
    await prisma.\$connect();
    const userCount = await prisma.user.count();
    console.log('Base de données NextAuth: ✅ (' + userCount + ' users)');
  } catch (error) {
    console.log('Base de données NextAuth: ❌', error.message);
  } finally {
    await prisma.\$disconnect();
  }
})();
"
```

## Prêt pour l'étape suivante

- [ ] **Étape 6 préparée** : Types NextAuth avancés
  - [ ] NextAuth.js configuré et fonctionnel
  - [ ] Types de base définis
  - [ ] Sessions et callbacks compris

Une fois cette checklist complètement validée, vous pouvez passer à l'**Étape 6 : Types NextAuth avancés** en toute confiance !

## Annexe 1 : Checklist PowerShell (Windows)

### Tests PowerShell spécifiques

- [ ] **Variables d'environnement PowerShell**
```powershell
if ($env:NEXTAUTH_SECRET) { Write-Host "✅ NEXTAUTH_SECRET" -ForegroundColor Green } else { Write-Host "❌ NEXTAUTH_SECRET manquante" -ForegroundColor Red }
```

- [ ] **Test des modules PowerShell**
```powershell
try { npm list next-auth | Out-Null; Write-Host "✅ NextAuth installé" -ForegroundColor Green } catch { Write-Host "❌ NextAuth manquant" -ForegroundColor Red }
```

- [ ] **Création d'utilisateur test PowerShell**
```powershell
$script = @"
const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')
// Script de création d'utilisateur...
"@
$script | Out-File -FilePath "test-user.js" -Encoding UTF8
node test-user.js
Remove-Item test-user.js
```

## Annexe 2 : Checklist CMD (Command Prompt)

### Tests CMD obligatoires

- [ ] **Variables d'environnement CMD**
```cmd
node -e "console.log('NEXTAUTH_SECRET:', !!process.env.NEXTAUTH_SECRET)"
```

- [ ] **Installation CMD**
```cmd
npm list next-auth @auth/prisma-adapter bcryptjs
```

- [ ] **Test serveur CMD**
```cmd
start /B npm run dev
timeout /t 5
curl http://localhost:3000/api/auth/providers 2>nul && echo ✅ API OK || echo ❌ API problème
```

Cette checklist exhaustive garantit une configuration NextAuth.js parfaitement fonctionnelle pour PhotoMarket !