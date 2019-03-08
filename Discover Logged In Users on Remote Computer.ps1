#Discover who is logged into a remote computer

<#
    This was made to discover who was logged into a computer, and would then query Active Directory for their information.
#>

#Menu
Clear-Host
Write-host " "
Write-Host "Welcome!"
Write-Host " "
Write-Host "********************MENU**************************"
Write-Host "          1. Find a user on one machine"
Write-Host "          2. Find users on multiple machines by feeding a text file in"
Write-Host "          3. Find an email address for one user"
Write-Host "          4. Find email address for multiple users by feeding a text file in"
Write-Host " "

#Selection
$selection = Read-Host "Please make a selection"

#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to other
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]


#Options
if($selection -eq "1")
    {
        $machine = Read-Host "Please enter a machine name"
        Write-Host " "
        Write-Host "Checking if $machine is online..."
        Write-Host " "

        if (Test-Connection $machine)
        {
            Write-Host "$Machine is online!"
            Write-Host " "
            try 
            {
                Write-Host "User is logged in locally "
                Write-Host " "
                Write-Host "************Machine Info*****************"
                $username = ($(Get-WmiObject -ComputerName $machine -Class Win32_ComputerSystem | Select-Object UserName).username).split("\")[1]
                Write-Host " "
                Write-Host "Machine: $machine"
                Write-Host "Status: Online"
                Write-host "Logon Type: Local"
                Write-Host "UID: $username"
                $MachineUserEmail = Get-ADUser $username | Select-Object UserPrincipalName
                Write-Host "Email:$($machineuseremail.userprincipalname)"
                Write-Host " "
                Write-Host "*****************************************"
            }
            catch 
            {
                Clear-Host
                Write-Host "User is NOT logged in locally"
                Write-Host " "
                Write-Host "************Machine Info*****************"
                $username = Get-WmiObject -Class WIN32_PROCESS -ComputerName $machine | Where-Object {$_.ProcessName -like 'explorer*'} | Invoke-WmiMethod -Name GetOwner 
                $remoteuser = $username.user
                Write-Host " "
                Write-Host "Machine: $machine"
                Write-Host "Status: Online"
                Write-Host "Logon Type: Remote"
                Write-Host "UID: $remoteuser"
                $MachineUserEmail = Get-ADUser $remoteuser | Select-Object UserPrincipalName
                Write-Host "Email:$($machineuseremail.userprincipalname)"
                Write-Host " "
                Write-Host "*****************************************"
            }
        }
    
        else
        {
            Write-Host "Error: $machine is currently offline"
        }
    }
elseif ($selection -eq "2" ) 
    {
        $machines = Get-Content "C:\Users\$UID\Desktop\EXAMPLE.txt"

        foreach ($machine in $machines)
        {
            if ((Test-Connection $machine -quiet -count 1) -eq $false)
            {
                Write-Host "$machine is offline!"
                Write-Host " "
                Continue
            }
                try 
                {
                    Write-Host " "
                    Write-Host "************Machine Info*****************"
                    $username = ($(Get-WmiObject -ComputerName $machine -Class Win32_ComputerSystem | Select-Object UserName).username).split("\")[1]
                    Write-Host " "
                    Write-Host "Machine: $machine"
                    Write-Host "Status: Online"
                    Write-host "Logon Type: Local"
                    Write-Host "UID: $username"
                    $MachineUserEmail = Get-ADUser $username | Select-Object UserPrincipalName
                    Write-Host "Email:$($machineuseremail.userprincipalname)"
                    Write-Host " "
                    Write-Host "*****************************************"
                }
                catch 
                {
                    Write-Host " "
                    Write-Host "************Machine Info*****************"
                    $username = Get-WmiObject -Class WIN32_PROCESS -ComputerName $machine | where {$_.ProcessName -like 'explorer*'} | Invoke-WmiMethod -Name GetOwner 
                    $remoteuser = $username.user
                    Write-Host " "
                    Write-Host "Machine: $machine"
                    Write-Host "Status: Online"
                    Write-Host "Logon Type: Remote"
                    Write-Host "UID: $remoteuser"
                    $MachineUserEmail = Get-ADUser $remoteuser | Select-Object UserPrincipalName
                    Write-Host "Email
                    :$($machineuseremail.userprincipalname)"
                    Write-Host " "
                    Write-Host "*****************************************"
                }
            }
    }
elseif ($selection -eq "3")
    {
        clear-host
        $username = Read-Host "Please enter the username"
        Write-Host " "
        $MachineUserEmail = Get-ADUser $username | Select-Object UserPrincipalName
        Write-Host "$($machineuseremail.userprincipalname)"
    }

elseif ($selection -eq "4") 
    {
        Clear-Host

        $usernames = Get-Content "C:\Users\$UID\Desktop\EXAMPLE.txt"

        Write-Host "Kangaroo will fetch $($usernames.count) usernames from Active Directory..."
        Write-Host " "
        Write-Host " "

        foreach ($username in $usernames)
        {
            $MachineUserEmail = Get-ADUser $username | Select-Object UserPrincipalName
            Write-Host "$username : $($machineuseremail.userprincipalname)"
        } 
        
        Write-Host " "
        Write-Host "********Operation Complete!********"
        Write-Host " "
    }

else
{
    Write-Host "Invalid Selection"
}
Write-Host " "