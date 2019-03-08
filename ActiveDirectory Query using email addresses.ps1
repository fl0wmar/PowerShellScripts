#Name: Mass User conversion
<#
    Purpose: I had a use-case scenario for this script where I was given a bunch of email addresses and was asked to get information on the people associated with them in active directory. So what did I was create a script that takes in a text file, queries active directory for those email addresses to get back user information, and then exports it out into a CSV!
#>


#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to others easier
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]

#Telling PowerShell we want this variable to be declared an array
$Userinfo = @()

#Feed whatever txt file here that you want 
$usernames = Get-Content "C:\Users\$UID\Desktop\EXAMPLE.txt"

#Decide what you want to name your export file here
$ExportFile = "C:\Users\$UID\Desktop\ActiveVsNonActive.csv"

Write-Host "Fetching $($usernames.count) usernames from Active Directory..."

#In this loop we're grabbing every user and all their properties
foreach ($username in $usernames)
{
    Write-Host "Grabbing information for $username..."
    $Userinfo += Get-ADUser -Filter { mail -like $username } -Properties *  
} 

#Export to CSV and open the file
$Userinfo | Export-Csv $ExportFile -NoTypeInformation
Invoke-Item $ExportFile