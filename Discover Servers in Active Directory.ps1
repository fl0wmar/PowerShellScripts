Clear-Host
<#
    Discover Windows servers in an environment using PowerShell and Active Directory, and export them to a CSV
#>



#VARIABLES
#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to other
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]
$ExportFile = "C:\Users\$UID\Desktop\ActiveAndNonActiveWindowsServers.csv"

<#
    So for this MACHINES variable, you got a couple of options

    If you already have a list of servers, then just throw em into a text document and feed it into the script.

    OR - use something like this to retrieve all servers stored in active directory instead
    ### $ADQuery = Get-ADComputer -Filter {(OperatingSystem -like "*server*")} | Select-Object Name
    ### $Names = $ADQuery.Name
    ### $Names
#>
$machines = Get-Content C:\Users\$UID\Desktop\EXAMPLE.txt
$report = @() 
$results = @()

#Get IP Address function
function Get-HostToIP($machine) {
    Try {
        $result = [system.Net.Dns]::GetHostByName($machine)
        $result.AddressList | ForEach-Object {$_.IPAddressToString } 
    } catch {
        "OFFLINE"
    }
    
}

    #Operation
foreach($machine in $machines) 
{ 
    $tempobject = New-Object psobject -property @{
        Machine = $machine
        "IP Address" = $(Get-HostToIP($machine))
    }
    if ( (Test-Connection $machine -quiet -count 2) -eq $false)
    {
        Write-host "WARNING: $machine is offline!"
        $tempobject."IP Address" = "OFFLINE"
        $results += $tempObject  
        Continue
    }
    Write-host "$machine is online"    
    [array]$report += $tempobject
} 

#Storing results in report and exporting
$report += $results
$report | Select-Object Machine, "IP Address" | Export-csv  -NoTypeInformation
Invoke-Item $ExportFile