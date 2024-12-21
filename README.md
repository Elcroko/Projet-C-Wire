# C-Wire

## Description

C-Wire est une application shell et C conçue pour analyser et traiter des données liées à des stations électriques de types `hvb`, `hva` et `lv` (Haute et Basse Tension). Elle inclut des fonctionnalités d'analyse avancée et de gestion des données avec des rapports détaillés.

---

## Fonctionnalités

- **Analyse par type de station** : `hvb`, `hva`, `lv`.
- **Support des consommateurs** : `comp`, `indiv`, `all`.
- **Options avancées** :
  - Génération des 10 postes LV avec le plus de consommation et les 10 avec le moins.
  - Tri des données par capacité ou par consommation.
- **Gestion des fichiers temporaires et résultats** :
  - Données intermédiaires stockées dans un dossier `tmp`.
  - Résultats dans `tests` ou fichiers spécifiques.
- **Performance** : Calculs rapides grâce à des structures AVL en C.

---

## Prérequis

- **Système d'exploitation** : Linux.
- **Logiciels requis** :
  - `gcc` pour la compilation.
  - `make` pour gérer la compilation.
  - `bash` pour exécuter le script shell.

---

## Installation

1. Clonez ce dépôt :
   ```bash
   git clone <URL_DU_DEPOT>
   cd c-wire
