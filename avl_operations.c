#include "avl_tree.h"

// Fonction pour obtenir le maximum de deux entiers
int Max(int a, int b) {
    return (a > b) ? a : b;
}

// Fonction pour obtenir le minimum de deux entiers
int Min(int a, int b) {
    return (a < b) ? a : b;
}

// Fonction pour obtenir le maximum de trois entiers
int max3(int a, int b, int c) {
    int m = (a > b) ? a : b;
    return (m > c) ? m : c;
}

// Fonction pour obtenir le minimum de trois entiers
int min3(int a, int b, int c) {
    int m = (a < b) ? a : b;
    return (m < c) ? m : c;
}

// Fonction pour créer un nouveau noeud
AVL* creerNoeud(int id_sta, long capa, long conso) {
    AVL* noeud = (AVL*)malloc(sizeof(AVL));
    if (noeud == NULL) {
        printf("Erreur : Échec de l'allocation mémoire.\n");
        exit(EXIT_FAILURE);
    }
    noeud->id_station = id_sta;
    noeud->capacite = capa;
    noeud->consommation = conso;
    noeud->fg = NULL;
    noeud->fd = NULL;
    noeud->hauteur = 1;
    return noeud;
}

// Rotations et équilibrage
AVL* Rotation_D(AVL* a);
AVL* Rotation_G(AVL* a);
AVL* doubleRotation_D(AVL* a);
AVL* doubleRotation_G(AVL* a);
AVL* equilibre(AVL* a);
AVL* insertion(AVL* a, int id_sta, long capa, long conso, int* h);
