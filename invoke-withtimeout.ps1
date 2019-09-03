$Job = Start-Job -ScriptBlock {

    Invoke-Command -ComputerName localhost -ScriptBlock {
    #
        Get-ChildItem c:\scripts\*.* -Recurse | Select-Object name | Out-File 'C:\Scripts\myfile.txt'
    #
    } 


}

$Job | Wait-Job -Timeout 10
$Job | Stop-Job