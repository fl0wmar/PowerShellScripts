Clear-Host

#Investigation script
<#
    Purpose: This script is designed to assist analysts with investigating events from a SIEM. I still work on this from time to time, so the version that I'm uploading isn't complete. The goal is to have a few additional capabilities in the future, and that hopefully shouldn't be too far down the line
#>

#Big thanks to Jeff Hicks for this function, as I was trying to do whois calls from Windows via a few other methods and it just wasn't working
Function Get-MyWhoIs {
 
    <#
    .SYNOPSIS
    Get WhoIS data
    .DESCRIPTION
    Use this command to get public WhoIS domain information for a given IP v4 address.
    .PARAMETER Ip
    Enter an IPv4 Address. This command has aliases of: Address
    .PARAMETER Full
    Show complete whoIs information.
    .EXAMPLE
    PS C:\> Get-MyWhoIs 208.67.222.222
    OpenDNS, LLC
    .EXAMPLE
    PS C:\> Get-MyWhoIs 208.67.222.222 -full
     
     
    IP                     : 208.67.222.222
    Name                   : OPENDNS-NET-1
    RegisteredOrganization : OpenDNS, LLC
    City                   : San Francisco
    StartAddress           : 208.67.216.0
    EndAddress             : 208.67.223.255
    NetBlocks              : 208.67.216.0/21
    Updated                : 3/2/2012 8:03:18 AM
    .NOTES
    NAME        :  Get-MyWhoIs
    VERSION     :  1.0   
    LAST UPDATED:  4/3/2015
    AUTHOR      :  Jeff Hicks (@JeffHicks)
     
    Learn more about PowerShell:
    http://jdhitsolutions.com/blog/essential-powershell-resources/
     
      ****************************************************************
      * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
      * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
      * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
      * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
      ****************************************************************
    .LINK
    Invoke-RestMethod
    .INPUTS
    [string]
    .OUTPUTS
    [string] or [pscustomobject]
    #>
     
    [cmdletbinding()]
    Param (
    [parameter(Position=0,Mandatory,HelpMessage="Enter an IPv4 Address.",
    ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias("Address")]
    [ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
    [string]$IP,
     
    [Parameter(Helpmessage="Show complete WhoIs information.")]
    [switch]$Full
    )
     
    Begin {
        Write-Verbose "Starting $($MyInvocation.Mycommand)"  
        $baseURL = 'http://whois.arin.net/rest'
        #default is XML anyway
        $header = @{"Accept"="application/xml"}
     
    } #begin
     
    Process {
        $url = "$baseUrl/ip/$ip"
        $r = Invoke-Restmethod $url -Headers $header
     
        Write-verbose ($r.net | out-string)
        if ($Full) {
        $propHash=[ordered]@{
            IP = $ip
            Name = $r.net.name
            RegisteredOrganization = $r.net.orgRef.name
            City = (Invoke-RestMethod $r.net.orgRef.'#text').org.city
            StartAddress = $r.net.startAddress
            EndAddress = $r.net.endAddress
            NetBlocks = $r.net.netBlocks.netBlock | foreach {"$($_.startaddress)/$($_.cidrLength)"}
            Updated = $r.net.updateDate -as [datetime]   
            }
            [pscustomobject]$propHash
        }
        else {
            #write just the name
            $r.net.orgRef.Name
        }
          
    } #Process
     
    End {
        Write-Verbose "Ending $($MyInvocation.Mycommand)"
    } #end 
    } #end Get-WhoIs
    
    



#This variable is commented out for now, but the idea here is that in the future we could funnel text or csv files into here for additional analysis
#Or we could use the variable for exporting csv's or something 

#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to other
#$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]
    Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~MENU~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    Write-Host " "
    Write-Host "Please selection an option from the menu below:"
    Write-Host " "
    Write-Host "1. Discover additional information about a user"
    Write-Host "2. Discover additional details behind an internal IP Address"
    Write-Host "3. Discover additional details about one computer or server"
    Write-Host "4. Discover Source and Destination information relating to a QRadar Offense"
    Write-Host "5. Discover additional information behind an EXTERNAL IP Address"
    Write-Host "6. Resolve internal-machine (Ping + NSLookup bada bing)"
    Write-Host "7. Discover running processes on a remote computer"
    Write-Host "8. Discover running services on a remote computer"
    Write-Host "9. Kill a process and/or service on a remote computer"
    #Write-Host "10. "
    Write-Host " "
    $Selection = Read-Host "Please make a selection"
    Write-Host " "
    Write-Host " "


if ($selection -eq "1") 
    {
        $src_username = Read-Host "Please enter the UID"
        Write-Host " "
        $src_user = Get-ADUser $src_username -Properties *                
        Write-Host "UID:           $($src_username)"
        Write-Host "Department:    $($src_user.Department)"
        Write-Host "Description:   $($src_user.Description)"
        Write-Host "Name:          $($src_user.DisplayName)"
        Write-Host "Email:         $($src_user.Mail)"
        Write-Host "Location:      $($src_user.Office)"
        Write-Host "Title:         $($src_user.Title)"
    }
elseif ($selection -eq "2") 
    {
        $src_ip = Read-Host "Please enter Source IP Address"
        $src_host = [System.Net.Dns]::GetHostByAddress($src_ip).Hostname.split(".")[0]
        
        Write-Host " "
        Write-Host " "
        Write-Host " "
        if (Test-Connection $src_ip -Quiet)
            {
                Write-Host "SUCCESS: $src_ip is online!" -ForegroundColor Green
                $src_status = "online"
            }
        else 
            {
                Write-Host "ERROR: $src_ip is NOT online" -ForegroundColor Red
                $src_status = "offline"
            }
        Write-Host " "
        Write-Host " "
        Write-Host " "
            if ($src_status -eq "online")
                {
                    try 
                    {
                        $src_username = ($(Get-WmiObject -ComputerName $src_host -Class Win32_ComputerSystem | Select-Object UserName).username).split("\")[1]
                        $src_user = Get-ADUser $src_username -Properties *
                        $src_machine = Get-ADComputer $src_host -Properties *
                        Write-Host "Machine:       $src_host"
                        Write-Host "Status:        Online"
                        Write-host "LogonType:     Local"
                        Write-Host "UID:           $($src_username)"
                        Write-Host "Department:    $($src_user.Department)"
                        Write-Host "Description:   $($src_user.Description)"
                        Write-Host "Name:          $($src_user.DisplayName)"
                        Write-Host "Email:         $($src_user.Mail)"
                        Write-Host "Location:      $($src_user.Office)"
                        Write-Host "Title:         $($src_user.Title)"
                        Write-Host "Status:        $($src_machine.Enabled)"
                        Write-Host "Description:   $($src_machine.Description)"
                        Write-Host "Chasis:        $($src_machine.ObjectClass)"
                        Write-Host "OS:            $($src_machine.OperatingSystem)"
                    }
                    catch 
                    {
                        $src_username = Get-WmiObject -Class WIN32_PROCESS -ComputerName $src_host | Where-Object {$_.ProcessName -like 'explorer*'} | Invoke-WmiMethod -Name GetOwner 
                        $src_remoteuser = $src_username.user
                        $src_user = Get-ADUser $src_remoteuser -Properties *
                        $src_machine = Get-ADComputer $src_host -Properties *
                        Write-Host "Machine:       $src_host"
                        Write-Host "Status:        Online"
                        Write-host "LogonType:     Remote"
                        Write-Host "UID:           $src_username"
                        Write-Host "Department:    $src_user.Department"
                        Write-Host "Description:   $src_user.Description"
                        Write-Host "Name:          $src_user.DisplayName"
                        Write-Host "Email:         $src_user.Mail"
                        Write-Host "Location:      $src_user.Office"
                        Write-Host "Title:         $src_user.Title"
                        Write-Host "Status:        $src_machine.Enabled"
                        Write-Host "Description:   $src_machine.Description"
                        Write-Host "Chasis:        $src_machine.ObjectClass"
                        Write-Host "OS:            $src_machine.OperatingSystem"
                    }
                }
        else
            {
                Write-Host "Error: $src_host is currently offline. Unable to fetch additional information." -ForegroundColor Red
                Write-Host " "
            }
    }
elseif ($selection -eq "3") 
    {
        try 
        {
            $src_host = Read-Host "Please enter the machine name"
            Write-Host " "
            $src_machine = Get-ADComputer $src_host -Properties *
            Write-Host "Machine:       $src_host"
            Write-Host "Status:        $($src_machine.Enabled)"
            Write-Host "Description:   $($src_machine.Description)"
            Write-Host "Chasis:        $($src_machine.ObjectClass)"
            Write-Host "OS:            $($src_machine.OperatingSystem)"
        }
        catch 
        {
            Write-Host "Error encountered. Machine is not in Active Directory" -ForegroundColor Red
            Write-Host " "
        }
        
    }
elseif ($selection -eq "4")
    {
        $src_ip = Read-Host "Please enter Source IP Address"
        $dst_ip = Read-Host "Please enter Destination IP Address"
        $src_host = [System.Net.Dns]::GetHostByAddress($src_ip).Hostname.split(".")[0]
        $dst_host = [System.Net.Dns]::GetHostByAddress($dst_ip).Hostname.split(".")[0]
        
        
        #Retrieve Source IP Address Information

        Write-Host " "
        Write-Host " "
        Write-Host "Checking if $src_ip and/or $dst_ip is online..." -ForegroundColor Gray
        Write-Host " "
        Write-Host " "

        if (Test-Connection $src_ip -Quiet)
            {
                Write-Host "SUCCESS: $src_ip is online!" -ForegroundColor Green
                $src_status = "online"
            }
        else 
            {
                Write-Host "ERROR: $src_ip is NOT online" -ForegroundColor Red
                $src_status = "offline" 
            }
        
        if (Test-Connection $dst_ip -Quiet)
            {
                Write-Host "SUCCESS: $dst_ip is online!" -ForegroundColor Green
                $dst_status = "online"
            }
        else 
            {
                Write-Host "ERROR: $dst_ip is NOT online" -ForegroundColor Red
                $dst_status = "offline"
            }
        
            Write-Host " "
            Write-Host " "

        
        Write-Host "**************SRC INFORMATION********************" -ForegroundColor Green
        if ($src_status -eq "online")
                {
                    try 
                    {
                        $src_username = ($(Get-WmiObject -ComputerName $src_host -Class Win32_ComputerSystem | Select-Object UserName).username).split("\")[1]
                        $src_user = Get-ADUser $src_username -Properties *
                        $src_machine = Get-ADComputer $src_host -Properties *
                        Write-Host "Machine:       $src_host"
                        Write-Host "Status:        Online"
                        Write-host "LogonType:     Local"
                        Write-Host "UID:           $($src_username)"
                        Write-Host "Department:    $($src_user.Department)"
                        Write-Host "Description:   $($src_user.Description)"
                        Write-Host "Name:          $($src_user.DisplayName)"
                        Write-Host "Email:         $($src_user.Mail)"
                        Write-Host "Location:      $($src_user.Office)"
                        Write-Host "Title:         $($src_user.Title)"
                        Write-Host "Status:        $($src_machine.Enabled)"
                        Write-Host "Description:   $($src_machine.Description)"
                        Write-Host "Chasis:        $($src_machine.ObjectClass)"
                        Write-Host "OS:            $($src_machine.OperatingSystem)"
                    }
                    catch 
                    {
                        $src_username = Get-WmiObject -Class WIN32_PROCESS -ComputerName $src_host | Where-Object {$_.ProcessName -like 'explorer*'} | Invoke-WmiMethod -Name GetOwner 
                        $src_remoteuser = $src_username.user
                        $src_user = Get-ADUser $src_remoteuser -Properties *
                        $src_machine = Get-ADComputer $src_host -Properties *
                        Write-Host "Machine:       $src_host"
                        Write-Host "Status:        Online"
                        Write-host "LogonType:     Remote"
                        Write-Host "UID:           $src_username"
                        Write-Host "Department:    $src_user.Department"
                        Write-Host "Description:   $src_user.Description"
                        Write-Host "Name:          $src_user.DisplayName"
                        Write-Host "Email:         $src_user.Mail"
                        Write-Host "Location:      $src_user.Office"
                        Write-Host "Title:         $src_user.Title"
                        Write-Host "Status:        $src_machine.Enabled"
                        Write-Host "Description:   $src_machine.Description"
                        Write-Host "Chasis:        $src_machine.ObjectClass"
                        Write-Host "OS:            $src_machine.OperatingSystem"
                    }
                }
        else
            {
                Write-Host "Error: $src_host is currently offline"
            }
        Write-Host " "
        Write-Host " "
        Write-Host " "
        Write-Host " "
        Write-Host " "
        Write-Host " "
        
        
        Write-Host "**************DST INFORMATION********************" -ForegroundColor Green
        #Retrieve Destination IP Address Information        
        if ($dst_status -eq "online")
                {
                    try 
                    {
                        $dst_username = ($(Get-WmiObject -ComputerName $dst_host -Class Win32_ComputerSystem | Select-Object UserName).username).split("\")[1]
                        $dst_user = Get-ADUser $dst_username -Properties *
                        $dst_machine = Get-ADComputer $dst_host -Properties *
                        Write-Host "Machine:       $dst_host"
                        Write-Host "Status:        Online"
                        Write-host "LogonType:     Local"
                        Write-Host "UID:           $($dst_username)"
                        Write-Host "Department:    $($dst_user.Department)"
                        Write-Host "Description:   $($dst_user.Description)"
                        Write-Host "Name:          $($dst_user.DisplayName)"
                        Write-Host "Email:         $($dst_user.Mail)"
                        Write-Host "Location:      $($dst_user.Office)"
                        Write-Host "Title:         $($dst_user.Title)"
                        Write-Host "Status:        $($dst_machine.Enabled)"
                        Write-Host "Description:   $($dst_machine.Description)"
                        Write-Host "Chasis:        $($dst_machine.ObjectClass)"
                        Write-Host "OS:            $($dst_machine.OperatingSystem)"           
                    }
                    catch 
                    {
                        $dst_username = Get-WmiObject -Class WIN32_PROCESS -ComputerName $dst_host | Where-Object {$_.ProcessName -like 'explorer*'} | Invoke-WmiMethod -Name GetOwner 
                        $dst_remoteuser = $dst_username.user
                        $dst_user = Get-ADUser $dst_remoteuser -Properties *
                        $dst_machine = Get-ADComputer $dst_host -Properties *
                        Write-Host "Machine:       $dst_host"
                        Write-Host "Status:        Online"
                        Write-host "LogonType:     Remote"
                        Write-Host "UID:           $dst_username"
                        Write-Host "Department:    $dst_user.Department"
                        Write-Host "Description:   $dst_user.Description"
                        Write-Host "Name:          $dst_user.DisplayName"
                        Write-Host "Email:         $dst_user.Mail"
                        Write-Host "Location:      $dst_user.Office"
                        Write-Host "Title:         $dst_user.Title"
                        Write-Host "Status:        $dst_machine.Enabled"
                        Write-Host "Description:   $dst_machine.Description"
                        Write-Host "Chasis:        $dst_machine.ObjectClass"
                        Write-Host "OS:            $dst_machine.OperatingSystem"
                    }
                }
        else
            {
                Write-Host "Error: $dst_host is currently offline" -ForegroundColor Red
            }
        
        Write-Host " "
        Write-Host " "  
    }
elseif ($selection -eq "5") 
{
    $answer = Read-Host "Enter external IP Address"
    $result = Get-MyWhoIs $answer
    Write-Host " "
    Write-host "$answer belongs to $result" 
    Write-Host " "
}
elseif ($selection -eq "6")
{
    $src_ip = Read-Host "Please enter the IP Address"
    $src_host = [System.Net.Dns]::GetHostByAddress($src_ip).Hostname.split(".")[0]
    Write-Host " "
    Write-Host "Attempting to ping $src_ip..."
    Write-Host " "
    if (Test-Connection $src_ip -Quiet)
            {
                Write-Host "SUCCESS: $src_ip is online and belongs to $src_host" -ForegroundColor Green
                Write-Host " "
            }
        else 
            {
                Write-Host "ERROR: $src_ip is NOT online" -ForegroundColor Red
                $src_status = "offline"
            }
}
elseif ($Selection -eq "7") 
{
    $machine = Read-Host "Please enter target machine"
    Write-Host " "
    Write-Host "Retrieving processes from $machine"
    Get-Process -ComputerName $machine | Out-GridView
}
elseif ($Selection -eq "8") 
{
    $machine = Read-Host "Please enter target machine"
    Write-Host " "
    Write-Host "Retrieving services from $machine"
    Get-Service -ComputerName $machine | Where-Object {$_.Status -eq "Running"} | Out-GridView
}
elseif ($Selection -eq "9") 
{
    $machine = Read-Host "Please enter target machine"
    Write-Host " "
    Write-Host "Retrieving processes and services from $machine"
    Get-Process -ComputerName $machine | Out-GridView
    Get-Service -ComputerName $machine | Where-Object {$_.Status -eq "Running"} | Out-GridView
if (condition) 
    {
        $msg = 'Would you like to stop something running on a computer? [y/n]'
        do 
            {
                $response = Read-Host -Prompt $msg
                if ($response -eq 'y') 
                    {
                        $answer = Read-Host "Would you like to kill a process or service? [p/s]"

                        if ($answer -eq "p") 
                            {
                                Write-Host " "
                                $KillID = Read-Host "Please enter the ID associated with the process you would like to kill"
                                Write-Host " "
                                Write-Host "Killing a process..."
                                Write-Host " "

                                if ((Get-WmiObject Win32_Process -ComputerName $machine | Where-Object {$_.processid -eq $KillID}).terminate())
                                    {
                                        Write-Host "Success!"
                                    }
                                else
                                    {
                                        Write-Host "ERROR stopping process"
                                    }
                            }
                        elseif ($answer -eq "s") 
                            {
                                Write-Host " "
                                $TargetService = Read-Host "Please enter the full name associated with the service you would like to kill"
                                Write-Host " "
                                Write-Host "Killing a service..."
                                Write-Host " "

                                if ((Get-Service -ComputerName $machine -Name $TargetService).Start())
                                    {
                                        Write-Host "Success!"
                                    }
                                else
                                    {
                                        Write-Host "ERROR stopping service"
                                    }
                            }
                        else 
                        {
                            Write-Host "Invalid option"
                        }
                    }
            } 
            until ($response -eq 'n')
        }
    else 
        {
            
        }
}
<#elseif ($Selection -eq "10") 
{
    $machine = Read-Host "Please enter target machine"
}
#>
else 
    {
        Write-Host "Invalid selection. " -ForegroundColor Red
    }