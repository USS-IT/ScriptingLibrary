<#
    .SYNOPSIS
    Installs base applications that members of the USS IT Services department use.

    .DESCRIPTION
    This script will install RSAT AD and Group Policy Management Tools, Configuration Manager Console, and a few other applications via winget.

    .NOTES
    Version:        0.1
    Author:         LDG
    Creation Date:  10/19/2023
    Purpose/Change: Automate setup process for USS IT admin systems.
#>

#-----------------------------------------------------------[Parameters]-----------------------------------------------------------

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Ensure best coding practices are followed
Set-StrictMode -Version Latest

# Set Error Action to Continue
$ErrorActionPreference = "Continue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#-----------------------------------------------------------[Functions]------------------------------------------------------------

<#
    .DESCRIPTION
    The Install-Rsat-Tools function installs RSAT AD and Group Policy Management Tools. During this process it will disable and re-enable WSUS listing in Policy to prevent Windows Updates.
 #>
function installRsatTools {
    # Temporarily disable Windows Update policy, restarting Windows Update.
    $UseWUServer = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | Select-Object -ExpandProperty UseWUServer
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
    Restart-Service "Windows Update"

    # Install RSAT AD Management Tools
    Get-WindowsCapability -Name "Rsat.ActiveDirectory.DS-LDS.Tools*" -Online | Add-WindowsCapability -Online

    # Install RSAT Group Policy Management Tools
    Get-WindowsCapability -Name "Rsat.GroupPolicy.Management.Tools*" -Online | Add-WindowsCapability -Online

    # Restore Windows Update policy and restart Windows Update service.
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $UseWUServer
    Restart-Service "Windows Update"
}


function installConfigurationManagerConsole {
    #todo
}


function installWingetApplications {
    # Declare an array of all Winget application ids.
    $wingetAppIds = @(
        "Yubico.Authenticator",
        "Yubico.YubikeyManager",
        "Notepad++.Notepad++",
        "DominikReichl.KeePass",
        "Git.Git",
        "Microsoft.WindowsTerminal",
        "Microsoft.SQLServerManagementStudio",
        "Microsoft.PowerToys",
        "Dell.CommandUpdate.Universal",
        "Mozilla.Firefox",
        "VideoLAN.VLC"
    )

    # Iterate over $wingetAppIds and install each one.
    foreach ($id in $wingetAppIds) {
        $wingetOutput = @(winget install -e --id $id --accept-package-agreements)

        if ($wingetOutput[-1] -ne "Successfully installed") {
            Write-Warning ($id + ": " + $wingetOutput[-1])
        } else {
            Write-Output ($id + ": " + $wingetOutput[-1])
        }
    }
}

function ConsoleOut {
    #todo
}



function main {
    installRsatTools
    #installConfigurationManagerConsole
    installWingetApplications
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Call the main function
main

#-----------------------------------------------------------[Finish up]------------------------------------------------------------
