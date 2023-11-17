#aggiorna le modifiche di questa cartella con --> . $PROFILE

Set-Alias -Name policy -Value Get-ExecutionPolicy

function Get-MilestoneHardwareInfo {
    <#
    .SYNOPSIS
    Retrieves hardware information from Milestone Recording Servers.
    
    .DESCRIPTION
    The Get-MilestoneHardwareInfo function retrieves hardware information from Milestone Recording Servers and stores the results in an array of custom objects. The function requires the MilestonePSTools PowerShell module, which will be installed automatically if it is not already present.
    
    .PARAMETER Server
    Specifies the IP address or hostname of the Milestone Recording Server. This parameter is mandatory.
    
    .PARAMETER CsvFilePath
    Specifies the path and filename of the CSV file to which the results will be saved. This parameter is mandatory.
    
    .EXAMPLE
    Get-MilestoneHardwareInfo -Server "10.80.1.50" -CsvFilePath "C:\report.csv"
    Retrieves hardware information from the Milestone Recording Server with IP address 10.80.1.50 and saves the results to the file C:\report.csv.
    
    .EXAMPLE
    Get-MilestoneHardwareInfo
    Prompts the user to enter the IP address or hostname of the Milestone Recording Server and the path and filename of the CSV file to which the results will be saved.
    
    .NOTES
    The function requires the MilestonePSTools PowerShell module, which will be installed automatically if it is not already present. The module requires PowerShell version 5.1 or later.
    
    Author: MrZepar
    Version: 1.0
    Date: May 1, 2023
    #>
    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Server,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$CsvFilePath
    )
    
    # Install the MilestonePSTools module if it is not already installed
    if (!(Get-Module -ListAvailable -Name MilestonePSTools))
    {
        Install-Module MilestonePSTools -Force
    }
    
    # Import the MilestonePSTools module and connect to the Milestone Recording Server
    Import-Module MilestonePSTools
    Connect-ManagementServer -Server $Server -AcceptEula
    
    # Initialize the array that will contain the hardware information
    $hardwareInfo = @()
    
    # Iterate over all Recording Servers and their associated hardware
    foreach ($rec in Get-RecordingServer)
    {
        # Retrieve the version of Windows running on the Recording Server
        $winVersion = (Get-WmiObject win32_operatingsystem -ComputerName $rec.HostName | Select-Object -ExpandProperty Caption)
        
        # Retrieve the date and time of the last boot of the Recording Server
        $winLastBootTime = (Get-WmiObject win32_operatingsystem -Computer $rec.HostName | select @{LABEL="LastBootUpTime";EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}|Select-Object -ExpandProperty lastbootuptime)   
        
        # Retrieve the IP address of the Recording Server
        $recIP = ((Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $rec.HostName | where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } | select IPAddress -First 1).IPAddress[0])
        
 	#Ottieni processore dal Recording Server
	$RecCPU = Get-WmiObject Win32_Processor -ComputerName $rec.HostName | Select-Object -ExpandProperty Name -First 1
	
	#Ottieni RAM totale del Recording Server 
	$RecRam = Get-WmiObject Win32_ComputerSystem -ComputerName $rec.HostName | Select-Object -ExpandProperty TotalPhysicalMemory
	$ramGB = [math]::Round($RecRam/1GB, 2)
	
	#$memoryInUse = (Get-Process | Measure-Object WorkingSet -Sum).Sum
	#$memoryInUseGB = [math]::Round($memoryInUse/1GB, 2)
	
		
	# Salva il nome del Recording Server e il suo hostname
	$HostName = $rec.HostName
	$RecName = $rec.Name
	
	#Dischi
	# Crea un array vuoto per contenere le informazioni sui dischi rigidi del Recording Server
$disks = @()

