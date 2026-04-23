if ($null -eq (Get-PSResourceRepository -Name output)) {
    Register-PSResourceRepository -Name output -Uri C:\src\PSUConfig\output -Trusted
}
Set-PSUSetting -PasswordExpirationDays 360
