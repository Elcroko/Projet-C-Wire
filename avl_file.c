#include "avl_tree.h"

// Fonction pour lire un fichier CSV et insérer les données dans un arbre AVL
AVL* lireFichierCSV(AVL* a, const char* cheminFichier) {
    FILE* fichier = fopen(cheminFichier, "r");
    if (fichier == NULL) {
        fprintf(stderr, "Erreur : Impossible d'ouvrir le fichier %s.\n", cheminFichier);
        return NULL;
    }
    char ligne[50];
    int h = 0;
    while (fgets(ligne, sizeof(ligne), fichier)) {
        int id_station;
        long capacite, consommation;
        if (strstr(ligne, "Station") != NULL) {
            continue;
        }
        if (sscanf(ligne, "%d:%ld:%ld", &id_station, &capacite, &consommation) != 3) {
            fprintf(stderr, "Erreur : Ligne mal formatée. Ignorée : %s\n", ligne);
            continue;
        }
        a = insertion(a, id_station, capacite, consommation, &h);
    }
    fclose(fichier);
    return a;
}

// Fonction pour exporter un arbre AVL dans un fichier CSV
void exporterAVL(AVL* arbre, FILE* fichier, char* tampon, size_t* indexTampon, size_t tailleTampon);
void exporterAVLVersCSV(AVL* arbre, const char* cheminFichier, size_t tailleTampon);
void libererAVL(AVL* a);
