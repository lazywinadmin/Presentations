<# PSKoans by Joel Sallow
https://github.com/vexx32/PSKoans

* Inspirer d'un projet F# https://github.com/ChrisMarinos/FSharpKoans
* Inspirer d'un autre projet Ruby https://github.com/edgecase/ruby_koans


# KOAN
Le kōan vient du bouddisme, et c'est un objet de méditation afin de permettre le discernement
 entre l'éveil et l’égarement.
In short: Vous meditez sur une contradiction dans le but d'atteindre une reponse intuitive.

Vous allez voir que les functions du module souleve un peu ces termes de:
 Meditation
 Karma
 Contemplation

* Donc pour revenir a PowerShell, en faite le concept est d'apprendre PowerShell directement
 par le code a travers une serie de puzzles/d'exercices
#>

<# Comment ca marche
    Lorsque vous charger le module, il va creer un dossier sous
    $home/PSKoans
    PSKoans utilise pester pour evaluer les exercices present
    
    
    vient avec une serie d'exercices built-in
    Utilise Pester pour demontrer des concepts du language PowerShell
    Vous devez corriger les erreurs retourner par Pester
#>
# Installation
Install-Module -Name Pester,PSKoans -Force -SkipPublisherCheck -Scope CurrentUser -Repository PSGallery -verbose

# Koans (Exercices)
dir $home/pskoans
Get-ChildItem -Path $home/pskoans -Recurse -Filter '*.Koans.ps1'

# PSKoans module files
ii $(split-path (gmo -list pskoans).path)

# Charger le module
Import-Module PSKoans

# Commencer avec Measure-Karma
Measure-Karma

# Le message montre:
# -Quelle partie ne fonctionne pas
# -Quel fichier doit etre verifier et a quelle ligne.
# -Suivre les instructions
# -Compte de Koans

# Corriger l'erreur
# Cela va ouvrir vscode
Measure-Karma -Meditate

# Ordre des Koans
#  Class defini dans le psm1
#  Sort est fait dans Measure-Karma a travers la position
#  Position defini dans chaque Koans