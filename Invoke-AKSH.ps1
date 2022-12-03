function Invoke-AKSH
{
<#
  .SYNOPSIS
  Helps in automating various tasks related to managing a VMWare Workstation based lab. 

  .DESCRIPTION
  This script is a wrapper on vmrun.exe, VMWare Workstation's command-line interface. It uses vmrun.exe to automate performing actions such as start, stop, suspend, snapshots, revert etc. on the entire lab or a single virtual machine.  

  .PARAMETER action
  Action to be performed on the lab / virtual machine. Vaild values are start, stop, suspend, reset, pause, unpause, snapshot and revert.

  .PARAMETER machineName
  Optional parameter. Specifies the name of the virtual machine on which the action is to be performed. If no value or "all" is specified, the specified action will be performed on the entire lab.

  .INPUTS
  None. You cannot pipe objects to Invoke-AKSH.ps1.

  .Notes
  Place this script in the folder containing lab virtual machines. It expects the following hierarchy:

    SAMPLE-LAB -> (Place the script here)
        - LAB-VM1
            - LAB-VM1.vmx
        - LAB-VM2
            - LAB-VM2.vmx
        - LAB-VM3
            - LAB-VM3.vmx
        - LAB-VM4
            - LAB-VM4.vmx
        ....
 

  .EXAMPLE
  PS> Invoke-AKSH -action start

  .EXAMPLE
  PS> Invoke-AKSH -action snapshot -machineName all

  .EXAMPLE
  PS> Invoke-AKSH -action revert -machineName Sample-VM

  .LINK
  https://yaksas.in
  https://github.com/yaksas443/Invoke-AKSH
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$action,
    [string]$machineName = "all"
)

function perform_action {
    param (
        [string]$action,
        [string]$vmxFilename,
        [string]$snapshotName
    )

    vmrun -T ws $action $vmxFilename $snapshotName
}

function check_previousSnapshot {
    param (
        [string]$vmxFilename
    )
    $snapshotName = ""
    Write-Host "[+] Checking if previous snapshot exists."
    $prevSnapshot = perform_action -action "listsnapshots" -vmxFilename $vmxFilename -snapshotName "" | Select-String "Total snapshots:" | Out-String
    $snapshotCount = [int]$($prevSnapshot.substring(19,1))
    if ($snapshotCount -gt 0) {
        $dirName = $dir.Name -replace "\(" , "\("
        $dirName = $dirName -replace "\)" , "\)"
        $prevSnapshotName = perform_action -action "listsnapshots" -vmxFilename $vmxFilename -snapshotName "" | Select-String -Pattern ($dirName) | Select-Object -First 1 | Out-String
        $prevSnapshotName = $($prevSnapshotName.TrimEnd())
        $prevSnapshotName = $($prevSnapshotName.TrimStart())
        Write-Host "[+] Snapshot found for :"$($dir.Name)
        Write-Host "[+] Snapshot name is :"$prevSnapshotName
        $snapshotName = $prevSnapshotName
    }
    else {
        Write-Host "[+] Previous snapshot does not exist"
    }
    $snapshotName
}

$action =  $action.ToLower()
$dirList = ""

if ($machineName.ToUpper() -eq "ALL" -or $machineName -eq "")
{
    $dirList = Get-ChildItem -Directory | select name
}
else {
    $dirList = Get-ChildItem -Directory -Filter $machineName | select name
}

if ($action -ne "start" -and $action -ne "stop" -and $action -ne "suspend" -and $action -ne "pause" -and $action -ne "unpause" -and $action -ne "reset" -and $action -ne "snapshot" -and $action -ne "revert") {
    Write-Host "[-] This action is not supported. Please choose from one of the following: start, stop, suspend, pause, unpause, snapshot, reverttosnapshot."
}
else {
    foreach($dir in $dirList) {
        $vmxFile = $null
        $vmxFile = Get-ChildItem .\$($dir.Name)\ -Filter "*.vmx" | select name
        if ($vmxFile.Name.length -gt 0)
            {
                $snapshotName = ""
                if ($action -eq "snapshot"){
                    $snapshotName = $($dir.Name)+"_"+$(Get-Date -Format "MM-dd-yyyy-HH-mm")
                    $prevSnapshotName = check_previousSnapshot -vmxFilename .\$($dir.Name)\$($vmxFile.Name)
                    if ($prevSnapshotName.length -gt 0) {
                        Write-Host "[+] Deleting previous snapshot"
                        perform_action -action "deletesnapshot" -vmxFilename .\$($dir.Name)\$($vmxFile.Name) -snapshotName $($prevSnapshotName.Trim())
                    }
                }
                if ($action -eq "revert" -or $action -eq "reverttosnapshot"){
                    $action = "reverttosnapshot"
                    $prevSnapshotName = check_previousSnapshot -vmxFilename .\$($dir.Name)\$($vmxFile.Name)
                    if ($prevSnapshotName.length -gt 0) {
                        $snapshotName = $prevSnapshotName
                    }
                }
                Write-Host "[+] Performing action"$action" on VM "$($dir.Name)
                if (($action -eq "revert" -or $action -eq "reverttosnapshot") -and $prevSnapshotName.length -eq 0)
                {
                    Write-Host "[-] Unable to perform revert operation. There is no snapshot to revert to."
                }
                else {
                    perform_action -action $action -vmxFilename .\$($dir.Name)\$($vmxFile.Name) -snapshotName $snapshotName
                }
                
                
            }
        
    } 
}
}
