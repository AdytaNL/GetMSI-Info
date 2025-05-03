<#
.SYNOPSIS
Reads MSI file properties and logs the output.

.DESCRIPTION
This script allows you to select an MSI file (interactively or via parameter), reads properties such as ProductCode, ProductVersion, ProductName, and Manufacturer using the Windows Installer COM object, and logs them to both file and console.

.PARAMETER LogPath
Optional: Path to store the log file. Default is C:\Install\Scripts\Logs.

.PARAMETER MSIPath
Optional: Path to the MSI file. Used in combination with -Silent mode.

.PARAMETER Silent
Optional: If specified, runs without user interaction and requires -MSIPath.

.AUTHOR
Lambert
Adyta.nl

.VERSION
1.0

.LICENSE
MIT
#>

param (
    [string]$LogPath = "C:\Install\Scripts\Logs",
    [string]$MSIPath = "",
    [switch]$Silent
)

# --- LOGGING INITIALIZATION ---
$logFile = Join-Path -Path $LogPath -ChildPath ((Get-Item -Path $PSCommandPath).Name.Replace(".ps1", ".log"))

# ----- FUNCTIONS ----
# Logging function
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )

    $username = $env:USERNAME

    if (-not (Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "$timestamp [$Level] [$username] $Message"

    # Display log in console if interactive
    if ($Host.UI.RawUI -ne $null) {
        Write-Host $logLine
    }

    # Append to log file
    Add-Content -Path $logFile -Value $logLine
}

# Function to get an MSI property
function Get-MSIProperty {
    param (
        [string]$propertyName
    )

    $query = "SELECT Value FROM Property WHERE Property = '$propertyName'"
    $view = $msiDatabase.OpenView($query)
    $view.Execute()
    $record = $view.Fetch()

    if ($record) {
        return $record.StringData(1)
    } else {
        return $null
    }
}

# Function to get and trim an MSI property
function Get-MSIPropertyAndTrim {
    param (
        [string]$propertyName
    )

    $propertyValue = Get-MSIProperty $propertyName

    if ($propertyValue) {
        $propertyValue = [string]$propertyValue
        $propertyValue = $propertyValue.Trim()
    } else {
        Write-Log "$propertyName is empty or null. Cannot trim." "WARNING"
        $propertyValue = "Unknown"
    }

    return $propertyValue
}
# ----- END FUNCTIONS ----

# ----- SELECT MSI FILE VIA GUI -----
if (-not $Silent -and -not $MSIPath) {
    Add-Type -AssemblyName System.Windows.Forms

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Filter = "MSI files (*.msi)|*.msi"
    $OpenFileDialog.Title = "Select an MSI file"
    $OpenFileDialog.InitialDirectory = "C:\Install\UniFlow\Input"

    if ($OpenFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $MSIPath = $OpenFileDialog.FileName
        Write-Log "Selected MSI file: $MSIPath"
    } else {
        Write-Log "No MSI file selected. Script is terminating." "ERROR"
        exit 1
    }
} elseif (-not (Test-Path $MSIPath)) {
    Write-Log "MSI path is invalid or not found. Script is terminating." "ERROR"
    exit 1
}
# ----- END MSI FILE SELECTION -----

# ---- RETRIEVE MSI PROPERTIES ----
try {
    $windowsInstallerObject = New-Object -ComObject WindowsInstaller.Installer
    $msiDatabase = $windowsInstallerObject.OpenDatabase($MSIPath, 0)

    Write-Log "Retrieving ProductCode, Version, Application Name, and Publisher from MSI file..."

    $ProductCode = Get-MSIPropertyAndTrim "ProductCode"
    $ProductVersion = Get-MSIPropertyAndTrim "ProductVersion"
    $AppName = Get-MSIPropertyAndTrim "ProductName"
    $Publisher = Get-MSIPropertyAndTrim "Manufacturer"

    # Display results
    Write-Log "Path to MSI: '$MSIPath'"
    Write-Log "Found ProductCode: $ProductCode"
    Write-Log "Found ProductVersion: $ProductVersion"
    Write-Log "Found AppName: $AppName"
    Write-Log "Found Publisher: $Publisher"

} catch {
    Write-Log "Error retrieving properties from MSI file: $_" "ERROR"
    exit 1
} finally {
    if ($msiDatabase) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($msiDatabase) | Out-Null }
    if ($windowsInstallerObject) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($windowsInstallerObject) | Out-Null }
}
# ---- END MSI PROPERTIES RETRIEVAL ----
