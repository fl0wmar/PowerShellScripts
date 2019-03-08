#Attack Simulator
<#
    Purpose: Ha, this was fun. The team in charge of phishing users wanted something to scare people, so I wrote this up for them in a half-hour and they got to use it for demonstrations.
#>




#Opening Message
Write-Host @"

WARNING: Please do not end the script by pressing "CTRL + C" unless you are at a safe spot to do so.

Welcome to Attack Simulator!

This script is designed to scare people who continue clicking on every link they see in their emails, so that they can see the possible actions an attacker may take against their issued computer.

This script will guide you to replicating an extremely basic attack on the victim of your choosing by moving files from their:
    -Desktop
    -Downloads
    -Documents

The files from the three above mentioned folders will be moved to the victims C: Drive in: 
    -C:\ProgramData\Windows\Operating System\AttackSimulator\Desktop\
    -C:\ProgramData\Windows\Operating System\AttackSimulator\Downloads\
    -C:\ProgramData\Windows\Operating System\AttackSimulator\Documents\

"@

#First identify the victim
$Victim = Read-Host "Please enter the machine you'd like to manipulate"

<#
    So instead of doing this, you could also use something else I wrote for some other scripts...

        ###This will tell fetch the username logged into a remote computer
        $UID = ($(Get-WmiObject -ComputerName $machine -Class Win32_ComputerSystem | Select-Object UserName).username).split("\")[1]

        ###If somebody is RDP'd into a computer, you could use this instead (or write a statement to test for either one, knock your socks off bud)
        $UID = Get-WmiObject -Class WIN32_PROCESS -ComputerName $machine | Where-Object {$_.ProcessName -like 'explorer*'} | Invoke-WmiMethod -Name GetOwner 
#>
$UID = Read-Host "Please enter the UID associated with $Victim"

#Verify the victim is online. If they're not, tough luck, go eat some cookies.
if ((Test-Connection $Victim -quiet -count 1) -eq $false)
{
        Write-Host @"
        
        WARNING: $Victim is offline and AttackSimulator cannot continue.

"@
}
else 
{
    Write-Host @"
    
    $Victim is online, now checking if filesystem can be manipulated...
    
"@
<#
    Now that the victims computer has been identified as online, we can verify if the attack can be completely carried out or not.
    If the C$-share is NOT accessible on the computer, then the attack cannot continue.
#>


#Verify the victims file system can be manipulated

<#
    If the victims file system can be tested, proceed

#>
    if (Test-Path "\\$victim\C`$")
    {
        Write-Host @"
        
        SUCCESS: $Victim is online and can be manipulated!

        AttackSimulator is attempting to create folders on $Victim...

"@
        
    #If you can create a "Test" folder on their computer, then proceed with creating the other folders
    if (New-Item -Path $("\\$victim\C`$\ProgramData\") -Type Directory -Name "Test") 
    {
        try 
        {
            New-Item -Path $("\\$victim\C`$\ProgramData\") -Type Directory -Name "Windows" -Force
            New-Item -Path $("\\$victim\C`$\ProgramData\Windows\") -Type Directory -Name "Operating System" -Force
            New-Item -Path $("\\$victim\C`$\ProgramData\Windows\Operating System\") -Type Directory -Name "Desktop" -Force
            New-Item -Path $("\\$victim\C`$\ProgramData\Windows\Operating System\") -Type Directory -Name "Downloads" -Force
            New-Item -Path $("\\$victim\C`$\ProgramData\Windows\Operating System\") -Type Directory -Name "Documents" -Force

            Write-Host @"
        
            AttackSimulator has successfully created folders on $Victim!

            Are you ready to simulate the attack?


"@
            $Selection = Read-Host "Please enter 'y' or 'n'"

                        #Start moving stuff!
                        if ($Selection -eq "y")
                        {
                                    Write-Host " "
                                    Write-Host "AttackSimulator is now simulating the attack..."
                                    Write-Host " "
                    
                                    Get-ChildItem -Path $("\\$victim\C`$\Users\$UID\Desktop\") -Recurse  | Move-Item -Destination $("\\$victim\C`$\ProgramData\Windows\Operating System\Desktop\")
                                    Get-ChildItem -Path $("\\$victim\C`$\Users\$UID\Downloads\") -Recurse  | Move-Item -Destination $("\\$victim\C`$\ProgramData\Windows\Operating System\Downloads\")
                                    Get-ChildItem -Path $("\\$victim\C`$\Users\$UID\Documents\") -Recurse  | Move-Item -Destination $("\\$victim\C`$\ProgramData\Windows\Operating System\Documents\")
                                    
                                    Write-Host " "
                                    Write-Host "Is it time to end the simulation?"
                                    Write-Host " "

                                    $Selection2 = Read-Host "Please enter 'y'"

                                    #Insert joke about the lack of freedom or whatever
                                    if ($Selection2 -eq "y")
                                    {
                                        Get-ChildItem -Path $("\\$victim\C`$\ProgramData\Windows\Operating System\Desktop\") -Recurse  | Move-Item -Destination $("\\$victim\C`$\Users\$UID\Desktop\") 
                                        Get-ChildItem -Path $("\\$victim\C`$\ProgramData\Windows\Operating System\Downloads\") -Recurse  | Move-Item -Destination $("\\$victim\C`$\Users\$UID\Downloads\")
                                        Get-ChildItem -Path $("\\$victim\C`$\ProgramData\Windows\Operating System\Documents\")     -Recurse  | Move-Item -Destination $("\\$victim\C`$\Users\$UID\Documents\")
                                    }
                                    else
                                    {
                                        Write-Host " "
                                        Write-Host "You appear to have entered the wrong answer, so we're ending the simulation anyways"
                                        Write-Host " "

                                        Get-ChildItem -Path $("\\$victim\C`$\ProgramData\Windows\Operating System\Desktop\") -Recurse  | Move-Item -Destination $("\\$victim\C`$\Users\$UID\Desktop\") 
                                        Get-ChildItem -Path $("\\$victim\C`$\ProgramData\Windows\Operating System\Downloads\") -Recurse  | Move-Item -Destination $("\\$victim\C`$\Users\$UID\Downloads\")
                                        Get-ChildItem -Path $("\\$victim\C`$\ProgramData\Windows\Operating System\Documents\")     -Recurse  | Move-Item -Destination $("\\$victim\C`$\Users\$UID\Documents\")

                                    }
                         
                        else
                        {
                            Write-Host @"
                            
                            No fun!

"@
                        }
                        }
                    }
        catch 
        {
            Write-Host "ERROR: AttackSimulator is unable to create the necessary directories on $victim"    
        }
    }
    else 
    {
        Write-Host "ERROR: AttackSimulator is unable to create the necessary directories on $victim"
    } 
        
    }
    
    else 
    {
        Write-Host @"

        "Sorry, it looks like the file system on this machine cannot be manipulated!
       
"@
    }    
}
