function Get-SystemInformation {
<#
.Synopsis
   Retrieves information details on local or remote hosts.
.DESCRIPTION
   Get-SystemInfo utilizes Windows Management Instrumentation (WMI) to retrieve PC info
   from multiple WMI Classes and combines them into a single output object.
.EXAMPLE
   Get-SystemInfo -ComputerName localhost
.EXAMPLE
   'SERVER1','SERVER2','SERVER3' | Get-SystemInfo
.Notes
    Written as an all PowerShell replacement for the CMD command 'SystemInfo'
#>
    [CmdletBinding()]
    Param
    (

        [Parameter( Mandatory=$True,
                    HelpMessage='Add help message for user',
                    ValueFromPipelineByPropertyName=$True)]
        [String]$ComputerName

    )

    Begin {}

    Process {

        foreach ($Computer in $ComputerName){

            Try {

                $gwmi = @{

                    'Class' = 'Win32_OperatingSystem';
                    'ComputerName' = $Computer;
                    'ErrorAction' = 'Stop'

                }


                $OS = Get-WmiObject @gwmi

                $gwmi = @{

                    'Class' = 'Win32_ComputerSystem';
                    'ComputerName' = $Computer;
                    'ErrorAction' = 'Stop'

                }

                $CS = Get-WmiObject @gwmi

                $Gwmi = @{

                    'Class' = 'Win32_Bios';
                    'ComputerName' = $Computer;
                    'ErrorAction' = 'Stop'

                }

                $Bios = Get-WmiObject @gwmi

                $gwmi = @{

                    'Class' = 'Win32_QuickFixEngineering';
                    'ComputerName' = $Computer;
                    'ErrorAction' = 'Stop'

                }

                $Hotfix = Get-WmiObject @gwmi

                $NIC = @{

                    'ComputerName' = $Computer;
                    'ErrorAction' = 'Stop'

                }

                $Network = Get-NetworkAdapterSettings @NIC | Where-Object {$_.IPAddress -ne $Null}

                $gwmi = @{

                    'Class' = 'Win32_Processor';
                    'ComputerName' = $Computer;
                    'ErrorAction' = 'Stop'
                    
                }

                $Processor = Get-WmiObject @gwmi

                $gwmi = @{

                    'Class' = 'Win32_PageFileUsage';
                    'ComputerName' = $computer;
                    'ErrorAction' = 'Stop'

                }

                $VirtualMemory = Get-WmiObject @gwmi

                <#
                $gwmi = @{

                    'Class' = 'Win32_PhysicalMemory';
                    'ComputerName' = $computer;
                    'ErrorAction' = 'Stop'

                }

                $PhysicalMemory = Get-WmiObject @gwmi
                #>

                $gwmi = @{

                    'Class' = 'Win32_Timezone';
                    'ComputerName' = $Computer;
                    'ErrorAction' = 'Stop'

                }

                $TimeZone = Get-WmiObject @gwmi

                $SystemLocale = Get-WinSystemLocale

                $InputLocale = Get-WinUserLanguageList

                $ObjectProperties = @{

                    'ComputerName' = $OS.PSComputerName;
                    'OSName' = $OS.Caption;
                    'OSManufacturer' = $OS.Manufacturer;
                    'OSBuildType' = $OS.BuildType;
                    'RegisteredOwner' = $OS.RegisteredUser;
                    'RegisteredOrganization' = $OS.Organization;
                    'ProductID' = $OS.SerialNumber;
                    'InstallDate' = $OS.ConvertToDateTime($OS.InstallDate);     
                    'LastBootTime' = $OS.ConvertToDateTime($OS.lastbootuptime); 
                    'Manufacturer' = $CS.Manufacturer;
                    'Model' = $CS.Model;
                    'SystemType' = $CS.SystemType;
                    'Processors' = $Processor.Name;
                    'BIOSVersion' = $BIOS.BIOSVersion;
                    'WindowsDirectory' = $OS.WindowsDirectory;
                    'SystemDirectory' = $OS.SystemDirectory;
                    'BootDevice' = $OS.BootDevice;
                    'SystemLocale' = $SystemLocale.Name;
                    'InputLocale' = $InputLocale.LanguageTag;
                    'TimeZone' = $TimeZone.Caption;
                    'TotalPhysicalMemory' = ($CS.TotalPhysicalMemory / 1MB -as [int]);
                    'AvailablePhysicalMemory' = ($OS.FreePhysicalMemory / 1GB -as [int]);
                    'MaximumVirtualMemory' = ($OS.TotalVirtualMemorySize / 1MB -as [int]);
                    'AvailableVirtualMemory' = ($OS.FreeVirtualMemory / 1MB -as [int]);
                    'UsedVirtualMemory' = (($VirtualMemory.CurrentUsage));
                    'PageFiles' = $VirtualMemory.Name;
                    'Domain' = $CS.Domain;
                    'LogonServers' = $env:LOGONSERVER;
                    'HotFixes' = $Hotfix.HotFixID;
                    'NetworkInformation' = $Network

                }

                $Object = New-Object -TypeName PSObject -Property $ObjectProperties
                $Object.PSObject.TypeNames.Insert(0,'SystemInfo.object')
                Write-Output -InputObject $Object

            } Catch{

                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve information about runtime error
                $info = [PSCustomObject]@{

                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine

                }
                
                # output information. Post-process collected info, and log info (optional)
                $info
            }

        }

    }

    End {}

}