#
# ComplianceScripts.psm1
#

# Contants

$defaultRequiredTags = "creator", "costallocation", "department"

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

function Get-ResourcesInWrongRegion {

	Get-AzureRmResource | where Location -NotIn @("westeurope", "northeurope", "global") | Select -Property Name, Location, ResourceType, ResourceGroupName
 
}

function Get-ResourceGroupsWithoutTags {
    [CmdletBinding()]
	param($requiredTags)

	if($requiredTags -eq $null){
		$requiredTags = $defaultRequiredTags
	}
	else{
		$requiredTags = @($requiredTags)
	}

	Write-Verbose $requiredTags

    $groupsWithTags = Get-AzureRmResourceGroup | Where Tags -ne $null | Select -ExpandProperty Tags -Property ResourceId

    foreach($requiredTag in $requiredTags){
        $groupsWithTags = $groupsWithTags | where -Property $requiredTag -NE $null
    }

    $compliantResourceGroupIds = $groupsWithTags | select -ExpandProperty ResourceId 

	# non compliant resource groups
	Get-AzureRmResourceGroup | Where ResourceId -NotIn $compliantResourceGroupIds | Select ResourceGroupName, ResourceId
}

