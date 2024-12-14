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
        echo "L'exécutable '$executable' est introuvable. Lancement de la compilation."
        gcc -o "$executable" "$source"
        if [ $? -ne 0 ]; then
            echo "Erreur : La compilation du programme C a échoué. Vérifiez le code source."
            exit 1
        else
            echo "Compilation réussie. L'exécutable '$executable' est prêt."
        fi
    else
        echo "L'exécutable '$executable' est déjà présent."
    fi
}

# Fonction pour valider les arguments et afficher une erreur en cas de problème
function valider_arguments {
    if [ $# -lt 3 ]; then
        echo "Erreur : Paramètres insuffisants. Vous devez fournir au moins le chemin du fichier, le type de station, et le type de consommateur."
        afficher_aide
        exit 1
    fi

    if [ ! -f "$1" ]; then
        echo "Erreur : Le fichier '$1' est introuvable ou inaccessible."
        afficher_aide
        exit 1
    fi

    if [[ ! "$2" =~ ^(hvb|hva|lv)$ ]]; then
        echo "Erreur : Type de station invalide. Les valeurs acceptées sont : hvb, hva, lv."
        afficher_aide
        exit 1
    fi

    if [[ ! "$3" =~ ^(comp|indiv|all)$ ]]; then
        echo "Erreur : Type de consommateur invalide. Les valeurs acceptées sont : comp, indiv, all."
        afficher_aide
        exit 1
    fi

    if ([ "$2" == "hvb" ] || [ "$2" == "hva" ]) && ([ "$3" == "all" ] || [ "$3" == "indiv" ]); then
        echo "Erreur : Les options '$2 $3' sont interdites. Seules les entreprises sont connectées aux stations HV-B et HV-A."
        afficher_aide
        exit 1
    fi
}


# Vérification de l'option -h
for arg in "$@"; do
    if [ "$arg" == "-h" ]; then
        afficher_aide
        exit 0
    fi
done

# Validation des arguments
valider_arguments "$@"

# Vérification et compilation de l'exécutable C
verifier_et_compiler

# Gestion de l'identifiant de centrale (optionnel)
if [ ! -z "$4" ]; then
    awk_condition="$4"
else
    awk_condition=".*"
fi

if [ ! -z "$4" ] && ! grep -q "$4" "$file_path"; then
    echo "Erreur : ID de centrale spécifiée introuvable dans le fichier CSV."
    exit 1
fi


# Cette ligne de commande permet de chercher le fichier data.csv dans mes dossiers
file_path=$(find .. -iname "data.csv") 2>/dev/null                                                                                      

# Cette ligne de commande permet de chercher si le dossier Graphs existe dans mes dossiers
Graphs_path=$(find . -type d -name "Graphs" -print -quit) 2>/dev/null
if [ -n "$Graphs_path" ]; then
  echo "Le dossier Graphs existe et il va être vidé."
  rm -r "${Graphs_path}"/*
else
  echo "Le dossier Graphs n'existe pas et il va être créé."
  mkdir -p "Graphs"
fi                                                                 

# Cette ligne de commande permet de chercher si le dossier Temps existe dans mes dossiers
Temps_path=$(find . -type d -name "Temps" -print -quit) 2>/dev/null
if [ -n "$Temps_path" ]; then
  echo "Le dossier Temps existe et il va être vidé."
  rm -r "${Temps_path}"/*
else
  echo "Le dossier Temps n'existe pas et il va être créé."
  mkdir -p "Temps"
fi                                                                     

chmod 777 c-wire.sh

# Dans cette condition je vérifie si le fichier data.csv existe bien dans mes dossiers
if [ -e "$file_path" ]; then
 echo "Le fichier data.csv existe"
 echo "$file_path"
else
 echo "Erreur : Le fichier data.csv est introuvable."
 exit 1
fi

# Dans cette condition je vérifie si le dossier Graphs existe bien dans mes dossiers
if [ -n "$Graphs_path" ]; then
  echo "Le dossier Graphs existe et il va être vidé"
  rm -r "$Graphs_path"/*
  echo "Le dossier a été vidé"
else
  echo "Le dossier Graphs n'existe pas et il va être créé"
  mkdir -p "Graphs"
fi

# Dans cette condition je vérifie si le dossier Temps existe bien dans mes dossiers
if [ -n "$Temps_path" ]; then
  echo "Le dossier Temps existe et il va être vidé"
  rm -r "$Temps_path"/*
  echo "Le dossier a été vidé"
else
  echo "Le dossier Temps n'existe pas et il va être créé"
  mkdir -p "Temps"
fi

# Initialisation de la variable start_time pour le calcul du temps d'exécution
start_time=$(date +%s.%s)

# Vérification de la sortie du programme C
if [ -e "Temps/avl_output.txt" ]; then
    echo "Résultats de l'arbre AVL :"
    cat Temps/avl_output.txt
else
    echo "Erreur : Fichier de sortie du programme C introuvable."
fi

# ORDRE DANS LE DATA.CSV
# Power plant;HV-B Station;HV-A Station;LV Station;Company;Individual;Capacity;Load
#  1          2             3           4          5       6          7        8

# Dans cette boucle on regarde l'ensemble des arguments et on lance le programme associé à l'argument mis en paramètre soit HVB / HVA / LV
# Exécution principale
for arg in "$@"; do
    case "$arg" in
        -hvb)
            echo "Tri des données selon la colonne Station HVB"
            cut -d';' -f2,5,6,7,8 "$file_path" | awk -F';' '$1 ~ /'"$awk_condition"'/ { print }' | sort -n -t';' -k1 > Temps/hvb.csv
            echo "Fichier 'Temps/hvb.csv' créé (filtré par ID centrale si spécifiée)."
            ;;
        -hva)
            echo "Tri des données selon la colonne Station HVA"
            cut -d';' -f3,5,6,7,8 "$file_path" | awk -F';' '$1 ~ /'"$awk_condition"'/ { print }' | sort -n -t';' -k1 > Temps/hva.csv
            echo "Fichier 'Temps/hva.csv' créé (filtré par ID centrale si spécifiée)."

            ;;
        -lv)
            echo "Tri des données selon la colonne Station LV"
            cut -d';' -f4,5,6,7,8 "$file_path" | awk -F';' '$1 ~ /'"$awk_condition"'/ { print }' | sort -n -t';' -k1 > Temps/lv.csv
            echo "Fichier 'Temps/lv.csv' créé (filtré par ID centrale si spécifiée)."
            ;;
        -comp)
            # Gestion spécifique pour HVB, HVA et LV
            for station in "hvb" "hva" "lv"; do
                if [ -f "Temps/${station}.csv" ]; then
                    echo "Calcul des capacités et consommations pour $station et Company"
                    awk -F';'-v id="$awk_condition" '
                    BEGIN { print "Station:Capacity:Consumption" }
                    $1 ~ id { capacity[$1] += $4; consumption[$1] += $5 }
                    END {
                        for (station in capacity) {
                            print station ":" capacity[station] ":" consumption[station]
                        }
                    }' "Temps/${station}.csv" | sort -t':' -k2n > "Temps/${station}_comp_final.csv"
                    echo "Fichier 'Temps/${station}_comp_final.csv' créé (avec filtrage par ID centrale si spécifiée)."
                fi
            done
            ;;
        -indiv)
            # Gestion spécifique pour LV uniquement
            if [ -f "Temps/lv.csv" ]; then
                echo "Calcul des capacités et consommations pour LV et Individual"
                awk -F';' -v id="$awk_condition" '
                BEGIN { print "Station:Capacity:Consumption" }
                $1 ~ id { capacity[$1] += $4; consumption[$1] += $5 }
                END {
                    for (station in capacity) {
                        print station ":" capacity[station] ":" consumption[station]
                    }
                }' "Temps/lv.csv" | sort -t':' -k2n > "Temps/lv_indiv_final.csv"
                echo "Fichier 'Temps/lv_indiv_final.csv' créé(avec filtrage par ID centrale si spécifiée)."
            fi
            ;;
        -all)
            # Vérifier si une option supplémentaire (minmax) est donnée
            if [[ "$@" =~ "minmax" ]]; then
                echo "Traitement supplémentaire pour LV : Extraction des 10 postes LV les plus et les moins consommateurs."

                # Étape 1 : Calcul des capacités et consommations totales par station
                awk -F';' -v id="$awk_condition" '
                BEGIN { print "Station:Capacity:Consumption" }
                $1 ~ id { capacity[$1] += $4; consumption[$1] += $5 }
                END {
                    for (station in capacity) {
                        print station ":" capacity[station] ":" consumption[station]
                    }
                }' "Temps/lv.csv" | sort -t':' -k2n > "Temps/lv_all_final.csv"
                echo "Fichier 'Temps/lv_all_final.csv' créé."

                # Étape 2 : Calcul de la différence absolue (capacité - consommation)
                awk -F':' '
                NR > 1 { diff = $2 - $3; print $1 ":" $2 ":" $3 ":" diff }
                ' "Temps/lv_all_final.csv" | sort -t':' -k4n > "Temps/lv_all_diff_sorted.csv"

                # Étape 3 : Extraire les 10 plus et 10 moins consommateurs
                head -n 11 "Temps/lv_all_diff_sorted.csv" > "Temps/lv_all_min.csv"
                tail -n 10 "Temps/lv_all_diff_sorted.csv" > "Temps/lv_all_max.csv"
                cat "Temps/lv_all_min.csv" "Temps/lv_all_max.csv" | sort -t':' -k4n > "Temps/lv_all_minmax.csv"

                # Supprimer les fichiers temporaires pour ne garder que le résultat final
                rm -f "Temps/lv_all_min.csv" "Temps/lv_all_max.csv" "Temps/lv_all_diff_sorted.csv"

                echo "Fichier 'Temps/lv_all_minmax.csv' créé avec les 10 postes LV les plus et les moins consommateurs, triés par différence."
            else
                echo "Traitement standard pour LV : Calcul des capacités et consommations totales pour tous les postes LV."
                
                # Calcul standard pour LV
                awk -F';' -v id="$awk_condition" '
                BEGIN { print "Station:Capacity:Consumption" }
                $1 ~ id { capacity[$1] += $4; consumption[$1] += $5 }
                END {
                    for (station in capacity) {
                        print station ":" capacity[station] ":" consumption[station]
                    }
                }' "Temps/lv.csv" | sort -t':' -k2n > "Temps/lv_all_final.csv"
                echo "Fichier 'Temps/lv_all_final.csv' créé."
            fi
            ;;

        *)
            echo "Argument inconnu : $arg"
            ;;
    esac
done

# Calcul et affichage du temps écoulé
end_time=$(date +%s.%s) 
elapsed_time=$(echo "$end_time - $start_time" | bc)
echo "Temps écoulé : $elapsed_time secondes"
