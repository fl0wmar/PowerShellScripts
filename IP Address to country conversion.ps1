#IP Address to country conversion

<#
    *This script is NOT my own. My coworker showed me this because it used to be something they used years and years ago. Not completely necessary if you have a SIEM that does proper conversions on its own to tell you what country an IP Address is sourcing from, but wanted to upload this here in case somebody could find an additional use-case for it. 
    
    Thank you TW!
#>
function Get-CountryForIP ( $strIP ) {

    write-host "[$(Get-Date -format "yyyy-MM-dd HH:mm:ss")] Getting data for $strIP"
    $strURL = "https://tools.keycdn.com/geo.json?host=" + $strIP 
    $page = Invoke-WebRequest $strURL 
    write-host "[$(Get-Date -format "yyyy-MM-dd HH:mm:ss")] Data returned."

    $PSObject = $page | ConvertFrom-Json

    $PSObject

}

#You can also feed in a file here with a list of IP Addresses
$strIPs = 
@"
71.77.146.83
157.34.3.199
"@


$results = @()

foreach  ( $IP in $strIPs.split("`n").trim() ) {

    $c = get-countryforIP $IP
    [array]$results += $C.data.geo
    
    
}

$results | Out-GridView

$results |  export-excel IPToCountry$(get-date -format "yyyyMMdd").xlsx

