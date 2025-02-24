# AI Development Setup Kit

## Overview

The **AI Development Setup Kit** script is a PowerShell tool designed to automate the setup of an AI development environment on Windows. It simplifies the installation of essential tools, libraries, and dependencies required for AI and machine learning development. The script checks system requirements, installs necessary dependencies, and provides an interactive menu for selecting and installing components such as NVIDIA drivers, CUDA Toolkit, Miniconda, and other development tools. It is designed to be run as an administrator and generates a detailed setup report upon completion.

---

## Features

- **System Requirements Check**: Ensures the system meets the minimum requirements for AI development.
- **Dependency Installation**: Automatically installs required dependencies such as .NET Framework, Visual C++ Redistributable, and PowerShell modules.
- **Interactive Component Selection**: Provides a user-friendly menu for selecting components to install.
- **Chocolatey Integration**: Uses Chocolatey, a package manager for Windows, to install common software packages.
- **Miniconda Setup**: Optionally sets up a Miniconda environment for AI development, including popular Python libraries like PyTorch and scikit-learn.
- **Detailed Setup Report**: Generates a comprehensive report with installation details and post-installation instructions.

---

## Prerequisites

Before running the script, ensure the following:

1. **Windows 10 or later**: The script requires Windows 10 or later.
2. **Administrator Privileges**: The script must be run as an administrator.
3. **Internet Connection**: The script downloads necessary files from the internet.

---

## Installation

1. **Download the Script**:
   - Save the script as `AiDevKit.ps1` on your local machine.
   - Alternatively, clone the repository (if available) to access the script.

2. **Run the Script**:
   - Open PowerShell as an administrator.
   - Navigate to the directory where the script is saved.
   - Run the script using the following command:
     ```powershell
     .\AiDevKit.ps1
     ```

---

## Usage

### Step 1: System Requirements Check
The script will first check if your system meets the minimum requirements, including:
- Windows version (must be Windows 10 or later).
- Administrator privileges.
- Required PowerShell modules and dependencies.

### Step 2: Component Selection
You will be presented with an interactive menu to select the components you want to install. Use the arrow keys to navigate and the spacebar to select/deselect components. Press **Enter** when done.

### Step 3: Installation
The script will proceed to install the selected components. This includes:
- Installing Chocolatey (if not already installed).
- Downloading and installing NVIDIA drivers, CUDA Toolkit, Miniconda, and other selected tools.

### Step 4: Miniconda Setup (Optional)
If Miniconda is selected, the script will:
- Install Miniconda3.
- Prompt you to set up an AI development environment.
- Install Python libraries such as NumPy, Pandas, scikit-learn, PyTorch, and CUDA Toolkit (if applicable).

### Step 5: Completion
Once the installation is complete:
- A setup report (`setup_report.txt`) will be saved to your desktop.
- The script will prompt you to restart your computer to complete the installation.

---

## Available Components

The script supports the installation of the following components:

| Component            | Description                          | Installation Method |
|----------------------|--------------------------------------|---------------------|
| NVIDIA Drivers       | Latest NVIDIA GPU drivers            | Direct Download     |
| CUDA Toolkit         | CUDA development toolkit             | Direct Download     |
| Google Chrome        | Web browser                          | Chocolatey          |
| Git                  | Version control system               | Chocolatey          |
| Miniconda3           | Python distribution for data science | Chocolatey          |
| FFmpeg               | Media processing tool                | Chocolatey          |
| Audacity             | Audio editor                         | Chocolatey          |
| OpenShot             | Video editor                         | Chocolatey          |
| GIMP                 | Image editor                         | Chocolatey          |
| WinRAR               | File compression tool                | Chocolatey          |
| Python               | Programming language                 | Chocolatey          |
| Discord              | Communication platform               | Chocolatey          |
| K-Lite Codec Pack    | Media codecs collection              | Chocolatey          |
| Notepad++            | Text editor                          | Chocolatey          |

---

## Setup Report

Upon completion, the script generates a setup report saved to your desktop (`setup_report.txt`). The report includes:

- **Date**: The date and time of the installation.
- **Installed Components**: A list of components that were installed.
- **Notes**: Important notes and instructions for completing the setup, such as:
  - Restarting your computer.
  - Verifying GPU compatibility for NVIDIA components.
  - Activating the Miniconda environment in a new terminal.

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## Support

If you encounter any issues, please ensure the following:
- **Windows Update**: Ensure your system is up to date.
- **System Requirements**: Verify that your system meets the minimum requirements.
- **Disk Space**: Ensure you have sufficient disk space for the installations.

For further assistance, please open an issue on the GitHub repository.

---

## Contributing

Contributions are welcome! If you'd like to contribute to this project, please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

---

## Acknowledgments

- **Chocolatey**: For providing a convenient package manager for Windows.
- **NVIDIA**: For providing GPU drivers and CUDA Toolkit.
- **Python Community**: For providing a robust ecosystem for AI development.

---

## Example Setup Report

```
Setup Report
===========
Date: 10/25/2023 14:30:00

Installed Components:
- NVIDIA Drivers
- CUDA Toolkit
- Miniconda3
- Git

Notes:
- Please restart your computer to complete the installation.
- For NVIDIA components, ensure your GPU is compatible.
- For Miniconda, open a new terminal to use the environment.

Support:
If you encounter any issues, please check the following:
- Windows Update is current.
- Your system meets the minimum requirements.
- You have sufficient disk space.
```
