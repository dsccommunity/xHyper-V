configuration Sample_xVhd_FixedVhd
{
    param
    (
        [string[]]$NodeName = 'localhost',
        
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [string]$Path,
        
        [ValidateSet("Vhd","Vhdx")]
        [string]$Generation = "Vhd",

        [ValidateSet("Dynamic","Fixed","Differencing")]
        [string]$Type = "Fixed",

        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present"    
    )

    Import-DscResource -module xHyper-V

    Node $NodeName
    {
        # Install HyperV feature, if not installed - Server SKU only
        WindowsFeature HyperV
        {
            Ensure = 'Present'
            Name   = 'Hyper-V'
        }
        
        xVhd DiffVhd
        {
            Ensure     = $Ensure
            Name       = $Name
            Path       = $Path
            Generation = $Generation
            Type       = $Type
            DependsOn  = '[WindowsFeature]HyperV'
        }
    }
}
