# Chasse RP pour FiveM

**Ajout de deux nouveaux items : Viande fraîche et Viande pourrie**

Ce script enrichit votre serveur FiveM avec une expérience immersive de chasse, intégrant la gestion d'items à travers `ox_inventory` et des interactions variées pour les joueurs.

## Fonctionnalités

- **Système de chasse** :  
  Les joueurs peuvent rejoindre ou quitter le métier de chasseur via un PNJ interactif.

- **Gestion des armes** :  
  Vérifie si le joueur possède un couteau (`WEAPON_KNIFE`) avant de pouvoir commencer la chasse.

- **Détection d'animaux** :  
  Identification des animaux spécifiques avec des modèles dédiés :
  - Vache
  - Lapin
  - Cerf
  - Halouf
  - Sanglier

- **Marqueurs dynamiques** :  
  Les animaux morts apparaissent avec un marqueur rouge sur leur position, permettant aux joueurs de les repérer facilement.

- **Récolte de viande** :  
  Les joueurs peuvent récupérer de la viande des animaux morts en utilisant une arme spécifique :
  - Viande fraîche avec un couteau (`WEAPON_KNIFE`).
  - Viande pourrie avec toute autre arme.

- **Optimisé pour ESX et ox_inventory** :  
  - Ajoute les items directement dans l'inventaire du joueur après la récolte.
  - Compatible avec ESX pour une gestion fluide des données.

## Installation

1. Clonez ce dépôt ou téléchargez-le sous forme de ZIP.
2. Ajoutez les fichiers dans votre dossier de ressources serveur.
3. Assurez-vous que `ox_inventory` est correctement configuré avec les nouveaux items :
   ```lua
   ox_inventory:registerItem('viande_fraiche', 'Viande Fraîche')
   ox_inventory:registerItem('viande_pourrie', 'Viande Pourrie')
    ```
4. Ajoutez et activez la ressource dans votre fichier `server.cfg`
    ```sql
    start ch_chasse
    ```
5. Redémarrez votre serveur.

## Utilisation

- Rejoindre le métier de chasseur :
Approchez le PNJ à la position `(966.145, -2128.694, 31.453)` et appuyez sur la touche `E`.

- Chasser et récolter :
Tuez un animal identifié, puis approchez le cadavre pour récupérer de la viande.

## Exigences

- **Framework** : ESX
- **Inventaire** : ox_inventory