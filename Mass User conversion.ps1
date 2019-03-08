#Mass user conversion script

<#
    Purpoose: Query Active Directory for multiple users, grab all their properties, and throw them into a CSV to export
#>


#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to others easier
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]
$Userinfo = @()
$usernames = Get-Content "C:\Users\$UID\Desktop\USERS.txt"
$ExportFile = "C:\Users\$UID\Desktop\EXPORT.csv"

Write-Host "Fetching $($usernames.count) usernames from Active Directory..."

#In this loop we're grabbing every user and all their properties
foreach ($username in $usernames)
{
    Write-Host "Grabbing information for $username..."
    $Userinfo += Get-ADUser $username -Properties *
} 

#Export to CSV and open the file
$Userinfo | Export-Csv $ExportFile -NoTypeInformation
Invoke-Item $ExportFile