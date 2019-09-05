#Method 1 Starting Individual Jobs
$attempts = @{}
   $attempts = 1..1000 | ForEach-Object -Parallel {
            $successcount = 1
            Do{
                $i = 0
                $success = $null
                $last = $null
                While(($i -le 9) -and ($success -ne $false)){
                    if(!$last){$last = Get-Random -Maximum 2 -Minimum 0}
                    elseif($last -eq $(Get-Random -Maximum 2 -Minimum 0)){
                        if($i -eq 9){
                            $success = $true
                            Return @{$_ = $successcount}
                        }
                    }
                    else{
                        $success = $false
                        $successcount++
                    }
                    $i++
                }
            }
            Until($success)
            $successcount
        }
    $attempts.values | Measure-Object -Average
#Method 2 Invoke-command multiple times
    # $computer = @(1..100)
    # foreach($i in 0..99){
    #     $computer[$i] = "localhost"
    # }
    # $results = @()
    # $results = Invoke-Command -ComputerName $computer -ScriptBlock {
    #     $successcount = 1
    #     Do{
    #         $i = 0
    #         $success = $null
    #         $last = $null
    #         While(($i -le 9) -and ($success -ne $false)){
    #             if(!$last){$last = Get-Random -Maximum 2 -Minimum 0}
    #             elseif($last -eq $(Get-Random -Maximum 2 -Minimum 0)){
    #                 if($i -eq 9){$success = $true}
    #             }
    #             else{
    #                 $success = $false
    #             }
    #             $i++
    #         }
    #         $successcount++
    #     }
    #     Until($success)
    #     $successcount
    # }
    # $results | Measure-Object -Average
