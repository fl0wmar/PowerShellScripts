#Extract logs from remote computers

<#
    PURPOSE: Rips files froms target computers; specifically ripping Log Files
#>

#This variable will grab your username and feed it into other areas. I personally use this so that I never have to worry about typing in my username into filepaths, and it makes giving this script to others easier
$UID = ($(Get-WmiObject -Class win32_computersystem | Select-Object username).username).split("\")[1]

###Here's a few different ways to get machines
#$machines = Read-Host "Enter Machine"
#$machines = Get-Content "C:\Users\$UID\Desktop\EXAMPLE.txt"
#$machines = Import-Csv "C:\Users\$UID\Desktop\EXAMPLE.csv" | Select-Object -ExpandProperty "System Name"
$LogsToCheck = @()
$LogsToCheck += New-Object psobject -Property @{Name="EXAMPLE";Path="\EXAMPLE\EXAMPLE\YADAYADA_$machine.log"}
$MSG = "Found $($($log.path)) on $machine"

#SCRIPT
foreach ($machine in $machines)
    {
        if ((Test-Connection $machine -quiet -count 1) -eq $false)
            {
                    Continue
            }
            foreach ( $log in $LogsToCheck)
                {
                    if (Test-Path "\\$machine\C`$$($($log.path))")
                        {
                            Write-Host $MSG
                            Copy-Item $("\\$machine\C`$$($($log.path))") $("C:\Users\$UID\Desktop\Example.txt")
                        }
                    else 
                        {
                            Write-Host "Cannot find $($log.path) on $machine"   
                        }
                }
    }   