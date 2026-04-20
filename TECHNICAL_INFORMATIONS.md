![Logo chantiers de l'atantique](/src/image/logo-chantiers-atlantique.svg)

# Documentation technique du Script : OTF (Outil de Test de Flux)

## Architecture du Script

Le script est structuré en plusieurs modules écrits en **AutoHotkey (AHK)** en suivant les principes de **POO**:

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

## Fonctionnement de l'Outil

L'outil s'appuie sur une matrice de flux au format CSV.

Pour chaque ligne :

1. Vérification que la machine locale correspond à la source (`source_ip`)
2. Sélection du protocole (TCP, UDP, ICMP)
3. Tentative de connexion vers la destination
4. Capture du résultat
5. Mise à jour de la colonne `status`

---

## Spécifications des Données (CSV)

Le fichier d'entrée et le rapport de sortie partagent une structure commune afin de faciliter l'exploitation et l'automatisation. Structure détailler dans le tableau ci-dessous.

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

## Analyse des Résultats

La colonne `status` est complétée après exécution :

* **Success** : Le flux est accessible et conforme
* **Failed** : Le flux est bloqué ou inaccessible
* **NOT TESTED (IP MISMATCH)** : Test non exécuté (la machine locale ne correspond pas à la source)
* **Sent/Open** : Paquet UDP envoyé (ne garantis pas la comunication dit juste qu' paquet a été envoyer avec succès)

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

## 7. Dépannage

### Aucun test ne s’exécute

* Vérifiez que votre IP correspond à la colonne `source_ip`

### Tous les tests échouent

* Vérifiez les règles de pare-feu locales
* Testez la connectivité réseau manuellement

### Problème d’import CSV

* Vérifiez le séparateur du CSV (`;` obligatoire)
* Vérifiez la présence de toutes les colonnes requises
