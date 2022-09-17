# Invoke-AKSH

## SYNOPSIS
Helps in automating various tasks related to managing a VMWare Workstation based lab. 

## DESCRIPTION
This script is a wrapper on vmrun.exe, VMWare Workstation's command-line interface. It uses vmrun.exe to automate performing actions such as start, stop, suspend, snapshots, revert etc. on the entire lab or a single virtual machine.  

## PARAMETERS 
 - action - Mandatory. Action to be performed on the lab / virtual machine. Vaild values are start, stop, suspend, reset, pause, unpause, snapshot and revert.
 - machineName - Optional. Specifies the name of the virtual machine on which the action is to be performed. If no value or "all" is specified, the specified action will be performed on the entire lab.

## NOTES
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
 ## INSTRUCTIONS TO EXECUTE
 - Import Invoke-AKSH.ps1 - `. .\Invoke-AKSH.ps1`
 - See command help - `Get-Help Invoke-AKSH -Full`
 - Follow the examples.

 ## EXAMPLES
  
 - `PS> Invoke-AKSH -action start`
 - `PS> Invoke-AKSH -action snapshot -machineName all`
 - `PS> Invoke-AKSH -action revert -machineName Sample-VM`

## LINKS
 - https://yaksas.in
 - https://github.com/yaksas443/Invoke-AKSH
 - https://ellitedevs.in/invoke-aksh-and-easily-manage-your-local-lab/
