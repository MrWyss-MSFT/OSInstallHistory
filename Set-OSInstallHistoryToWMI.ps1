# THIS SAMPLE CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# WHETHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# IF THIS CODE AND INFORMATION IS MODIFIED, THE ENTIRE RISK OF USE OR RESULTS IN
# CONNECTION WITH THE USE OF THIS CODE AND INFORMATION REMAINS WITH THE USER.

<#
.Synopsis
    Default mode gathers OS Installation History an outputs it
    CIDiscoveryMode switch creates OS History WMI Class, fills it with OS History data and if succeeded returns Compliant
    RemoveWMIClass removes the WMI Class, defined in the script.
.DESCRIPTION
    Default (script run without switches)
    --------------
    Gathers OS History Information, such as in InstallDate and ReleaseID. Works with Machines that were 
    Upgraded from Win7 to Win8/8.1, Win7 to Win10/11, Win8/8.1 to Win10/11 or not at all. Per OS History entity
    it will create an instance in the custom created WMI Class. e.g. 

    Index InstallDate     CimInstallDate            OS         Version BuildNumber CodeName
    ----- -----------     --------------            --         ------- ----------- --------
    0 20/03/2019 06:36:50 20190320063650.000000+060 Windows 10 1809    17763       Redstone 5 (rs5)
    1 26/05/2019 17:53:49 20190526175349.000000+120 Windows 10 1909    18363       19H1 (19h1)
    2 16/06/2020 23:00:35 20200616230035.000000+120 Windows 10 20H2    19042       Vibranium (vb)
    3 25/02/2021 10:07:11 20210225100711.000000+060 Windows 10 21H1    19043       Vibranium (vb)
    4 05/10/2021 09:49:40 20211005094940.000000+120 Windows 11 21H2    22000       Cobalt (co)
    
    If it was able to do so the script would return Compliant with exit code 0, 
    if not an non zero exit will be return with a short error description
    
    ViewOnly 
    ------------------------------------------
    Outputs an array with OS History details, such as InstallDate and ReleaseID
    Installdate is in CIMDate format

    RemoveWMIClass
    ---------------
    Removes the WMI Class defined in the script. Maybe used if it's not needed anymore, 
    ClassName has been changed orfor Troubleshooting purpose
.NOTES  
    File Name   : Set-OSInstallHistoryToWMI.ps1
    Author      : marius.wyss@microsoft.com
    Version     : 4

.Example
    Set-OSInstallHistoryToWMI.ps1

    Returns Compliant if WMIClass is created, Configure your Compliance Item 
    rule as Compliance: The value returned by the specified script: equals Compliant
.Example
    Set-OSInstallHistoryToWMI.ps1 -ViewOnly
    Returns array of OS History
    
    e.g.
    Index InstallDate     CimInstallDate            OS         Version BuildNumber CodeName
    ----- -----------     --------------            --         ------- ----------- --------
    0 20/03/2019 06:36:50 20190320063650.000000+060 Windows 10 1809    17763       Redstone 5 (rs5)
    1 26/05/2019 17:53:49 20190526175349.000000+120 Windows 10 1909    18363       19H1 (19h1)
    2 16/06/2020 23:00:35 20200616230035.000000+120 Windows 10 20H2    19042       Vibranium (vb)
    3 25/02/2021 10:07:11 20210225100711.000000+060 Windows 10 21H1    19043       Vibranium (vb)
    4 05/10/2021 09:49:40 20211005094940.000000+120 Windows 11 21H2    22000       Cobalt (co)


.Example
    Set-OSInstallHistoryToWMI.ps1 -RemoveWMIClass

    Use this if you change the WMI Class Name, for Troubleshooting or if 
    functionallity is not needed anymore
#>

param(
    [Parameter(Mandatory = $false,
        HelpMessage = "Returns Array with OS History")]
    [switch]$ViewOnly,
    
    [Parameter(Mandatory = $false,
        HelpMessage = "Removes the WMI Class")]
    [switch]$RemoveWMIClass  

)
$ClassName = "CM_OSInstallHistory"

