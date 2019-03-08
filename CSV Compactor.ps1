#CSV Combiner
<#
    Purpose: This script takes multiple files (CSV's in this case), and as long as they all have the same column-headers, it will combine them into one file. I initially wrote this to help with some metrics until PowerBI came along, and then I stopped using this.
#>

#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to other
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]

#Decide where you want your file to output
$Output = "C:\Users\$UID\EXAMPLE.csv"

#Choose the folder you want the script to read that has multiple CSV's 
$Metrics = "C:\Users\$UID\Documents\EXAMPLE\*"
$StepOne= @()

#I honestly don't think I even needed to declare this as a variable, but whatever
$StepTwo = @()


#In this loop, for each file that get-childitem see's in a folder, import them into one array so we can manipulate it later
foreach ($File in (Get-ChildItem $Metrics))
{
    Write-Host "Importing $File"
    $StepOne+=Import-Csv $File
}


#You don't need to necessarily keep this variable here, but I used to use it at one point
#I left in the commented part just to give an example of how 
$FirstPass = $StepOne #| Where-Object {($_.'Name' -notlike "*CRITERIA*")}

#Here I was saying that if a property in the CSV was empty, I DON'T WANT IT 
$StepTwo = $FirstPass | Where-Object {($_.'PROPERTY' -ne "")}

$StepThree | Export-Csv $Output -NoTypeInformation