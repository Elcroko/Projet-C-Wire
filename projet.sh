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
    echo "  ./c-wire.sh data.csv lv all min_max"
    echo "  ./c-wire.sh data.csv hva comp centrale1"
    exit 0
}


# Vérification et compilation de l'exécutable C
function verifier_et_compiler {
    local executable="avl_tree"

    if [ ! -f "$executable" ]; then
        echo "L'exécutable C '$executable' est introuvable. Compilation en cours..."
        make
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
    if [[ "$@" =~ "-h" ]]; then
        afficher_aide
    fi

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
    local id_centrale="${3:-}"

    echo "Préparation des données pour $station..."
    case "$station" in
        hvb)
            cut -d';' -f2,7,5,6 "$file_path" | awk -F';' -v centrale="$id_centrale" \
                'centrale == "" || $1 == centrale {print $1, $2, $3, $4}' > Temps/hvb_input.txt
            ;;
        hva)
            cut -d';' -f3,7,5,6 "$file_path" | awk -F';' -v centrale="$id_centrale" \
                'centrale == "" || $1 == centrale {print $1, $2, $3, $4}' > Temps/hva_input.txt
            ;;
        lv)
            cut -d';' -f4,7,5,6 "$file_path" | awk -F';' -v centrale="$id_centrale" \
                'centrale == "" || $1 == centrale {print $1, $2, $3, $4}' > Temps/lv_input.txt
            ;;
        *)
            echo "Erreur : Type de station invalide."
            echo "Temps utile de traitement : 0.0 secondes"
            afficher_aide
            exit 1
            ;;
    esac
}

# Ajouter les titres de colonnes aux fichiers de sortie
function ajouter_titres {
    local station="$1"
    local consommateur="$2"
    local output_file="$3"
    local id_centrale="${4:-}"

    # Construire le titre de colonne en fonction des cas
    case "$station" in
        hvb)
            echo "Station HV-B:Capacité:Consommation (Entreprises)" > "$output_file"
            ;;
        hva)
            echo "Station HV-A:Capacité:Consommation (Entreprises)" > "$output_file"
            ;;
        lv)
            case "$consommateur" in
                indiv)
                    echo "Station LV:Capacité:Consommation (Individuelles)" > "$output_file"
                    ;;
                comp)
                    echo "Station LV:Capacité:Consommation (Entreprises)" > "$output_file"
                    ;;
                all)
                    if [ "$id_centrale" == "min_max" ]; then
                        # Cas particulier pour lv all minmax
                        echo "Min and Max 'capacity-load' extreme nodes" > "$output_file"
                        echo "Station LV:Capacité:Consommation (Tous):Différence" >> "$output_file"
                    else
                        echo "Station LV:Capacité:Consommation (Tous)" > "$output_file"
                    fi
                    ;;
            esac
            ;;
    esac
}


# Exécution du programme C
function executer_programme_c {
    local station="$1"
    local consommateur="$2"
    local id_centrale="${3:-}"

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

# Traitement spécial pour lv all min_max
function traitement_lv_all_minmax {
    echo "Traitement supplémentaire : lv all min_max"
    local input_file="tmp/lv_output.txt"
    local minmax_file="tmp/lv_minmax_output.txt"
    local temp_sorted_file="Temps/lv_diff_sorted.txt"

    if [ ! -f "$input_file" ]; then
        echo "Erreur : Fichier d'entrée '$input_file' introuvable. Assurez-vous que le traitement initial a été effectué."
        exit 1
    fi

    # Calcul des différences et tri des résultats
    awk -F':' 'NR > 1 { diff = $2 - $3; print $0 ":" diff }' "$input_file" | sort -t':' -k5,5n > "$minmax_file"
    
    # Ajouter les titres au fichier minmax
    ajouter_titres "lv" "all" "$minmax_file" "min_max"

    # Extraction des 10 postes avec le moins de consommation (sans la colonne différence)
    head -n 10 "$temp_sorted_file" | cut -d':' -f1-4 >> "$minmax_file"

    # Extraction des 10 postes avec le plus de consommation (sans la colonne différence)
    tail -n 10 "$temp_sorted_file" | cut -d':' -f1-4 >> "$minmax_file"

    # Suppression des fichiers intermédiaires
    rm -f "Temps/lv_diff_sorted.txt"

    echo "Fichier contenant les postes extrêmes généré : $minmax_file"
}

# Boucle pour traiter les arguments
function boucle_traitement {
    local chemin_csv="$1"
    local consommateur="$2"
    local id_centrale="${3:-}"
    shift 3 # On ignore les trois premiers arguments déjà utilisés
    
    for station in "$@"; do
        case "$station" in
            -hvb)
                preparer_donnees "hvb" "$chemin_csv" "$id_centrale"
                executer_programme_c "hvb" "$type_consommateur" "$id_centrale"
                ;;
            -hva)
                preparer_donnees "hva" "$chemin_csv" "$id_centrale"
                executer_programme_c "hva" "$type_consommateur" "$id_centrale"
                ;;
            -lv)
                preparer_donnees "lv" "$chemin_csv" "$id_centrale"
                executer_programme_c "lv" "$type_consommateur" "$id_centrale"
                
                if [ "$consommateur" == "all" ] && [[ "$@" =~ "min_max" ]]; then
                    traitement_lv_all_minmax
                fi
                ;;
            *)
                echo "Option non reconnue : $station"
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
boucle_traitement "$chemin_csv" "$type_consommateur" "$type_station" "$option_min_max"

echo "Script terminé."
