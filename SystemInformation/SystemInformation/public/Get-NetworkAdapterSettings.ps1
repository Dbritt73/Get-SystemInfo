function Get-NetworkAdapterSettings {
  <#
    .SYNOPSIS
    Describe purpose of "Get-NetworkAdapterSettings" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER computerName
    Describe parameter -computerName.

    .EXAMPLE
    Get-NetworkAdapterSettings -computerName Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-NetworkAdapterSettings

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param(

        [String[]]$ComputerName
        
    )

    Foreach ($Computer in $computerName) {

        Try {

            $NetWMI = @{

                'Class' = 'Win32_NetworkAdapter'

                'ComputerName' = $computer

                'ErrorAction' = 'Stop'
    
            }
    
            $NICs = Get-WmiObject @NetWMI
    
            Foreach ($NIC in $NICs){
    
                $Gwmi = @{
    
                    'Class' = 'Win32_NetworkAdapterConfiguration'
    
                    'ComputerName' = $Computer
    
                    'ErrorAction' = 'Stop'
    
                }
    
                $NetAdapt = Get-WmiObject @Gwmi | Where-Object {$_.Description -eq $Nic.Name}
    
                $Properties = @{
    
                    'Description' = $NetAdapt.Description
    
                    'ConnectionName' = $NIC.NetConnectionID
    
                    'DHCPEnabled' = $NetAdapt.DHCPEnabled
    
                    'DHCPServer' = $NetAdapt.DHCPServer
    
                    'IPAddress' = $NetAdapt.IPAddress
    
                }
    
                $Object = New-Object -TypeName PSObject -Property $Properties
                $object.PSObject.TypeNames.Insert(0,'SysInfo.NIC')
                Write-Output -InputObject $object
    
            }

        } Catch {
        
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