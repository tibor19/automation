#
# ComplianceScripts.psm1
#

# Contants

$defaultRequiredTags = "creator", "costallocation", "department"
$defaultAllowedRegions = "westeurope", "northeurope", "global"

# Private functions

function Get-StorageAccountTierForVhd ($uri) {
	Get-AzureRmStorageAccount | Where {([System.Uri]$_.PrimaryEndpoints.Blob).Host -eq ([System.Uri]$uri).Host} | Select {$_.Sku.Tier}
}

function Get-VMsWithUnmanagedPremiumDisks {
	Get-AzureRmVM | Select Id -ExpandProperty StorageProfile | Select Id -ExpandProperty OsDisk | Where { $_.ManagedDisk -EQ $null -and $_.Vhd -ne $null -and (Get-StorageAccountTierForVhd $_.Vhd.Uri) -EQ "Premium" } | Select -Unique -ExpandProperty Id
}

function Get-VMsWithPremiumDisks {
	Get-AzureRmVM | Where { ($_.StorageProfile.OsDisk.ManagedDisk -ne $null -and $_.StorageProfile.OsDisk.ManagedDisk.StorageAccountType -EQ "PremiumLRS") -or ($_.StorageProfile.OsDisk.ManagedDisk -EQ $null -and $_.StorageProfile.OsDisk.Vhd -ne $null -and (Get-TierForStorageAccount $_.StorageProfile.OsDisk.Vhd.Uri) -EQ "Premium") } | Select -Unique -ExpandProperty Id
}

function Test-Any {
    [CmdletBinding()]
    param($EvaluateCondition,
        [Parameter(ValueFromPipeline = $true)] $ObjectToTest)
    begin {
        $any = $false
    }
    process {
        if (-not $any) {
            $any = & $EvaluateCondition $ObjectToTest
        }
    }
    end {
        $any
    }
}

filter bigger ($val){
    
    if($_ -gt $val){ 
        $_
    }
}

function Test-All {
    [CmdletBinding()]
    param($EvaluateCondition,
        [Parameter(ValueFromPipeline = $true)] $ObjectToTest)
    begin {
        $any = $true
    }
    process {
        if ($any) {
            $any = & $EvaluateCondition $ObjectToTest
        }
    }
    end {
        $any
    }
}

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

# Exported Functions

function Get-UserAssignement {

    Get-AzureRmRoleAssignment -IncludeClassicAdministrators | where ObjectType -eq 'User' | select  -Property DisplayName, SignInName, RoleDefinitionName, Scope
    
}

function Get-VpnGateways {

	Get-AzureRmResource | Where ResourceType -Like "Microsoft.Network/virtualNetworkGateways" | Get-AzureRmVirtualNetworkGateway | Where GatewayType -NE 'ExpressRoute' | Select Name, Location, ResourceGroupName, GatewayType

}

function Get-OutdatedResources {
    
	Get-AzureRmResource | where ResourceType -like "*Classic*" | Select -Property Name, Location, ResourceType, ResourceGroupName

}

function Get-ResourcesInWrongRegion ($allowedRegions = $defaultAllowedRegions){

	$allowedRegions = @($allowedRegions)

	Get-AzureRmResource | where Location -NotIn $allowedRegions | Select -Property Name, Location, ResourceType, ResourceGroupName
 
}

function Get-ResourceGroupsWithoutTags ($requiredTags = $defaultRequiredTags) {
	$requiredTags = @($requiredTags)

    $groupsWithTags = Get-AzureRmResourceGroup | Where Tags -ne $null | Select -ExpandProperty Tags -Property ResourceId

    foreach($requiredTag in $requiredTags){
        $groupsWithTags = $groupsWithTags | where -Property $requiredTag -NE $null
    }

    $compliantResourceGroupIds = $groupsWithTags | select -ExpandProperty ResourceId 

	# non compliant resource groups
	Get-AzureRmResourceGroup | Where ResourceId -NotIn $compliantResourceGroupIds | Select ResourceGroupName, ResourceId
}

function Get-VMsWithoutSLA {

	# This method might need improving, as being part of an Availability set is not enough. You need at least two machnies in the same AS
	Get-AzureRmVM | Where { ($_.AvailabilitySetReference -eq $null) -and !(IsPremiumStorageProfile -storageProfile $_.StorageProfile) }  | select Name, Location, ResourceGroupName
}

