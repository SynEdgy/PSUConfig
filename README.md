# PSUConfig

PowerShell Universal Instance Configuration

## Usage

Create a file named `secret.local.ps1 at the root of your project with the
following content.  
This file is ignored by git and can be used to store secrets for local
development for development purposes. You can set the Universal Server URL
and App Token in this file to allow the build script to publish modules directly
to your Universal Automation instance.

```powershell
#./secret.local.ps1
$Env:UniversalServerUrl = 'http://localhost:5000'
Write-Warning -Message ('Importing secret. Universal URL: {0}' -f $Env:UniversalServerUrl)
$Env:UniversalServerAppToken = 'e....4' # insert your token here

```

Once you have the `secret.local.ps1` file created, you can run the build script
to build and publish your module to PowerShell Universal.

```powershell
. .\secrets.local.ps1 
.\build.ps1 -Tasks build,pack,deploy
