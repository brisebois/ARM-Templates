configuration DataDisk {
    param (
        [UInt64]$DriveSize = 32TB,
        [UInt32]$NumberOfColumns = 32
             
    )

    Import-DscResource -module cDiskTools
    node localhost
    {   
        cDiskTools StripeVHDsAndPrepareVolume 
        {
            DriveSize = $DriveSize
            NumberOfColumns = $NumberOfColumns
        }
    }
}
DataDisk