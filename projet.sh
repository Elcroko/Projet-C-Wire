#!/bin/bash

# Fonction d'aide
function afficher_aide {
    echo "Utilisation : ./c-wire.sh <chemin_csv> <type_station> <type_consommateur> [id_centrale] [-h]"
    echo "\nOptions :"
    echo "  <chemin_csv>         Chemin du fichier CSV d'entrée (obligatoire)"
    echo "  <type_station>       Type de station à traiter (hvb, hva, lv) (obligatoire)"
    echo "  <type_consommateur>  Type de consommateur à traiter (comp, indiv, all) (obligatoire)"
    echo "  [id_centrale]        Identifiant de la centrale (optionnel)"
    echo "  -h                   Affiche cette aide (optionnel)"
    echo "\nRègles :"
    echo "  - Les options hvb all, hvb indiv, hva all, hva indiv sont interdites."
    echo "  - Le fichier de sortie est trié par capacité croissante."
    echo "\nExemples :"
    echo "  ./c-wire.sh data.csv lv all"
    echo "  ./c-wire.sh data.csv hvb comp"
    echo "  ./c-wire.sh data.csv lv all minmax"
    echo "  ./c-wire.sh data.csv hva comp centrale1"
    exit 0
}

# Vérifier si l'exécutable C existe, sinon compiler
function verifier_et_compiler {
    local executable="avl_tree"
    local source="avl_tree.c"

    if [ ! -f "$executable" ]; then
        echo "Compilation du programme C..."
        gcc -o "$executable" "$source"
        if [ $? -ne 0 ]; then
            echo "Erreur : La compilation du programme C a échoué. Vérifiez le code source."
            echo "Temps utile de traitement : 0.0 secondes"
            exit 1
        fi
    fi
}

# Fonction pour valider les arguments et afficher une erreur en cas de problème
function valider_arguments {
    if [ $# -lt 3 ]; then
        echo "Erreur : Paramètres insuffisants. Vous devez fournir au moins le chemin du fichier, le type de station, et le type de consommateur."
        afficher_aide
        echo "Temps utile de traitement : 0.0 secondes"
        exit 1
    fi

    if [ ! -f "$1" ]; then
        echo "Erreur : Le fichier '$1' est introuvable ou inaccessible."
        afficher_aide
        echo "Temps utile de traitement : 0.0 secondes"
        exit 1
    fi

    if [[ ! "$2" =~ ^(hvb|hva|lv)$ ]]; then
        echo "Erreur : Type de station invalide. Les valeurs acceptées sont : hvb, hva, lv."
        afficher_aide
        echo "Temps utile de traitement : 0.0 secondes"
        exit 1
    fi

    if [[ ! "$3" =~ ^(comp|indiv|all)$ ]]; then
        echo "Erreur : Type de consommateur invalide. Les valeurs acceptées sont : comp, indiv, all."
        afficher_aide
        echo "Temps utile de traitement : 0.0 secondes"
        exit 1
    fi

    if ([ "$2" == "hvb" ] || [ "$2" == "hva" ]) && ([ "$3" == "all" ] || [ "$3" == "indiv" ]); then
        echo "Erreur : Les options '$2 $3' sont interdites. Seules les entreprises sont connectées aux stations HV-B et HV-A."
        afficher_aide
        echo "Temps utile de traitement : 0.0 secondes"
        exit 1
    fi
}
