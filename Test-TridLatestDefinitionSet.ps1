<#
	Copyright (c) 2018 S. Herbert Wong. All rights reserved.
#>

<#

.SYNOPSIS
	Checks if newer file type definitions are available

.DESCRIPTION
	Checks if newer file type definitions are available

.PARAMETER DefinitionFilePath
	Specify the location of the current defintion file

.PARAMETER UpdateDefinitionMd5Uri
	Specify the URI of the definition file MD5 hash

.INPUTS
	(None)

.OUTPUTS
	Whether the current definition file is up-to-date (true/false)

.NOTES
	Version:        1.0
	Author:         S. Herbert Wong
	Creation Date:  18/06/2018
	Purpose/Change: Initial release

.LINK
	https://github.com/SHerbertWong

.EXAMPLE
	Test-TridLatestDefinitionSet
	<Look up, at the default URI, the MD5 hash for the latest definition file and compare it to that of the current definition file at the default location>

.EXAMPLE
	Test-TridLatestDefinitionSet -DefinitionFilePath <path-to-definition-file>
	<Look up, at the default URI, the MD5 hash for the latest definition file and compare it to that of the current definition file at the specified location>

.EXAMPLE
	Install-TridEngineCore -UpdateDefintionMd5Uri <URI>
	<Look up, at the specified URI, the MD5 hash for the latest definition file and compare it to that of the current definition file at the default location>
#>

Function Test-TridLatestDefinitionSet
{
	Param
	(
		[Parameter(Mandatory = $FALSE)]
		[String] $DefinitionFilePath = [PSTrID.Constant]::TridDefsTrdPath,

		[Parameter(Mandatory = $FALSE)]
		[Uri] $UpdateDefinitionMd5Uri = [PSTrID.Constant]::TridDefsTrdMd5Uri
	)

	# Temporary file for the MD5 hash of the latest definition
	$ReturnValue = $FALSE

	if ($ReturnValue = Test-Path -Path $DefinitionFilePath -PathType Leaf)
	{
		$DefinitionMd5String = [PSTrID.Hash]::ToMd5String($DefinitionFilePath)

		$WebClient = New-Object -TypeName Net.WebClient -ErrorAction Stop
		try
		{
			$UpdateDefinitionMd5String = $WebClient.DownloadString($UpdateDefinitionMd5Uri).ToUpper()
		}
		catch
		{
			throw $_.Exception.InnerException.Message
		}

		$ReturnValue = $DefinitionMd5String -eq $UpdateDefinitionMd5String
	}

	return $ReturnValue
}
