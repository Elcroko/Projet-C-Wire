# C-Wire - Gestion et Analyse de Données de Stations

## Description
**C-Wire** est une application permettant de traiter et d'analyser des données provenant de différentes stations électriques. Elle intègre un script Shell pour l'orchestration et un programme en C basé sur des arbres AVL pour le traitement des données.

---

## Structure du Projet

```plaintext
├── README.md           # Ce fichier d'instructions
├── c-wire.sh           # Script Shell principal
├── makefile            # Fichier Makefile pour compiler le programme C
├── codeC/
│   ├── main.c          # Point d'entrée du programme C
│   ├── avl_file.c      # Gestion des fichiers CSV
│   ├── avl_operations.c# Opérations sur l'arbre AVL
│   ├── avl_tree.h      # En-tête du programme
├── input/              # Contient les fichiers d'entrée
├── tmp/                # Fichiers temporaires générés pendant l'exécution
├── graphs/             # Graphiques générés
├── tests/              # Résultats des tests et exécutions précédentes
