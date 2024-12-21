# C-Wire - Gestion et Analyse de Données de Stations

## Description
**C-Wire** est une application permettant de traiter et d'analyser des données provenant de différentes stations électriques. Elle intègre un script Shell pour l'orchestration et un programme en C basé sur des arbres AVL pour le traitement des données.

---

## Structure du Projet

```plaintext
├── README.md            # Ce fichier d'instructions
├── c-wire.sh            # Script Shell principal
├── codeC/
│   ├── main.c           # Point d'entrée du programme C
│   ├── avl_file.c       # Gestion des fichiers CSV
│   ├── avl_operations.c # Opérations sur l'arbre AVL
│   ├── avl_tree.h       # En-tête du programme
|   ├── makefile         # Fichier Makefile pour compiler le programme C
├── input/               # Contient les fichiers d'entrée
├── tmp/                 # Fichiers temporaires générés pendant l'exécution
├── graphs/              # Graphiques générés
├── tests/               # Résultats des tests et exécutions précédentes


Prérequis
GNU Make pour la compilation.
Compilateur GCC pour compiler le programme C.
Bash Shell pour exécuter le script.

Installation
Cloner le dépôt :

bash
Copier le code
git clone <url-du-depot>
cd <nom-du-dossier>
Compiler le programme C :

bash
Copier le code
make -C codeC/

Utilisation
Commande de base
bash
Copier le code
./c-wire.sh <chemin_csv> <type_station> <type_consommateur> [id_centrale] [-h]
Options
Argument	Description
<chemin_csv>	Chemin du fichier CSV d'entrée (obligatoire).
<type_station>	Type de station : hvb, hva, lv (obligatoire).
<type_consommateur>	Type de consommateur : comp, indiv, all (obligatoire).
[id_centrale]	Identifiant de la centrale : 1, 2, 3, 4, 5, min_max (optionnel).
-h	Affiche l'aide.
Exemples
Traitement complet d'une station LV :

bash
Copier le code
./c-wire.sh input/data.csv lv all
Filtrage pour une station spécifique :

bash
Copier le code
./c-wire.sh input/data.csv lv comp 1
Mode min_max :

bash
Copier le code
./c-wire.sh input/data.csv lv all min_max
Fonctionnalités
Traitement des Données :
Trie les données par capacité ou consommation.
Identifie les 10 stations les plus chargées et les 10 moins chargées.
Gestion des Fichiers :
Les fichiers temporaires sont placés dans tmp/.
Les résultats sont stockés dans tests/.
Rapport de Temps :
Affiche la durée utile des traitements à la fin de l'exécution.
Nettoyage
Pour supprimer les fichiers générés, utilisez :

bash
Copier le code
make -C codeC/ clean
