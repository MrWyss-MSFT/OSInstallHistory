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
    Upgraded from Win7 to Win8/8.1, Win7 to Win10, Win8/8.1 to Win10 or not at all. Per OS History entity
    it will create an instance in the custom created WMI Class. e.g. 

    InstallDate               ReleaseId Index
    -----------               --------- -----
    20151114143823.000000+060 1511          0
    20160802202109.000000+120 1607          1
    20170407184532.000000+120 1703          2
    
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
    Version     : 2
    ChangeLog   : Win10 RTM to report back 1507 instead of ProductName

.Example
    Set-OSInstallHistoryToWMI.ps1

    Returns Compliant if WMIClass is created, Configure your Compliance Item 
    rule as Compliance: The value returned by the specified script: equals Compliant
.Example
    Set-OSInstallHistoryToWMI.ps1 -ViewOnly
    Returns array of OS History
    
    e.g.
    InstallDate               ReleaseId Index
    -----------               --------- -----
    20151114143823.000000+060 1511          0
    20160802202109.000000+120 1607          1
    20170407184532.000000+120 1703          2
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

# If Changed MOF file needs to be corrected accodingly
$ClassName = "CM_OSInstallHistory"

#############
# Functions #
#############

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

function Convert-CimDate() {
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

function Get-InstallDateAsCIMDate() {
    <#
  .SYNOPSIS
      Returns the InstallDate regkey as Cim Date of a given RegKey Path
  .DESCRIPTION
      Returns the InstallDate regkey as Cim Date of a given RegKey Path, Convert-CimDate and Convert-UnixTimeToDateTime required
  #>
    [Alias('gidc')]
    [OutputType([String])]
    param(
        # Regkey String e.g. "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string] $RegKeyPath
    )

    $Value = "InstallDate"
    try {
        $InstallDate = (Get-ItemProperty -Path $RegKeyPath | Select-Object -ExpandProperty $Value -ErrorAction Stop)
    }
    catch {
        $InstallDate = 0
    }
    return $(Convert-CimDate -date $(Convert-UnixTimeToDateTime -unixtime $InstallDate))
}
 
function Get-ReleaseID() {
    <#
  .SYNOPSIS
      Returns ReleaseID of Win10, ProductName + CSDVersion of Win7, ProductName of Win8/8.1
  .DESCRIPTION
      Returns ReleaseID of Win10, ProductName + CSDVersion of Win7, ProductName of Win8/8.1
  #>
    [Alias('grid')]
    [OutputType([String])]
    param(
        # Regkey String e.g. "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string] $RegKeyPath
    )

    $value = "ReleaseID"
    if (Test-Path -Path $RegKeyPath) {
        # Try to get ReleaseID Win10 only
        try {
            $ReleaseID = Get-ItemProperty -Path $RegKeyPath | Select-Object -ExpandProperty "ReleaseID" -ErrorAction Stop
        }
        catch {
            $ReleaseID = ""
        }

        # Try to get ProductName all OSs
        try {
            $ProductName = Get-ItemProperty -Path $RegKeyPath | Select-Object -ExpandProperty "ProductName" -ErrorAction Stop 
        }
        catch {
            $ProductName = ""
        }

        # Try to get CSDVersion Win7 only
        try {
            $CSDVersion = Get-ItemProperty -Path $RegKeyPath | Select-Object -ExpandProperty "CSDVersion" -ErrorAction stop 
        }
        catch {
            $CSDVersion = ""
        }
  
        # Win10 1511 and higher
        If ($ReleaseID -ne "") {
            return $ReleaseID
        }
  
        # Win8/8.1 and Win10 1507
        elseif ($ReleaseID -eq "" -and $CSDVersion -eq "" -and $ProductName -ne "") {
            if ($ProductName -like "Windows 10*") {
                return "1507"
            } else {
                return $ProductName
            }
        }

        # Win7
        elseif ($ReleaseID -eq "" -and $CSDVersion -ne "" -and $ProductName -ne "") {
            return "$ProductName $CSDVersion"
        }
        # Error
        else {
            return "Error Getting ReleaseID"
        }
    }
}

function Get-OSInstallDates() {
    <#
  .SYNOPSIS
      Return an Object with OS History Information
  .DESCRIPTION
      Return an Object with InstallDates as CIM-Date, ReleaseID as String, Index as uint16 of each OS that was Installed sorted by Date
  #>
    [OutputType([Object[]])]

    $InstallDates = @()
    [uint16]$Count = 0

    # Machine was Upgraded Win7 to Win8/8.1, Win7 to Win10, Win8/8.1 to Win10
    If (Test-Path 'HKLM:\SYSTEM\Setup\Source OS*') {
        $SubKeys = Get-ItemProperty -Path 'HKLM:\SYSTEM\Setup\Source OS*' -Name "InstallDate" | Sort-Object InstallDate
 
        ForEach ($SubKey in $SubKeys) {
            $temp = New-Object -TypeName PSObject
            $temp | Add-Member -Type NoteProperty -Name InstallDate -Value $(Get-InstallDateAsCIMDate -RegKeyPath $SubKey.PSPath)
            $temp | Add-Member -Type NoteProperty -Name ReleaseId -Value $(Get-ReleaseID -RegKeyPath $SubKey.PSPath)
            $temp | Add-Member -Type NoteProperty -Name Index -Value $Count

            $InstallDates += $temp

            $Count++
        }
    }
    #Current OS 
    $CurPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    If (Test-Path -Path $CurPath) {
        $temp = New-Object -TypeName PSObject
        $temp | Add-Member -Type NoteProperty -Name InstallDate -Value $(Get-InstallDateAsCIMDate -RegKeyPath $CurPath)
        $temp | Add-Member -Type NoteProperty -Name ReleaseId -Value $(Get-ReleaseID -RegKeyPath $CurPath)
        $temp | Add-Member -Type NoteProperty -Name Index -Value $Count

        $InstallDates += $temp
    }
    return $InstallDates
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

    $newClass.Properties.Add("ReleaseID", [System.Management.CimType]::String, $false)
    $newClass.Properties["ReleaseID"].Qualifiers.Add("key", $true)
    $newClass.Properties["ReleaseID"].Qualifiers.Add("read", $true)
    $newClass.Properties["ReleaseID"].Qualifiers.Add("Description", "OS Release ID")

    $newClass.Properties.Add("InstallDate", [System.Management.CimType]::DateTime, $false)
    $newClass.Properties["InstallDate"].Qualifiers.Add("read", $true)
    $newClass.Properties["InstallDate"].Qualifiers.Add("Description", "Original Install Date")

    $newClass.Properties.Add("Index", [System.Management.CimType]::UInt16, $false)
    $newClass.Properties["Index"].Qualifiers.Add("read", $true)
    $newClass.Properties["Index"].Qualifiers.Add("Description", "Index 0 is the oldest")

    $newClass.Put() | out-null
}

function CIMode () {
    <#
  .SYNOPSIS
      Creates a Custom WMI Class specific for OSHistory and returns Compliant for a SCCM  CI Item 
  .DESCRIPTION
      Creates a Custom WMI Class specific for OSHistory, removes it if it is already there, and fill it with the following 
      Properties ReleaseID, InstallDate and Index if all worked Script Exits with 0 and returns Compliant
  #>
   
    #Create Custom WMI Class
    [void](Get-WMIObject $ClassName -ErrorAction SilentlyContinue -ErrorVariable wmiclasserror)
    if ($wmiclasserror) {
        try { Set-OSHistoryWMIClass -ClassName $ClassName }
        catch {
            "Could not create WMI class"
            Exit 1
        }
    }
    Get-WmiObject $ClassName | Remove-WmiObject

    $OSs = Get-OSInstallDates

    #Fill create instances for the WMI Class
    ForEach ($OS in $OSs) {
        Try { [void](Set-WmiInstance -Path "\\.\root\cimv2:$ClassName" -Arguments @{InstallDate = $OS.InstallDate; ReleaseId = $OS.ReleaseId; Index = $OS.Index} -ErrorAction stop) 
        }
        Catch {
            "Could not write into WMI class"
            Exit 1
        }
    }
    "Compliant"
    Exit 0
}


#Parse cmdlet switches
If ($ViewOnly.IsPresent -eq $false) {
    CIMode
} 
elseif ($RemoveWMIClass.IsPresent) {
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
else {
    Get-OSInstallDates
}