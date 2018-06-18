Function Install-TridUpdate
{
	Param
	(
		[Parameter(Mandatory = $TRUE)]
		[String] $InstallPath,

		[Parameter(Mandatory = $TRUE)]
		[Uri] $InstallPackageUri,

		[Parameter(Mandatory = $FALSE)]
		[String[]] $InstallFileNameList = @()
	)

	$WebClient = New-Object -TypeName Net.WebClient
	$InstallPackagePath = Join-Path -Path $env:TEMP -ChildPath ([IO.Path]::ChangeExtension("TrID-$([IO.Path]::GetRandomFileName())", 'zip'))

	if (-not (Test-Path -Path $InstallPath -PathType Container))
	{
		New-Item -Path $InstallPath -ItemType Container -ErrorAction Stop > $NULL
	}

	# Download update package
	try
	{
		$WebClient.DownloadFile($InstallPackageUri, $InstallPackagePath)
	}
	catch
	{
		throw $_.Exception.InnerException.Message
	}

	# Extract update content
	try
	{
		$Shell = New-Object -ComObject Shell.Application
		$ZipFile = $Shell.Namespace($InstallPackagePath)
		$InstallFiles = if ($InstallFileNameList.Length -le 0)
		{
			$ZipFile.Items()
		} `
		else
		{
			$ZipFile.Items() | ForEach-Object `
			{
				if ([Array]::IndexOf($InstallFileNameList, $_.Name) -ge 0)
				{
					$_
				}
			}
		}
		$InstallFiles | ForEach-Object `
		{
			$Shell.Namespace($InstallPath).CopyHere($_, 20)
		}
	}
	catch
	{
		throw $_.Exception.Message
	}

	Remove-Item -Path $InstallPackagePath -Force -ErrorAction SilentlyContinue
}
