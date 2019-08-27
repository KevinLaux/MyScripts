1..100 | foreach {Start-Job -Name $_ -ScriptBlock{
        $successcount = 1
        Do{
            $i = 0
            $success = $null
            $last = $null
            While(($i -le 9) -and ($success -ne $false)){
                if(!$last){$last = Get-Random -Maximum 2 -Minimum 0}
                elseif($last -eq $(Get-Random -Maximum 2 -Minimum 0)){
                    if($i -eq 9){$success = $true}
                }
                else{
                    $success = $false
                }
                $i++
            }
            $successcount++
        }
        Until($success)
        $successcount
    }
}
$attempts
