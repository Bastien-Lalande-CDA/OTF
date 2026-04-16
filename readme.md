# Documentation du Projet : VAPF (Vérification Automatisée du Pare-Feu)

## 1. Présentation Générale
Le projet **VAPF** est un outil d'audit réseau conçu pour automatiser la vérification des règles de filtrage (Pare-feu). L'objectif principal est de s'assurer que l'état réel des flux sur le réseau correspond aux autorisations définies dans une **matrice de flux**.

L'outil permet de testé les flux afin de vérifier si les service pourron acèder au reseau.

## 2. Fonctionnement de l'Outil
L'outil s'appuie sur une matrice de flux au format CSV. Il itère sur chaque ligne, tente d'établir une connexion selon le protocole et le port spécifiés et note le résultat.

## 3. Spécifications des Données (CSV)

Le fichier d'entrée et le rapport de sortie partagent une structure commune afin de faciliter la lecture et l'automatisation.

## 4. Structure du fichier CSV
Le fichier doit comporter les colonnes suivantes :

| Colonne | Description | Exemple |
| :--- | :--- | :--- |
| `source_name` | Nom de la machine/zone émettrice | `SRV-WEB-01` |
| `source_ip` | Adresse IP source | `192.168.1.10` |
| `destination_name` | Nom de la machine/zone cible | `DB-PROD-01` |
| `destination_ip` | Adresse IP de destination | `10.0.2.50` |
| `designation_port` | Numéro de port TCP/UDP | `443` |
| `protocol` | Protocole utilisé | `TCP` , `UDP` ou `ICMP` |
| `service_name` | Nom usuel du service | `HTTPS` |
| `status` | État constaté en sortie | `Success` |


## 5. Analyse des Résultats
Le fichier de sortie complétera la colonne `status` :
* **Success** : Le flux est accessible.
* **Failed** : .
* **NOT TESTED (IP MISMATCH)** : Ligne non testé car la machine sur laquel le script a été executé n'est pas la source.
* **Sent/Open** : 