$tbl = @()
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 7"; Version = "NA"; ReleaseID = "NA"; NTVersion = "6.1"; BuildVersion = "7601"; BaseVersion = ""; CodeName = "Windows 7 (win7)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 8"; Version = "NA"; ReleaseID = "NA"; NTVersion = "6.2"; BuildVersion = "9200"; BaseVersion = ""; CodeName = "Windows 8 (win8)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 8.1"; Version = "NA"; ReleaseID = "NA"; NTVersion = "6.3"; BuildVersion = "9600"; BaseVersion = ""; CodeName = "Blue (winblue)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "1507"; ReleaseID = "NA"; NTVersion = "6.3 (10.0)"; BuildVersion = "10240"; BaseVersion = ""; CodeName = "Threshold 1 (th1)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "1511"; ReleaseID = "1511"; NTVersion = "6.3 (10.0)"; BuildVersion = "10586"; BaseVersion = ""; CodeName = "Threshold 2 (th2)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "1607"; ReleaseID = "1607"; NTVersion = "6.3 (10.0)"; BuildVersion = "14393"; BaseVersion = ""; CodeName = "Redstone 1 (rs1)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "1703"; ReleaseID = "1703"; NTVersion = "6.3 (10.0)"; BuildVersion = "15063"; BaseVersion = ""; CodeName = "Redstone 2 (rs2)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "1709"; ReleaseID = "1709"; NTVersion = "6.3 (10.0)"; BuildVersion = "16299"; BaseVersion = ""; CodeName = "Redstone 3 (rs3)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "1803"; ReleaseID = "1803"; NTVersion = "6.3 (10.0)"; BuildVersion = "17134"; BaseVersion = ""; CodeName = "Redstone 4 (rs4)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "1809"; ReleaseID = "1809"; NTVersion = "6.3 (10.0)"; BuildVersion = "17763"; BaseVersion = ""; CodeName = "Redstone 5 (rs5)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "1903"; ReleaseID = "1903"; NTVersion = "6.3 (10.0)"; BuildVersion = "18362"; BaseVersion = ""; CodeName = "19H1 (19h1)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "1909"; ReleaseID = "1903"; NTVersion = "6.3 (10.0)"; BuildVersion = "18363"; BaseVersion = "18352"; CodeName = "19H1 (19h1)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "2004"; ReleaseID = "2004"; NTVersion = "6.3 (10.0)"; BuildVersion = "19041"; BaseVersion = ""; CodeName = "Vibranium (vb)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "20H2"; ReleaseID = "2009"; NTVersion = "6.3 (10.0)"; BuildVersion = "19042"; BaseVersion = "19041"; CodeName = "Vibranium (vb)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "21H1"; ReleaseID = "2009"; NTVersion = "6.3 (10.0)"; BuildVersion = "19043"; BaseVersion = "19041"; CodeName = "Vibranium (vb)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "21H2"; ReleaseID = "2009"; NTVersion = "6.3 (10.0)"; BuildVersion = "19044"; BaseVersion = "19041"; CodeName = "Vibranium (vb)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 10"; Version = "22H2"; ReleaseID = "2009"; NTVersion = "6.3 (10.0)"; BuildVersion = "19045"; BaseVersion = "19041"; CodeName = "Vibranium (vb)" })
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 11"; Version = "21H2"; ReleaseID = "2009"; NTVersion = "6.3 (10.0)"; BuildVersion = "22000"; BaseVersion = "22000"; CodeName = "Sun Valley"})
$tbl += New-Object psobject -Property ([Ordered]@{OS = "Windows 11"; Version = "22H2"; ReleaseID = "2009"; NTVersion = "6.3 (10.0)"; BuildVersion = "22621"; BaseVersion = "22621"; CodeName = "Sun Valley 2"})


#region Helper Functions

Function Get-OsInfoLocation {
    <#
    .SYNOPSIS
      Returns OS Information Registry locations
    .DESCRIPTION
      Returns OS Information Registry locations including the current OS Path. 
    #>
    $OldSearchPath = 'HKLM:\SYSTEM\Setup\Source OS*'
    If (Test-Path $OldSearchPath) {
        $SubKeys = Get-ItemProperty -Path $OldSearchPath -Name "InstallDate" | Sort-Object InstallDate
 
    }
    $CurPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $CurrentReg = Get-Item -Path $CurPath 
    $SubKeys += $CurrentReg
    return $SubKeys
}

