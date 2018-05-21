function Get-NIC {
    [CmdletBinding()]
    Param(
        [String[]]$computerName
    )

    Foreach ($Computer in $computerName){

        $NICs = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $Computer 

        Foreach ($NIC in $NICs){

            $Gwmi = @{

                'Class' = 'Win32_NetworkAdapterConfiguration';
                'ComputerName' = $Computer;
                'ErrorAction' = 'Stop'

            }

            $NetAdapt = Get-WmiObject @Gwmi | Where-Object {$_.Description -eq $Nic.Name}

            $Properties = @{

                'Description' = $NetAdapt.Description;
                'ConnectionName' = $NIC.NetConnectionID;
                'DHCPEnabled' = $NetAdapt.DHCPEnabled;
                'DHCPServer' = $NetAdapt.DHCPServer;
                'IPAddress' = $NetAdapt.IPAddress

            }

            $Object = New-Object -TypeName PSObject -Property $Properties
            $object.PSObject.TypeNames.Insert(0,'SysInfo.NIC')
            Write-Output $object

        }

    }

}
#-----------------------------------------------------------------------------------------
function Get-SystemInfo {
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

        [Parameter(Mandatory=$True,
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

                $Network = Get-NIC @NIC | Where-Object {$_.IPAddress -ne $Null}

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

                $gwmi = @{

                    'Class' = 'Win32_PhysicalMemory';
                    'ComputerName' = $computer;
                    'ErrorAction' = 'Stop'

                }

                $PhysicalMemory = Get-WmiObject @gwmi

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
                Write-Output $Object

            } Catch{}

        }

    }

    End {}

}