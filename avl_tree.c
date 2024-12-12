#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Définition d'un nœud d'un arbre AVL
typedef struct Node {
    int valeur;
    struct Node* fg;
    struct Node* fd;
    int hauteur;
} AVL;

// Fonction pour obtenir le maximum de deux entiers
int max(int a, int b) {
    return (a > b) ? a : b;
}

// Fonction pour obtenir le mnimum de deux entiers
int min(int a, int b) {
    return (a < b) ? a : b;
}

// Fonction pour obtenir le maximum de trois entiers
int max3(int a, int b, int c) {
    int m = (a > b) ? a : b;  // Trouver le maximum entre `a` et `b`
    return (m > c) ? m : c;  // Comparer ensuite avec `c`
}


// Fonction pour obtenir le minimum de trois entiers
int min3(int a, int b, int c) {
    int mi = (a < b) ? a : b;  // Trouver le minimum entre `a` et `b`
    return (mi < c) ? mi : c;  // Comparer ensuite avec `c`
}


// Fonction pour créer un nouveau nœud avec une clé donnée
AVL* creerAVL(int e) {
    AVL* node = (AVL*)malloc(sizeof(AVL));
    node->valeur = e;
    node->fg = NULL;
    node->fd = NULL;
    node->hauteur = 1;  // La hauteur d'un nœud isolé est 1
    return node;
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
    a->hauteur = hauteur_a - min(hauteur_pivot, 0) + 1;  // Facteur d'équilibre de `y` après rotation
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
    a->hauteur = hauteur_a - max(hauteur_pivot, 0) - 1;  // Facteur d'équilibre de `a` après rotation
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
AVL* insertion(AVL* a, int e, int *h) {

    if (a == NULL) {
        *h = 1;
        return creerAVL(e);
    }

    if (e < a->valeur) {
        a->fg = insertion(a->fg, e, h);
        *h = -*h;
    } else if (e > a->valeur) {
        a->fd = insertion(a->fd, e, h);
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

// Fonction pour effectuer une recherche dans l'arbre AVL
AVL* recherche(AVL* a, int e) {
    // Si la clé est trouvée ou si l'arbre est vide
    if (a == NULL || a->valeur == e) {
        return a;
    }

    // Si la clé est plus petite que la racine, elle se trouve dans le sous-arbre gauche
    if (e < a->valeur) {
        return recherche(a->fg, e);
    }

    // Sinon, la clé est dans le sous-arbre droit
    return recherche(a->fd, e);
}

// Fonction pour afficher un arbre AVL en parcours infixe
void infixe(AVL* a) {
    if (a != NULL) {
        infixe(a->fg);
        printf("%d ", a->valeur);
        infixe(a->fd);
    }
}

// Fonction pour lire un fichier CSV et insérer les données dans un arbre AVL
AVL* InsererCSV(AVL* a, const char* file_path) {
    FILE* file = fopen(file_path, "r");
    if (file == NULL) {
        printf("Erreur : Impossible d'ouvrir le fichier %s.\n", file_path);
        return a;
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        int valeur;
        // Lire la clé (par exemple, première colonne) dans chaque ligne
        if (sscanf(line, "%d", &valeur) == 1) {
            int h = 0;
            a = insertion(a, valeur, &h);
        }
    }
    fclose(file);
    return a;
}


// Fonction pour écrire un arbre AVL dans un fichier CSV en ordre croissant
void Ecrire_AVL_CSV(AVL* a, FILE* file) {
    if (a != NULL) {
        Ecrire_AVL_CSV(a->fg, file);
        fprintf(file, "%d\n", a->valeur);  // Remplacez par les colonnes nécessaires
        Ecrire_AVL_CSV(a->fd, file);
    }
}

// Fonction principale pour écrire dans un fichier CSV
void Ecrire_CSV(AVL* a, const char* output_path) {
    FILE* file = fopen(output_path, "w");
    if (file == NULL) {
        printf("Erreur : Impossible d'écrire dans le fichier %s.\n", output_path);
        return;
    }
    Ecrire_AVL_CSV(a, file);
    fclose(file);
    printf("Arbre AVL exporté dans le fichier %s.\n", output_path);
}



int main() {
    AVL* a = NULL;

    // Lire les données d'un fichier CSV et les insérer dans l'arbre AVL
    const char* input_csv = "data.csv";
    a = InsererCSV(a, input_csv);

    // Exporter l'arbre AVL trié dans un nouveau fichier CSV
    const char* output_csv = "sorted_data.csv";
    Ecrire_CSV(a, output_csv);

    printf("Tri terminé. Données exportées dans %s.\n", output_csv);

    return 0;
}

