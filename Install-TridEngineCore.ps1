<#
	Copyright (c) 2018 S. Herbert Wong. All rights reserved.
#>

<#
.SYNOPSIS
	Downloads and installs the TrID core library to a temporary location in $env:TEMP or to the module's subdirectory (if -permanent is specified)

.DESCRIPTION
	Downloads and installs the TrID core library to a temporary location in $env:TEMP or to the module's subdirectory (if -permanent is specified)

.PARAMETER InstallEngineZipUri
	Specify the URI for the TrID core library package download

.PARAMETER Permanent
	Instruct the cmdlet to install TrID core library DLL to the module's subdirectory

.INPUTS
	(None)

.OUTPUTS
	The location of the installed TrID core library DLL file

.NOTES
	Version:        1.0
	Author:         S. Herbert Wong
	Creation Date:  18/06/2018
	Purpose/Change: Initial release

.LINK
	https://github.com/SHerbertWong

.EXAMPLE
	Install-TridEngineCore
	<Download the TrID core package from the default URI and then install it to a temporary location in $env:TEMP>

.EXAMPLE
	Install-TridEngineCore -Permanent
	<Download the TrID core package from the default URI and then install it to the module's subdirectory>

.EXAMPLE
	Install-TridEngineCore -InstallEngineZipUri <URI>
	<Download the TrID core package from <URI> and then install it to a temporary location in $env:TEMP>
#>

Function Install-TridEngineCore
{
	Param
	(
		[Parameter(Mandatory = $FALSE)]
		[Uri] $InstallEngineZipUri = [PSTrID.Constant]::TridLibDllZipUri,

		[Parameter(Mandatory = $FALSE)]
		[Switch] $Permanent
	)

	$EngineDirectoryPath = if ($Permanent)
	{
		[PSTrID.Constant]::TridRootPath
	} `
	else
	{
		Join-Path -Path $env:TEMP -ChildPath ([IO.Path]::GetRandomFileName())
	}
	
	if (-not (Test-Path -Path $EngineDirectoryPath))
	{
		New-Item -Path $EngineDirectoryPath -ItemType Container -Force -ErrorAction Stop > $NULL
	}

	Install-TridUpdate -InstallPath $EngineDirectoryPath -InstallPackageUri $InstallEngineZipUri -InstallFileNameList ([PSTrID.Constant]::TridLibDllFileName)

	return (Join-Path -Path $EngineDirectoryPath -ChildPath ([PSTrID.Constant]::TridLibDllFileName))
}
