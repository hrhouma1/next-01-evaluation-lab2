# Étape 3 : Checklist - Compréhension du schéma Prisma

## Checklist principale

### Compréhension des concepts

- [ ] **Types de relations maîtrisés**
  - [ ] Relation 1:1 (Un vers Un) comprise
  - [ ] Relation 1:N (Un vers Plusieurs) comprise  
  - [ ] Relation N:N (Plusieurs vers Plusieurs) comprise
  - [ ] Table de liaison (Purchase) comprise

- [ ] **Modèles métier PhotoMarket analysés**
  - [ ] Modèle User et ses relations comprises
  - [ ] Modèle Photo et ses relations comprises
  - [ ] Modèle Purchase et son rôle de liaison compris
  - [ ] Modèles NextAuth.js (Account, Session, VerificationToken) compris

- [ ] **Relations spécifiques identifiées**
  - [ ] User → Photo (1:N) : Un utilisateur possède plusieurs photos
  - [ ] User → Purchase (1:N) : Un utilisateur effectue plusieurs achats
  - [ ] Photo → Purchase (1:N) : Une photo peut être achetée plusieurs fois
  - [ ] User → Account (1:N) : Un utilisateur peut avoir plusieurs comptes OAuth
  - [ ] User → Session (1:N) : Un utilisateur peut avoir plusieurs sessions

### Diagramme et visualisation

- [ ] **Diagramme ERD consulté et compris**
  - [ ] Toutes les entités identifiées
  - [ ] Toutes les relations visualisées
  - [ ] Clés primaires (PK) identifiées
  - [ ] Clés étrangères (FK) identifiées
  - [ ] Contraintes uniques (UK) identifiées

- [ ] **Prisma Studio testé**
  - [ ] Interface graphique ouverte (`npx prisma studio`)
  - [ ] Tables visibles dans l'interface
  - [ ] Relations cliquables entre tables
  - [ ] Structure des données comprise

### Tests de requêtes

- [ ] **Tests basiques exécutés**
  - [ ] Test de connexion réussi
  - [ ] Comptage des enregistrements effectué
  - [ ] Relations testées avec `include`
  - [ ] Requêtes avec `_count` testées

- [ ] **Tests de relations complexes**
  - [ ] Chaîne User → Photo → Purchase testée
  - [ ] Relation circulaire (vendeur/acheteur) testée
  - [ ] Requêtes d'agrégation (`aggregate`, `groupBy`) testées
  - [ ] Requêtes avec filtres complexes testées

### Contraintes et règles métier

- [ ] **Contraintes Prisma comprises**
  - [ ] Clés primaires automatiques comprises
  - [ ] Clés étrangères automatiques comprises
  - [ ] Contraintes unique identifiées
  - [ ] Règles de suppression en cascade comprises

- [ ] **Règles métier identifiées**
  - [ ] Un utilisateur ne peut pas acheter sa propre photo
  - [ ] Une photo doit être PUBLISHED pour être achetée
  - [ ] Les photos supprimées suppriment leurs achats
  - [ ] Les utilisateurs supprimés suppriment leurs données

### Requêtes typiques maîtrisées

- [ ] **Galerie publique**
  - [ ] Requête pour afficher toutes les photos publiées
  - [ ] Inclusion des informations vendeur
  - [ ] Comptage des achats par photo
  - [ ] Tri par date de création

- [ ] **Dashboard vendeur**
  - [ ] Statistiques de vente par utilisateur
  - [ ] Revenus total calculé
  - [ ] Nombre de photos par vendeur
  - [ ] Photos les plus vendues

- [ ] **Historique acheteur**
  - [ ] Liste des achats par utilisateur
  - [ ] Informations des photos achetées
  - [ ] Informations des vendeurs
  - [ ] Tri chronologique

### Optimisations

- [ ] **Index automatiques identifiés**
  - [ ] Index sur clés primaires
  - [ ] Index sur clés étrangères
  - [ ] Index sur contraintes uniques

- [ ] **Index supplémentaires analysés**
  - [ ] Index composé status + createdAt pour photos
  - [ ] Index sur prix pour recherches
  - [ ] Index sur userId + createdAt pour achats
  - [ ] Index sur photoId + createdAt pour statistiques

## Checklist de validation pratique

### Tests obligatoires à réussir

- [ ] **Test 1 : Connexion et structure**
```bash
node -e "const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();p.\$connect().then(()=>console.log('✅')).catch(()=>console.log('❌')).finally(()=>p.\$disconnect());"
```

- [ ] **Test 2 : Comptage des tables**
```bash
node -e "const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();Promise.all([p.user.count(),p.photo.count(),p.purchase.count()]).then(([u,ph,pu])=>console.log('Users:',u,'Photos:',ph,'Purchases:',pu)).finally(()=>p.\$disconnect());"
```

- [ ] **Test 3 : Relations avec include**
```bash
node -e "const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();p.user.findMany({include:{_count:{select:{photos:true,purchases:true}}}}).then(u=>console.log('Relations testées:',u.length,'utilisateurs')).finally(()=>p.\$disconnect());"
```

- [ ] **Test 4 : Requête complexe**
```bash
node -e "const{PrismaClient}=require('@prisma/client');const p=new PrismaClient();p.photo.findMany({include:{user:{select:{name:true}},_count:{select:{purchases:true}}}}).then(ph=>console.log('Photos avec vendeurs:',ph.length)).finally(()=>p.\$disconnect());"
```

### Vérifications visuelles

- [ ] **Prisma Studio accessible**
  - [ ] URL http://localhost:5555 ouverte
  - [ ] 6 tables visibles (users, photos, purchases, accounts, sessions, verificationtokens)
  - [ ] Relations cliquables entre tables
  - [ ] Données de test visibles (si ajoutées)