# Itera su tutti i dischi locali del Recording Server
Get-WmiObject Win32_LogicalDisk -ComputerName $rec.HostName | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
    $disk = $_.DeviceID
    $size = [math]::Round($_.Size/1GB, 2)
    $freeSpace = [math]::Round($_.FreeSpace/1GB, 2)

    # Aggiungi un nuovo oggetto personalizzato all'array per ogni disco trovato
    $disks += [PSCustomObject]@{
        Disk = $disk
        Size = $size
        FreeSpace = $freeSpace
    }
}

	# Unisci il nome dei dischi rigidi e le relative dimensioni totali in una sola stringa
	$disksInfo = ($disks | Select-Object -ExpandProperty Disk) -join ', '
	$sizeInfo = ($disks | Select-Object -ExpandProperty Size) -join ', '
	$diskInfo = "$disksInfo ($sizeInfo GB)"
	
	# Unisci i nomi dei dischi rigidi e il relativo spazio libero in una sola stringa
	$disksInfo2 = ($disks | Select-Object -ExpandProperty Disk) -join ', '
	$freeSpaceInfo = ($disks | Select-Object -ExpandProperty FreeSpace) -join ', '
	$diskInfo2 = "$disksInfo ($freeSpaceInfo GB free)"	


	
	# Conta tutti i dispositivi del Recording Server, inclusi quelli disabilitati
	$numHardware = ($rec | Get-Hardware | Where-Object {$_.Enabled}).count
	
	#Conta tutti i device anche quelli disabilitati
	$numHardwareAll = ($rec | Get-Hardware).count
    $devices = $rec | Get-Hardware
	
	
	# Aggiunge una riga vuota per il Recording Server se non ci sono dispositivi associati
    if ($devices.Count -eq 0) {
		
		# Aggiunge una riga vuota per il Recording Server se non ci sono dispositivi associati
        $hardwareInfo += [PSCustomObject]@{
			IP = $RecIP
            HostName = $HostName
			RSName = $RecName
			CPU = $RecCPU
			RAM = $ramGB 
			Dischi = $diskInfo2
			SpazioTotale = $diskInfo
			#Memoria = $memoryInUseGB
            WindowsVersion = $winVersion
			LastBoot = $winLasTimetBoot
            DeviceName = ''
            Enabled = ''
            Address = ''
            UserName = ''
            Password = ''
            MacAddress = ''
            DriverName = ''
            Firmware = ''
            HardwareId = ''
			HardwareCountEnabled = $numHardware

        }
    }
    else {
        # Aggiunge una riga per il Recording Server con i suoi campi
        $hardwareInfo += [PSCustomObject]@{
			IP= $RecIP
            HostName = $HostName
			RSName = $RecName
			CPU = $RecCPU
			RAM = $ramGB
			Dischi = $diskInfo2
			SpazioTotale = $diskInfo
			#Memoria = $memoryInUseGB
            WindowsVersion = $winVersion
			LastBoot = $winLasTimetBoot
            DeviceName = ''
            Enabled = ''
            Address = ''
            UserName = ''
            Password = ''
            MacAddress = ''
            DriverName = ''
            Firmware = ''
            HardwareId = ''
			HardwareCountEnabled = $numHardware
        }

        # add rows with device fields
        foreach ($hardware in $devices)
        {
            $driver = $hardware | Get-VmsHardwareDriver

            $hardwareInfo += [PSCustomObject]@{
                RecordingServerName = ''
                WindowsVersion = ''
                DeviceName = $hardware.Name
                Enabled = $hardware.Enabled
                Address = $hardware.Address
                UserName = $hardware.UserName
                Password = ($hardware | Get-HardwarePassword)
                MacAddress = ($hardware | Get-HardwareSetting -Name MacAddress).MacAddress
                DriverName = $driver.Name
                Firmware = ($hardware | Get-HardwareSetting -Name FirmwareVersion).FirmwareVersion
                HardwareId = $hardware.Id
            }
        }
    }
}

$hardwareInfo | Export-Csv -Path $csvFilePath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Disconnect-ManagementServer

}

