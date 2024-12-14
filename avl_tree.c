#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Définition d'un nœud d'un arbre AVL
typedef struct Node {
    int capacite;
    int consommation;
    struct Node* fg;
    struct Node* fd;
    int hauteur;
} AVL;

// Fonction pour obtenir le maximum de deux entiers
int Max(int a, int b) {
    return (a > b) ? a : b;
}

// Fonction pour obtenir le mnimum de deux entiers
int Min(int a, int b) {
    return (a < b) ? a : b;
}

// Fonction pour obtenir le maximum de trois entiers
int max3(int a, int b, int c) {
    int m = (a > b) ? a : b;  // Trouver le maximum entre `a` et `b`
    return (m > c) ? m : c;  // Comparer ensuite avec `c`
}


// Fonction pour obtenir le minimum de trois entiers
int min3(int a, int b, int c) {
    int m = (a < b) ? a : b;  // Trouver le minimum entre `a` et `b`
    return (m < c) ? m : c;  // Comparer ensuite avec `c`
}


// Fonction pour créer un nouveau nœud avec une clé donnée
AVL* creerNoeud(int capa, int conso) {
    AVL* noeud = (AVL*)malloc(sizeof(AVL));
    noeud->capacite = capa;
    noeud->consommation = conso;
    noeud->fg = NULL;
    noeud->fd = NULL;
    noeud->hauteur = 1;  
    return noeud;
}

// Rotation droite
AVL* Rotation_D(AVL* a) {
    AVL* pivot = a->fg;

    int hauteur_a = a->hauteur;
    int hauteur_pivot = pivot->hauteur;

    // Effectuer la rotation
    a->fg = pivot->fd;
    pivot->fd = a;

    // Mise à jour des facteurs d'équilibre
    a->hauteur = hauteur_a - Min(hauteur_pivot, 0) + 1;  // Facteur d'équilibre de `y` après rotation
    pivot->hauteur = max3(hauteur_a + 2, hauteur_a + hauteur_pivot + 2, hauteur_pivot + 1);  // Facteur d'équilibre de `x` après rotation

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
    a->hauteur = hauteur_a - Max(hauteur_pivot, 0) - 1;  // Facteur d'équilibre de `a` après rotation
    pivot->hauteur = min3(hauteur_a - 2, hauteur_a + hauteur_pivot - 2, hauteur_pivot - 1);  // Facteur d'équilibre de `pivot` après rotation

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
    if (a->hauteur >= 2) {
        if (a->fd->hauteur >= 0){
            return Rotation_G(a);
        }
        else{
            return doubleRotation_G(a);
        }
    }
    else if(a->hauteur <= -2){
        if (a->fg->hauteur <= 0){
            return Rotation_D(a);
        }
        else{
            return doubleRotation_D(a);
        }
    }
    return(a);
}

// Fonction d'insertion dans un arbre AVL
AVL* insertion(AVL* a, int capa, int conso, int *h) {

    if (a == NULL) {
        *h = 1;
        return creerNoeud(capa, conso);
    }

    if (capa < a->capacite) {
        a->fg = insertion(a->fg, capa, conso, h);
        *h = -*h;
    } else if (capa > a->capacite) {
        a->fd = insertion(a->fd, capa, conso, h);
    } else {
        *h = 0;
        return a;
    }

    if(*h != 0){
        a->hauteur += *h;
        a = equilibre(a);
        if (a->hauteur == 0){
            *h = 0;
        } 
        else{
            *h = 1; // MAJ de la hauteur
        }
    }
    return a;
}

// Exporter l'arbre AVL trié dans un fichier
void exporterAVL(AVL* a, FILE* fichier) {
    if (a != NULL) {
        exporterAVL(a->fg, fichier);
        fprintf(fichier, "%d:%d\n", a->capacite, a->consommation);
        exporterAVL(a->fd, fichier);
    }
}

// Fonction pour lire un fichier CSV et insérer les données dans un arbre AVL

AVL* LireEtInsererCSV(AVL* a, const char* chemin_fichier, const char* typeConsommateur) {
    FILE* fichier = fopen(chemin_fichier, "r");
    if (fichier == NULL) {
        printf( "Erreur : Impossible d'ouvrir le fichier %s.\n", chemin_fichier);
        exit(EXIT_FAILURE);
    }

    char ligne[256];
    while (fgets(ligne, sizeof(ligne), fichier)) {
        int capa;
        int conso;
        char type[10];
        if (sscanf(ligne, "%d:%d:%s", &capa, &conso, type) == 3) {
            if(strcmp(typeConsommateur, "all") == 0 || strcmp(type, typeConsommateur) == 0){
                int h = 0;
                a = insertion(a, capa, conso, &h);
            }
        }
    }
    fclose(fichier);
    return a;
}

int main(int argc, char* argv[]) {
    if (argc < 4) {
        fprintf(stderr, "Usage : %s <fichier_entree> <fichier_sortie> <type_consommateur>\n", argv[0]);
        return EXIT_FAILURE;
    }
    
    const char* fichierEntree = argv[1];
    const char* fichierSortie = argv[2];
    const char* typeConsommateur = argv[3];

    AVL* arbre = NULL;

    // Lecture des données à partir d'un fichier CSV
    const char* fichier_entree = "data.csv";
    arbre = LireEtInsererCSV(arbre, fichier_entree, typeConsommateur);

    FILE* fichier = fopen(fichierSortie, "w");
    if (fichier == NULL) {
        fprintf(stderr, "Erreur : Impossible d'écrire dans le fichier %s.\n", fichierSortie);
        return EXIT_FAILURE;
    }

    exporterAVL(arbre, fichier);
    fclose(fichier);

    printf("Opération terminée. Données exportées dans %s.\n", fichierSortie);
    return 0;
    return EXIT_SUCCESS;
}


