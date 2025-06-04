# 🔍 Simulation BFS (Breadth-First Search) - GAMA - TP NOTÉ SMA & IA

## 📋 Description

Cette simulation implémente l'algorithme de **recherche en largeur (BFS)** dans l'environnement GAMA. Elle visualise de manière interactive et pédagogique le processus de recherche de chemin optimal entre deux points dans un graphe avec obstacles.

### 🎯 Objectifs pédagogiques
- Comprendre le fonctionnement de l'algorithme BFS
- Visualiser la propagation de l'exploration en "vagues"
- Analyser l'efficacité de la recherche selon différents paramètres
- Observer l'impact des obstacles sur la connectivité du graphe

## ✨ Fonctionnalités

### 🖥️ Interface multi-displays
- **🔍 Graphe BFS** : Visualisation principale avec animation temps réel
- **📋 Légende** : Guide complet des éléments visuels
- **📊 Statistiques** : Métriques détaillées de la simulation
- **📈 Évolution** : Graphiques de progression en temps réel
- **🎯 Vue d'ensemble** : Résumé compact de l'état

### 🎨 Visualisation avancée
- **Animation fluide** avec effets de vague BFS
- **Codage couleur** intelligent selon les niveaux d'exploration
- **Obstacles variés** (cercles et rectangles)
- **Chemin optimal** mis en évidence
- **Zone d'exploration** (enveloppe convexe)

### ⚙️ Paramètres configurables
- **Nombre de points** (10-200)
- **Nombre de voisins** par nœud (2-8)
- **Nombre d'obstacles** (0-30)
- **Rayon des obstacles** (2.0-10.0)
- **Options visuelles** (animation, distances, connexions)

## 🚀 Installation et utilisation

### Prérequis
- **GAMA Platform** (version 1.8.2 ou supérieure)
- Système d'exploitation : Windows, macOS, ou Linux

