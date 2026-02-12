# Author : Madhu Perera
# Summary: Check Secure Boot 2023 Certificate Compliance
# Checks for 2023 Secure Boot certificates (KEK and DB) and validates registry values

# ------------------------------- START -------------------------------

# ______________________________________________________________

[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false

function Get-DeviceDetails
{
	
	$Date_String = Get-Date -Format "dddd dd/MM/yyyy HH:mm:ss"
	$ComputerName = $ENV:COMPUTERNAME
	
	$DeviceDetails = "Script running on the Computer: $ComputerName on $Date_String`n`n"
	return $DeviceDetails

}

function Update-OutputOnExit
{
    param
    (
        [String] $UDF_Value,
        [bool] $ExitCode,
        [String] $Results,
        [String] $Registry_Value
    )

    if ($UDF_Value -and $Registry_Value)
    {
        New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $UDF_Value -PropertyType String -Value $Registry_Value -Force | Out-Null
    }
        
    write-host '<-Start Result->' -ErrorAction SilentlyContinue
    write-host "STATUS=$Results" -ErrorAction SilentlyContinue
    write-host '<-End Result->' -ErrorAction SilentlyContinue
    exit $ExitCode
}

# Function to get registry values
function Get-RegValueOrMissing {
	param (
		[string]$Path,
		[string]$Name
	)

	try {
		if (-not (Test-Path -Path $Path)) {
			return "${Path}:${Name} = <path not present>"
		}

		$value = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop
		return "${Path}:${Name} = $value"
	}
	catch {
		return "${Path}:${Name} = <value not present>"
	}
}

# Function to parse Secure Boot certificates
function Get-SecureBootCertSubjects {
	param(
		[Parameter(Mandatory=$true)]
		[string]$Database
	)
	
	try {
		$db = (Get-SecureBootUEFI -Name $Database).Bytes
		
		$EFI_CERT_X509_GUID = [guid]"a5c059a1-94e4-4aa7-87b5-ab155c2bf072"
		$EFI_CERT_SHA256_GUID = [guid]"c1c41626-504c-4092-aca9-41f936934328"
		
		$signatures = @()
		
		for ($o = 0; $o -lt $db.Length; ) {
			$guid = [Guid][Byte[]]$db[$o..($o+15)]
			$signatureListSize = [BitConverter]::ToUInt32($db, $o+16)
			$signatureSize = [BitConverter]::ToUInt32($db, $o+24)
			$signatureCount = ($signatureListSize - 28) / $signatureSize
			$so = $o + 28
			
			for ($i = 0; $i -lt $signatureCount; $i++) {
				$signatureOwner = [Guid][Byte[]]$db[$so..($so+15)]
				
				if ($guid -eq $EFI_CERT_X509_GUID) {
					$certBytes = $db[($so+16)..($so+16+$signatureSize-1)]
					try {
						$cert = if ($PSEdition -eq "Core") {
							[System.Security.Cryptography.X509Certificates.X509Certificate]::new([Byte[]]$certBytes)
						} else {
							$c = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
							$c.Import([Byte[]]$certBytes)
							$c
						}
						$signatures += [PSCustomObject]@{SignatureOwner=$signatureOwner; SignatureSubject=$cert.Subject; Signature=$cert; SignatureType=$guid}
					} catch {
						$signatures += [PSCustomObject]@{SignatureOwner=$signatureOwner; SignatureSubject="Failed to parse cert"; Signature=$null; SignatureType=$guid}
					}
				} elseif ($guid -eq $EFI_CERT_SHA256_GUID) {
					$sha256Hash = ([Byte[]]$db[($so+16)..($so+47)] | ForEach-Object { $_.ToString('X2') }) -join ''
					$signatures += [PSCustomObject]@{SignatureOwner=$signatureOwner; Signature=$sha256Hash; SignatureType=$guid}
				} else { 
					$unknownData = [Byte[]]$db[($so+16)..($so+16+$signatureSize-1)]
					$signatures += [PSCustomObject]@{SignatureOwner=$signatureOwner; SignatureSubject="Unknown signature type"; Signature=$unknownData; SignatureType=$guid}
				}
				$so += $signatureSize
			}
			$o += $signatureListSize
		}
		
		return $signatures
	}
	catch {
		return $null
	}
}

# Function to perform the comprehensive Secure Boot check
function Confirm-SecureBootCert2023 {
	
	# Define registry paths
	$servicingPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing"
	$rootPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot"

	$servicingValues = @(
		"UEFICA2023Status",
		"WindowsUEFICA2023Capable",
		"UEFICA2023Error",
		"UEFICA2023ErrorEvent"
	)

	$rootValues = @(
		"AvailableUpdates"
	)

	$outputs = New-Object System.Collections.Generic.List[string]

	try {
		# Collect registry values
		$outputs.Add("=== Registry Values ===")
		foreach ($name in $servicingValues) {
			$outputs.Add((Get-RegValueOrMissing -Path $servicingPath -Name $name))
		}

		foreach ($name in $rootValues) {
			$outputs.Add((Get-RegValueOrMissing -Path $rootPath -Name $name))
		}

		# Get Secure Boot certificate values
		$outputs.Add("`n=== Secure Boot Certificate Check ===")
		
		# Get KEK certificates
		$KEKcerts = Get-SecureBootCertSubjects -Database kek
		$KEKVersion = $null
		
		if ($KEKcerts) {
			foreach ($cert in $KEKcerts) {
				$subject = $cert.SignatureSubject
				if ($subject -match 'Microsoft Corporation KEK CA (\d{4})') {
					$KEKVersion = $matches[1]
					break
				}
			}
		}
		
		if (-not $KEKVersion) {
			$KEKVersion = "unknown"
		}
		$outputs.Add("SecureBootKEK = $KEKVersion")
		
		# Get DB certificates
		$DBcerts = Get-SecureBootCertSubjects -Database db
		$DBVersions = @()
		
		if ($DBcerts) {
			foreach ($cert in $DBcerts) {
				$subject = $cert.SignatureSubject
				if ($subject -match 'Microsoft Corporation UEFI CA (\d{4})') {
					$DBVersions += [int]$matches[1]
				}
				elseif ($subject -match 'Microsoft Windows Production PCA (\d{4})') {
					$DBVersions += [int]$matches[1]
				}
			}
		}
		
		if ($DBVersions.Count -gt 0) {
			$DBVersion = ($DBVersions | Measure-Object -Minimum).Minimum.ToString()
		} else {
			$DBVersion = "unknown"
		}
		$outputs.Add("SecureBootDB = $DBVersion")
		
		# Check if DB has Windows UEFI CA 2023
		$DBHas2023 = [bool] ($DBcerts | Where-Object { $_.SignatureSubject -match 'Windows UEFI CA 2023' })
		$outputs.Add("SecureBootDBHas2023 = $($DBHas2023.ToString().ToLower())")
		
		# Validation: Check if all values meet compliance requirements
		$outputs.Add("`n=== Compliance Check ===")
		
		if ($KEKVersion -eq "2023" -and $DBVersion -eq "2023" -and $DBHas2023 -eq $true) {
			$outputs.Add("Status = COMPLIANT")
			$result = @{
				IsCompliant = $true
				Details = ($outputs -join "`n")
			}
		} else {
			$outputs.Add("Status = NON-COMPLIANT")
			$outputs.Add("Reason: KEKVersion=$KEKVersion (expected 2023), DBVersion=$DBVersion (expected 2023), DBHas2023=$($DBHas2023.ToString().ToLower()) (expected true)")
			$result = @{
				IsCompliant = $false
				Details = ($outputs -join "`n")
			}
		}
		
		return $result
	}
	catch {
		$outputs.Add("`n=== ERROR ===")
		$outputs.Add("Error occurred: $($_.Exception.Message)")
		return @{
			IsCompliant = $false
			Details = ($outputs -join "`n")
		}
	}
}


try
{
    $result = Confirm-SecureBootCert2023
    
    if ($result.IsCompliant)
    {
        Update-OutputOnExit -ExitCode $ExitWithNoError -Results $result.Details
    }
    else
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results $result.Details
    } 
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Command was not successful on the device. Error: $($_.Exception.Message)"
}