- [ ] **Neon Dashboard vérifié**
  - [ ] Tables créées dans l'onglet "Tables"
  - [ ] Requêtes visibles dans l'onglet "Queries"
  - [ ] Connexions actives dans "Monitoring"

## Checklist de compréhension avancée

### Scénarios métier maîtrisés

- [ ] **Scénario 1 : Alice vend, Bob achète**
  - [ ] Alice upload une photo (User → Photo)
  - [ ] Bob achète la photo (User → Purchase, Photo → Purchase)
  - [ ] Revenus d'Alice calculables
  - [ ] Historique de Bob consultable

- [ ] **Scénario 2 : Authentification multi-comptes**
  - [ ] User connecté avec Google (User → Account)
  - [ ] Même user connecté avec GitHub (User → Account)
  - [ ] Sessions multiples gérées (User → Session)

- [ ] **Scénario 3 : Gestion admin**
  - [ ] Utilisateur avec rôle ADMIN identifiable
  - [ ] Toutes les photos accessibles pour admin
  - [ ] Tous les achats visibles pour admin

### Requêtes business comprises

- [ ] **Analytics vendeur**
  - [ ] Top 10 des vendeurs par revenus
  - [ ] Photos les plus populaires
  - [ ] Évolution des ventes dans le temps
  - [ ] Panier moyen par acheteur

- [ ] **Analytics plateforme**
  - [ ] Revenus total de la plateforme
  - [ ] Nombre d'utilisateurs actifs
  - [ ] Photos les plus rentables
  - [ ] Taux de conversion visiteur → acheteur

## Dépannage PowerShell (Windows)

### Tests PowerShell spécifiques

- [ ] **Test connexion PowerShell**
```powershell
node -e "const{PrismaClient}=require('@prisma/client');new PrismaClient().\$connect().then(()=>Write-Host '✅ OK' -ForegroundColor Green).catch(()=>Write-Host '❌ ERREUR' -ForegroundColor Red)"
```

- [ ] **Vérification variables PowerShell**
```powershell
Get-Content .env | Select-String "DATABASE_URL|NEXTAUTH"
if ($?) { Write-Host "✅ Variables trouvées" } else { Write-Host "❌ Variables manquantes" }
```

- [ ] **Test Prisma Studio PowerShell**
```powershell
Start-Process "npx" -ArgumentList "prisma studio" -WindowStyle Hidden
Start-Sleep 3
$prismaProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*prisma studio*" }
if ($prismaProcess) { 
    Write-Host "✅ Prisma Studio démarré" 
    Stop-Process $prismaProcess -Force
} else { 
    Write-Host "❌ Problème démarrage Prisma Studio" 
}
```

## Annexe 2 : Checklist CMD (Command Prompt)

### Tests CMD obligatoires

- [ ] **Test basique CMD**
```cmd
node -e "console.log('Test Node.js OK')"
```

- [ ] **Test Prisma CMD**
```cmd
node -e "try{require('@prisma/client');console.log('✅ Prisma Client OK')}catch(e){console.log('❌ Prisma manquant')}"
```

- [ ] **Test variables CMD**
```cmd
findstr "DATABASE_URL" .env >nul && echo ✅ DATABASE_URL trouvée || echo ❌ DATABASE_URL manquante
findstr "NEXTAUTH_SECRET" .env >nul && echo ✅ NEXTAUTH_SECRET trouvée || echo ❌ NEXTAUTH_SECRET manquante
```

- [ ] **Test connexion DB CMD**
```cmd
node -e "const{PrismaClient}=require('@prisma/client');new PrismaClient().$connect().then(()=>console.log('✅ DB OK')).catch(e=>console.log('❌ DB ERREUR:',e.message))"
```

### Vérifications système CMD

- [ ] **Processus Node.js**
```cmd
tasklist /FI "IMAGENAME eq node.exe" | find "node.exe" >nul && echo ✅ Node.js actif || echo ❌ Node.js inactif
```

- [ ] **Ports utilisés**
```cmd
netstat -ano | findstr :3000 >nul && echo ✅ Port 3000 utilisé || echo Port 3000 libre
netstat -ano | findstr :5555 >nul && echo ✅ Prisma Studio actif || echo Prisma Studio inactif
```

- [ ] **Fichiers présents**
```cmd
if exist "prisma\schema.prisma" (echo ✅ Schema Prisma présent) else (echo ❌ Schema manquant)
if exist ".env" (echo ✅ Fichier .env présent) else (echo ❌ .env manquant)
if exist "node_modules\@prisma\client" (echo ✅ Client Prisma installé) else (echo ❌ Client manquant)
```

## Validation finale

### Critères de réussite

✅ **L'étape 3 est RÉUSSIE si :**

1. **Compréhension théorique** : Tous les types de relations sont maîtrisés
2. **Analyse pratique** : Le diagramme ERD est compris et mémorisé
3. **Tests techniques** : Toutes les requêtes de test fonctionnent
4. **Validation visuelle** : Prisma Studio affiche correctement la structure
5. **Scénarios métier** : Les cas d'usage PhotoMarket sont clairs

### Prêt pour l'étape suivante

- [ ] **Étape 4 préparée** : NextAuth.js configuration
  - [ ] Relations User/Account/Session comprises
  - [ ] Structure d'authentification claire
  - [ ] Rôles USER/ADMIN identifiés

Une fois cette checklist complètement validée, vous pouvez passer à l'**Étape 4 : Configuration NextAuth.js** en toute confiance !