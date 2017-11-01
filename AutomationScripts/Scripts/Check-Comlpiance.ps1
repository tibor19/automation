#
# Check_Comlpiance.ps1
#

$complianceScriptsModule = "ComplianceScripts"
$complianceScriptsVerb = "Get"
$storageAccountName = "automationscripts201710"
$storageAccountResourceGroup = "automation-rg"
$storageAccountContainerName = "output"

$connectionName = "AzureRunAsConnection"

try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    Write-Verbose "Logging in to Azure..."
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

Import-Module $complianceScriptsModule

$context = Get-AzureRmContext
Write-Verbose 'Context:' 
Write-Verbose ($context | Format-List | Out-String)

$scripts = Get-Command -Module $complianceScriptsModule -Verb $complianceScriptsVerb | Select -ExpandProperty Name

Write-Verbose 'Scripts to run:' 
Write-Verbose ($scripts | Format-List | Out-String)

Set-AzureRmCurrentStorageAccount -ResourceGroupName $storageAccountResourceGroup -Name $storageAccountName
New-AzureStorageContainer -Name $storageAccountContainerName -ErrorAction Ignore

foreach($script in $scripts){

	$scriptName = (Get-Command -Name $script -Module $complianceScriptsModule).Noun
	$outputFile = $scriptName + ".csv"

	Write-Verbose "Running script $scriptName"

	$result = &"$script" 
	Write-Verbose 'Result: '
	Write-Verbose ($result | Format-List | Out-String)
	
	if(($result -ne $null) -and (@($result).Count -gt 0)){

		$result | Export-Csv -NoTypeInformation -Path $outputFile 
		Set-AzureStorageBlobContent -Container $storageAccountContainerName -File $outputFile -Blob $outputFile
		Write-Output $result
	}
	else{
		Write-Verbose "Nothing to report on $scriptName for $($context.Subscription.Name)"
	}
}
