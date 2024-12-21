#!/bin/bash

# Fonction d'aide pour afficher l'utilisation du script et les options disponibles
function afficher_aide {
	echo ""
    echo "Utilisation : ./c-wire.sh <chemin_csv> <type_station> <type_consommateur> [id_centrale] [-h]"
	echo ""
    echo "Options :"
    echo "  <chemin_csv>         Chemin du fichier CSV d'entrée (obligatoire)"
    echo "  <type_station>       Type de station à traiter (hvb, hva, lv) (obligatoire)"
    echo "  <type_consommateur>  Type de consommateur à traiter (comp, indiv, all) (obligatoire)"
    echo "  [id_centrale]        Identifiant de la centrale (optionnel)"
    echo "  -h                   Affiche cette aide dans n'importe quelle option(optionnel)"
	echo ""
    echo "Règles :"
    echo "  - Les options hvb all, hvb indiv, hva all, hva indiv sont interdites."
    echo "  - Le fichier de sortie est trié par capacité croissante."
    echo "  - Dans le cas de lv all min_max le fichier est trié par la valeur croissante de la différence entre la capacité et la consommation." 
	echo ""
    echo "Exemples :"
    echo "  ./c-wire.sh input/data.csv lv all "
    echo "  ./c-wire.sh input/data.csv lv comp 1"
    echo "  ./c-wire.sh input/data.csv lv indiv 2"
    echo "  ./c-wire.sh input/data.csv hvb comp 3"
    echo "  ./c-wire.sh input/data.csv hva comp 4"
    echo "  ./c-wire.sh input/data.csv lv all min_max"
    echo ""
    exit 0
}

# Vérification et compilation de l'exécutable C
function verifier_et_compiler {
    local executable="avl_tree" # Nom de l'exécutable attendu

    # Vérifier si l'exécutable est déjà présent
    if [ ! -f "$executable" ]; then
		echo ""
        echo "L'exécutable C '$executable' est introuvable. Compilation en cours..."
        make # Lancer la compilation via makefile
        if [ $? -ne 0 ]; then
			echo ""
            echo "Erreur : La compilation du programme C a échoué. Vérifiez le fichier source $source."
            exit 1
        else
			echo ""
            echo "Compilation réussie. L'exécutable '$executable' est prêt."
        fi
    else
		echo ""
        echo "L'exécutable C '$executable' est déjà présent."
    fi
}

