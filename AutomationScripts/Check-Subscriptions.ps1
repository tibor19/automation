#
# Check-Subscriptions.ps1
#

# Login-AzureRmAccount


$rootFolder = Join-Path -Path $PSScriptRoot -ChildPath "Output"
$subscriptionsFolder = Join-Path -Path $rootFolder -ChildPath "Subscriptions"
$complianceScriptsModule = "ComplianceScripts"
$complianceScriptsVerb = "Get"

$module = Get-Module $complianceScriptsModule

if($module -eq $null){
	Import-Module ".\Modules\$($complianceScriptsModule).psd1"
}

$cmdlets = Get-Command -Module $complianceScriptsModule -Verb $complianceScriptsVerb 

Write-Output 'Commands to run:' 
Write-Output ($cmdlets | Format-List | Out-String)


function CreateIfNotExists {
    Param([string]$folder)

    $pathExists = Test-Path -LiteralPath $folder

    if(!$pathExists){
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        Write-Host "Creating $folder"
    }
    else {
        Write-Host "$folder Exists"
    }   

}

function EnsureFolders {
    Param([string]$rootFolder, [string]$subscriptionsFolder, [string[]]$folders)

    CreateIfNotExists -folder $rootFolder
	CreateIfNotExists -folder $subscriptionsFolder

    foreach($folder in $folders){
        $fullPath = Join-Path -Path $rootFolder -ChildPath $folder
        CreateIfNotExists -folder $fullPath
    }
}

$vnets = @() 
$subs = Get-AzureRmSubscription 

EnsureFolders -rootFolder $rootFolder -subscriptionsFolder $subscriptionsFolder -folders ($cmdlets | Select -ExpandProperty Noun)

foreach($sub in $subs){

    Write-Host "Findings for Subscription " $sub.Name
    Write-Host ""
    
    Select-AzureRmSubscription -SubscriptionId $sub.Id | Out-Null
    
	$subId = "$($sub.Name).$($sub.Id)"
	$subscriptionFolder = Join-Path $subscriptionsFolder -ChildPath $subId
	CreateIfNotExists $subscriptionFolder

	foreach($cmdlet in $cmdlets){
		Write-Host "Running " $cmdlet.Noun

		$result = &($cmdlet.Name)
		
		if(($result -ne $null) -and (@($result).Count -gt 0)){
			$perScriptPath = Join-Path $rootFolder -ChildPath $cmdlet.Noun | Join-Path -ChildPath "$($subId).csv"
			$perSubscriptionPath = Join-Path -Path $subscriptionFolder -ChildPath "$($cmdlet.Noun).csv"
			$result | Export-Csv -NoTypeInformation -Path $perScriptPath
			$result | Export-Csv -NoTypeInformation -Path $perSubscriptionPath
		}
		else{
			Write-Host "Nothing to report on $($cmdlet.Noun) for $($sub.Name)"
		}
	}

    $vnets += Get-AzureRmVirtualNetwork | Select -Property @{Name = "SubscriptionName"; Expression = {$sub.SubscriptionName}}, @{Name = "SubscriptionId"; Expression = {$sub.SubscriptionId}}, Name, Location, @{ Name = "AddressPrefixes"; Expression = {$_.AddressSpace.AddressPrefixes}}

    Write-Host ""
}

$vnets | Export-Csv -NoTypeInformation -Path "$rootFolder\vnets.csv"

if($module -eq $null){
	Remove-Module $complianceScriptsModule
}

$files = gci -Recurse -File -Filter "Get-*"
foreach($file in $files){
	Rename-Item $file.FullName -NewName $file.Name.Substring(4)
}