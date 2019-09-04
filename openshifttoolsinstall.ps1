[CmdletBinding(DefaultParameterSetName='Install')]
param(
    [string] $Path = "$($env:USERPROFILE)\Documents\OpenShiftClientTools\",
    [switch] $Admin,
    [Parameter(ParameterSetName='Install')]
    [switch] $Overwrite,
    [Parameter( Mandatory=$true,
                ParameterSetName='Uninstall')]
    [switch] $Uninstall
)
if(-not ($Path.EndsWith("\"))){$Path = $Path + "\"}
# Expand an archive using Expand-archive when available
# and the DotNet API when it is not
function Expand-ArchiveInternal {
    [CmdletBinding()]
    param(
        $Path,
        $DestinationPath
    )

    if((Get-Command -Name Expand-Archive -ErrorAction Ignore))
    {
        Expand-Archive -Path $Path -DestinationPath $DestinationPath
    }
    else
    {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        $resolvedDestinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DestinationPath)
        [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPath,$resolvedDestinationPath)
    }
}
function Test-OCAdminRights{
    [CmdletBinding()]
    param(
        $Path
    )
    Write-Verbose "Admin parameter was provided, testing Admin rights and setting installation location to Program Files"
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $result = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    if (!($result)){
        Write-Warning "You are not running as Administrator either relaunch as administrator or remove the -Admin Parameter to install in user path"
        Exit
    }
    if($Path -eq "$($env:USERPROFILE)\Documents\OpenShiftClientTools\"){
        $Path = "$env:ProgramFiles\OpenShiftClientTools\"
    }
    Return $Path
}
function Test-OCInstalled{
    [CmdletBinding()]
    param(
        $Path,
        $Overwrite
    )
    $oc = (Get-Command "oc.exe" -ErrorAction SilentlyContinue).Source -replace "oc.exe" , ""
    if(!($oc)){
        if(Test-Path $Path){$oc = $Path}
    }
    if ($oc) 
    { 
        Write-Verbose "Found OC.exe"
        if($($oc -eq $Path) -and $Overwrite){
            Remove-Item $Path -Recurse -Force
        }
        else{
            if($oc -eq $Path){
                Write-Warning "Installing will overwrite Openshift install at $Path, use -Overwrite parameter to force installation"
            }
            else{
                Write-Warning "Openshift is already installed in path $oc, you are attempting to install in $Path. You may need to remove or change the destination parameter"
            }
            Exit
        }
    }

}
function Get-OCInstall{  
    #Set TLS version to 1.2 so that it is not blocked by proxy
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    #Get Latest Version number for finding the correct github page
    $latestRelease = Invoke-WebRequest https://github.com/openshift/origin/releases/latest -Headers @{"Accept"="application/json"}
    $json = $latestRelease.Content | ConvertFrom-Json
    $latestVersion = $json.tag_name

    #Pull the contents of the latest site and get the windows link, split the full path into array based on "/"
    $winpath = (((Invoke-WebRequest "https://github.com/openshift/origin/releases/tag/$latestVersion" -UseBasicParsing).Links | Where-Object href -match "windows.zip").href).split("/")
    $url = "https://github.com/openshift/origin/releases/download/$latestVersion/$($winpath[$($winpath.Count - 1)])"

    $download_path = "$env:USERPROFILE\Downloads\openshift-master.zip"

    #Download Files from Git
    Invoke-WebRequest -Uri $url -OutFile $download_path
    Get-Item $download_path | Unblock-File
    if(Test-path $download_path){
        Return $download_path
    }
    else{
        Write-Error "Error Downloading files to $download_path"
        Exit
    }
}
function Set-OCEnvPath{
    [CmdletBinding()]
    param(
        $Path
    )
    if(!(Get-Command "oc.exe" -ErrorAction SilentlyContinue)){
        #Set the Environment Variable path Permanently, only installed per user
        $oldpath = (Get-ItemProperty -Path 'HKCU:\Environment' -Name PATH).path
        if($oldpath -notmatch $Path){
            $newpath = "$oldpath;$Path"
            $newpath = $newpath -replace ";;",";"
            Set-ItemProperty -Path 'HKCU:\Environment' -Name PATH -Value $newPath
        }
        #Set the Environment Variable path temporarily needed until restart.
        $oldpath = $env:Path
        if($oldpath -notmatch $Path){
            $newpath = "$oldpath;$Path"
            $newpath = $newpath -replace ";;",";"
            $env:Path = $newpath
        }
    }
}
function Remove-OCInstall{
    [CmdletBinding()]
    param(
        $Path
    )
    if(Test-Path $Path){
        if(Get-ChildItem $Path -Recurse | Where-Object name -eq 'oc.exe'){
            Remove-Item $Path -Force -Recurse
        }
    }
}
#TODO NEED TO PASS DESTINATION TO TEST-OCADMINRIGHTS
if($Admin){$Path = Test-OCAdminRights -Path $Path}

#Need to check where oc is installed if its in a known path we can remove it and the path from the environment variables.
#If it is in an unknown path we should probably only remove the files and leave the env path
#we could consider removing only kubectl and oc.exe will need to think about it more.
if($Uninstall){
     $oc = (Get-Command "oc.exe" -ErrorAction SilentlyContinue).Source -replace "oc.exe" , ""
     if($oc -eq "$env:ProgramFiles\OpenShiftClientTools\"){
        Remove-OCInstall -Path $(Test-OCAdminRights -Path $Path)
        }
     elseif($oc -eq "$($env:USERPROFILE)\Documents\OpenShiftClientTools\"){Remove-OCInstall -Path $Path}
}
else{
    Test-OCInstalled -Path $Path -Overwrite $Overwrite

    $download_path = Get-OCInstall

    #Extract Files, uses User path so that Admin rights are not needed
    if (-not (Test-Path -Path $Path))
    {
        New-Item -Path $Path -ItemType Directory | Out-Null
    }
    Expand-ArchiveInternal -Path $download_path -DestinationPath $Path
    Set-OCEnvPath -Path $Path
}