function Get-Value() {
    <#
    .SYNOPSIS
      Gets Registry Value
    .DESCRIPTION
      Gets a Registry Value from a given Path and ValueName. If not found it Returns N/A.
    #>

    [OutputType([String])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $RegKeyPath,
        [Parameter(Mandatory = $true)]
        [string] $ValueName
    )
    if (Test-Path -Path $RegKeyPath) {
        try {
            $ret = Get-ItemProperty -Path $RegKeyPath | Select-Object -ExpandProperty $ValueName -ErrorAction Stop
        }
        catch {
            $ret = ""
        }

        If ($ret -ne "") {
            return $ret
        }
        else {
            return "N/A"
        }
    }
}

function Convert-UnixTimeToDateTime() {
    <#
    .SYNOPSIS
      Converts Unix Time to Date Time Format
    .DESCRIPTION
      Converts Unix Time to Date Time Format, helpfull for unixtime read from registry
    #>
    [Alias('cuttdt')]
    [OutputType([datetime])]
    param(
        # int for Unix Time, Seconds that have elapsed since Jan 1 1970
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [int] $unixtime
    )

    return [TimeZone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($unixtime))
}

function ConvertTo-CimDate() {
    <#
  .SYNOPSIS
      Converts TimeDate to CIM Date Format in order to save it to WMI
  .DESCRIPTION
      Converts TimeDate to CIM Date Format in order to save it to WMI, helpfull if it needs to be written to WMI
  #>
    [Alias('ccd')]
    [OutputType([String])]
    param(
        # datetime as input value
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [datetime] $datetime
    )

    $objScriptTime = New-Object -ComObject WbemScripting.SWbemDateTime 
    $objScriptTime.SetVarDate($datetime) 
    $CimDate = $objScriptTime.Value
    return [string] $CimDate
}

function Set-OSHistoryWMIClass() {
    <#
  .SYNOPSIS
      Creates a Custom WMI Class specific for OSHistory
  .DESCRIPTION
      Creates a Custom WMI Class specific for OSHistory with the following Properties ReleaseID, InstallDate and Index
  #>
    [Alias('ccwc')]
    [OutputType([datetime])]
    param(
        # ClassName e.g. CM_OSInstallDateHistory
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [String] $ClassName
    )
    $newClass = New-Object System.Management.ManagementClass("root\cimv2", [String]::Empty, $null); 
    $newClass["__CLASS"] = $ClassName;

    $newClass.Properties.Add("Index", [System.Management.CimType]::UInt16, $false)
    $newClass.Properties["Index"].Qualifiers.Add("key", $true)
    $newClass.Properties["Index"].Qualifiers.Add("read", $true)
    $newClass.Properties["Index"].Qualifiers.Add("Description", "Index 0 is the oldest")

    $newClass.Properties.Add("InstallDate", [System.Management.CimType]::DateTime, $false)
    $newClass.Properties["InstallDate"].Qualifiers.Add("read", $true)
    $newClass.Properties["InstallDate"].Qualifiers.Add("Description", "Original Install Date")
    
    $newClass.Properties.Add("OS", [System.Management.CimType]::String, $false)
    $newClass.Properties["OS"].Qualifiers.Add("read", $true)
    $newClass.Properties["OS"].Qualifiers.Add("Description", "OS Name")

    $newClass.Properties.Add("Version", [System.Management.CimType]::String, $false)
    $newClass.Properties["Version"].Qualifiers.Add("read", $true)
    $newClass.Properties["Version"].Qualifiers.Add("Description", "OS Version")

    $newClass.Properties.Add("BuildNumber", [System.Management.CimType]::String, $false)
    $newClass.Properties["BuildNumber"].Qualifiers.Add("read", $true)
    $newClass.Properties["BuildNumber"].Qualifiers.Add("Description", "OS Build Number")

    $newClass.Put() | out-null
} 
Function Remove-WMIClass {
    try {
        Remove-WmiObject -Class $ClassName -ErrorAction Stop #Delete The whole class
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        #$FailedItem = $_.Exception.ItemName
        "Could not remove WMI Class: $ClassName due to: $ErrorMessage"
        exit 1
    }
}


