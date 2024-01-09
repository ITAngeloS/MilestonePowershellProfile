# 🛠️ PowerShell Milestone Integration Profile

Welcome to the PowerShell Milestone Integration Profile repository! This comprehensive PowerShell profile is designed to streamline various tasks associated with Milestone Recording Servers and devices. 
Dive into the details of this profile's functionalities below.

## Profile Overview 📋

### Overview 🌟

This profile simplifies tasks related to Milestone Recording Servers and associated devices within your PowerShell environment. It's a collection of functions aimed at providing convenience and efficiency.

### Functions 🧰

#### Get-HardwareInfo 💻

- **Description**: Fetches hardware information from Milestone Recording Servers and exports the data to a CSV file.
- **Usage**:
    - `Get-HardwareInfo -Server "10.80.1.50" -CsvFilePath "C:\report.csv"` fetches hardware details from the specified Milestone Recording Server IP and exports them to C:\report.csv.
    - Use `Get-HardwareInfo` to interactively input server details and CSV file path.

#### Get-LastBootTime 🕒

- **Description**: Retrieves the last boot time of a remote or local computer.
- **Usage**: `Get-LastBootTime [ComputerName]` (defaults to local if ComputerName is omitted).

#### Get-WindowsVersion ℹ️

- **Description**: Retrieves the Windows version of a remote or local computer.
- **Usage**: `Get-WindowsVersion [ComputerName]` (defaults to local if ComputerName is omitted).

#### Get-CPUInfo ⚙️

- **Description**: Retrieves CPU information of a remote or local computer.
- **Usage**: `Get-CPUInfo [ComputerName]` (defaults to local if ComputerName is omitted).

#### Add-MilestoneExclusionsToDefender 🔒

- **Description**: Adds exclusions to Windows Defender for Milestone processes, programs, and files.
- **Usage**: `Add-MilestoneExclusionsToDefender`

#### RunAsAdmin 🚀

- **Description**: Opens a new PowerShell window with admin privileges.
- **Usage**: `RunAsAdmin`

#### Set-ExecutionPolicyRemoteSigned 🔐

- **Description**: Sets the execution policy to RemoteSigned for the LocalMachine scope.
- **Usage**: `Set-ExecutionPolicyRemoteSigned`

#### Set-ExecutionPolicyRestricted 🔒

- **Description**: Sets the execution policy to Restricted for the LocalMachine scope.
- **Usage**: `Set-ExecutionPolicyRestricted`

## Usage Guide 📖

This repository houses a comprehensive PowerShell profile intended for streamlined integration with Milestone Recording Servers:

1. **Installation**: Clone this repository to your local environment.
2. **Usage**:
    - **Local Scripts**: Execute PowerShell scripts/functions by calling their respective aliases or names in your local PowerShell environment.
    - **Remote Scripts**: For remote execution, ensure network connectivity and replace `[ComputerName]` with the target machine's name or IP address.

## Additional Information 🌐🚀🔧

- **Author**: Angelo S.
- **Contribution**: Contributions, feedback, and issue reports are appreciated via pull requests or issues on this repository.
