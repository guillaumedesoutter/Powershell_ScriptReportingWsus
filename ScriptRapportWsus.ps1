[void][Reflection.Assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer("localhost", $False, 8530) #Ici la connexion est non-secure sur le 8530, vous devez modifier avec les infos de votre WSUS


$TargetGroupName = ""  # <-- On insère le nom du lot que l'on veut analyser

# On recupere le Lot
$LotCible = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -eq $TargetGroupName }

if (!$LotCible) {
    Write-Host "Le groupe '$TargetGroupName' n'a pas ete trouve. Veuillez verifier le nom du groupe."
    exit
}

#On recupere les serveurs du lotcible
$computers = $LotCible.GetComputerTargets()

if ($computers.Count -eq 0) {
    Write-Host "Aucun ordinateur trouve dans le groupe '$TargetGroupName'."
    exit
}

# On definit les KB que l'on vérifier pour chaque OS
$KBacheck = @{
    'Windows Server 2016' = 'KB5044293'
    'Windows Server 2019' = 'KB5044277'
    'Windows Server 2022' = 'KB5044281'
}

# Créer une liste pour stocker les résultats
$report = @()

$compteur = 1  # Initialiser un compteur
$totalComputers = $computers.Count  # Nombre total d'ordinateurs

foreach ($computer in $computers) {

    Write-Host "[$compteur/$totalComputers] Traitement de l'ordinateur : $($computer.FullDomainName)"
    $compteur++

    # On recupere l'os
    $os = $computer.OSDescription

    # On determine quel KB est a check suivant l'os
    $kbSpecific = $null
    foreach ($osName in $KBacheck.Keys) {
        if ($os -like "*$osName*") {
            $kbSpecific = $KBacheck[$osName]
            break
        }
    }

    if (-not $kbSpecific) {
        # J'ai mis le continue si jamais l'os est pas un 2016, 2019 ou 2022        
        Write-Host "  - Systeme d'exploitation non pris en charge : $os"
        continue
    }

    # J'affine le scope pour n'afficher les KB qui sont en installed
    $updateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
    $updateScope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::Installed

    # On recupere les KB installed sur l'ordi
    $installationInfo = $computer.GetUpdateInstallationInfoPerUpdate($updateScope)

    # On refiltre une seconde fois les KB avec le status Installed pour etre sur de n'avoir que les installed
    $successfulUpdates = $installationInfo | Where-Object {
        $_.UpdateInstallationState -eq [Microsoft.UpdateServices.Administration.UpdateInstallationState]::Installed
    }

    # Si pas de KB installe on remplit le status avec le cas correspondant
    if ($successfulUpdates.Count -eq 0) {
        Write-Host "  - Aucune mise à jour installee trouvee pour cet ordinateur."
        $status = "KB non installee"
    } else {

        # On recupere l'id dans le titre car j'ai pas reussi autrement
        $updatesDetails = foreach ($updateStatus in $successfulUpdates) {
            $update = $wsus.GetUpdate($updateStatus.UpdateId)
            
            #Regex pour extraire le KB
            $kbNumber = ""
            if ($update.Title -match "KB(\d+)\)") {
                $kbNumber = "KB$($Matches[1])"
            }
            

            [PSCustomObject]@{
                KB           = $kbNumber
                Title        = $update.Title
            }
        }

        # On compare les KB installe avec ceux qu'on veut par rapport à l'OS
        $kbInstalled = $updatesDetails | Where-Object { $_.KB -eq $kbSpecific }

        if ($kbInstalled) {
            $status = "KB installee"
        } else {
            # La KB n'est pas installée
            $status = "KB non installee"
        }
    }

    # On incremente le report
    $report += [PSCustomObject]@{
        'Serveur'          = $computer.FullDomainName
        'OS'               = $os
        'KB'               = $kbSpecific
        'Statut'           = $status
    }
}

$date= Get-Date -Format "dd-MM-yyyy_HH-mm"
# Exporter le rapport vers un fichier CSV (vous pouvez modifier la nomenclature ainsi que le path où vous souhaitez que le rapport soit généré)
$reportFilePath = "C:\Temp\Rapport\WSUS_KB_Report_$($TargetGroupName)_$date.csv"
$report | Export-Csv -Path $reportFilePath -NoTypeInformation -Encoding UTF8

Write-Host "Le rapport a ete genere : $reportFilePath"
