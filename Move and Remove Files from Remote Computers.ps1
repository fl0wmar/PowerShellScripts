#Move or remove files from remote computers

#PURPOSE: Interacts with files on a remote machine so you can transfer something directly to it, or delete something directly from it


#Variables
#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to others easier
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]
    
#Menu
Write-Host "*******************************MENU*************************************"
Write-Host "    1. Copy a file to another machine (or multiple machines)"
Write-Host "    2. Remove a file from a local machine"
Write-Host " "
$Selection = Read-Host "Please make a selection"

#Selection 1: Copy files to another machine
    if ($Selection -eq "1")
    {
        $Answer = Read-Host "Would you like to copy files to one machine or multiple? (one/multiple)"

        if ($Answer -eq "one")
        {
            $machine = Read-Host "Please enter the machine name"
            $LocalFile = Read-Host "Please enter the file you would like to copy to a machine"
            $TargetPath = Read-Host "Please enter the path you want to copy the file to"
            Write-Host "Pinging $machine..."
            Write-Host " "
            if ((Test-Connection $machine -quiet -count 1) -eq $false)
                    {
                        Write-Host "$machine is online!"    
                        Write-Host " "
                        Continue
                    }
                            if(Test-Path $("\\$machine\C`$"))
                            {
                                Write-Host "Attempting to copy file..."
                                Try 
                                {
                                    Copy-Item $($LocalFile) $("\\$machine\C`$\$TargetPath") -Recurse
                                }
                                catch
                                {
                                    Write-Host "ERROR: File could not be copied"
                                }
                            }
                            else 
                            {
                                Write-Host "ERROR: Machine cannot be contacted"
                            }
        }
        else 
        {
            $machines = Get-Content C:\Users\$UID\Desktop\MachineList.txt
            $LocalFile = Read-Host "Please enter the file you would like to copy to a machine"
            $TargetPath = Read-Host "Please enter the path you want to copy the file to"

            foreach ($machine in $machines)
            {
                if ((Test-Connection $machine -quiet -count 1) -eq $false)
                        {
                                Continue
                        }
                            foreach ( $machine in $machines)
                            {
                                if(Test-Path $("\\$machine\C`$"))
                                {
                                    Try 
                                    { 
                                        Write-Host "Attempting to copy  file..."
                                        Copy-Item $($LocalFile) $("\\$machine\C`$\$TargetPath") -Recurse
                                        Write-Host "SUCCESS: File was copied!"
                                    }
                                    catch
                                    {
                                        Write-Host "ERROR: File could not be copied"
                                    }
                                }
                                else 
                                {
                                    Write-Host "ERROR: Machine cannot be contacted"
                                }
                            }
            }
        }
    }
#Selection 2
    elseif ($Selection -eq "2") 
    {
        $InfectedFile = Read-Host "Please enter the file path of the folder/file you would like to remove from a machine"
        $machine = Read-Host "Please enter the machine name"
    
        if ((Test-Connection $machine -quiet -count 1) -eq $false)
            {
                Continue
                Write-Host "Machine is online!"
            }   
        if(Test-Path $("\\$machine\C`$"))
        {
            if(Test-Path $("\\$machine\C`$\$InfectedFile"))
            {
                Write-Host "The file/folder has been found"
                Write-Host "Attempting to remove the file..."
                Try
                {
                    Remove-Item $("\\$machine\C`$\$InfectedFile") 
                    Write-Host "SUCCESS: Infected file/folder removed"
                }
                Catch
                {
                    Write-Host "ERROR: File/Folder could not be removed."
                }
            }
        }
        else 
        {
            Write-Host "ERROR: Machine cannot be contacted"
        }
    } 
#Invalid Selection
    else 
    {
        "Invalid selection"
    }    