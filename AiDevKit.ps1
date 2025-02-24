# Interactive AI Development Environment Setup Script
# Run as Administrator

# Enable TLS 1.2 for downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create temporary directory
$tempDir = "C:\temp_installer"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Function to get the correct desktop path
function Get-DesktopPath {
    try {
        # First try to get the desktop path using the Windows Shell
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace(0x0010)
        $desktopPath = $folder.Self.Path
    }
    catch {
        # Fallback methods if Shell method fails
        try {
            # Try getting from the registry
            $desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
        }
        catch {
            # Final fallback - check both standard and OneDrive paths
            $standardPath = "$env:USERPROFILE\Desktop"
            $oneDrivePath = "$env:USERPROFILE\OneDrive\Desktop"
            
            if (Test-Path $oneDrivePath) {
                $desktopPath = $oneDrivePath
            }
            else {
                $desktopPath = $standardPath
            }
        }
    }
    return $desktopPath
}

# Function to check and install dependencies
function Install-RequiredDependencies {
    Write-Host "`n=== Checking System Requirements ===" -ForegroundColor Cyan
    
    # Check Windows version
    $osInfo = Get-WmiObject -Class Win32_OperatingSystem
    $osVersion = [Version]($osInfo.Version)
    if ($osVersion -lt [Version]"10.0") {
        Write-Host "This script requires Windows 10 or later." -ForegroundColor Red
        exit
    }

    # Check if running as administrator
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Please run this script as Administrator!" -ForegroundColor Red
        exit
    }

    # Check PowerShellGet
    if (!(Get-Module -ListAvailable -Name PowerShellGet)) {
        Write-Host "Installing PowerShellGet..." -ForegroundColor Yellow
        Install-Module -Name PowerShellGet -Force -AllowClobber -Scope CurrentUser
    }
    
    # Check NuGet
    if (!(Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Host "Installing NuGet package provider..." -ForegroundColor Yellow
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    }
    
    # Check PowerShell modules
    $requiredModules = @("PackageManagement")
    foreach ($module in $requiredModules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing required module: $module" -ForegroundColor Yellow
            Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
        }
    }
    
    # Check .NET Framework
    $ndpKey = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\"
    if (Test-Path $ndpKey) {
        if ((Get-ItemProperty $ndpKey).Release -lt 461808) {
            Write-Host "Installing .NET Framework 4.7.2..." -ForegroundColor Yellow
            $netFrameworkUrl = "https://go.microsoft.com/fwlink/?LinkId=863262"
            $netFrameworkPath = "$tempDir\ndp472-kb4054530-x86-x64-allos-enu.exe"
            Invoke-WebRequest -Uri $netFrameworkUrl -OutFile $netFrameworkPath
            Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet /norestart" -Wait
        }
    }
    
    # Check Visual C++ Redistributable
    if (!(Test-Path "C:\Windows\System32\vcruntime140.dll")) {
        Write-Host "Installing Visual C++ Redistributable..." -ForegroundColor Yellow
        $vcRedistUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
        $vcRedistPath = "$tempDir\vc_redist.x64.exe"
        Invoke-WebRequest -Uri $vcRedistUrl -OutFile $vcRedistPath
        Start-Process -FilePath $vcRedistPath -ArgumentList "/quiet /norestart" -Wait
    }

    Write-Host "All system requirements checked and installed." -ForegroundColor Green
}

