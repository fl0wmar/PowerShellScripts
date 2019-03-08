#Generate tickets with ServiceNOW API

<#
    Purpose: self-explanatory, and this script is in no means my own. This was shown to me by a coworker and I know other people could use it.

    Big thanks to TW!
#>

<#
    NOTES: Requester/company is not automatically inserted, so remember to specifcy email addresses to contact

            -Attaching files via the script is currently not functioning, may be available soon; API's may be changing from SOAP to REST
#>


#  Username and password for ServiceNow

$username = "EXAMPLE"
$password = "EXAMPLE"


# The address to post the SOAP request.  Each table in servicenow has a different address.  
#  We are creating a task using the "sc_task" table
#Take QA off below when ready to create tickets
$URI = "https://example.service-now.com/sc_task.do?SOAP"

#  Assignment group for the task/ticket, different assignment groups can be found in servicenow
#Change assignement group to whatever appropriate team per tickets
$assignmentGroup = "GROUP"

#  Summary of the ticket
$ShortDescription = "Task Summary is here" 

#  Description for the ticket
#Don't put in greater than or less than symbols, it interferes with XML
$description = @"
Task body goes here
"@

#  The XML we are going to post.  There are other ways to make an XML element in code, this was a simple method I used
#  An example of more complex XML creation can be found here:  https://github.com/harbingereternal/ServiceNow-PowerShell/blob/master/Scripts/ServiceNowSOAP/Public/New-ServiceNowTicketSOAP.ps1
$XML = @"
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
        <insert xmlns="$URI">
            <assignment_group>$assignmentGroup</assignment_group>
            <short_description>$ShortDescription</short_description>
            <description>$description</description>
        </insert>
    </soap:Body>
</soap:Envelope>
"@


#  We build the header with the login information
$header = @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username+":"+$password))}


#  Try to open the ticket
Try {
    Write-host "Sending web request"
    #  We run invoke-webrequest with the address, the XML body and the headers (login info) we created earlier
    $result = Invoke-WebRequest $URI -Body $XML -ContentType "text/xml" -method Post -Headers $header -ErrorAction Stop
} Catch {
   write-host "Error detected!" -ForegroundColor Red
   $error[0] 
}

#  Save the result XML from the response
$ResultXML = [xml]$result.content

write-host "Result Code is: $($result.StatusCode)"


#  Check the status code from the HTTP request
if ( $result.StatusCode -ne 200 ) {

    write-host "Error, status code returned $($result.StatusCode) does not indicate success." -ForegroundColor Red

} Else {
    #  We extract the ticket number from the response XML
    $ticket_number = $ResultXML.Envelope.body.insertResponse.number
    write-host "Ticket number is:  $ticket_number"

}