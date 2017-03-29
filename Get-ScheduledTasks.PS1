Param(
    $OutPutFile="C:\Temp\ScheduledTasks.CSV"
)

$ComputerName = (Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' } `
                -Properties OperatingSystem | Select-Object Name).Name

Workflow GetSchTask {
    Param([String[]]$ComputerName)
    foreach -parallel($Computer in $ComputerName) {
        Sequence {
            $TempCSV = @()
            $TempCSV += schtasks /Query /S $($Computer) /FO CSV /V
            $TempCSV | Out-File "$ENV:Temp\$Computer.CSV" -Encoding ascii
            $TempCSV = Import-CSV "$ENV:Temp\$Computer.CSV"
            $DelFile = Remove-Item "$ENV:Temp\$Computer.CSV"
            $TempCSV
        }
    }
}

$ScheduledCSV = GetSchTask -ComputerName $ComputerName
$ScheduledCSV = $ScheduledCSV | ? {$_.Hostname -ne "Hostname"}
$ScheduledCSV | Export-CSV $OutputFile
Get-Date
