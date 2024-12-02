#!/bin/bash

# Cette ligne de commande permet de chercher le fichier data.csv dans mes dossiers
file_path=$(find .. -iname "data.csv") 2>/dev/null                                                                                      

# Cette ligne de commande permet de chercher si le dossier Graphs existe dans mes dossiers
Graphs_path=$(find . -type d -name "Graphs" -print -quit) 2>/dev/null                                                                   

# Cette ligne de commande permet de chercher si le dossier Temps existe dans mes dossiers
Temps_path=$(find . -type d -name "Temps" -print -quit) 2>/dev/null                                                                     

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

# Cette condition permet de voir si je passe bien un argument dans station il y a trois types d'arguments HVB / HVA / LV dans le cas où il n'y a pas d'argument, j'affiche qu'il n'y a pas d'argument et j'arrête le programme 
if [ $# -eq 0 ]; then
    echo "Aucun argument fourni"
    exit 1
fi

# ORDRE DANS LE DATA.CSV
# Power plant;HV-B Station;HV-A Station;LV Station;Company;Individual;Capacity;Load
#  1          2             3           4          5       6          7        8

# Dans cette boucle on regarde l'ensemble des arguments et on lance le programme associé à l'argument mis en paramètre soit HVB / HVA / LV
for arg in "$@"; do 
  case "$arg" in
    -hvb) 
        echo "Exécution du tri selon la colonne Station HVB"
        cut -d';' -f2,5,6,7,8 "$file_path" | sort -n -t';' -k1 > Temps/hvb.csv
        echo "Le tri selon la colonne Station HVB a été exécuté"

        # Lance une nouvelle boucle dans laquelle on regarde un nouvel argument qui peut être l'un des suivants COMPANY / INDIVIDUAL / ALL
        for arg in "$@"; do 
          case "$arg" in
            -comp) 
                echo "Exécution du tri selon la colonne Company"
                awk -F';' '
                BEGIN { print "HV-B Station:Capacity:Consumption" }
                { capacity[$1] += $4; consumption[$1] += $5 }
                END {
                    for (station in capacity) {
                        print station ":" capacity[station] ":" consumption[station]
                    }
                }' Temps/hvb.csv | sort -t':' -k2n > Temps/hvb_comp_final.csv
                echo "Le calcul pour HVB et Company a été exécuté : Temps/hvb_comp_final.csv"
                ;;
            -indiv) 
                echo "Cette commande ne peut pas être appliquée"
                exit 1
                ;;
            -all) 
                echo "Cette commande ne peut pas être appliquée"
                exit 1
                ;;
          esac
        done
        ;; 

    -hva)
        echo "Exécution du tri selon la colonne Station HVA"
        cut -d';' -f3,5,6,7,8 "$file_path" | sort -n -t';' -k1 > Temps/hva.csv
        echo "Le tri selon la colonne Station HVA a été exécuté"
        ;; 

    -lv)
        echo "Exécution du tri selon la colonne Station LV"
        cut -d';' -f4,5,6,7,8 "$file_path" | sort -n -t';' -k1 > Temps/lv.csv
        echo "Le tri selon la colonne Station LV a été exécuté"

        for arg in "$@"; do 
          case "$arg" in
            -comp) 
                echo "Exécution du tri selon la colonne Company"
                awk -F';' '
                BEGIN { print "LV Station:Capacity:Consumption" }
                { capacity[$1] += $4; consumption[$1] += $5 }
                END {
                    for (station in capacity) {
                        print station ":" capacity[station] ":" consumption[station]
                    }
                }' Temps/lv.csv | sort -t':' -k2n > Temps/lv_comp_final.csv
                echo "Le calcul pour LV et Company a été exécuté : Temps/lv_comp_final.csv"
                ;;
            -indiv) 
                echo "Exécution du tri selon la colonne Individual"
                awk -F';' '
                BEGIN { print "LV Station:Capacity:Consumption" }
                { capacity[$1] += $4; consumption[$1] += $5 }
                END {
                    for (station in capacity) {
                        print station ":" capacity[station] ":" consumption[station]
                    }
                }' Temps/lv.csv | sort -t':' -k2n > Temps/lv_indiv_final.csv
                echo "Le calcul pour LV et Individual a été exécuté : Temps/lv_indiv_final.csv"
                ;;
            -all) 
                echo "Exécution du tri selon la colonne Individual et Company"
                awk -F';' '
                BEGIN { print "LV Station:Capacity:Consumption" }
                { capacity[$1] += $4; consumption[$1] += $5 }
                END {
                    for (station in capacity) {
                        print station ":" capacity[station] ":" consumption[station]
                    }
                }' Temps/lv.csv | sort -t':' -k2n > Temps/lv_all_final.csv
                echo "Le calcul pour LV avec tous les clients a été exécuté : Temps/lv_all_final.csv"
                ;;
          esac
        done 
        ;; 

    *) 
      echo "Argument inconnu : $arg"
      ;; 
  esac
done

# Calcul et affichage du temps écoulé
end_time=$(date +%s.%s) 
elapsed_time=$(echo "$end_time - $start_time" | bc