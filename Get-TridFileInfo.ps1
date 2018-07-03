<#
	Copyright (c) 2018 S. Herbert Wong. All rights reserved.
#>

<#
.SYNOPSIS
	Provides weighted guesses of the type of a given file 

.DESCRIPTION
	Provides weighted guesses of the type of a given file 

.PARAMETER Path
	(Mandatory) The path of the file to analyse

.INPUTS
	(None)

.OUTPUTS
	Guesses of the type of the file specified ranked by PointValue (larger = more likely)

.NOTES
	Version:        1.0
	Author:         S. Herbert Wong
	Creation Date:  18/06/2018
	Purpose/Change: Initial release

.LINK
	https://github.com/SHerbertWong

.EXAMPLE
	Get-TridFileInfo <path-to-a-file>
	<Return a list of file types based on likeliness (from the most likely to the least likely>
#>

Function Get-TridFileInfo
{
	Param
	(
		[Parameter(Mandatory = $TRUE, Position = 0)]
		[String] $Path
	)

	# Normalise $Path
	$FullPath = if ([IO.Path]::IsPathRooted($Path))
	{
		[IO.Path]::GetFullPath($Path)
	} `
	else
	{
		[IO.Path]::GetFullPath((Join-Path -Path (Get-Location).Path -ChildPath $Path))
	}

	$Buffer = New-Object -TypeName Text.StringBuilder -ArgumentList 4096

	if (([Pontello.PInvoke.TrID]::TrID_SubmitFileA($FullPath)) -eq 0)
	{
		if (-not (Test-Path -Path $FullPath))
		{
			throw "`"$Path`" not found"
		}
		else
		{
			throw "fatal error while accessing `"$Path`""
		}
	}

	if (([Pontello.PInvoke.TrID]::TrID_Analyze()) -eq 0)
	{
		throw "fatal error while analysing `"$Path`""
	}

	$NumberOfResults = [Pontello.PInvoke.TrID]::TrID_GetInfo(1, 0, $Buffer)
	$Results = @()

	for ($i = 1; $i -le $NumberOfResults; $i++)
	{
		$TridResFileType = ""
		$TridResFileExt = ""
		$TridResPointValue = 0

		[Pontello.PInvoke.TrID]::TrID_GetInfo([Pontello.PInvoke.TrID]::TRID_GET_RES_FILETYPE, $i, $Buffer) > $NULL
		$TridResFileType = $Buffer.ToString()

		[Pontello.PInvoke.TrID]::TrID_GetInfo([Pontello.PInvoke.TrID]::TRID_GET_RES_FILEEXT, $i, $Buffer) > $NULL
		$TridResFileExt = $Buffer.ToString()

		$TridResPointValue = [Pontello.PInvoke.TrID]::TrID_GetInfo([Pontello.PInvoke.TrID]::TRID_GET_RES_POINTS, $i, $Buffer)

		$Results += New-Object -TypeName PSTrID.Result -ArgumentList $TridResFileType, $TridResFileExt, $TridResPointValue
	}

	return $Results | Sort-Object -Property PointValue -Descending
}