### Installation
1. Téléchargez et installez [GAMA Platform](https://gama-platform.org/)
2. Clonez ou téléchargez ce projet
3. Ouvrez GAMA et importez le projet
4. Ouvrez le fichier `BFS_Simulation.gaml`

### Lancement
1. Cliquez sur l'onglet **"Experiments"**
2. Sélectionnez **"BFS_Enhanced_Experiment"**
3. Ajustez les paramètres selon vos besoins
4. Cliquez sur **"Launch"** pour démarrer la simulation

## 🎮 Guide d'utilisation

### 🎛️ Paramètres recommandés

#### Configuration basique (débutants)
```
Nombre de points: 30
Nombre de voisins: 4
Nombre d'obstacles: 5
Animation lente: activée
```

#### Configuration avancée (analyse)
```
Nombre de points: 100
Nombre de voisins: 6
Nombre d'obstacles: 15
Toutes les options visuelles: activées
```

### 📊 Lecture des résultats

#### Codes couleur des nœuds
- 🟢 **Vert** : Point de départ (START)
- 🔴 **Rouge** : Point de destination (GOAL)
- 🟡 **Jaune** : Nœud en cours d'exploration
- 🔵 **Bleu dégradé** : Nœuds visités (couleur = niveau BFS)
- 🟣 **Violet** : Chemin optimal final

#### Métriques importantes
- **Étape actuelle** : Nombre d'itérations BFS
- **Progression** : Pourcentage de nœuds explorés
- **Efficacité** : Ratio chemin optimal / nœuds explorés
- **Temps d'exécution** : Performance de l'algorithme

## 🔧 Structure du code

### 📁 Architecture
```
BFS_Simulation.gaml
├── 🌐 Modèle global
│   ├── Paramètres de configuration
│   ├── Variables d'état BFS
│   ├── Initialisation du graphe
│   └── Boucle principale BFS
├── 🎭 Espèce noeud
│   ├── Attributs visuels
│   ├── Aspects de rendu
│   └── Logique de connexion
└── 🧪 Expérience
    ├── Interface utilisateur
    ├── Displays multiples
    └── Moniteurs temps réel
```

### 🔄 Algorithme BFS implémenté

1. **Initialisation**
   - Création du graphe avec obstacles
   - Sélection des points départ/destination
   - Initialisation de la file d'attente

2. **Boucle principale**
   - Extraction du premier nœud de la file
   - Vérification si c'est la destination
   - Exploration des voisins non visités
   - Ajout des nouveaux nœuds à la file

3. **Finalisation**
   - Reconstruction du chemin optimal
   - Calcul des statistiques
   - Affichage des résultats

## 📈 Analyses possibles

### 🧮 Études de performance
- Impact du nombre de voisins sur l'efficacité
- Influence des obstacles sur la connectivité
- Comparaison temps d'exécution vs taille du graphe

### 🎯 Cas d'usage pédagogiques
- **Cours d'algorithmique** : Démonstration BFS vs DFS
- **Théorie des graphes** : Analyse de connectivité
- **Intelligence artificielle** : Recherche de chemin
- **Optimisation** : Comparaison d'heuristiques

## 🛠️ Personnalisation

### 🎨 Modifications visuelles
```gama
// Changer les couleurs
rgb couleur_depart <- #green;
rgb couleur_destination <- #red;
rgb couleur_chemin <- #purple;

// Ajuster les tailles
float taille_noeud <- 2.0;
float epaisseur_connexion <- 1.5;
```

### ⚙️ Paramètres algorithme
```gama
// Critères d'arrêt personnalisés
int max_iterations <- 1000;
float timeout_seconds <- 30.0;

// Stratégies de connexion
bool connexion_euclidienne <- true;
bool eviter_croisements <- false;
```

## 🐛 Dépannage

### ❌ Erreurs communes

#### "Type mismatch in string concatenation"
**Solution** : Utilisez `string()` pour convertir les nombres
```gama
// ❌ Incorrect
draw "Valeur: " + ma_variable;

// ✅ Correct
draw "Valeur: " + string(ma_variable);
```

#### "No path found"
**Causes possibles** :
- Trop d'obstacles bloquant les connexions
- Points départ/destination isolés
- Nombre de voisins trop faible

**Solutions** :
- Réduire le nombre d'obstacles
- Augmenter le nombre de voisins
- Vérifier la connectivité du graphe

#### Performance lente
**Optimisations** :
- Réduire le nombre de points
- Désactiver l'animation lente
- Limiter les displays actifs

## 📚 Resources supplémentaires

### 📖 Documentation
- [GAMA Documentation](https://gama-platform.org/wiki/Home)
- [Algorithme BFS](https://en.wikipedia.org/wiki/Breadth-first_search)
- [Théorie des graphes](https://en.wikipedia.org/wiki/Graph_theory)

### 🎓 Exercices proposés
1. **Modifier** l'algorithme pour implémenter DFS
2. **Ajouter** des poids aux arêtes (Dijkstra)
3. **Implémenter** A* avec heuristique
4. **Créer** des obstacles dynamiques
5. **Comparer** les performances de différents algorithmes

### 🔗 Extensions possibles
- **Multi-agents** : Plusieurs recherches simultanées
- **Graphes dirigés** : Connexions unidirectionnelles
- **Coûts variables** : Terrains difficiles
- **Recherche bidirectionnelle** : Départ et destination simultanés

## 👥 Contribution

### 🤝 Comment contribuer
1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

### 📝 Conventions de code
- **Variables** : snake_case
- **Fonctions** : camelCase
- **Commentaires** : Français ou Anglais
- **Indentation** : 4 espaces

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🙏 Remerciements

- **GAMA Platform** pour l'excellent environnement de simulation
- **Communauté GAMA** pour le support et les exemples
- **Algorithmes classiques** pour l'inspiration pédagogique

---

## 📞 Contact

Pour toute question ou suggestion :
- 📧 Email : yvalttnomdecode@gmail.com
- 🐛 Issues : https://github.com/Tchoutouo/BFS_Simulation/tree/main/.github/ISSUE_TEMPLATE

---

*Développé avec ❤️ pour l'apprentissage de l'algorithmique dans le cadre d'un TP noté📚 du cours Systèmes multi agents et Intelligence artificielle * 