#Ottieni data ultima accensione del pc remoto 
#example --> LastBoot ipserver
Set-Alias -Name LastBoot -Value Get-RemoteLastBootUpTime
function Get-RemoteLastBootUpTime {
    param(
        [Parameter(Mandatory=$false)]
        [string]$ComputerName = $env:COMPUTERNAME
    )

    # Controllo che il nome host sia valido e raggiungibile
    if (-not (Test-Connection -ComputerName $ComputerName -Quiet -Count 1)) {
        Write-Error "Impossibile connettersi a $ComputerName. Verificare che il nome host sia corretto e la macchina sia raggiungibile in rete."
        return
    }

    # Controllo che il servizio WMI sia attivo sulla macchina remota
    $service = Get-Service -Name winmgmt -ComputerName $ComputerName -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-Error "Il servizio WMI non è attivo su $ComputerName. Verificare che il servizio sia attivo e in esecuzione."
        return
    }

    # Eseguo la query WMI per ottenere l'ultimo boot time
    $bootTime = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName -Credential $credential | Select-Object -ExpandProperty LastBootUpTime

    # Verifico che la data di boot sia valida
    if (-not $bootTime) {
        Write-Error "Impossibile ottenere l'ultimo boot time da $ComputerName. Verificare che la macchina sia accesa e il servizio WMI sia in esecuzione."
        return
    }

    # Restituisco la data di boot formattata
    return [Management.ManagementDateTimeConverter]::ToDateTime($bootTime)
}


#Ottieni versione window di un pc remoto 
#example --> LastBoot ipserver
Set-Alias -Name ver -Value Get-WindowsVersion
function Get-WindowsVersion {
	
    param (
        [string]$ComputerName = $env:COMPUTERNAME
    )
    
    try {
        $os = Get-WmiObject win32_operatingsystem -ComputerName $ComputerName | Select-Object Caption
        return $os
    }
    catch {
        Write-Error "Failed to get last boot up time for computer '$ComputerName'. $($Error[0].ToString())"
        return $null
    }
}

#Ottieni info CPU di un pc remoto 
#example --> LastBoot ipserver
Set-Alias -Name cpu -Value Get-CpuInfo
function Get-CpuInfo {
	
    param (
        [string]$ComputerName = $env:COMPUTERNAME
    )
    
    try {
        $cpu = Get-WmiObject Win32_Processor -ComputerName $ComputerName | Select-Object -ExpandProperty Name -First 1
        return $cpu
    }
    catch {
        Write-Error "Failed to get last boot up time for computer '$ComputerName'. $($Error[0].ToString())"
        return $null
    }
}

#Aggiungi esclusioni all'antivirus per i processi,programmi e file di Milestone
#example -->  notvirus
Set-Alias -Name notvirus -Value Add-MilestoneExclusionsToDefender
Function Add-MilestoneExclusionsToDefender {
   
    # Aggiungi le cartelle di Milestone XProtect alle esclusioni di Windows Defender
    Add-MpPreference -ExclusionPath "C:\Program Files\Milestone\*"
    Add-MpPreference -ExclusionPath "C:\Program Files (x86)\Milestone\*"
    Add-MpPreference -ExclusionPath "C:\ProgramData\Milestone\*"

    #Escludiamo le estensioni 
    $Extensions = ".blk",".idx",".sts",".pic",".ts"
    foreach ($Extension in $Extensions) {
        Add-MpPreference -ExclusionExtension $Extension
    }
    #Aggiungiamo alle esclusioni anche il disco dove vengono registrate le immagini (il disco D può variare)
    Add-MpPreference -ExclusionPath "D:\*" 

    # Aggiungi i processi di Milestone XProtect alle esclusioni di Windows Defender
    Add-MpPreference -ExclusionProcess "C:\Program Files\Milestone\*"
    Add-MpPreference -ExclusionProcess "C:\Program Files (x86)\Milestone\*"
    Add-MpPreference -ExclusionProcess "VideoOS.*"
}

#Apre una nuova finestra powershell con permessi ADMIN
Set-Alias -Name admin -Value RunAsAdmin
function RunAsAdmin {
    Start-Process powershell.exe -Verb RunAs
}

Set-Alias -Name remote -Value Set-ExecutionPolicyRemoteSigned
function Set-ExecutionPolicyRemoteSigned {
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -verbose
}


Set-Alias -Name restricted -Value Set-ExecutionPolicyRestricted
function Set-ExecutionPolicyRestricted {
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force -verbose
}
