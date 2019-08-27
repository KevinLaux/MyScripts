#Method 1 Starting Individual Jobs
    # 1..100 | ForEach-Object {Start-Job -Name $_ -ScriptBlock{
    #         $successcount = 1
    #         Do{
    #             $i = 0
    #             $success = $null
    #             $last = $null
    #             While(($i -le 9) -and ($success -ne $false)){
    #                 if(!$last){$last = Get-Random -Maximum 2 -Minimum 0}
    #                 elseif($last -eq $(Get-Random -Maximum 2 -Minimum 0)){
    #                     if($i -eq 9){$success = $true}
    #                 }
    #                 else{
    #                     $success = $false
    #                 }
    #                 $i++
    #             }
    #             $successcount++
    #         }
    #         Until($success)
    #         $successcount
    #     }
    # }
    # $attempts
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
