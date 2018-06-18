<#
	Copyright (c) 2018 S. Herbert Wong. All rights reserved.
#>

<#
.SYNOPSIS
	Downloads, installs (if -permanent is specified) and loads the TrID file type definition file

.DESCRIPTION
	Downloads, installs (if -permanent is specified) and loads the TrID file type definition file

.PARAMETER UpdateDefinitionZipUri
	Specify the URI for the TrID file type definition package download

.PARAMETER Permanent
	Instruct the cmdlet to install TrID file type definition file to the module's subdirectory

.INPUTS
	(None)

.OUTPUTS
	The number file type definitions loaded

.NOTES
	Version:        1.0
	Author:         S. Herbert Wong
	Creation Date:  18/06/2018
	Purpose/Change: Initial release

.LINK
	https://github.com/SHerbertWong

.EXAMPLE
	Update-TridDefinitionSet
	<Download the file type definition package from the default URI and then load it>

.EXAMPLE
	Update-TridDefinitionSet -Permanent
	<Download the file type definition package from the default URI, install it to the module's subdirectory and then load it>

.EXAMPLE
	Update-TridDefinitionSet -UpdateDefintionZipUri <URI>
	<Download the file type definition package from <URI> and then install it to the module's subdirectory>
#>

Function Update-TridDefinitionSet
{
	Param
	(
		[Parameter(Mandatory = $FALSE)]
		[Uri] $UpdateDefintionZipUri = [PSTrID.Constant]::TridDefsTrdZipUri,

		[Parameter(Mandatory = $FALSE)]
		[Switch] $Permanent
	)

	$DefinitionDirectoryPath = if ($Permanent)
	{
		[PSTrID.Constant]::TridRootPath
	} `
	else
	{
		Join-Path -Path $env:TEMP -ChildPath ([IO.Path]::GetRandomFileName())
	}

	if (-not (Test-Path -Path $DefinitionDirectoryPath))
	{
		New-Item -Path $DefinitionDirectoryPath -ItemType Container -Force -ErrorAction Stop > $NULL
	}

	Install-TridUpdate -InstallPath $DefinitionDirectoryPath -InstallPackageUri $UpdateDefintionZipUri -InstallFileNameList ([PSTrID.Constant]::TridDefsTrdFileName)

	[Pontello.PInvoke.TrID]::TrID_LoadDefsPack($DefinitionDirectoryPath)

	if (-not $Permanent)
	{
		Remove-Item -Path $DefinitionDirectoryPath -Recurse -Force -ErrorAction SilentlyContinue
	}
}
