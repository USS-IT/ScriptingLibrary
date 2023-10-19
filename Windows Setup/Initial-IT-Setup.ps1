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

# Declare log types and their values.
$normalLog = "Normal"
$warningLog = "Warning"
$errorLog = "Error"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

<#
    .DESCRIPTION
    The installRsatTools function installs RSAT AD and Group Policy Management Tools. During this process it will disable and re-enable WSUS listing in Policy to prevent Windows Updates.
    todo: check for OS version and apply the correct WSUS policy. Currently errors on Win 11
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

<#
    .DESCRIPTION
    The installWingetApplications function installs all applications whose id's are listed in $wingetAppIds.
    #todo: before installing applications, check and update to latest winget version. https://stackoverflow.com/questions/74166150/install-winget-by-the-command-line-powershell
#>
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
        $message = ($id + " - " + $wingetOutput[-1])

        # Determine console log type based on successful install
        if ($message -notcontains "Successfully installed") {
            log $warningLog Get-FunctionName $message
        } else {
            log $normalLog Get-FunctionName $message
        }
    }
}

<#
    .DESCRIPTION
    The log function takes in three parameters, the type of log, the function it originated from, and the log message and outputs it to the console.

    .PARAMETER type
    Specifies the type of output to write.

    .PARAMETER function
    Specifies the name of the function passing the log message.

    .PARAMETER message
    Specifies the message of the log.

#>
function log ([string]$type, [string]$function, [string]$message) {
    switch -Exact ($type) {
        $normalLog {Write-Output ($function + ": " + $message); Break}
        $warningLog {Write-Warning ($function + ": " + $message); Break}
        $errorLog {Write-Error ($function + ": " + $message); Break}
        Default {Write-Error "Something went very wrong!"}
    }
}

<#
    .DESCRIPTION
    The main function calls all other functions to perform the actions required by this script.
#>
function main {
    installRsatTools
    #installConfigurationManagerConsole
    installWingetApplications
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Call the main function
main

#-----------------------------------------------------------[Finish up]------------------------------------------------------------
