#Emails from PowerShell

#PURPOSE: I REALLY didn't want to send out emails for a few things, so I wrote a script to do so reguarly for me
Clear-Host

$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]


#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to other
$MyEmail = "EXAMPLE@EXAMPLE.com"

#Specify your SMTP information here
$SMTP = "smtp.EXAMPLE.com"
$BCC = Get-Content "C:\Users\$UID\Desktop\BCC Email List.txt"
$To = "EXAMPLE@EXAMPLE.com"
$Subject = "PowerShell Test: HTML Test"

<#
    For the body variable of the email, you can use the variable below for something similar OR do something else like the following:

        $Body = @"
    YADA YADA THIS IS A BODY
    "@
#>
$Body = Get-Content "C:\Users\$UID\Desktop\EmailBody.txt" -Raw
$Creds = ( Get-Credential -Credential "$MyEmail")


#Command
Send-MailMessage -To $To -From $MyEmail -Subject $Subject -Body $Body -SmtpServer $SMTP -Credential $Creds -DeliveryNotificationOption OnSuccess