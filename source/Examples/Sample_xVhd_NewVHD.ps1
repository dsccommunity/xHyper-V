configuration Sample_xVHD_NewVhd
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost',

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.UInt64]
        $MaximumSizeBytes,

        [Parameter()]
        [ValidateSet('Vhd', 'Vhdx')]
        [System.String]$Generation = 'Vhd',

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Import-DscResource -ModuleName 'xHyper-V'

    Node $NodeName
    {
        # Install HyperV feature, if not installed - Server SKU only
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

        xVhd NewVhd
        {
            Ensure           = $Ensure
            Name             = $Name
            Path             = $Path
            Generation       = $Generation
            MaximumSizeBytes = $MaximumSizeBytes
            DependsOn        = '[WindowsFeature]HyperV', '[WindowsFeature]HyperVPowerShell'
        }
    }
}
