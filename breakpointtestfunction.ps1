function Test-InnerFunction{
    param(
        $var3,
        $var4
    )
    $result = $var3 + $var4
    Write-Host "Doing some stuff inside of doing some stuff"
}
function Test-Function {
    param (
        $var1,
        $var2
    )
    $result = $var1 + $var2
    Write-host "Doing some stuff!"
    Test-InnerFunction -var3 $var1 -var4 $var2
}
$items = 1..10
Foreach($item in $items){
    Write-host "About to do some stuff"
    Test-Function -var1 $item -var2 ($item + 1)
    Write-host "Done doing some stuff"
}
# 1..10 | Foreach{
#     Write-host "About to do some stuff"
#     Test-Function -var1 $_ -var2 ($_ + 1)
#     Write-host "Done doing some stuff"
# }
