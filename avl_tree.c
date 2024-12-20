#include "avl_tree.h"

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
    int m = (a > b) ? a : b;  // Trouver le maximum entre a et b
    return (m > c) ? m : c;  // Comparer ensuite avec c
}

// Fonction pour obtenir le minimum de trois entiers
int min3(int a, int b, int c) {
    int m = (a < b) ? a : b;  // Trouver le minimum entre a et b
    return (m < c) ? m : c;  // Comparer ensuite avec c
}

// Fonction pour créer un nouveau noeud
AVL* creerNoeud(int id_sta, long capa, long conso) {
    AVL* noeud = (AVL*)malloc(sizeof(AVL));
    if (noeud == NULL) {
    printf( "Erreur : Échec de l'allocation mémoire.\n");
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

// Fonction pour lire un fichier CSV et insérer les données dans un arbre AVL
AVL* lireFichierCSV(AVL* a, const char* cheminFichier) {
    FILE* fichier = fopen(cheminFichier, "r");
    if (fichier == NULL) {
        fprintf(stderr, "Erreur : Impossible d'ouvrir le fichier %s.\n", cheminFichier);
        return NULL;
    }

    // -------------------
    // Initialiser les compteurs
    // -------------------

    // Définir la taille de la ligne lue :
    //
    // id_station     : int    = 4  octets
    // délimiteur     : 1 char = 1  octet
    // capacité       : long   = 8  octets
    // délimiteur     : 1 char = 1  octet
    // consommation   : long   = 8  octets
    // retour chariot : 2 char = 2  octets
    // -------------------------------
    // taille totale requise = 24 octets
    //*

    char ligne[50]; 
    int h = 0; // Variable pour suivre l'équilibrage de l'arbre

    // Lire le fichier ligne par ligne
    while (fgets(ligne, sizeof(ligne), fichier)) {
        int id_station; 
        long capacite, consommation; // Initialisation des variables
        
        if (strstr(ligne, "Station") != NULL) { // Ignore l'en-tête
            continue;
        }
        // Extraire les donnees du CSV
        if (sscanf(ligne, "%d:%ld:%ld", &id_station, &capacite, &consommation) != 3) {
            fprintf(stderr, "Erreur : Ligne mal formatée. Ignorée : %s\n", ligne);
            continue;
        }
        // Insérer les données dans l'arbre AVL
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


int main(int argc, char* argv[]) { 

    // Vérifier que le programme reçoit suffisamment d'arguments
    if (argc < 3) {
        fprintf(stderr, "Utilisation : %s [fichier_entrée] [fichier_sortie] [taille_tampon]\n", argv[0]);
        return EXIT_FAILURE;
    }

    // Déclaration de l'arbre AVL et des fichiers d'entrée/sortie
    AVL* arbre = NULL;
    const char* cheminFichier = argv[1]; // Chemin du fichier d'entrée
    const char* fichierSortie = argv[2]; // Chemin du fichier de sortie

    // Permettre à l'utilisateur de spécifier une taille de tampon
    // Taille par défaut : 8 Ko (8192 octets) pour les machines 64 bits
    size_t tailleTampon = (argc >= 4) ? atol(argv[3]) : TAILLE_TAMPON_DEFAUT;

    // Lecture du fichier CSV et insertion des données dans l'arbre AVL
    arbre = lireFichierCSV(arbre, cheminFichier);

    // Vérifier si l'arbre AVL a été correctement rempli
    if (arbre == NULL) {
        fprintf(stderr, "Erreur lors du traitement du fichier %s.\n", cheminFichier);
        return EXIT_FAILURE;
    }

    // Exporter les données de l'arbre AVL dans un fichier CSV
    exporterAVLVersCSV(arbre, fichierSortie, tailleTampon);

    // Libérer la mémoire allouée à l'arbre AVL
    libererAVL(arbre);

    return 0;
}
