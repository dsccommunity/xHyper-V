configuration Sample_xVMHyperV_Complete
{
    param
    (
        [string[]]$NodeName = 'localhost',

        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [uint64]$VhdSizeBytes,

        [Parameter(Mandatory = $true)]
        [Uint64]$StartupMemory,

        [Parameter(Mandatory = $true)]
        [Uint64]$MinimumMemory,

        [Parameter(Mandatory = $true)]
        [Uint64]$MaximumMemory,

        [Parameter(Mandatory = $true)]
        [String]$SwitchName,

        [Parameter(Mandatory = $true)]
        [String]$Path,

        [Parameter(Mandatory = $true)]
        [Uint32]$ProcessorCount,

        [ValidateSet('Off','Paused','Running')]
        [String]$State = 'Off',

        [Switch]$WaitForIP,

        [bool]$AutomaticCheckpointsEnabled
    )

    Import-DscResource -ModuleName 'xHyper-V'

    Node $NodeName
    {
        # Logic to handle both Client and Server OS
        # Configuration needs to be compiled on target server
        $Operatingsystem = Get-CimInstance -ClassName Win32_OperatingSystem
        if ($Operatingsystem.ProductType -eq 1)
        {
            # Client OS, install Hyper-V as OptionalFeature
            $HyperVDependency = '[WindowsOptionalFeature]HyperV'
            WindowsOptionalFeature HyperV
            {
                Ensure = 'Enable'
                Name = 'Microsoft-Hyper-V-All'
            }
        }
        else {
            # Server OS, install HyperV as WindowsFeature
            $HyperVDependency = '[WindowsFeature]HyperV','[WindowsFeature]HyperVPowerShell'
        WindowsFeature HyperV
        {
            Ensure = 'Present'
            Name   = 'Hyper-V'
        }
            WindowsFeature HyperVPowerShell
            {
                Ensure = 'Present'
                Name   = 'Hyper-V-PowerShell'
            }
        }

        # Create new VHD
        xVhd NewVhd
        {
            Ensure           = 'Present'
            Name             = "$VMName-OSDisk.vhdx"
            Path             = $Path
            Generation       = 'vhdx'
            MaximumSizeBytes = $VhdSizeBytes
            DependsOn        = $HyperVDependency
        }

        # Ensures a VM with all the properties
        xVMHyperV NewVM
        {
            Ensure          = 'Present'
            Name            = $VMName
            VhdPath         = (Join-Path -Path $Path -ChildPath "$VMName-OSDisk.vhdx")
            SwitchName      = $SwitchName
            State           = $State
            Path            = $Path
            Generation      = 2
            StartupMemory   = $StartupMemory
            MinimumMemory   = $MinimumMemory
            MaximumMemory   = $MaximumMemory
            ProcessorCount  = $ProcessorCount
            MACAddress      = $MACAddress
            RestartIfNeeded = $true
            WaitForIP       = $WaitForIP
            AutomaticCheckpointsEnabled = $AutomaticCheckpointsEnabled
            DependsOn       = '[xVhd]NewVhd'
        }
    }
}
