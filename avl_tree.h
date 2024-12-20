#ifndef AVL_TREE_H
#define AVL_TREE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAILLE_TAMPON_DEFAUT 8192

// Structure de l'arbre AVL
typedef struct Node {
    long capacite;           // Capacité associée à un nœud
    long consommation;       // Consommation associée à un nœud
    struct Node* fg;         // Pointeur vers le fils gauche
    struct Node* fd;         // Pointeur vers le fils droit
    int id_station;          // Identifiant de la station
    int hauteur;             // Hauteur du nœud pour le calcul des rotations
} AVL;

// Prototypes des fonctions

// Crée un nouveau nœud AVL avec les données fournies
AVL* creerNoeud(int id_sta, long capa, long conso);

// Insère un nouveau nœud dans l'arbre AVL et équilibre l'arbre si nécessaire
AVL* insertion(AVL* a, int id_sta, long capa, long conso, int* h);

// Libère récursivement la mémoire allouée pour l'arbre AVL
void libererAVL(AVL* a);

// Retourne le maximum entre deux entiers
int Max(int a, int b);

// Retourne le minimum entre deux entiers
int Min(int a, int b);

// Retourne le maximum entre trois entiers
int max3(int a, int b, int c);

// Retourne le minimum entre trois entiers
int min3(int a, int b, int c);

// Effectue une rotation droite sur un nœud de l'arbre AVL
AVL* Rotation_D(AVL* a);

// Effectue une rotation gauche sur un nœud de l'arbre AVL
AVL* Rotation_G(AVL* a);

// Effectue une double rotation droite (gauche + droite) sur un nœud
AVL* doubleRotation_D(AVL* a);

// Effectue une double rotation gauche (droite + gauche) sur un nœud
AVL* doubleRotation_G(AVL* a);

// Équilibre un nœud de l'arbre AVL si nécessaire
AVL* equilibre(AVL* a);

// Lit un fichier CSV et insère les données dans l'arbre AVL
AVL* lireFichierCSV(AVL* a, const char* cheminFichier);

// Exporte récursivement l'arbre AVL dans un fichier avec un tampon
void exporterAVL(AVL* arbre, FILE* fichier, char *tampon, size_t *indexTampon, size_t tailleTampon);

// Exporte les données de l'arbre AVL dans un fichier CSV avec gestion de tampon
void exporterAVLVersCSV(AVL* arbre, const char* cheminFichier, size_t tailleTampon);

#endif // AVL_TREE_H
