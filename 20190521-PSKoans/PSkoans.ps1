<# PSKoans
PowerShell module created by Joel Sallow
Source code: https://github.com/vexx32/PSKoans

* Inspired from a F# project https://github.com/ChrisMarinos/FSharpKoans
* itself inspired from a Ruby project https://github.com/edgecase/ruby_koans

# KOAN
https://en.wikipedia.org/wiki/K%C5%8Dan

Koan is coming from the buddist:
A koan is a riddle or puzzle that Zen Buddhists use during meditation to help them unravel
greater truths about the world and about themselves.


In this PowerShell module, you'll see terms related to this philosophy:
 Meditation
 Karma
 Contemplation

The goal of this module is to help people learn PowerShell with a series of puzzles/exercices.


# What is it about ?

    The PowerShell koans are a set of exercises designed to


# How does it work

    Lorsque vous charger le module, il va creer un dossier sous
    $home/PSKoans
    PSKoans utilise pester pour evaluer les exercices present


    vient avec une serie d'exercices built-in
    Utilise Pester pour demontrer des concepts du language PowerShell
    Vous devez corriger les erreurs retourner par Pester

# Puzzles
    A puzzle give you a target to hit
        write this function
        Test it
        Worked ? next puzzle
        Did not work ? review your code

    Most of the puzzles are "Fill the blanks"


# Where are the puzzle located ?
When you run Measure-Karma, it will put all the exercices inside the following folder:
C:\Users\$env:username\PSKoans\Foundations\


# Sorted
dir C:\Users\fxavi\PSKoans\ -recu -File |
    select-string -Pattern 'Koan\(position' |
    sort line

# Other info
## test a particular topic
Measure-Karma -Topic <tab>
## reset a particular topic
Measure-Karma -Topic <tab> -Reset
## reset everything
Measure-Karma -Reset

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