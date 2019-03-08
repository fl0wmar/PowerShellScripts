#PowerShell script to email people in a list from a CSV

Clear-Host
<#
    Purpose: This script was written to email a lot of people that were listed in a CSV for _______ reason
#>

#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to others easier
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]
$currentuser = Get-ADUser $UID -Properties *
$MyEmail = $currentuser.mail
$Creds = ( Get-Credential -Credential "$MyEmail")
$CC = "example@example.com"

#Variables
$ListOfUsers = Import-CSV "C:\Users\$UID\Desktop\EXAMPLE.csv"
$SMTP = "smtp.EXAMPLE.com"

#Operation
foreach ($user in $ListOfUsers)
{
                    $Subject = "URGENT: Internal Communication to $($user.USERNAME) from ___________ "
                    
                    <#
                        So here in the body you'll notice $($user.TASK). The CSV I was feeding this script had a column for:
                        -User email address (USERNAME)
                        -Task they were working on (TASK)
                        -Their target completion (TargetCompletion)
                    #>
                    $Body = @"
_______________ is reaching out to you regarding ___________.

You are required to finish $($user.TASK) by $($user.TargetCompletion).


If you have any questions, please reach out to _________________


Best, 

_______________
_______________

"@
        Send-MailMessage -To $user.USERNAME -Cc $CC -From $MyEmail -Subject $Subject -Body $Body -SmtpServer $SMTP -Credential $Creds -DeliveryNotificationOption Never
}