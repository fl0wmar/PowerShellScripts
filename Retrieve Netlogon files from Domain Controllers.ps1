#Retrieve Netlogon files from Domain Controllers

<#
    Purpose: Pretty self-explanatory (or so I'd like to think), but this script will query Active Directory for a list of all domain controllers in your CURRENT domain, and will then cycle through them all grabbing the log and backup files, along with renaming them to the name of where the log or backup file came from.
#>



#This variable will house all domain controllers
$DomainControllers = Get-ADDomainController -Filter * | Select-Object -ExpandProperty name 

#These two variables are the source and destination variables for the Netlogon LOGS
$SourceLog = $("\\$DC\C`$\Windows\debug\netlogon.log")
$DestinationLog = $("C:\EXAMPLE\Netlogon Logs\$DC-netlogon.log")

#These two variables are the source and destination variables for the Netlogon BACKUPS
$SourceBAK = $("\\$DC\C`$\Windows\debug\netlogon.bak")
$DestinationBAK = $("C:\EXAMPLE\Netlogon Logs\$DC-netlogon.bak")

#In this loop, we're saying "For every domain controller, retrieve their netlogon log and backup"
foreach ($DC in $DomainControllers)
{
    if (Test-Path $SourceLog) 
        {
            Write-Host "Netlogon file on $DC has been identified"
            Write-Host " "
            Try
                {
                    Write-host "Fetching the Netlogon file for $DC..."
                    Copy-Item  $SourceLog $DestinationLog
                    Write-Host "SUCCESS!"
                    Write-Host " "

                    Write-Host "Fetching the backup file for $DC..."
                    Copy-Item  $SourceBAK $DestinationBAK
                    Write-Host "SUCCESS!"
                    Write-Host " "
                    Write-Host " "
                }
            Catch
                {
                    Write-Host "Error retrieving file"
                }
        }
    else 
        {
            Write-Host "ERROR"
        }
}