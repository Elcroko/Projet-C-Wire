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


# Vérification et compilation de l'exécutable C
function verifier_et_compiler {
    local executable="avl_tree"
    local source="avl_tree.c"

    if [ ! -f "$executable" ]; then
        echo "L'exécutable C '$executable' est introuvable. Compilation en cours..."
        gcc -o "$executable" "$source"
        if [ $? -ne 0 ]; then
            echo "Erreur : La compilation du programme C a échoué. Vérifiez le fichier source $source."
            exit 1
        else
            echo "Compilation réussie. L'exécutable '$executable' est prêt."
        fi
    else
        echo "L'exécutable C '$executable' est déjà présent."
    fi
}

# Fonction pour valider les arguments et afficher une erreur en cas de problème
function valider_arguments {
    if [ $# -lt 3 ]; then
        echo "Erreur : Paramètres insuffisants. Vous devez fournir au moins le chemin du fichier, le type de station, et le type de consommateur."
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    if [ ! -f "$1" ]; then
        echo "Erreur : Le fichier '$1' est introuvable ou inaccessible."
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    if [[ ! "$2" =~ ^(hvb|hva|lv)$ ]]; then
        echo "Erreur : Type de station invalide. Les valeurs acceptées sont : hvb, hva, lv."
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    if [[ ! "$3" =~ ^(comp|indiv|all)$ ]]; then
        echo "Erreur : Type de consommateur invalide. Les valeurs acceptées sont : comp, indiv, all."
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    if ([ "$2" == "hvb" ] || [ "$2" == "hva" ]) && ([ "$3" == "all" ] || [ "$3" == "indiv" ]); then
        echo "Erreur : Les options '$2 $3' sont interdites. Seules les entreprises sont connectées aux stations HV-B et HV-A."
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi
}

# Vérification/création des dossiers tmp et graphs
function verifier_dossiers {
    for dir in "Temps" "Graphs"; do
        if [ -d "$dir" ]; then
            echo "Le répertoire '$dir' existe déjà. Vidage en cours..."
            rm -rf "$dir"/*
        else
            echo "Le répertoire '$dir' n'existe pas. Création en cours..."
            mkdir -p "$dir"
        fi
    done
}

# Préparation des données pour une station spécifique
function preparer_donnees {
    local station="$1"
    local file_path="$2"

    echo "Préparation des données pour $station..."
    case "$station" in
        hvb)
            cut -d';' -f2,7,5,6 "$file_path" | awk -F';' '{print $1, $2, $3, $4}' > Temps/hvb_input.txt
            ;;
        hva)
            cut -d';' -f3,7,5,6 "$file_path" | awk -F';' '{print $1, $2, $3, $4}' > Temps/hva_input.txt
            ;;
        lv)
            cut -d';' -f4,7,5,6 "$file_path" | awk -F';' '{print $1, $2, $3, $4}' > Temps/lv_input.txt
            ;;
        *)
            echo "Erreur : Type de station invalide."
            echo "Temps utile de traitement : 0.0 secondes"
            afficher_aide
            exit 1
            ;;
    esac
}


# Exécution du programme C
function executer_programme_c {
    local station="$1"
    local consommateur="$2"

    echo "Exécution du programme C pour $station..."
    local start_time=$(date +%s.%s) # Heure de début
    ./avl_tree "Temps/${station}_input.txt" "Temps/${station}_output.txt" "$consommateur"

    local end_time=$(date +%s.%N)   # Heure de fin
    local elapsed_time=$(echo "$end_time - $start_time" | bc) # Calcul du temps écoulé

    if [ $? -ne 0 ]; then
        echo "Erreur : Échec du traitement dans le programme C pour $station."
        echo "Temps utile pour $station : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    if [ -s "Temps/${station}_output.txt" ]; then
        echo "Résultats pour $station disponibles dans Temps/${station}_output.txt."
        echo "Temps utile pour $station : $elapsed_time secondes"
    else
        echo "Erreur : Aucune donnée produite pour $station."
        echo "Temps utile pour $station : 0.0 secondes"
        afficher_aide
        exit 1
    fi
}


# Boucle pour traiter les arguments
function boucle_traitement {
    local chemin_csv="$1"
    local consommateur="$2"
    shift 2 # On ignore les deux premiers arguments déjà utilisés
    
    for station in "$@"; do
        case "$station" in
            -hvb)
                preparer_donnees "hvb" "$chemin_csv"
                executer_programme_c "hvb" "$type_consommateur"
                ;;
            -hva)
                preparer_donnees "hva" "$chemin_csv"
                executer_programme_c "hva" "$type_consommateur"
                ;;
            -lv)
                preparer_donnees "lv" "$chemin_csv"
                executer_programme_c "lv" "$type_consommateur"
                ;;
            *)
                echo "Option non reconnue : $arg"
                echo "Temps utile de traitement : 0.0 secondes"
                afficher_aide
                ;;
        esac
    done
}

if [[ "$@" =~ "-h" ]]; then
    afficher_aide
    exit 0
fi

valider_arguments "$@"
chemin_csv="$1"
type_station="$2"
type_consommateur="$3"
id_centrale="${4:-}"

verifier_et_compiler
verifier_dossiers
boucle_traitement "$chemin_csv" "$type_consommateur" "$type_station"

echo "Script terminé."
