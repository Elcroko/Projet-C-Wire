#include "avl_tree.h"

int main(int argc, char* argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Utilisation : %s [fichier_entrée] [fichier_sortie] [taille_tampon]\n", argv[0]);
        return EXIT_FAILURE;
    }

    AVL* arbre = NULL;
    const char* cheminFichier = argv[1];
    const char* fichierSortie = argv[2];
    size_t tailleTampon = (argc >= 4) ? atol(argv[3]) : TAILLE_TAMPON_DEFAUT;

    arbre = lireFichierCSV(arbre, cheminFichier);
    if (arbre == NULL) {
        fprintf(stderr, "Erreur lors du traitement du fichier %s.\n", cheminFichier);
        return EXIT_FAILURE;
    }

    exporterAVLVersCSV(arbre, fichierSortie, tailleTampon);
    libererAVL(arbre);

    return 0;
}
