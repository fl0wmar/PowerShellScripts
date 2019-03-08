#Discover files,folders,services, and processes

<#
    Purpose: This script has been designed to help troubleshoots product issues to see if an agent was actually running and installing things like it was supposed to
#>

#UID, Variables, and base arrays
    <#
        In this section I housed the variables that Crocodile is using

        UID: In order to read/export results to/from the computer running Crocodile, the script needs a UID from the user who's running it, so this one line of code grabs it
        Machines: The script works based off a TXT file on your desktop titled "MachineList" (You can change this if you want)
        Results: We're gonna be using an array to store all of our results in, so to use an array we have to declare it as a variable
        Services to check: We're checking multiple services, so we're using an array
        Processes to check: We're checking multiple processes, so we're using an array
        Columns: The things we're actually going to exporting, so we declare an array
        Files to check: We're checking multiple files, so we're using an array
    #>
$Date = Get-Date -Format "MM-dd-yyyy"
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]
$machines = Get-Content C:\Users\$UID\Desktop\ServersProductCheck.txt
$ExportFile = "C:\Users\$UID\Desktop\EXAMPLE.csv"
$results = @()
$ServicesToCheck = @()
$ProcessesToCheck = @()
$columns = @()
$filesToCheck = @()

Write-Host "Crocodile will look for Product Files, Folders, Processes, and Services"

#FUNCTIONS
    <#
        For the love of God, please don't touch this function.

        It works, and grabs the address of a machine. That's it.
    #>
    function Get-HostToIP($machine) 
        {
            Write-host "Looking for $machine..."
            Try {
                $result = [system.Net.Dns]::GetHostByName($machine)
                $result.AddressList | ForEach-Object {$_.IPAddressToString } 
            } catch {
                "OFFLINE"
                Write-Host "$Machine is OFFLINE"
            }
        }

#Services Array
    <#
        We're specifying all the services we're checking as an array, so to do that we declare the array variable and append a new ps object and declare the properties of it    
    #>
    $ServicesToCheck += new-object psobject -Property @{Name="EXAMPLE"}

#Processes Array
        <#
            We're specifying all the processes we're checking as an array, so to do that we declare the array variable and append a new ps object and declare the properties of it    
        #>
    $ProcessesToCheck += New-Object psobject -Property @{Name="mfecanary"}

#Files and Folders
    <#
        We're specifying all the files/folders we're checking as an array, so to do that we declare the array variable and append a new ps object and declare the path of it    
    #>
    $filesToCheck += new-object psobject -Property @{Name="Program Files";Path="\Program Files\Product"}

#COLUMNS
    <#
        Here is where we're storing all of the columns that we're using, and to avoid having to type in every single column for files/folders, processes, and services, we just use the name function since that's part of the array
    #>

    $columns += "Name"
    $columns += "IP Address"
    #$columns += "Reboot Time"
    $columns += $($ServicesToCheck.Name)
    $columns += $($ProcessesToCheck.Name)
    $columns += $($filesToCheck.Name)

#Base Function
    <#
        This is where the script actually starts working! We're going to be using a foreach loop, this way we can interact with every machine in the file.

        In order to make sure the script knows how to handle the data we're giving it, we're specifying that each machine is going to be an object this way it creates a row for each machine.

        We additionally specify that we're piping in a member into the tempobject to create a column that's going to house an IP Address per each machine
    #>
    foreach ($machine in $machines)
    {
        $tempObject = New-Object psobject -Property @{Name=$machine}
        $tempObject | Add-Member "IP Address"  $(Get-HostToIP($machine))

#IP Address and Reboot Functions    
    <#
        This is pretty simple, here we're just saying telling the script that for each machine we want to test a connection (aka ping). If we can't ping the machine, we don't want the script doing anything else with offline machines because it's a waste of time. 

        So we're specifically saying, hey test a connection to a machine, and if that machine doesn't talk back, mark it as offline in all areas and continue with the script; specifically, obtain the reboot time if able. And if it can't obtain the reboot time, mark it as "N/A"
    #>
    if ( (Test-Connection $machine -quiet -count 1) -eq $false)
    {
        Write-Host "Could not ping $machine"
        
        foreach ( $service in $ServicesToCheck ) 
        {
            $tempObject | Add-Member $($service.name) "OFFLINE"
        }
        foreach ( $process in $ProcessesToCheck)
        {
            $tempObject | Add-Member $($process.name) "OFFLINE"
        }
        foreach ( $file in $filesToCheck )
        {
            $tempObject | Add-Member $($file.name) "OFFLINE"
        }
        $results += $tempObject  
        Continue
    } 

#Processes and Services ERROR Check Function
    <#
        Here we're going to try and check for processes and services on a machine to see if we're even able to do so, and if we can't, there's an error action of "stop".
    #>

    
    Try
    {
        $ProductService = Get-Service -ComputerName $machine -ErrorAction Stop
        $ProductProcess = Get-Process -ComputerName $machine -ErrorAction Stop
    }
    catch
    {
        Write-Host "$machine has encountered an error; proceeding to next machine."
        Continue
    }

#Services Function
    <#
        Crocodile uses this foreach loop to check for each service from the services machines in an array. If it finds the service, it tells us its status (running/stopped), and if it can't find the service the script labels it as "missing"
    #>

    foreach ( $service in $ServicesToCheck ) 
    {
        $MasterService = $ProductService | Where-object {$_.DisplayName -eq $($service.name)}

            if ($MasterService -ne $null) 
            {
                $tempObject | Add-Member $($service.name) $($MasterService.Status)

                if ($MasterService.Status -eq "Stopped")
                {
                    Write-Host "WARNING: The $($service.name) on $machine is stopped"
                }
                else 
                {
                    Write-Host "The $($service.name) on $machine is running"     
                }
            } 
            else 
            {
                $tempObject | Add-Member $($service.name) "MISSING"
            }
    }
#Process Function
    <#
        Here's where we're checking for each process in the processes array
    #>

    foreach ( $process in $ProcessesToCheck)
    {
        $MasterProcess = $ProductProcess | Where-Object {$_.ProcessName -eq $($process.name)}

            if ($MasterProcess -ne $null) 
            {
                $tempObject | Add-Member $($process.name) $($MasterProcess.Name)
                Write-Host "$($process.name) found"
            }
            else 
            {
                $tempObject | Add-Member $($process.name) "MISSING"   
                Write-Host "$($process.name) MISSING"
            }
    }

#Files to check
    <#
        Here's where we're checking for each file in the files array
    #>
    foreach ( $file in $filesToCheck ) 
    {
        if ( Test-Path "\\$machine\C`$$($($file.path))" ) 
        {
            $tempObject | Add-Member $($file.name) "Exists"
            Write-Host "$($file.path) found"
        } 
        Else 
        {
            $tempObject | Add-Member $($file.name) "MISSING"
            Write-Host "$($file.path) MISSING"
        }
    }
    $results += $tempObject
    }

$results | Select-object $columns | Export-Csv $ExportFile -NoTypeInformation
Invoke-Item $ExportFile