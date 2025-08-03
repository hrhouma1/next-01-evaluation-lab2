# Étape 1 : Initialisation du projet Next.js avec TypeScript

## Phase 1 - Configuration initiale du projet

### Objectif

Avoir un projet Next.js 14 fonctionnel avec App Router, TypeScript et Tailwind CSS 3.

**Note importante** : Nous utilisons spécifiquement Tailwind CSS 3 (pas la v4) pour assurer la compatibilité avec l'ensemble du projet et éviter les changements breaking de la v4.

### Technologies utilisées

- Next.js 14 avec App Router
- TypeScript
- Tailwind CSS 3
- ESLint
- Structure src/ directory

### Instructions d'installation

#### 1. Créer le projet

```bash
# Créer le projet avec toutes les bonnes options
npx create-next-app@latest photo-marketplace --typescript --tailwind --eslint --app --src-dir --import-alias="@/*"
```

#### 2. Naviguer dans le projet et forcer Tailwind CSS 3

```bash
cd photo-marketplace

# IMPORTANT: S'assurer d'utiliser Tailwind CSS 3 (pas la v4)
npm uninstall tailwindcss
npm install tailwindcss@^3.4.0 postcss autoprefixer
npx tailwindcss init -p
```

#### 3. Vérifier que tout fonctionne

```bash
# Lancer le serveur de développement
npm run dev
```

L'application devrait être accessible sur http://localhost:3000

### Options de configuration expliquées

- `--typescript` : Active TypeScript pour un développement plus robuste
- `--tailwind` : Installe et configure Tailwind CSS 3
- `--eslint` : Configure ESLint pour la qualité du code
- `--app` : Utilise le nouveau App Router de Next.js 14
- `--src-dir` : Place le code source dans un dossier src/
- `--import-alias="@/*"` : Configure les imports absolus avec @/

### Structure attendue après création

```
photo-marketplace/
├── src/
│   ├── app/
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx
│   └── (autres dossiers src/)
├── public/
├── package.json
├── tsconfig.json
├── tailwind.config.ts
├── next.config.js
└── README.md
```


#### 4. Résolution des erreurs

```bash
# Lancer le serveur de développement
npm run dev
```


L’erreur suivante indique que **Tailwind CSS n’est pas installé** dans ton projet :

```
Module not found: Can't resolve 'tailwindcss'
```

Cela vient du fichier `globals.css` (ou équivalent) qui tente d'importer Tailwind via :

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

Mais `tailwindcss` n’est **pas présent dans `node_modules`**.



###  Solution : installer Tailwind CSS correctement

Exécute **ces 4 commandes** à la racine de ton projet :

```bash
npm uninstall tailwindcss
npm install tailwindcss@^3.4.0 postcss autoprefixer
npx tailwindcss init -p
```

Cela va :

* installer les dépendances manquantes
* créer les fichiers `tailwind.config.js` et `postcss.config.js`


###  Étapes supplémentaires à vérifier

1. **tailwind.config.js** doit inclure les bons chemins (pour Next.js 13+ avec App Router) :

```js
// tailwind.config.js
module.exports = {
  content: [
    "./src/app/**/*.{js,ts,jsx,tsx}",
    "./src/components/**/*.{js,ts,jsx,tsx}"
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

2. **globals.css** doit inclure les directives suivantes :

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

3. Ton fichier **`src/app/layout.tsx` ou `layout.js`** doit importer le fichier CSS global :

```tsx
import './globals.css'
```



###  Redémarrer le serveur

Après installation, redémarre ton serveur Next.js :

```bash
npm run dev
```



###  Test rapide

Tu peux tester Tailwind avec ce composant :

```tsx
export default function Home() {
  return (
    <div className="text-3xl font-bold text-blue-600">
      Hello Tailwind!
    </div>
  );
}
```





### Vérifications à effectuer

1. **Page d'accueil accessible** : http://localhost:3000 doit afficher la page Next.js par défaut
2. **TypeScript fonctionnel** : Aucune erreur TypeScript dans les fichiers .tsx
3. **Tailwind CSS actif** : Les styles Tailwind doivent être appliqués
4. **Hot reload** : Les modifications doivent s'afficher automatiquement

### Livrables

- [ ] Projet Next.js initialisé et fonctionnel
- [ ] Première page d'accueil qui s'affiche correctement
- [ ] Configuration TypeScript, Tailwind CSS et ESLint active
- [ ] Commit initial sur GitHub

### Prochaines étapes

Une fois cette étape terminée, vous pourrez passer à l'étape 2 : Configuration de Prisma avec Neon PostgreSQL.

### Dépannage courant

#### Erreur de permission Node.js
```bash
# Si erreur de permission
npm cache clean --force
```

#### Port 3000 déjà utilisé
```bash
# Utiliser un autre port
npm run dev -- -p 3001
```

### Ressources

- [Documentation Next.js 14](https://nextjs.org/docs)
- [Documentation TypeScript](https://www.typescriptlang.org/docs/)
- [Documentation Tailwind CSS](https://tailwindcss.com/docs)
