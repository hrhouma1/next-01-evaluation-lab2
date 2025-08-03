# Checklist - Étape 1 : Initialisation Next.js

## Prérequis

- [ ] Node.js version 18 ou supérieure installée
- [ ] npm ou yarn installé
- [ ] Git installé et configuré
- [ ] Éditeur de code (VS Code recommandé)

## Étapes d'exécution

### Installation du projet

- [ ] Exécuter la commande `npx create-next-app@latest`
- [ ] Confirmer toutes les options (TypeScript, Tailwind, ESLint, App Router, src/, alias @/)
- [ ] Naviguer dans le dossier du projet `cd photo-marketplace`
- [ ] **IMPORTANT**: Forcer l'installation de Tailwind CSS 3 (pas v4)
- [ ] Vérifier que la version de Tailwind CSS est bien 3.x.x avec `npm list tailwindcss`
- [ ] Créer `src/app/globals.css` s'il n'existe pas
- [ ] Ajouter les directives Tailwind dans `globals.css`

### Vérification de la structure

- [ ] Vérifier que `src/app/globals.css` existe et contient les directives Tailwind
- [ ] Vérifier que `src/app/layout.tsx` importe `globals.css`
- [ ] Vérifier que `tailwind.config.js` est à la racine du projet
- [ ] Vérifier la structure complète avec `tree src/` ou `ls -la src/app/`

### Vérification de l'installation

- [ ] Lancer `npm run dev`
- [ ] Ouvrir http://localhost:3000 dans le navigateur
- [ ] Vérifier que la page Next.js par défaut s'affiche
- [ ] Vérifier qu'il n'y a pas d'erreurs dans la console

### Tests de configuration

- [ ] **TypeScript** : Aucune erreur TypeScript visible
- [ ] **Tailwind CSS** : Classes CSS Tailwind fonctionnelles
- [ ] **ESLint** : Aucune erreur de linting
- [ ] **Hot reload** : Modifications détectées automatiquement

### Test Tailwind CSS

- [ ] Modifier `src/app/page.tsx` avec le composant de test
- [ ] Vérifier que la page affiche un fond gris avec un texte bleu centré
- [ ] Vérifier que la boîte blanche avec ombre s'affiche correctement
- [ ] Confirmer que Tailwind CSS 3 fonctionne

### Initialisation Git

- [ ] Initialiser le dépôt Git si pas déjà fait : `git init`
- [ ] Ajouter tous les fichiers : `git add .`
- [ ] Premier commit : `git commit -m "Initial commit - Next.js 14 setup"`
- [ ] Créer un dépôt GitHub
- [ ] Pousser le code : `git push origin main`

## Validation finale

- [ ] Le projet démarre sans erreur avec `npm run dev`
- [ ] La page d'accueil est accessible sur http://localhost:3000
- [ ] La structure des dossiers est conforme (src/, app/, etc.)
- [ ] Le code est versionné sur GitHub

## Temps estimé

**Durée** : 15-20 minutes

## Dépannage Windows PowerShell

### Commandes à connaître (Windows)

- [ ] Savoir lister les processus Node.js : `Get-Process node`
- [ ] Savoir tuer les processus bloqués : `Get-Process node | Stop-Process -Force`
- [ ] Savoir vérifier le port 3000 : `netstat -ano | findstr :3000`
- [ ] Savoir libérer le port automatiquement :
  ```powershell
  $port = 3000
  Get-NetTCPConnection -LocalPort $port | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
  ```

## En cas de problème

### Erreurs courantes

1. **Port 3000 occupé**
   - Solution simple : `npm run dev -- -p 3001`
   - Solution PowerShell : `Get-Process node | Stop-Process -Force`

2. **Processus Node.js bloqué**
   - Solution PowerShell : `Get-Process node | Stop-Process -Force`
   - Puis : `npm run dev`

3. **Erreurs de cache npm**
   - Solution : `npm cache clean --force`
   - PowerShell : `Remove-Item -Recurse -Force node_modules; npm install`

4. **Problèmes de permissions**
   - Solution : Vérifier les droits du dossier
   - Redémarrer PowerShell en tant qu'administrateur si nécessaire

### Support

- Documentation Next.js : https://nextjs.org/docs
- Communauté Discord Next.js
- Stack Overflow avec tag "next.js"

## Résultat attendu

Un projet Next.js 14 fonctionnel avec :
- TypeScript configuré
- Tailwind CSS 3 actif
- App Router activé
- Structure src/ en place
- Imports absolus avec @/

## Annexe 2 : Commandes CMD (Command Prompt)

### Alternative CMD aux commandes PowerShell

Si vous préférez utiliser CMD :

**Processus Node.js** :
```cmd
tasklist | findstr node                  → Voir processus Node.js
tasklist /fi "imagename eq node.exe"     → Filtrer processus Node.js
taskkill /f /im node.exe                 → Tuer tous processus Node.js
taskkill /f /im node.exe /t              → Tuer avec processus enfants
taskkill /f /im "node*"                  → Tuer tous processus node*
wmic process where "name='node.exe'" delete → Alternative WMIC
taskkill /f /pid [PID]                   → Tuer processus spécifique
```

**Port 3000** :
```cmd
netstat -ano | findstr :3000             → Vérifier port 3000
for /f "tokens=5" %a in ('netstat -ano ^| findstr :3000') do taskkill /f /pid %a  → Libérer port
```

**Nettoyage** :
```cmd
rmdir /s /q node_modules                 → Supprimer node_modules
rmdir /s /q .next                        → Supprimer cache Next.js
npm cache clean --force                  → Nettoyer cache npm
```

### Checklist CMD supplémentaire

- [ ] Savoir lister les processus : `tasklist | findstr node`
- [ ] Savoir tuer les processus : `taskkill /f /im node.exe`
- [ ] Savoir vérifier le port : `netstat -ano | findstr :3000`
- [ ] Savoir supprimer les dossiers : `rmdir /s /q node_modules`