Function Get-OsInstallInfo {
    <#
    .SYNOPSIS
      Returns OS Install Info array
    .DESCRIPTION
      Returns OS Install Info array with OS information such as InstallDate, OS, BuildNumber
    #>
    $OSInfos = @() #array
    $OsInfoLocations = Get-OsInfoLocation
    
    [uint16]$Count = 0
    
    foreach ($OsLoc in ($OsInfoLocations | Sort-Object Property.InstallDate)) {
        $temp = New-Object -TypeName PSObject
        $temp | Add-Member -Type NoteProperty -Name Index -Value $Count
        $temp | Add-Member -Type NoteProperty -Name InstallDate -Value $(Convert-UnixTimeToDateTime((Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'InstallDate')))
        $temp | Add-Member -Type NoteProperty -Name CimInstallDate -Value $(ConvertTo-CimDate $(Convert-UnixTimeToDateTime((Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'InstallDate'))))
        $temp | Add-Member -Type NoteProperty -Name OS -Value $($tbl | Where-Object BuildVersion -eq ($(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'CurrentBuildNumber'))).OS
        $temp | Add-Member -Type NoteProperty -Name Version -Value $($tbl | Where-Object BuildVersion -eq ($(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'CurrentBuildNumber'))).Version
        $temp | Add-Member -Type NoteProperty -Name BuildNumber -Value $(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'CurrentBuildNumber')
        $temp | Add-Member -Type NoteProperty -Name CodeName -Value $($tbl | Where-Object BuildVersion -eq ($(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'CurrentBuildNumber'))).CodeName
        #$temp | Add-Member -Type NoteProperty -Name ReleaseId -Value $(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'ReleaseId')
        #$temp | Add-Member -Type NoteProperty -Name BuildBranch -Value $(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'BuildBranch')
        #$temp | Add-Member -Type NoteProperty -Name DisplayVersion -Value $(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'DisplayVersion')
        #$temp | Add-Member -Type NoteProperty -Name CompositionEditionID -Value $(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'CompositionEditionID')
        #$temp | Add-Member -Type NoteProperty -Name ProductName -Value $(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'ProductName')
        #$temp | Add-Member -Type NoteProperty -Name CurrentVersion -Value $(Get-Value -RegKeyPath $($OsLoc.PSPath) -ValueName 'CurrentVersion')
        $Count++
        $OSInfos += $temp
    
    }
    return $OSInfos
}
#endregion
function CIMode () {
    <#
  .SYNOPSIS
      Creates a Custom WMI Class specific for OSHistory and returns Compliant for a SCCM  CI Item 
  .DESCRIPTION
      Creates a Custom WMI Class specific for OSHistory, removes it if it is already there, and fill it with the following 
      Properties ReleaseID, InstallDate and Index if all worked Script Exits with 0 and returns Compliant
  #>
   
    #Create Custom WMI Class
    [void](Get-CimClass $ClassName -ErrorAction SilentlyContinue -ErrorVariable wmiclasserror)
    if (!($wmiclasserror)) {
        Remove-WMIClass
    }
    try { Set-OSHistoryWMIClass -ClassName $ClassName }
    catch {
        "Could not create WMI class"
        Exit 1
    }
    
    $OSs = Get-OsInstallInfo

    #Fill create instances for the WMI Class
    ForEach ($OS in $OSs) {
        Try {
            [void](Set-WmiInstance -Path "\\.\root\cimv2:$ClassName" -Arguments @{Index = $OS.Index; InstallDate = $OS.CimInstallDate; OS = $OS.OS; Version = $OS.Version; BuildNumber = $OS.BuildNumber } -ErrorAction stop) 
        }
        Catch {
            "Could not write into WMI class"
            Exit 1
        }
    }
    "Compliant"
    Exit 0
}

#region Business Logic

If ($ViewOnly.IsPresent) {
    Get-OsInstallInfo | Format-Table
}

If (($ViewOnly.IsPresent -eq $false) -and ($RemoveWMIClass.IsPresent -eq $false)) {
    CIMode
}

If ($RemoveWMIClass.IsPresent) {
    Remove-WMIClass
}
#endregion