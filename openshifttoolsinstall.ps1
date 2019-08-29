param(
    [string] $Destination = "$env:USERPROFILE\Documents\OpenShiftClientTools\",
    [switch] $Admin,
    [switch] $Overwrite
)
if(-not ($Destination.EndsWith("\"))){$Destination = $Destination + "\"}
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
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $result = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    if (!($result)){
        Write-Warning "You are not running as Administrator either relaunch as administrator or remove the -Admin Parameter to install in user path"
        Exit
    }
    if($Destination -eq "$($env:USERPROFILE)\Documents\OpenShiftClientTools\"){
        $Destination = "$env:ProgramFiles\OpenShiftClientTools\"
    }
}
function Test-OCInstalled{
    [CmdletBinding()]
    param(
        $Destination,
        $Overwrite
    )
    $oc = (Get-Command "oc.exe" -ErrorAction SilentlyContinue).Source -replace "oc.exe" , ""
    if ($oc) 
    { 
        if($($oc -eq $Destination) -and $Overwrite){
            Remove-Item $Destination -Recurse -Force
        }
        else{
            if($oc -eq $Destination){
                Write-Warning "Installing will overwrite Openshift install at $Destination, use -Overwrite parameter to force installation"
            }
            else{
                Write-Warning "Openshift is already installed in path $oc, you are attempting to install in $destination. You may need to remove or change the path parameter"
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
    $winpath = (((Invoke-WebRequest https://github.com/openshift/origin/releases/tag/$latestVersion).Links | Where-Object href -match "windows.zip").href).split("/")
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
        $Destination
    )
    
    #Set the Environment Variable path Permanently, only installed per user
    $oldpath = (Get-ItemProperty -Path 'HKCU:\Environment' -Name PATH).path
    $newpath = "$oldpath;$Destination"
    $newpath = $newpath -replace ";;",";"
    Set-ItemProperty -Path 'HKCU:\Environment' -Name PATH -Value $newPath

    #Set the Environment Variable path temporarily needed until restart.
    $oldpath = $env:Path
    $newpath = "$oldpath;$Destination"
    $newpath = $newpath -replace ";;",";"
    $env:Path = $newpath
}

if($Admin){Test-OCAdminRights}

Test-OCInstalled -Destination $Destination -Overwrite $Overwrite

$download_path = Get-OCInstall

#Extract Files, uses User path so that Admin rights are not needed
if (-not (Test-Path -Path $Destination))
{
    New-Item -Path $Destination -ItemType Directory | Out-Null
}
Expand-ArchiveInternal -Path $download_path -DestinationPath $Destination
Set-OCEnvPath -Destination $Destination