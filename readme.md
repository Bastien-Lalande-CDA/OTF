# Documentation du Projet : VAPF (Vérification Automatisée du Pare-Feu)

## 1. Présentation Générale

Le projet **VAPF** est un outil d'audit réseau conçu pour automatiser la vérification des règles de filtrage (pare-feu). Son objectif principal est de valider que l'état réel des flux réseau correspond aux autorisations définies dans une **matrice de flux**.

Dans les environnements complexes, la conformité des règles de pare-feu est critique. VAPF permet de détecter automatiquement les écarts entre la configuration attendue et le comportement réel du réseau.

---

## 2. Objectifs du Projet

* Automatiser les tests de connectivité réseau
* Vérifier la conformité des règles de filtrage
* Identifier rapidement les flux bloqués ou non conformes
* Générer des rapports exploitables pour les équipes réseau et sécurité

---

## 3. Architecture du Projet

Le projet est structuré en plusieurs modules écrits en **AutoHotkey (AHK)** :

* **Controller.ahk** : Orchestrateur principal, pilote l'exécution globale
* **Parser.ahk** : Lecture et validation du fichier CSV d'entrée
* **TestsEngine.ahk** : Moteur de tests réseau (TCP, UDP, ICMP)
* **Register.ahk** : Gestion des résultats et génération du rapport
* **HMI.ahk** : Interface utilisateur (affichage, interactions)

### Flux de traitement

1. Chargement du fichier CSV
2. Validation des données
3. Itération sur chaque ligne
4. Exécution du test réseau correspondant
5. Enregistrement du résultat
6. Génération du rapport final

---

## 4. Fonctionnement de l'Outil

L'outil s'appuie sur une matrice de flux au format CSV.

Pour chaque ligne :

1. Vérification que la machine locale correspond à la source (`source_ip`)
2. Sélection du protocole (TCP, UDP, ICMP)
3. Tentative de connexion vers la destination
4. Capture du résultat
5. Mise à jour de la colonne `status`

---

## 5. Spécifications des Données (CSV)

Le fichier d'entrée et le rapport de sortie partagent une structure commune afin de faciliter l'exploitation et l'automatisation.

### Structure du fichier CSV

| Colonne            | Description                      | Exemple                |
| :----------------- | :------------------------------- | :--------------------- |
| `source_name`      | Nom de la machine/zone émettrice | `SRV-WEB-01`           |
| `source_ip`        | Adresse IP source                | `192.168.1.10`         |
| `destination_name` | Nom de la machine/zone cible     | `DB-PROD-01`           |
| `destination_ip`   | Adresse IP de destination        | `10.0.2.50`            |
| `designation_port` | Numéro de port TCP/UDP           | `443`                  |
| `protocol`         | Protocole utilisé                | `TCP`, `UDP` ou `ICMP` |
| `service_name`     | Nom usuel du service             | `HTTPS`                |
| `status`           | État du test                     | `Success`              |

---

## 6. Analyse des Résultats

La colonne `status` est complétée après exécution :

* **Success** : Le flux est accessible et conforme
* **Failed** : Le flux est bloqué ou inaccessible
* **NOT TESTED (IP MISMATCH)** : Test non exécuté (la machine locale ne correspond pas à la source)
* **Sent/Open** : Paquet envoyé ou port ouvert (cas spécifique selon protocole)

---

## 7. Détails des Tests Réseau

### TCP

* Tentative d'ouverture de socket sur le port cible
* Validation basée sur la réussite de la connexion

### UDP

* Envoi d'un paquet
* Validation basée sur l'absence d'erreur ou réponse

### ICMP

* Ping de la destination
* Validation basée sur la réponse reçue

---

## 8. Prérequis

* Système Windows
* AutoHotkey installé
* Droits réseau suffisants pour effectuer les tests

---

## 9. Utilisation

1. Préparer le fichier CSV
2. Lancer le script principal (`VAPF.ahk`)
3. Attendre la fin des tests
4. Consulter le fichier de sortie généré dans `\outputs`