# Fonction pour valider les arguments et afficher une erreur en cas de problème
function valider_arguments {
    if [[ "$@" =~ "-h" ]]; then # Afficher l'aide si l'option -h est détectée
        afficher_aide
    fi

    # Vérifier que le nombre d'arguments est suffisant
    if [ $# -lt 3 ]; then
		echo ""
        echo "Erreur : Paramètres insuffisants. Vous devez fournir au moins le chemin du fichier, le type de station, et le type de consommateur."
        echo ""
		echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    # Vérifier que le fichier CSV d'entrée existe
    if [ ! -f "$1" ]; then
		echo ""
        echo "Erreur : Le fichier '$1' est introuvable ou inaccessible."
		echo ""
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    # Vérifier si le type de station est valide
    if [[ ! "$2" =~ ^(hvb|hva|lv)$ ]]; then
		echo ""
        echo "Erreur : Type de station invalide. Les valeurs acceptées sont : hvb, hva, lv."
		echo ""
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    # Vérifier si le type de consommateur est valide
    if [[ ! "$3" =~ ^(comp|indiv|all)$ ]]; then
		echo ""
        echo "Erreur : Type de consommateur invalide. Les valeurs acceptées sont : comp, indiv, all."
		echo ""
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    # Vérifier que certaines combinaisons d'options sont interdites
    if ([ "$2" == "hvb" ] || [ "$2" == "hva" ]) && ([ "$3" == "all" ] || [ "$3" == "indiv" ]); then
		echo ""
        echo "Erreur : L'option '$2 $3' est interdite. Seules les entreprises sont connectées aux stations HV-B et HV-A."
		echo ""
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi

    # Vérifier la validité de l'argument 4 si présent
    if [ -n "$4" ] && [[ ! "$4" =~ ^(1|2|3|4|5|min_max)$ ]]; then
        echo ""
        echo "Erreur : Valeur invalide pour le quatrième argument. Les valeurs acceptées sont : 1, 2, 3, 4, 5, ou min_max."
        echo ""
        echo "Temps utile de traitement : 0.0 secondes"
        afficher_aide
        exit 1
    fi
}

# Vérification/création des dossiers tmp et graphs
function verifier_dossiers {
    for dir in "tmp" "Graphs"; do
        if [ -d "$dir" ]; then
			echo ""
            echo "Le répertoire '$dir' existe déjà. Vidage en cours..."
            rm -rf "$dir"/* # Vider le dossier si déjà existant
        else
			echo ""
            echo "Le répertoire '$dir' n'existe pas. Création en cours..."
            mkdir -p "$dir" # Créer le dossier si inexistant
        fi
    done
}

# Message de bienvenue
echo "============="
echo " C-WIRE v1.0 "
echo "============="

# Validation des arguments passés au script
valider_arguments "$@"

echo ""
echo "1 - Initialisation des variables"

# Initialisation des variables principales
DONNEES="$1"       # Fichier de données d'entrée
STATION="$2"       # Type de station (hva, hvb, lv)
ENTREPRISE="$3"    # Type de consommateur (comp, indiv, all)
CENTRALE="$4"      # Identifiant de la centrale ou "min_max"
TEMP="tmp"         # Dossier pour les fichiers temporaires

# Vérification de la présence et compilation du programme C
verifier_et_compiler
verifier_dossiers

# Configuration des fichiers d'entrée et de sortie
FICHIER_ENTREE="$TEMP/${STATION}_entree.csv"

if [ "$STATION" == "lv" ] && [ "$CENTRALE" == "min_max" ]; then
    FICHIER_SORTIE="$TEMP/${STATION}_${ENTREPRISE}_min_max.csv"
else
    if [ -n "$CENTRALE" ]; then
        FICHIER_SORTIE="$TEMP/${STATION}_${ENTREPRISE}_${CENTRALE}.csv"
    else
        FICHIER_SORTIE="$TEMP/${STATION}_${ENTREPRISE}.csv"
    fi
fi

# Suppression des anciens fichiers temporaires
if [ -e "$FICHIER_ENTREE" ]; then
    rm "$FICHIER_ENTREE"
fi
if [ -e "$FICHIER_SORTIE" ]; then
    rm "$FICHIER_SORTIE"
fi

# Créer le dossier temporaire s'il n'existe pas
mkdir -p "$TEMP"

# Enregistrement de l'heure de début pour mesurer la durée du traitement
HEURE_DEBUT=$(date +"%Y-%m-%d %H:%M:%S")
SECONDES_DEBUT=$(date +%s)

# Exécuter le script AWK
echo ""
echo "2 - Exécution du AWK"
echo ""

awk '
BEGIN {
    FS = ";"            # Définir le séparateur de champs d entree
    OFS = ":"           # Définir le séparateur de champs de sortie
    # Vérification du nombre d arguments
    if (ARGC < 4) {
        print "Erreur : Nombre d arguments insuffisant pour AWK."
        print "Utilisation : awk -f script.awk data.csv OPT1 OPT2 [OPT3]"
        exit 1
    }
    # Récupération des options
    OPT1 = ARGV[2]
    OPT2 = ARGV[3]
    OPT3 = (ARGC >= 5) ? ARGV[4] : ""
    # Nettoyage des arguments pour éviter des erreurs avec ARGV
    ARGV[2] = ""
    ARGV[3] = ""
    ARGV[4] = ""
}

NR == 1 {
    next
}

{
    # Remplacer les valeurs "-" par 0 pour simplifier le traitement
    $7 = ($7 == "-") ? 0 : $7
    $8 = ($8 == "-") ? 0 : $8

    # Bloc principal pour traiter chaque ligne en fonction des options
    if (OPT3 == "" || OPT3 == "min_max") {
        if (OPT1 == "hvb" && $2 != "-" && $3 == "-") {
            print $2, $7, $8
        } else if (OPT1 == "hva" && $3 != "-" && $4 == "-") {
            print $3, $7, $8
        } else if (OPT1 == "lv" && $4 != "-") {
            if (OPT2 == "comp" && $6 == "-") {
                print $4, $7, $8
            } else if (OPT2 == "indiv" && $5 == "-") {
                print $4, $7, $8
            } else if (OPT2 == "all") {
                print $4, $7, $8
            }
        }
    } else if (OPT3 ~ /^[1-5]$/) {
        if (OPT1 == "hvb" && $2 != "-" && $3 == "-" && $1 == OPT3) {
            print $2, $7, $8
        } else if (OPT1 == "hva" && $3 != "-" && $4 == "-" && $1 == OPT3) {
            print $3, $7, $8
        } else if (OPT1 == "lv" && $4 != "-" && $1 == OPT3) {
            if (OPT2 == "comp" && $6 == "-") {
                print $4, $7, $8
            } else if (OPT2 == "indiv" && $5 == "-") {
                print $4, $7, $8
            } else if (OPT2 == "all") {
                print $4, $7, $8
            }
        }
    }
}' "$DONNEES" "$STATION" "$ENTREPRISE" "$CENTRALE" > "$FICHIER_ENTREE"

sleep 1

# Exécuter le programme AVL
# NB : Ajouter une taille de tampon variable si nécessaire.
echo "3 - Exécution du script AVL"
echo ""
./avl_tree "$FICHIER_ENTREE" "$FICHIER_SORTIE"

# Traitement de l'option min_max
if [ "$STATION" == "lv" ] && [ "$CENTRALE" == "min_max" ]; then
	FICHIER_TEMP="$TEMP/lv_all_min_max.csv"
	if [ ! -f "$FICHIER_SORTIE" ]; then
		echo "Erreur : Fichier intermédiaire '$FICHIER_SORTIE' introuvable."
		exit 1
	fi
	# traitement par étape du cas min_max

	# étape 1 : calcul de la différence entre la capacité et la consommation
    awk -F':' 'NR > 1 {diff = $2 - $3; print $1 ":" $2 ":" $3 ":" diff;}' "$FICHIER_SORTIE" > tmp/s1.csv

	# étape 2 : trier la différence par ordre croissant
	sort -t':' -k4,4n < tmp/s1.csv > tmp/s2.csv

	# étape 3 : supprimer la différence
	cut -d':' -f1,2,3 < tmp/s2.csv > tmp/s3.csv

	# étape 4 : filtrer les 10 plus grands/petits consommateurs
	(head -n 10 tmp/s3.csv; tail -n 10 tmp/s3.csv) > tmp/s4.csv


	# étape 5 : enlever les doublons
	 awk '!seen[$0]++' tmp/s4.csv > "$FICHIER_TEMP"

	# on se remet dans la file de traitement classique
	FICHIER_SORTIE="$FICHIER_TEMP"

    mv "$FICHIER_SORTIE" tmp/body.csv

else
    # on tri par la capacité et par ordre croissant
    sort -t':' -k2,2n < "$FICHIER_SORTIE" > tmp/body.csv

fi  

# Enregistrer l'heure et la date de fin
HEURE_FIN=$(date +"%Y-%m-%d %H:%M:%S")
SECONDES_FIN=$(date +%s)

# Créer un titre dynamique basé sur les variables $STATION et $ENTREPRISE
TITRE="Station $STATION : Capacité : Consommation($ENTREPRISE)"

# Écrire le titre dynamique dans un fichier temporaire
echo "$TITRE" > tmp/header.csv

    # Remplacer le fichier de sortie avec le nouveau titre suivi du contenu
cat tmp/header.csv tmp/body.csv > "$FICHIER_SORTIE"
   
# Nettoyage final des fichiers temporaires
if [ -f "tmp/s1.csv" ]; then
	rm -f tmp/s1.csv 2>/dev/null
fi
if [ -f "tmp/s2.csv" ]; then
	rm -f tmp/s2.csv 2>/dev/null
fi
if [ -f "tmp/s3.csv" ]; then
	rm -f tmp/s3.csv 2>/dev/null
fi
if [ -f "tmp/s4.csv" ]; then
	rm -f tmp/s4.csv 2>/dev/null
fi
if [ -f "tmp/body.csv" ]; then
	rm -f tmp/body.csv 2>/dev/null
fi
if [ -f "tmp/header.csv" ]; then
	rm -f tmp/header.csv 2>/dev/null
fi

# Suppression du fichier d'entrée s'il existe
if [ -f "$FICHIER_ENTREE" ]; then
	rm -f "$FICHIER_ENTREE" 2>/dev/null
else
	echo "Fichier d'entrée '$FICHIER_ENTREE' introuvable ou déjà supprimé."
fi

echo ""
echo "Début du processus : $HEURE_DEBUT"
echo "Fin du processus   : $HEURE_FIN"

# Calculer le temps écoulé
TEMPS_ECOULE=$((SECONDES_FIN - SECONDES_DEBUT))
HEURES=$((TEMPS_ECOULE / 3600))
MINUTES=$(( (TEMPS_ECOULE % 3600) / 60 ))
SECONDES=$((TEMPS_ECOULE % 60))
echo "Temps écoulé : ${HEURES}h ${MINUTES}m ${SECONDES}s"

echo ""
echo "Fin du processus."
echo ""
# Fin du script
