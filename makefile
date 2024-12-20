# Nom de l'exécutable final
TARGET = avl_tree

# Nom du compilateur
CC = gcc

# Options de compilation
CFLAGS = -Wall -Wextra -O2

# Liste des fichiers source
SRCS = avl_tree.c

# Fichiers objets (générés automatiquement à partir des fichiers source)
OBJS = $(SRCS:.c=.o)

# Règle principale : compiler l'exécutable
all: $(TARGET)

# Règle pour générer l'exécutable à partir des fichiers objets
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Règle pour compiler les fichiers objets
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Nettoyer les fichiers objets et l'exécutable
clean:
	rm -f $(OBJS) $(TARGET)

# Nettoyer tous les fichiers générés (y compris les temporaires)
distclean: clean
	rm -f *~
