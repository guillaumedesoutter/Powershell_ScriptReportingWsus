# 🔍WSUS KB Verification Script

## Description
Ce script PowerShell permet de vérifier si des correctifs spécifiques (KBs) sont installés sur les machines d'un groupe cible dans WSUS (Windows Server Update Services).  
Il génère un rapport détaillé pour chaque machine du groupe, contenant l'OS, le correctif attendu et son statut (installé ou non).


## Fonctionnalités
- **Chargement dynamique de l'assembly WSUS.**
- **Détection des machines dans un groupe cible** spécifié.
- **Vérification des correctifs par OS** : Windows Server 2016, 2019 et 2022.
- **Rapport CSV détaillé** généré avec les informations sur les machines et le statut des correctifs.


## Prérequis
- **Serveur WSUS actif** : Le script doit pouvoir accéder au WSUS via son adresse et son port.
- **Accès administrateur** : Pour récupérer les informations des groupes et machines WSUS.
- **PowerShell 5.1 ou supérieur** installé.
- **Répertoire d'exportation du rapport** (`C:\Temp\Rapport`) doit exister ou être modifié dans le script.


## Installation
1. Clonez ou téléchargez ce dépôt.
2. Assurez-vous que PowerShell est configuré pour exécuter des scripts (`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`).
3. Vérifiez que les prérequis sont respectés.


## Utilisation

1. **Modifier le script** : 
   - **Adresse WSUS** : Remplacez `localhost` dans la ligne suivante avec l'adresse de votre serveur WSUS :
     ```powershell
     $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer("localhost", $False, 8530)
     ```
   - **Nom du groupe cible** : Définissez la variable `$TargetGroupName` avec le nom du groupe WSUS à analyser :
     ```powershell
     $TargetGroupName = "NomDuGroupe"
     ```
   - **Liste des KB par OS** : Changez le contenu de `KBacheck` avec les KB que vous voulez vérifier correspondant à leur version d'OS.

3. **Exécuter le script** :
   Lancez le script dans une console PowerShell :
   ```powershell
   .\ScriptRapportWsus.ps1


## Resultat

![image](https://github.com/user-attachments/assets/f3af67df-e248-4db8-9234-6e2381ab6d68)


## Contribuer

Les contributions sont les bienvenues ! N'hésitez pas à soumettre des issues ou des pull requests pour améliorer ce script.


## Licence

Ce projet est sous licence [MIT](LICENSE). Vous êtes libre de l'utiliser, de le modifier et de le distribuer selon les termes de cette licence.


## Remerciements

Ce script a été conçu pour faciliter l'analyse des correctifs WSUS sur des groupes spécifiques. Merci à toutes les personnes qui contribuent à l'amélioration des outils d'administration Windows !

