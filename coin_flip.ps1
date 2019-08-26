Do{
    $attempts = 1
    $successcount = 1
    $results = @{}
    Do{
        $i = 0
        $success = $null
        $last = $null
        While(($i -le 9) -and ($success -ne $false)){
            Write-Host $i
            if(!$last){$last = Get-Random -Maximum 2 -Minimum 0}
            elseif($last -eq $(Get-Random -Maximum 2 -Minimum 0)){
                if($i -eq 9){$success = $true}
            }
            else{
                $success = $false
                Write-Warning "Failure"
            }
            $i++
        }
        $successcount++
    }
    Until($success)
    $results = $results.Add($attempts, $successcount)
    $attempts++
    Write-Output "Succeeded in: $successcount attempts"
}
Until($attempts -eq 100)
$attempts
