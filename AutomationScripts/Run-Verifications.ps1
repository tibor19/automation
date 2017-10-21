#
# Run_Verifications.ps1
#

Login-AzureRmAccount

# Set-AzureRmContext -SubscriptionId 347c6db3-859c-4582-89ad-bbd066c9bdfb

$rootFolder = Join-Path -Path $PSScriptRoot -ChildPath "Output"
$subscriptionsFolder = Join-Path -Path $rootFolder -ChildPath "Subscriptions"
$scripts=@("UserAssignement", "OutdatedResources", "ResourcesInWrongRegion", "ResourceGroupsWithoutTags", "VpnGateways", "VMsWithoutSLA")

function Get-UserAssignement {

    Get-AzureRmRoleAssignment -IncludeClassicAdministrators | where ObjectType -eq 'User' | select  -Property DisplayName, SignInName, RoleDefinitionName, Scope
    
}

function Get-VpnGateways {

    $gws = $()
    $resources = Get-AzureRmResource | Where ResourceType -Like "Microsoft.Network/virtualNetworkGateways"

    foreach($resource in $resources){ 
        $gw = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $resource.ResourceGroupName -Name $resource.ResourceName | Select Name, Location, ResourceGroupName, GatewayType
        if($gw.GatewayType -ne 'ExpressRoute'){
            $gws += @($gw)
        }
    }

	$gws
}

function Get-OutdatedResources {
    
	Get-AzureRmResource | where ResourceType -like "*Classic*" | Select -Property Name, Location, ResourceType, ResourceGroupName

}

function Get-ResourcesInWrongRegion {

	Get-AzureRmResource | where Location -NotIn @("westeurope", "northeurope", "global") | Select -Property Name, Location, ResourceType, ResourceGroupName
 
}

function Get-ResourceGroupsWithoutTags{

    $requiredTags=@("creator", "costallocation", "department")

    $groupsWithTags = Get-AzureRmResourceGroup | Where tags -ne $null | Select -ExpandProperty tags -Property ResourceId

    foreach($requiredTag in $requiredTags){
        $groupsWithTags = $groupsWithTags | where -Property $requiredTag -NE $null
    }

    $resourceGroupsWithTags = $groupsWithTags | select -ExpandProperty ResourceId 

	# $resourceGroupsWithoutTags
	Get-AzureRmResourceGroup | Where ResourceId -NotIn $resourceGroupsWithTags | Select ResourceGroupName, ResourceId
}

function Get-VMsWithoutSLA {

	function IsPremiumDisk {
		Param($disk)
		$isPremiumDisk = $disk.ManagedDisk -ne $null -and $disk.ManagedDisk.StorageAccountType -eq [Microsoft.Azure.Management.Compute.Models.StorageAccountTypes]::PremiumLRS
		if(!$isPremiumDisk -and $disk.Vhd -ne $null){
			$isPremiumDisk = (Get-AzureRmStorageAccount | Where {$_.Sku.Tier -eq [Microsoft.Azure.Management.Storage.Models.SkuTier]::Premium -and ([System.Uri]$_.PrimaryEndpoints.Blob).Host -eq ([System.Uri]$disk.Vhd.Uri).Host}).Count -eq 1
		}
		return $isPremiumDisk
	}

	function IsPremiumOsDisk {
		Param([Microsoft.Azure.Management.Compute.Models.OsDisk]$osDisk)
		return IsPremiumDisk -disk $osDisk
	}

	function ArePremiumDataDisks {
		Param([System.Collections.Generic.IList[Microsoft.Azure.Management.Compute.Models.DataDisk]]$dataDisks)

		$arePremiumDisk = $true

		foreach($disk in $dataDisks) {
			$arePremiumDisk = IsPremiumDisk -disk $disk
			if(!$arePremiumDisk){
				break
			}
		}
		return $arePremiumDisk
	}

	function IsPremiumStorageProfile {
		Param([Microsoft.Azure.Management.Compute.Models.StorageProfile]$storageProfile)
	
		return ((IsPremiumOsDisk $storageProfile.OsDisk) -and (ArePremiumDataDisks $storageProfile.DataDisks))
	}
	
	# This method might need improving, as being part of an Availability set is not enough. You need at least two machnies in the same AS
	Get-AzureRmVM | Where { ($_.AvailabilitySetReference -eq $null) -and !(IsPremiumStorageProfile -storageProfile $_.StorageProfile) }  | select Name, Location, ResourceGroupName
}

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

EnsureFolders -rootFolder $rootFolder -subscriptionsFolder $subscriptionsFolder -folders $scripts

foreach($sub in $subs){

    Write-Host "Findings for Subscription " $sub.Name
    Write-Host ""
    
    Select-AzureRmSubscription -SubscriptionId $sub.Id | Out-Null
    
	$subId = "$($sub.Name).$($sub.Id)"
	$subscriptionFolder = Join-Path $subscriptionsFolder -ChildPath $subId
	CreateIfNotExists $subscriptionFolder

	foreach($script in $scripts){
		Write-Host "Running " $script

		$result = &"Get-$script" 
		
		if(($result -ne $null) -and (@($result).Count -gt 0)){
			$perScriptPath = Join-Path $rootFolder -ChildPath $script | Join-Path -ChildPath "$($subId).csv"
			$perSubscriptionPath = Join-Path -Path $subscriptionFolder -ChildPath "$($script).csv"
			$result | Export-Csv -NoTypeInformation -Path $perScriptPath
			$result | Export-Csv -NoTypeInformation -Path $perSubscriptionPath
		}
		else{
			Write-Host "Nothing to report on $script for " $sub.Name
		}
	}

    $vnets += Get-AzureRmVirtualNetwork | Select -Property @{Name = "SubscriptionName"; Expression = {$sub.SubscriptionName}}, @{Name = "SubscriptionId"; Expression = {$sub.SubscriptionId}}, Name, Location, @{ Name = "AddressPrefixes"; Expression = {$_.AddressSpace.AddressPrefixes}}

    Write-Host ""
}

$vnets | Export-Csv -NoTypeInformation -Path "$rootFolder\vnets.csv"

