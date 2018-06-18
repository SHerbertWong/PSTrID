<#
	Copyright (c) 2018 S. Herbert Wong. All rights reserved.
#>

<#
.SYNOPSIS
	Return the number of file type defintions in the current definition file

.DESCRIPTION
	Return the number of file type defintions in the current definition file

.INPUTS
	(None)

.OUTPUTS
	The number of file type defintions in the current definition file

.LINK
	https://github.com/SHerbertWong

.NOTES
	Version:        1.0
	Author:         S. Herbert Wong
	Creation Date:  18/06/2018
	Purpose/Change: Initial release
#>

Function Get-TridDefinitionCount
{
    $Buffer = New-Object -TypeName Text.StringBuilder -ArgumentList 4096

    return [Pontello.PInvoke.TrID]::TrID_GetInfo([Pontello.PInvoke.TrID]::TRID_GET_DEFSNUM, 0, $Buffer)
}
