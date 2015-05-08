New-xDscResource –Name cStripeVHDsAndPrepareVolume `
                 -Property (New-xDscResourceProperty –Name DriveSize `
                                                     –Type UInt64 `
                                                     -Attribute Key), `
                           (New-xDscResourceProperty –Name NumberOfColumns `
                                                     -Type Uint32 `
                                                     -Attribute Required) `
                 -Path 'C:\Program Files\WindowsPowerShell\Modules\' `
                 -ModuleName cDiskTools `
                 -FriendlyName cDiskTools `
                 -Verbose