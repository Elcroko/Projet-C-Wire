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



// Fonction pour libérer la mémoire de l'arbre AVL
void libererAVL(AVL* a) {
    if (a != NULL) {
        libererAVL(a->fg);
        libererAVL(a->fd);
        free(a);
    }
}

// Fonction pour exporter l'arbre AVL dans un fichier avec un tampon
void exporterAVL(AVL* arbre, FILE* fichier, char *tampon, size_t *indexTampon, size_t tailleTampon) {
    if (arbre != NULL) {
        // Exporter le sous-arbre gauche
        exporterAVL(arbre->fg, fichier, tampon, indexTampon, tailleTampon);

        // Écrire les données du nœud actuel dans le tampon
        int tailleEcrite = snprintf(tampon + *indexTampon, tailleTampon - *indexTampon, 
                                    "%d:%ld:%ld\n", arbre->id_station, arbre->capacite, arbre->consommation);
        *indexTampon += tailleEcrite; // Mettre à jour l'index du tampon

        // Si le tampon est presque plein, écrire son contenu dans le fichier
        if (*indexTampon >= tailleTampon - 100) {
            fwrite(tampon, 1, *indexTampon, fichier); // Écriture dans le fichier
            *indexTampon = 0; // Réinitialiser l'index du tampon
        }

        // Exporter le sous-arbre droit
        exporterAVL(arbre->fd, fichier, tampon, indexTampon, tailleTampon);
    }
}


void exporterAVLVersCSV(AVL* arbre, const char* cheminFichier, size_t tailleTampon) {
    // Ouvrir le fichier en mode écriture
    FILE* fichier = fopen(cheminFichier, "w");
    if (fichier == NULL) {
        // Afficher un message d'erreur si le fichier ne peut pas être créé
        fprintf(stderr, "Erreur : Impossible de créer le fichier %s.\n", cheminFichier);
        return;
    }

    // Allouer un tampon pour optimiser les écritures dans le fichier
    char *tampon = (char *)malloc(tailleTampon);
    if (tampon == NULL) {
    fprintf(stderr, "Erreur : Échec de l'allocation mémoire pour le tampon.\n");
    fclose(fichier);
    exit(EXIT_FAILURE);
}
    size_t indexTampon = 0; // Initialiser l'index du tampon

    // Exporter les données de l'arbre AVL dans le fichier
    exporterAVL(arbre, fichier, tampon, &indexTampon, tailleTampon);

    // Écrire les données restantes dans le tampon (si non vide)
    if (indexTampon > 0) {
        fwrite(tampon, 1, indexTampon, fichier);
    }

    // Libérer la mémoire du tampon
    free(tampon);

    // Fermer le fichier
    fclose(fichier);
}