function Show-Menu {
    Clear-Host
    Write-Host "================ AI Development Environment Setup ================" -ForegroundColor Cyan
    Write-Host "Select components to install (Use arrow keys and Space to select)" -ForegroundColor Yellow
    Write-Host "Press Enter when you're done selecting" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Get-MultipleChoice {
    param(
        [array]$Options
    )
    
    $Selection = @()
    $CurrentSelection = 0
    $OptionsState = @{}
    
    foreach ($Option in $Options) {
        $OptionsState[$Option] = $false
    }
    
    while ($true) {
        Show-Menu
        
        # Display all options
        for ($i = 0; $i -lt $Options.Length; $i++) {
            $Prefix = if ($i -eq $CurrentSelection) { ">" } else { " " }
            $Checkbox = if ($OptionsState[$Options[$i]]) { "[X]" } else { "[ ]" }
            Write-Host "$Prefix $Checkbox $($Options[$i])"
        }
        
        # Handle key input
        $Key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($Key.VirtualKeyCode) {
            38 { # Up arrow
                $CurrentSelection = if ($CurrentSelection -le 0) { $Options.Length - 1 } else { $CurrentSelection - 1 }
            }
            40 { # Down arrow
                $CurrentSelection = if ($CurrentSelection -ge ($Options.Length - 1)) { 0 } else { $CurrentSelection + 1 }
            }
            32 { # Spacebar
                $OptionsState[$Options[$CurrentSelection]] = !$OptionsState[$Options[$CurrentSelection]]
            }
            13 { # Enter
                foreach ($Option in $Options) {
                    if ($OptionsState[$Option]) {
                        $Selection += $Option
                    }
                }
                return $Selection
            }
        }
    }
}

# Available components
$components = @{
    "NVIDIA Drivers" = @{
        type = "nvidia"
        url = "https://us.download.nvidia.com/tesla/527.41/527.41-data-center-tesla-driver-for-windows-server-2019-2016-released.exe"
        description = "Latest NVIDIA GPU drivers"
    }
    "CUDA Toolkit" = @{
        type = "cuda"
        url = "https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_522.06_windows.exe"
        description = "CUDA development toolkit"
    }
    "Google Chrome" = @{
        type = "choco"
        package = "googlechrome"
        description = "Web browser"
    }
    "Git" = @{
        type = "choco"
        package = "git"
        description = "Version control system"
    }
    "Miniconda3" = @{
        type = "choco"
        package = "miniconda3"
        description = "Python distribution for data science"
    }
    "FFmpeg" = @{
        type = "choco"
        package = "ffmpeg"
        description = "Media processing tool"
    }
    "Audacity" = @{
        type = "choco"
        package = "audacity"
        description = "Audio editor"
    }
    "OpenShot" = @{
        type = "choco"
        package = "openshot"
        description = "Video editor"
    }
    "GIMP" = @{
        type = "choco"
        package = "gimp"
        description = "Image editor"
    }
    "WinRAR" = @{
        type = "choco"
        package = "winrar"
        description = "File compression tool"
    }
    "Python" = @{
        type = "choco"
        package = "python"
        description = "Programming language"
    }
    "Discord" = @{
        type = "choco"
        package = "discord"
        description = "Communication platform"
    }
    "K-Lite Codec Pack" = @{
        type = "choco"
        package = "k-litecodecpackfull"
        description = "Media codecs collection"
    }
    "Notepad++" = @{
        type = "choco"
        package = "notepadplusplus"
        description = "Text editor"
    }
}

# Start main installation process
try {
    # Check and install dependencies
    Install-RequiredDependencies

    # Get user selection
    $selectedComponents = Get-MultipleChoice -Options $components.Keys

    if ($selectedComponents.Count -eq 0) {
        Write-Host "No components selected. Exiting..." -ForegroundColor Yellow
        exit
    }

    # Install Chocolatey if needed
    if ($selectedComponents | Where-Object { $components[$_].type -eq "choco" }) {
        if (!(Test-Path "$env:ProgramData\chocolatey\choco.exe")) {
            Write-Host "`nInstalling Chocolatey..." -ForegroundColor Yellow
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        }
    }

    # Install selected components
    foreach ($component in $selectedComponents) {
        Write-Host "`nInstalling $component..." -ForegroundColor Yellow
        Write-Host "Description: $($components[$component].description)" -ForegroundColor Cyan
        
        try {
            switch ($components[$component].type) {
                "choco" {
                    choco install $components[$component].package -y
                }
                "nvidia" {
                    $driverPath = "$tempDir\nvidia_driver.exe"
                    Write-Host "Downloading NVIDIA drivers..."
                    Invoke-WebRequest -Uri $components[$component].url -OutFile $driverPath
                    Write-Host "Installing NVIDIA drivers..."
                    Start-Process -FilePath $driverPath -ArgumentList "/s /n" -Wait
                }
                "cuda" {
                    $cudaPath = "$tempDir\cuda_installer.exe"
                    Write-Host "Downloading CUDA toolkit..."
                    Invoke-WebRequest -Uri $components[$component].url -OutFile $cudaPath
                    Write-Host "Installing CUDA toolkit..."
                    Start-Process -FilePath $cudaPath -ArgumentList "-s" -Wait
                }
            }
        }
        catch {
            Write-Host "Error installing $component : $_" -ForegroundColor Red
        }
    }

    # Setup Miniconda environment if selected
    if ($selectedComponents -contains "Miniconda3") {
        Write-Host "`nSetting up Miniconda environment..." -ForegroundColor Yellow
        $condaPath = "$env:USERPROFILE\miniconda3\Scripts\conda.exe"
        if (Test-Path $condaPath) {
            & $condaPath init powershell
            
            $setupAI = Read-Host "Would you like to set up an AI development environment? (y/n)"
            if ($setupAI -eq 'y') {
                & $condaPath create -n ai_dev python=3.9 -y
                & $condaPath activate ai_dev
                & $condaPath install numpy pandas scikit-learn pytorch torchvision torchaudio cudatoolkit -c pytorch -y
            }
        }
    }

    # Create setup report
    $report = @"
Setup Report
===========
Date: $(Get-Date)

Installed Components:
$($selectedComponents | ForEach-Object { "- $_" } | Out-String)

Notes:
- Please restart your computer to complete the installation
- For NVIDIA components, ensure your GPU is compatible
- For Miniconda, open a new terminal to use the environment

Support:
If you encounter any issues, please check the following:
- Windows Update is current
- Your system meets the minimum requirements
- You have sufficient disk space
"@

    # Save report using the new desktop path function
    $desktopPath = Get-DesktopPath
    $reportPath = Join-Path -Path $desktopPath -ChildPath "setup_report.txt"
    $report | Out-File $reportPath -Force

    Write-Host "`nSetup completed successfully!" -ForegroundColor Green
    Write-Host "A detailed report has been saved to: $reportPath" -ForegroundColor Yellow
    Write-Host "Please restart your computer to complete the installation." -ForegroundColor Yellow
}
catch {
    Write-Host "An error occurred during installation: $_" -ForegroundColor Red
}
finally {
    # Cleanup
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
}
