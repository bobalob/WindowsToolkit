Param(
    $OutPutFile="C:\Temp\Services.CSV"
)
Get-Date
$ComputerName = (Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' } `
                -Properties OperatingSystem | Select-Object Name).Name

Workflow GetSchTask {
    Param([String[]]$ComputerName)
    foreach -parallel($Computer in $ComputerName) {
            Get-WMIObject -Class Win32_Service -PSComputerName $($Computer) | 
                ? { $_.StartName -notmatch "LocalSystem|LocalService|NetworkService"} | 
                    Select-Object SystemName, Name, pathName, Caption, DisplayName, StartName, State
    }
}

$ServiceCSV = GetSchTask -ComputerName $ComputerName

$ServiceCSV | Export-CSV $OutPutFile
Get-Date
