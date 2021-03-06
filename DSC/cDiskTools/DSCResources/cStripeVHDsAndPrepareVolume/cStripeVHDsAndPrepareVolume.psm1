function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.UInt64]
		$DriveSize,

		[parameter(Mandatory = $true)]
		[System.UInt32]
		$NumberOfColumns
	)

    Try 
    {
        if (Test-Path $DriveLetter) 
        {
            Write-Debug 'F:/ exists on target.'
            @{
                DriveLetter = 'F'
                Mounted   = $true
            }
        }
        else {
             Write-Debug "F:/ can't be found."
             @{
                DriveLetter = 'F'
                Mounted   = $false
             }
        }
    }
    Catch 
    {
        throw "An error occured getting the F:/ drive informations. Error: $($_.Exception.Message)"
    }
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.UInt64]
		$DriveSize,

		[parameter(Mandatory = $true)]
		[System.UInt32]
		$NumberOfColumns
	)
    
    Write-Verbose 'Creating Storage Pool'
 
    New-StoragePool -FriendlyName 'LUN-0' `
                    -StorageSubSystemUniqueId (Get-StorageSubSystem -FriendlyName '*Space*').uniqueID `
                    -PhysicalDisks (Get-PhysicalDisk -CanPool $true)

    Write-Verbose 'Creating Virtual Disk'
 
    New-VirtualDisk -FriendlyName 'Datastore01' `
                    -StoragePoolFriendlyName 'LUN-0' `
                    -Size $DriveSize `
                    -NumberOfColumns $NumberOfColumns `
                    -ProvisioningType Thin `
                    -ResiliencySettingName Simple
 
    Start-Sleep -Seconds 90
 
    Write-Verbose 'Initializing Disk'
 
    Initialize-Disk -VirtualDisk (Get-VirtualDisk -FriendlyName 'Datastore01')
  
    Start-Sleep -Seconds 90
 
    $diskNumber = ((Get-VirtualDisk -FriendlyName 'Datastore01' | Get-Disk).Number)
    Write-Verbose $diskNumber
    Write-Verbose 'Creating Partition'
 
    New-Partition -DiskNumber $diskNumber `
              -UseMaximumSize `
              -AssignDriveLetter    
     
    Start-Sleep -Seconds 90
 
    Write-Verbose 'Formatting Volume and Assigning Drive Letter'
     
    Format-Volume -DriveLetter F `
              -FileSystem NTFS `
              -NewFileSystemLabel 'Data' `
              -Confirm:$false `
              -Force
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.UInt64]
		$DriveSize,

		[parameter(Mandatory = $true)]
		[System.UInt32]
		$NumberOfColumns
	)
    
    $result = [System.Boolean]
    Try 
    {
        if (Test-Path F) 
        {
            Write-Verbose 'F:/ exists on target.'
            $result = $true
        }
        else 
        {
            Write-Verbose "F:/ can't be found."
            $result = $false
        }
    }
    Catch 
    {
        throw "An error occured getting the F:/ drive informations. Error: $($_.Exception.Message)"
    }
    $result
}


Export-ModuleMember -Function *-TargetResource

