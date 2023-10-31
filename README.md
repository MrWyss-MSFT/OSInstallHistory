# Introduction

> seems like Win11 23H2 does not create the Setup key for the previous version anymore. So this is not working anymore. I will try to find a solution for this.

Windows (10/11) in-place Upgrades change/overrides Win32_OperatingSystem.InstallDate. (Original Install Date)
This makes it hard to find the original installation date or to see the history of in-place upgrades performed on your Win10/11 machines.

It turns out that in-place Upgrades process does make a copy of Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion to Computer\HKEY_LOCAL_MACHINE\SYSTEM\Setup (Source OS + Date).

This **Framework**, consisting of a PowerShell script, a mof file and RDL Files (Reports) will help you to gather all the OS’s previously and currently installed on the machine via a ConfigMgr/SCCM Configuration Item/Baseline.

The PowerShell script (Set-OSInstallHistoryToWMI.ps1) is meant to be a discovery script of a Compliance Item. It will create a WMI instance with all reviously and currently installed Feature Updates including their installation date. The MOF file is the wmi class defintion that allows you to gather the information with a hardware inventory cycle.

## Getting Started

## Standalone Script

To quickly check on a client how many and when In-Place Upgrades have been performed, you can run the script standalone.

```powershell
./Set-OSInstallHistoryToWMI.ps1 -ViewOnly
```

![Alt text](/res/StandAloneScript.png "Stand Alone Script")

### Compliance Item

Create a Compliance Item. Give it a meaningful name and description.
Edit Script, set the script language to PowerShell and browse to Set-OSinstallHistoryToWMI.ps1

On the compliance rule setting, set change it to equals compliant

![Alt text](/res/CI_Rule.png "CI Rule")

Add this CI to a Baseline and deploy it to a collection.

### WMI Class to Hardware Inventory

Goto \Administration\Overview\Client Settings and edit your client setting.
Under Hardware Inventory -> Set Classes, import the WMIOSInstallDates.mof file

![Alt text](/res/Hinv_MOF_import.png "Hinv MOF import")

### Gathering Data

Two things need to run now. A Hardware Inventory Scan and the Baseline evaluation on the clients.
Once that is done you should see on the clients Resource Explorer properties a section OS history
with at least one entry (index, Install Date, Release ID)

![Alt text](/res/ResourceExplorer_example.png "Resource Explorer")

### Reporting

In order to use the reports, open den RDL Files with Report Builder for SQL Server,
change the DateSource to your SCCM SSRS Date Source and save it to the SSRS Location.

#### Initial OS Install Date

This will list the initial Install Date of the machines by a given collection.

![Alt text](/res/Initial_OS_Install_Date.jpg "Initial OS Install Date Report")
Reporting\SSRS\OS_Initial_Install_Date.rdl

#### Install Dashboard for machine

Shows details of Current OS, OS History, Partitioning, HW Details, etc.. of a given computer

![Alt text](/res/OS_Install_Dashboard_for_machine.PNG "OS install Dashboard for machine")
Reporting\SSRS\Computer_Install_Dates.rdl

## TODO

- [ ] Spellchecking, Wording and Validation
- [ ] More Reports
- [ ] Tests

## Contribute

Let me know, create issues or PR's
