$Job = Start-Job -ScriptBlock {

    Invoke-Command -ComputerName localhost -ScriptBlock {
    #
        Get-ChildItem c:\scripts\*.* -Recurse | select name | Out-File 'C:\Scripts\myfile.txt'
    #
    } 


}

$Job | Wait-Job -Timeout 10
$Job | Stop-Job