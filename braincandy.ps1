$i=1
$a = "         "
Do{
    Write-host  "$($a.Substring(0, $a.Length - $i%10)) $($i) x " -ForegroundColor Black -BackgroundColor White -NoNewline
    Write-Host "8" -ForegroundColor Red -BackgroundColor White -NoNewline
    Write-Host " + " -ForegroundColor Black -BackgroundColor White -NoNewline
    Write-host "$($i%10)" -ForegroundColor Blue -BackgroundColor White -NoNewline
    Write-Host " = $($i * 8 + $i%10)$($a.Substring(0, $a.Length - $i%10))" -ForegroundColor Black -BackgroundColor White
    $i = $i * 10 + $i%10 + 1
}
While($i -le 123456789)