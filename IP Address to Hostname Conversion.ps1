#Mass IP Address to hostname conversion

<#
    Purpose: Nobody should ever have to do an NSLOOKUP on more than one thing, but in the event that you do, this is supposed to help with that
#>


#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to other
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]

#This is the variable that stores the list of IP Addresses; give it whatever file you want
$listofIPs = Get-Content "C:\Users\$UID\Desktop\EXAMPLE.txt"

#This is where the results are stored; choose whatever location you would like
$NewResults = "C:\Users\$UID\Desktop\EXAMPLE.csv"

#This is the necessary cast declaring a variable as an ARRAY; DO NOT CHANGE
$ResultList = @()




foreach ($ip in $listofIPs)
{
     $result = $null
     $currentEAP = $ErrorActionPreference
     $ErrorActionPreference = "silentlycontinue"
     $result = [System.Net.Dns]::gethostentry($ip)
     $ErrorActionPreference = $currentEAP
     If ($Result)
     {
          $Resultlist += [string]$Result.HostName
     }
     Else
     {
          $Resultlist += "$IP - ERROR"
     }
}

$ResultList | Export-Csv $NewResults -NoTypeInformation
Invoke-Item $NewResults