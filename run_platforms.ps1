if ($args.count -ge 1) {
	$command = $args[0]
} else {
	Write-Error "Usage: run_platforms.ps1 <command>"
	return -1;
}

$platforms = @("x64", "x86")

$processes = @()

foreach ($platform in $platforms) {
	$processes += Start-Process powershell -NoNewWindow -PassThru -Wait -ArgumentList "$command $platform"
}

$failed = $false
for ($idx = 0; $idx -lt $processes.Count; $idx++) {
	if ($processes[$idx].ExitCode -ne 0) {
		Write-Host "Failed:" $command $platforms[$idx] "=" $processes[$idx].ExitCode
		$failed = $true
	}
}

if ($failed) {
	exit -1
} else {
	exit 0
}
