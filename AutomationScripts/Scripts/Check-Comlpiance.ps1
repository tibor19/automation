#
# Check_Comlpiance.ps1
#

$connectionName = "AzureRunAsConnection"

try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$sub = Get-AzureRmContext | Get-AzureRmSubscription

$scripts = Get-Module ComplianceScripts | Select -ExpandProperty ExportedFunctions | Select -ExpandProperty Keys

foreach($script in $scripts){
	Write-Output "Running script" $script

	$result = &"$script" 
		
	if(($result -ne $null) -and (@($result).Count -gt 0)){
		#$perScriptPath = Join-Path $rootFolder -ChildPath $script | Join-Path -ChildPath "$($subId).csv"
		#$perSubscriptionPath = Join-Path -Path $subscriptionFolder -ChildPath "$($script).csv"
		#$result | Export-Csv -NoTypeInformation -Path $perScriptPath
		#$result | Export-Csv -NoTypeInformation -Path $perSubscriptionPath
		Write-Output $result
	}
	else{
		Write-Output "Nothing to report on $script for " $sub.Name
	}
}

Write-Output  ""
