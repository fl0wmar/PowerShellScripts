#BOBCAT

#Purpose: This script checks the last reboot of machines in a TXT file placed on your desktop and then creates a .CSV file with a column of machine names, last reboot time, and their IP Addresses. This was helpful when working with a product vendor and troubleshooting machines that weren't conducting __________ activity.



#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to others easier
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]
#$machines = Get-Content "C:\Users\$UID\Desktop\Example.txt"
#$machines = Import-Csv "C:\Users\$UID\Desktop\Example.csv" | Select-Object -ExpandProperty "System Name"
$Machines = Get-Content "C:\Users\$UID\Desktop\Hosts.txt"
$report = @() 
$results = @()
$ExportFile = "C:\$UID\Desktop\EXAMPLE.csv"
#Get IP Address function
    function Get-HostToIP($machine) {
        Try {
            $result = [system.Net.Dns]::GetHostByName($machine)
            $result.AddressList | ForEach-Object {$_.IPAddressToString } 
        } catch {
            "OFFLINE"
        }
    }


foreach($machine in $machines) 
{ 
    $tempobject = New-Object psobject -property @{
        Machine = $machine
        "Last Reboot" = $null 
        "IP Address" = $(Get-HostToIP($machine))
    }
    if ( (Test-Connection $machine -quiet -count 1) -eq $false)
    {
        Write-host "WARNING: $machine is offline!"
        $tempobject."IP Address" = "OFFLINE"
        $tempobject."Last Reboot" = "OFFLINE"
        $results += $tempObject  
        Continue
    }
    Write-host "$machine is online"
    
    [array]$report += $tempobject

    Try {
        $tempobject."Last Reboot" = Get-WmiObject win32_operatingsystem -ComputerName $machine -ErrorAction Stop| Select-Object  @{LABEL='Last Reboot';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} | Select-Object -ExpandProperty "Last Reboot" 
    } catch {
        $tempobject."Last Reboot" = "UNKNOWN"
    }

} 

 
$report += $results

$report | Export-Csv $ExportFile -NoTypeInformation