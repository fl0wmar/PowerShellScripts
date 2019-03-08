Clear-Host
Write-Host " "

<#
    Purpose: This has been created so that we can query Active Directory via PowerShell for multiple display names and then do whatever after
#>

#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to others easier
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]
$usernames = Import-Csv "C:\Users\$UID\Desktop\EXAMPLE.csv" | Select-Object -ExpandProperty "Username"
$FinalResults = "C:\Users\$UID\Desktop\usernames.csv"
$results = @()
$columns = @()
$tempObject = @()
$columns += "Name"
$columns += "UID"
$columns += "Email"


#Write to the screen how many items we're about to query Active Directory for; this is more a sanity check to make sure that the script see's the same amount of data that you see
Write-Host "Querying Active Directory for $($usernames.count) display names.."
Write-Host " "

#OPERATION
ForEach ($user in $usernames.Split("`n").Trim())
{  
    
    $tempObject = New-Object psobject -Property @{Name=$user}
    #$usernamesearch = "*$user*"
    
    try 
    {
        #$discovered = Get-ADUser -Filter { displayName -like $usernamesearch }
        #$UID = $discovered.SamAccountName
        $UserEmail = Get-ADUser $user | Select-Object UserPrincipalName
        Write-Host "Found $user!"
        $tempObject | Add-Member "UID"  "$user"
        $tempObject | Add-Member "Email" "$($UserEmail.userprincipalname)"    
    }
    catch 
    {
        Write-Host "ERROR: Could not find $user"
        $tempObject | Add-Member "UID"  "UNKNOWN"
        $tempObject | Add-Member "Email" "UNKNOWN"    
    }
     
    $results += $tempObject
}

Write-Host " "
Write-Host "Finished fetching $($usernames.count) display names!"


#This will export the results as a CSV
$results | Select-Object $columns | Export-Csv $FinalResults -NoTypeInformation
Invoke-Item  $FinalResults