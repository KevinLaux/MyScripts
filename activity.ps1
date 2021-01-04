param($minutes = 120)
$myshell = New-Object -com "Wscript.Shell"
for ($i = 0; $i -lt $minutes; $i++) {
  Start-Sleep -Seconds 30
  $myshell.sendkeys(".")
}