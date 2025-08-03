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

### Structure complète du projet Next.js 14

```
photo-marketplace/
├── src/                          ← Dossier source principal
│   ├── app/                      ← App Router (Next.js 14)
│   │   ├── globals.css           ← CSS global avec Tailwind
│   │   ├── layout.tsx            ← Layout principal (importe globals.css)
│   │   ├── page.tsx              ← Page d'accueil
│   │   └── favicon.ico           ← Favicon
│   ├── components/               ← Composants réutilisables (à créer)
│   └── lib/                      ← Utilitaires (à créer plus tard)
├── public/                       ← Fichiers statiques
│   ├── next.svg
│   └── vercel.svg
├── node_modules/                 ← Dépendances npm
├── package.json                  ← Configuration npm
├── package-lock.json             ← Verrouillage des versions
├── tsconfig.json                 ← Configuration TypeScript
├── tailwind.config.js            ← Configuration Tailwind CSS
├── postcss.config.js             ← Configuration PostCSS
├── next.config.js                ← Configuration Next.js
├── eslint.config.js              ← Configuration ESLint
└── README.md                     ← Documentation
```

**Fichiers clés à retenir** :
- `src/app/layout.tsx` : Layout principal qui importe `globals.css`
- `src/app/globals.css` : CSS global avec directives Tailwind
- `src/app/page.tsx` : Page d'accueil
- `tailwind.config.js` : Configuration Tailwind (racine)


### Dépannage courant

#### Erreur "Can't resolve 'tailwindcss'"

L'erreur suivante indique que **Tailwind CSS n'est pas installé** dans votre projet :

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



**Solution** : installer Tailwind CSS correctement

Exécutez **ces commandes** à la racine de votre projet :

```bash
npm uninstall tailwindcss
npm install tailwindcss@^3.4.0 postcss autoprefixer
npx tailwindcss init -p
```

Cela va :

* installer les dépendances manquantes
* créer les fichiers `tailwind.config.js` et `postcss.config.js` à la racine

**Important** : Si `create-next-app` n'a pas créé `globals.css`, créez-le manuellement :

```bash
# Créer le fichier globals.css s'il n'existe pas
touch src/app/globals.css
```

Ou créez-le via votre éditeur de code dans `src/app/globals.css`


**Étapes supplémentaires à vérifier** :

1. **tailwind.config.js** (à la racine du projet) doit inclure les bons chemins :

```
photo-marketplace/
├── tailwind.config.js  ← ICI
├── src/
└── package.json
```

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

2. **src/app/globals.css** doit inclure les directives Tailwind :

```
photo-marketplace/
├── src/
│   ├── app/
│   │   ├── globals.css  ← ICI
│   │   ├── layout.tsx
│   │   └── page.tsx
│   └── components/
└── package.json
```

```css
/* src/app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Vous pouvez ajouter vos styles personnalisés ici */
```

**Note** : Si le fichier `globals.css` n'existe pas, créez-le manuellement dans `src/app/`

3. **src/app/layout.tsx** doit importer le fichier CSS global :

```
photo-marketplace/
├── src/
│   ├── app/
│   │   ├── globals.css
│   │   ├── layout.tsx  ← ICI
│   │   └── page.tsx
│   └── components/
└── package.json
```

```tsx
// src/app/layout.tsx
import './globals.css'  // ← Import du CSS global

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body>
        {children}
      </body>
    </html>
  )
}
```



**Redémarrer le serveur** :

Après installation, redémarrez votre serveur Next.js :

```bash
npm run dev
```



**Test rapide** :

Modifiez le fichier **src/app/page.tsx** pour tester Tailwind :

```
photo-marketplace/
├── src/
│   ├── app/
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx  ← MODIFIER ICI
│   └── components/
└── package.json
```

```tsx
// src/app/page.tsx
export default function Home() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="text-3xl font-bold text-blue-600 bg-white p-8 rounded-lg shadow-lg">
        Hello Tailwind CSS 3!
      </div>
    </div>
  );
}
```

**Résultat attendu** : 
- Page avec fond gris clair
- Texte bleu, gros et en gras, centré
- Boîte blanche avec ombre portée
- Si vous voyez ce style → Tailwind CSS fonctionne ! ✅





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

### Autres problèmes courants

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
