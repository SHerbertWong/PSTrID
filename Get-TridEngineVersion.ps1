<#
	Copyright (c) 2018 S. Herbert Wong. All rights reserved.
#>

<#
.SYNOPSIS
	Return the version number of the TrID core library in an object

.DESCRIPTION
	Return the version number of the TrID core library in an object

.INPUTS
	(None)

.OUTPUTS
	The version number of the TrID core library in an object

.LINK
	https://github.com/SHerbertWong

.NOTES
	Version:        1.0
	Author:         S. Herbert Wong
	Creation Date:  18/06/2018
	Purpose/Change: Initial release
#>

Function Get-TridEngineVersion
{
    $Buffer = New-Object -TypeName Text.StringBuilder -ArgumentList 4096
    $RawVersionValue = [Pontello.PInvoke.TrID]::TrID_GetInfo([Pontello.PInvoke.TrID]::TRID_GET_VER, 0, $Buffer)

    return New-Object -TypeName PSTrID.Version -ArgumentList $RawVersionValue
}
