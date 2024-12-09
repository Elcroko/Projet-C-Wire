#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Définition d'un nœud d'un arbre AVL
typedef struct Node {
    int key;
    struct Node* left;
    struct Node* right;
    int height;
} Node;

// Fonction pour obtenir la hauteur d'un nœud
int height(Node* node) {
    if (node == NULL) {
        return 0;
    }
    return node->height;
}

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
    int maxAB = (a > b) ? a : b;  // Trouver le maximum entre `a` et `b`
    return (maxAB > c) ? maxAB : c;  // Comparer ensuite avec `c`
}


// Fonction pour obtenir le minimum de trois entiers
int min3(int a, int b, int c) {
    int minAB = (a < b) ? a : b;  // Trouver le minimum entre `a` et `b`
    return (minAB < c) ? minAB : c;  // Comparer ensuite avec `c`
}


// Fonction pour créer un nouveau nœud avec une clé donnée
Node* newNode(int key) {
    Node* node = (Node*)malloc(sizeof(Node));
    node->key = key;
    node->left = node->right = NULL;
    node->height = 1;  // La hauteur d'un nœud isolé est 1
    return node;
}

// Rotation droite
Node* rightRotate(Node* y) {
    Node* x = y->left;

    int height_y = y->height;
    int height_x = x->height;

    // Effectuer la rotation
    y->left = x->right;
    x->right = y;

    // Mise à jour des facteurs d'équilibre
    y->height = height_y - min(height_x, 0) + 1;  // Facteur d'équilibre de `y` après rotation
    x->height = max3(height_y + 2, height_y + height_x + 2, height_x + 1);  // Facteur d'équilibre de `x` après rotation

    return x;  // Le pivot devient la nouvelle racine
}


// Rotation gauche
Node* leftRotate(Node* y) {
    Node* x = y->right;

    int height_y = y->height;
    int height_x = x->height;

    // Effectuer la rotation
    y->right = x->left;
    x->left = y;

    // Mise à jour des facteurs d'équilibre
    y->height = height_y - max(height_x, 0) - 1;  // Facteur d'équilibre de `y` après rotation
    x->height = min3(height_y - 2, height_y + height_x - 2, height_x - 1);  // Facteur d'équilibre de `x` après rotation

    return x;  // Le pivot devient la nouvelle racine
}

// doubleRightRotate
Node* doubleRightRotate(Node* node) {
    node->left = leftRotate(node->left);  // Rotation gauche sur le sous-arbre gauche
    return rightRotate(node);  // Puis rotation droite sur le nœud déséquilibré
}

// doubleLeftRotate
Node* doubleLeftRotate(Node* node) {
    node->right = rightRotate(node->right);  // Rotation droite sur le sous-arbre droit
    return leftRotate(node);  // Puis rotation gauche sur le nœud déséquilibré
}

// Calcul du facteur d'équilibre d'un nœud
Node* getBalance(Node* node) {
    if (node->height >= 2) {
        if (node->right->height >= 0){
            return leftRotate(node);
        }
        else{
            return doubleLeftRotate(node);
        }
    }
    else if(node->height <= -2){
        if (node->left->height <= 0){
            return rightRotate(node);
        }
        else{
            return doubleRightRotate(node);
        }
    }
    return(node);
}

// Fonction d'insertion dans un arbre AVL
Node* insert(Node* node, int e, int *h) {
    // 1. Effectuer l'insertion dans l'arbre binaire de recherche standard
    if (node == NULL) {
        *h = 1;
        return newNode(e);
    }

    if (e < node->key) {
        node->left = insert(node->left, e, h);
        *h = -*h;
    } else if (e > node->key) {
        node->right = insert(node->right, e, h);
    } else {
        *h = 0;
        return node;
    }

    if(*h != 0){
        node->height += *h;
        node = getBalance(node);
        *h = (node->height == 0) ? 0 : 1; // MAJ de la hauteur
    }
    return node;
}

// Fonction pour effectuer une recherche dans l'arbre AVL
Node* search(Node* root, int key) {
    // Si la clé est trouvée ou si l'arbre est vide
    if (root == NULL || root->key == key) {
        return root;
    }

    // Si la clé est plus petite que la racine, elle se trouve dans le sous-arbre gauche
    if (key < root->key) {
        return search(root->left, key);
    }

    // Sinon, la clé est dans le sous-arbre droit
    return search(root->right, key);
}

// Fonction pour afficher un arbre AVL en ordre (in-order traversal)
void inorder(Node* root) {
    if (root != NULL) {
        inorder(root->left);
        printf("%d ", root->key);
        inorder(root->right);
    }
}

// Fonction pour lire un fichier CSV et insérer les données dans un arbre AVL
Node* readCSVAndInsert(Node* root, const char* file_path) {
    FILE* file = fopen(file_path, "r");
    if (file == NULL) {
        printf("Erreur : Impossible d'ouvrir le fichier %s.\n", file_path);
        return root;
    }

    char line[256];
    while (fgets(line, sizeof(line), file)) {
        int key;
        // Lire la clé (par exemple, première colonne) dans chaque ligne
        if (sscanf(line, "%d", &key) == 1) {
            int h = 0;
            root = insert(root, key, &h);
        }
    }
    fclose(file);
    return root;
}


// Fonction pour écrire un arbre AVL dans un fichier CSV en ordre croissant
void writeTreeToCSV(Node* root, FILE* file) {
    if (root != NULL) {
        writeTreeToCSV(root->left, file);
        fprintf(file, "%d\n", root->key);  // Remplacez par les colonnes nécessaires
        writeTreeToCSV(root->right, file);
    }
}

// Fonction principale pour écrire dans un fichier CSV
void exportTreeToCSV(Node* root, const char* output_path) {
    FILE* file = fopen(output_path, "w");
    if (file == NULL) {
        printf("Erreur : Impossible d'écrire dans le fichier %s.\n", output_path);
        return;
    }
    writeTreeToCSV(root, file);
    fclose(file);
    printf("Arbre AVL exporté dans le fichier %s.\n", output_path);
}



int main() {
    Node* root = NULL;

    // Lire les données d'un fichier CSV et les insérer dans l'arbre AVL
    const char* input_csv = "data.csv";
    root = readCSVAndInsert(root, input_csv);

    // Exporter l'arbre AVL trié dans un nouveau fichier CSV
    const char* output_csv = "sorted_data.csv";
    exportTreeToCSV(root, output_csv);

    printf("Tri terminé. Données exportées dans %s.\n", output_csv);

    return 0;
}

