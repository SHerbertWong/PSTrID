#REQUIRES -version 2.0

# See "Determine if current PowerShell Process is 32-bit or 64-bit?": https://stackoverflow.com/a/8588982
if ([IntPtr]::size -ne 4)
{
	throw "only 32-bit Windows and WoW64 are currently supported"
}

if ($__MODULE_PSTrid) {exit}

New-Variable -Name '__MODULE__PSTrid' -Value $TRUE -Option Constant -Scope Global -Force

# C# functions, classes and constants for this module
@'
	namespace PSTrID
	{
		public class Constant
		{
			public const string TridRootPath = @"%TRIDROOTPATH%";
			public const string TridLibDllFileName = @"%TRIDLIBDLLFILENAME%";
			public const string TridLibDllPath = @"%TRIDLIBDLLPATH%";
			public const string TridLibDllZipUri = @"%TRIDLIBDLLURI%";
			public const string TridDefsTrdFileName = @"%TRIDDEFSTRDFILENAME%";
			public const string TridDefsTrdPath = @"%TRIDDEFSTRDPATH%";
			public const string TridDefsTrdZipUri = @"%TRIDDEFSTRDZIPURI%";
			public const string TridDefsTrdMd5Uri = @"%TRIDDEFSTRDMD5URI%";
		}

		public class Result
		{
			public readonly string Description;
			public readonly string Extension;
			public readonly int PointValue;

			public Result(string description, string extension, int pointValue)
			{
				Description = description;
				Extension = extension;
				PointValue = pointValue;
			}
		}

		public class Version
		{
			public readonly int Major;
			public readonly int Minor;

			public Version(int version)
			{
				Major = version / 100;
				Minor = version % 100;
			}
		}

		public class Hash
		{
			public static string ToMd5String(string path)
			{
				byte[] fileBytes = System.IO.File.ReadAllBytes(path);

				System.Security.Cryptography.MD5 md5 = System.Security.Cryptography.MD5.Create();
				byte[] md5Bytes = md5.ComputeHash(fileBytes);

				string ReturnValue = "";
				foreach (byte md5Byte in md5Bytes)
				{
					ReturnValue += md5Byte.ToString("X");
				}

				return ReturnValue;
			}
		}
	}
'@ | `
ForEach-Object `
{
	$Definition = $_ | `
			ForEach-Object {$_ -replace '%TRIDROOTPATH%', (Join-Path -Path $PSScriptRoot -ChildPath 'TridLib')} | `
			ForEach-Object {$_ -replace '%TRIDLIBDLLFILENAME%', 'TrIDLib.dll'} | `
			ForEach-Object {$_ -replace '%TRIDLIBDLLPATH%', (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'TridLib') -ChildPath 'TrIDLib.dll')} | `
			ForEach-Object {$_ -replace '%TRIDLIBDLLURI%' , "http://mark0.net/download/tridlib-free.zip"} | `
			ForEach-Object {$_ -replace '%TRIDDEFSTRDFILENAME%', 'triddefs.trd'} | `
			ForEach-Object {$_ -replace '%TRIDDEFSTRDPATH%', (Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'TridLib') -ChildPath 'triddefs.trd')} | `
			ForEach-Object {$_ -replace '%TRIDDEFSTRDZIPURI%', "http://mark0.net/download/triddefs.zip"} | `
			ForEach-Object {$_ -replace '%TRIDDEFSTRDMD5URI%', "http://mark0.net/download/triddefs.trd.md5"}

	Add-Type -TypeDefinition $Definition
}

# Initialise PowerShell functions and cmdlets provided by this module
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath '*.ps1') | Foreach-Object {. $_.FullName}

$TrIDLibDllPath = ""
# Determine if a TrID core library download is needed
if (Test-Path -Path ([PSTrID.Constant]::TridLibDllPath))
{
	$TrIDLibDllPath = [PSTrID.Constant]::TridLibDllPath
}
else
{
	$TrIDLibDllPath = Install-TridEngineCore
}

# PInvoke for the unmanaged TrID core library
# Note: Code partially adapted from Pontello's sample C# source
@'
	// Constants FOR TrID_GetInfo
	public const int TRID_GET_RES_NUM = 1; // Get the number of results available
	public const int TRID_GET_RES_FILETYPE = 2; // Filetype descriptions
	public const int TRID_GET_RES_FILEEXT = 3; // Filetype extension
	public const int TRID_GET_RES_POINTS = 4; // Matching points
	public const int TRID_GET_VER = 1001; // TrIDLib version (major * 100 + minor)
	public const int TRID_GET_DEFSNUM = 1004; // Number of filetypes definitions loaded

	// Additional constants for the full version
	public const int TRID_GET_DEF_ID = 100; // Get the id of the filetype's definition for a given result
	public const int TRID_GET_DEF_FILESCANNED = 101; // Various info about that def
	public const int TRID_GET_DEF_AUTHORNAME = 102;
	public const int TRID_GET_DEF_AUTHOREMAIL = 103;
	public const int TRID_GET_DEF_AUTHORHOME = 104;
	public const int TRID_GET_DEF_FILE = 105;
	public const int TRID_GET_DEF_REMARK = 106;
	public const int TRID_GET_DEF_RELURL = 107;
	public const int TRID_GET_DEF_TAG = 108;
	public const int TRID_GET_DEF_MIMETYPE = 109;
	public const int TRID_ISTEXT = 1005; // Check if the submitted file is text or binary one

	[DllImport(@"%TRIDLIB%", CharSet = CharSet.Ansi)]
	public static extern int TrID_LoadDefsPack
	(
		string Path
	);

	[DllImport(@"%TRIDLIB%", CharSet = CharSet.Ansi)]
	public static extern int TrID_SubmitFileA
	(
		string Filename
	);

	[DllImport(@"%TRIDLIB%", CharSet = CharSet.Ansi)]
	public static extern int TrID_Analyze
	(
	);

	[DllImport(@"%TRIDLIB%", CharSet = CharSet.Ansi)]
	public static extern int TrID_SetDefsPack
	(
		int DefsPtr
	);

	[DllImport(@"%TRIDLIB%", CharSet = CharSet.Ansi)]
	public static extern int TrID_GetInfo
	(
		int InfoType,
		int InfoIdx,
		StringBuilder TrIDRes
	);
'@ | `
ForEach-Object `
{
	$Definition = $_ -replace '%TRIDLIB%', $TrIDLibDllPath
	Add-Type -MemberDefinition $Definition -Name TrID -Namespace Pontello.PInvoke -Using System.Text
}

if (Test-Path -Path ([PSTrID.Constant]::TridDefsTrdPath))
{
	[Pontello.PInvoke.TrID]::TrID_LoadDefsPack([PSTrID.Constant]::TridRootPath) > $NULL
}
else
{
	# Get the latest file type definitions for the TrID core
	Update-TridDefinitionSet
}
