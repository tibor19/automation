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

$context = Get-AzureRmContext

Write-Warning $context

$scripts = Get-Module ComplianceScripts | Select -ExpandProperty ExportedFunctions | Select -ExpandProperty Keys

foreach($script in $scripts){
	Write-Warning "Running script $script"

	$result = &"$script" 
	
	Write-Warning "$script has this $($result.Count) result: $result"
	
	if(($result -ne $null) -and (@($result).Count -gt 0)){
		#$result | Export-Csv -NoTypeInformation -Path $perScriptPath
		#$result | Export-Csv -NoTypeInformation -Path $perSubscriptionPath
		
		Write-Output $result
	}
	else{
		Write-Warning "Nothing to report on $script for $($context.Subscription.Name)"
	}
}
