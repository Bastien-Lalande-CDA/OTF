![Logo chantiers de l'atantique](/src/image/logo-chantiers-atlantique.svg)

# Guide d'utilisation du Script : VAPF (Vérification Automatisée du Pare-Feu)

## 1. Introduction

Ce guide explique comment utiliser le script **VAPF** afin de tester et valider des flux réseau à partir d’une matrice de flux.

---

## 2. Lancement du Script

1. Accédez au dossier racine du projet.
2. Localisez le fichier `VAPF.ahk`.
3. Double-cliquez sur ce fichier pour lancer le script.

> ⚠️ Assurez-vous qu’AutoHotkey v2 est installé sur votre machine avant de lancer le script.

---

## 3. Étape 1 : Choix du mode d’entrée

Au démarrage, une interface vous propose deux options :

* **Importer une matrice de flux (CSV)**
* **Créer une nouvelle matrice de flux**

![Choix de l'entrée](/src/image/UI/input-choice.png)

### Cas 1 : Import d’une matrice

* Sélectionnez cette option si vous disposez déjà d’un fichier CSV.
* Une fenêtre s’ouvre pour choisir le fichier à importer.

![Choix du chemin](/src/image/UI/path-choice.png)

### Cas 2 : Création d’une matrice

* Sélectionnez cette option pour créer une nouvelle matrice.
* Une interface d’édition vous permet de saisir les flux manuellement.

---

## 4. Édition de la matrice

Une fois dans l’éditeur de matrice, vous pouvez :

* **Ajouter** une ligne
* **Supprimer** une ligne
* **Modifier** une ligne existante

Ces actions sont accessibles via les trois boutons de contrôle.

![Choix édition de la matice](/src/image/UI/matrix-editing.png)

### Champs à renseigner

* Machine source
* Adresse IP source*
* Machine destination
* Adresse IP destination*
* Port*
* Protocole (TCP / UDP / ICMP)*
* Nom du service

* signifie que le champ est obligatoire

---

## 5. Exécution des Tests

Une fois la matrice chargée ou créée :

1. Le script parcourt chaque ligne de la matrice.
2. Il vérifie si la machine actuelle correspond à la source.
3. Il exécute le test réseau correspondant :

   * TCP : tentative de connexion
   * UDP : envoi de paquet
   * ICMP : ping
4. Le résultat est enregistré automatiquement.

---

## 6. Lecture des Résultats

À la fin de l’exécution, un écran de résultats s’affiche :

![Résultat des tests](/src/image/UI/results.png)

### Signification des statuts

* **Success** : Le flux est accessible
* **Failed** : Le flux est bloqué ou inaccessible
* **NOT TESTED (IP MISMATCH)** : Le test n’a pas été exécuté (la machine locale ne correspond pas à la source)
* **Sent/Open** : Paquet envoyé ou port ouvert (selon le protocole)

---

## 7. Enregistrement des résultats

Après avoir cliqué sur **« Enregistrer les résultats »**, une copie de la matrice d’entrée est créée dans le dossier :

``` path
/outputs/results_AAAAMMJJ_HHMMSS.csv
```

### Format du nom de fichier

* `AAAA` : année
* `MM` : mois
* `JJ` : jour
* `HHMMSS` : heure, minute et seconde

Ce format permet de conserver un historique horodaté des exécutions.

---

## 8. Bonnes pratiques

* Vérifiez que votre machine correspond bien aux entrées `source_ip`
* Assurez-vous que les ports testés sont autorisés en sortie
* Exécutez le script avec les droits nécessaires
* Validez le format du fichier CSV avant import
