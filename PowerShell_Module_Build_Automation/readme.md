# PowerShell Module Build Automation

Comment automatiser le build de vos modules.

Voir: https://github.com/lazywinadmin/PSModuleSample/

## Assumptions

* Familiar with Git
* Familiar with PowerShell

## Acronyms and definitions

| Name | Definition |
| -- | -- |
| CI | Continuous Integration |
| CD | Continuous Deployment |
| IDE | Integrated Development Environment|
| Appveyor | CI/CD engine|
| Azure DevOps | CI/CD engine|

## Agenda

1. Modules Folder Structures
1. Build automation c'est quoi ?
1. Yaml - Show syntax from appveyor / az devops
1. Yaml fait juste rouler des test pester, les publier.
1. Deplacer logic vers build.ps1
1. Deployer dans la gallery
  1. Gestion de secrets
1. Probleme avec cette approche
  1. Gestion de version du module
  1. Gestion du psm1 file
  1. Build then test the final product
  1. Deploy only in some scenario "deploy!"
1. Ameliorer cette approche
  1. PSake
  1. CI/CD agnostic avec BuildHelper
  1. Documentation
  1. Presentation




#########################################
#########################################
#########################################




## Folders structure

Voir presentation de

  * *readme*
    * contains useful information for user and contributors
  * *license*
    * define the license to follow
  * *git config*
  * *tests*
    * Pester Unit tests
  * *appveyor.yml*
    * Consumed by the CI/CD engine

## Other topics to cover ?

* template / plaster
* ModuleCommon files / Central location
* IDE settings / conformite
* Best Practices enforcement
* documentation management
* dependences management

# Demos
## Scenario A - One psm1 file

* root
  * Readme.md
  * License
  * Folder "PSModuleSampleA"
    * PSModuleSampleA.psd1
    * PSModuleSampleA.psm1
  * Folder "Tests"
  * appveyor.yml

Simple module with unit tests and appveyor (CI/CD) running them.
1. +Fast to load
1. +Easy distribution
1. -Hard to maintain (can be a very long file)
1. Integration with Appveyor
1. See content of appveyor.yml

## Scenario B - Dot Sourcing

* root
  * Readme.md
  * License
  * Folder "PSModuleSampleA"
    * *Folder "Public"*
      * *one file per function*
    * *Folder "Private"*
      * *one file per function*
    * PSModuleSampleA.psd1
    * PSModuleSampleA.psm1
  * Folder "Tests"
  * appveyor.yml

Using Each functions in a ps1 file
1. +Easy to maintain
1. +Short Psm1
1. +Adding functions
1. -Slow to load
1. -Potential security issues
1. -Slow command discovery


## Scenario C - Compiled psm1

* root
  * Readme.md
  * License
  * Folder "PSModuleSampleA"
    * *Folder "Functions"*
      * *one file per function*
    * PSModuleSampleA.psd1
    * PSModuleSampleA.psm1
  * Folder "Tests"
  * appveyor.yml
  * *build.ps1*

"Compiling" your ps1 into a psm1 file.
1. +Easy to maintain
1. +Quick to load
1. +Distribute
1. +Adding functions
1. -Complexe to learn
1. -Automation needed

## Scenario D - Using a PowerShell script to build

Create a new file `build.ps1` and delegate it to run build tasks.

* root
  * Readme.md
  * License
  * Folder "PSModuleSampleA"
    * Folder "Public"
      * one file per function
    * Folder "Private"
      * one file per function
    * PSModuleSampleA.psd1
    * PSModuleSampleA.psm1
  * Folder "Tests"
  * appveyor.yml
  * *build.ps1*

## Scenario - PSDepends, Invoke-Build, PSake
## Scenario - Testing
* Test against the psm1
* if a bug is found, write a test for it and then fix it
## Scenario - Documentation
* Write it
* Consider PlatyPS to generate External help
* Remind user about Get-Help
* About_pages are your friend for complex details

## Scenario - Publish Tests
## Scenario - Publish Tests
## Scenario - Local development
## Scenario - Local development


Invoke-Build
PSake
PSDepend
Azure
Appveyor

Build your psm1
Test your psm1 (test what you are shipping)
ScriptAnalyzer your psm1

## Scenario - Publish to Gallery

## How to you simplify this whole process for each of your new module
### Creating a Plaster template
### Creating a Reference library
Contains all the generic files

* root
  * Folder "Source"
    * *Folder "Public"*
      * *one file per function*
    * *Folder "Private"*
      * *one file per function*
  * Folder "Tests"
  * appveyor.yml
  * azure-pipelines.yml
  * *build.ps1*
  * *psake.ps1*
  * CONTRIBUTING.md
    * https://github.com/PowerShell/PowerShell/blob/master/.github/CONTRIBUTING.md
  * CHANGELOG.md
  * .github/ISSUE_TEMPLATE/
    * bug_report.md
    * feature_request.md
  * .gitignore
```
    **TestPad.ps1
    **-PSGSuite.xml
    **.insyncdl
    .vscode
    API-to-Function-Map.md
    QueueExample.ps1
    ChatBotLoop.ps1
    DLLUnpack.ps1
    DLLUnpackStg
    DLLUnpackStg/*
    FunctionBackups
    FunctionBackups/*
    BuildOutput/*
    *config.csv
    PSGSuite.zip
```


Pour le meeting sur les PowerShell module build automation, je pensais faire genre:
1. Commencer avec un module simple qui contient des tests et l'organisation des dossiers
2. Ajouter Continuous deployment (Appveyor/Azure Devops) qui roule simplement les tests
3. Aller plus en profondeur dans le build, ajouter psake, buildhelper etc...
4. Autre idees: Gerer les version de module, Compiler les ps1 dans un psm1, publier dans la gallery etc...
c'est mes premieres idees pour le moment
peut-etre je peux regarder la presentation de Chris pour voir ce qu'il a couvert

https://www.youtube.com/watch?reload=9&v=-gyvP-h-zXs
https://www.youtube.com/watch?v=wSFwOib_48g
https://blog.netnerds.net/2018/12/even-faster-powershell-module-loading/
https://www.youtube.com/watch?v=Y3aALvpNZrk

documentation
vscode configuration


https://www.dell.com/support/article/us/en/04/sln171944/how-to-troubleshoot-slow-performance-issues?lang=en

## Resources
* Chris Gardner - Building Better Bricks https://www.youtube.com/watch?v=-gyvP-h-zXs&t=833s
* https://github.com/PoshCode/ModuleBuilder
* https://github.com/gaelcolas/SampleModule
