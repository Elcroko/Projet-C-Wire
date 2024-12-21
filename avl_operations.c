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

// Rotation droite
AVL* Rotation_D(AVL* a) {
    AVL* pivot = a->fg;

    int hauteur_a = a->hauteur;
    int hauteur_pivot = pivot->hauteur;

    // Effectuer la rotation
    a->fg = pivot->fd;
    pivot->fd = a;

    // Mise à jour des facteurs d'équilibre
    a->hauteur = hauteur_a - Min(hauteur_pivot, 0) + 1; // Facteur d'équilibre de a après rotation
    pivot->hauteur = max3(hauteur_a + 2, hauteur_a + hauteur_pivot + 2, hauteur_pivot + 1);  // Facteur d'équilibre de pivot après rotation

    return pivot;  // Le pivot devient la nouvelle racine
}

// Rotation gauche
AVL* Rotation_G(AVL* a) {
    AVL* pivot = a->fd;

    int hauteur_a = a->hauteur;
    int hauteur_pivot = pivot->hauteur;

    // Effectuer la rotation
    a->fd = pivot->fg;
    pivot->fg = a;

    // Mise à jour des facteurs d'équilibre
    a->hauteur = hauteur_a - Max(hauteur_pivot, 0) - 1;  // Facteur d'équilibre de a après rotation
    pivot->hauteur = min3(hauteur_a - 2, hauteur_a + hauteur_pivot - 2, hauteur_pivot - 1);  // Facteur d'équilibre de pivot après rotation

    return pivot;  // Le pivot devient la nouvelle racine
}

// doubleRightRotate
AVL* doubleRotation_D(AVL* a) {
    a->fg = Rotation_G(a->fg);  // Rotation gauche sur le sous-arbre gauche
    return Rotation_D(a);  // Puis rotation droite sur le nœud déséquilibré
}

// doubleLeftRotate
AVL* doubleRotation_G(AVL* a) {
    a->fd = Rotation_D(a->fd);  // Rotation droite sur le sous-arbre droit
    return Rotation_G(a);  // Puis rotation gauche sur le nœud déséquilibré
}

// Calcul du facteur d'équilibre d'un nœud
AVL* equilibre(AVL* a) {
    if (a->hauteur >= 2) { // Si l'arbre est déséquilibré à droite
        if (a->fd->hauteur >= 0){
            return Rotation_G(a);
        }
        else{
            return doubleRotation_G(a);
        }
    }
    else if(a->hauteur <= -2){ // Si l'arbre est déséquilibré à gauche
        if (a->fg->hauteur <= 0){
            return Rotation_D(a);
        }
        else{
            return doubleRotation_D(a);
        }
    }
    return(a);
}

// Fonction pour insérer un noeud
AVL* insertion(AVL* a, int id_sta, long capa, long conso, int* h) {
    if (a == NULL) {
        *h = 1;
        return creerNoeud(id_sta, capa, conso);
    }
    if (id_sta < a->id_station) {
        a->fg = insertion(a->fg, id_sta, capa, conso, h);
        *h = -*h;
    } else if (id_sta > a->id_station) {
        a->fd = insertion(a->fd, id_sta, capa, conso, h);
    } else {
        a->capacite += capa;
        a->consommation += conso;
        *h = 0;
        return a;
    }
    // Mettre à jour la hauteur et équilibrer l'arbre si nécessaire
    if (*h != 0) {
        a->hauteur += *h;
        a = equilibre(a);
        if (a->hauteur == 0) {
            *h = 0;
        } else {
            *h = 1;
        }
    }
    return a;
}
