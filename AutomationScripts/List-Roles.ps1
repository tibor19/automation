# Login-AzureRmAccount

# Get-AzureRmPolicyAssignment
# Set-AzureRmContext -SubscriptionId 917df964-d420-4170-b4d4-2cfe0b1848f2
# Set-AzureRmContext -SubscriptionId 01d9b941-7c21-4f20-b0bb-147831d78267
# Set-AzureRmContext -SubscriptionId c4390814-2a81-4b1a-bec2-958dc760977a

# Get-AzureRmSubscription

# Get-AzureRmPolicyDefinition -Id "/subscriptions/01d9b941-7c21-4f20-b0bb-147831d78267/providers/Microsoft.Authorization/policyDefinitions/eu-regions-policy"

# Get-AzureRmResourceLock

#Get-AzureRmVM | Format-List -Property * -Force

#Get-AzureRmStorageAccount

#Get-AzureRmVM -Name "iamacc11607" -ResourceGroupName "IAM-RG-ACC"  | Select AvailabilitySetId

#$ids = @()

#$ids += Get-AzureRmAvailabilitySet  -ResourceGroupName "IAM-RG-ACC" | Select -ExpandProperty VirtualMachinesReferences | Select -ExpandProperty Id
# $ids += Get-AzureRmDisk | Where AccountType -NE PremiumLRS | Select -ExpandProperty OwnerId
#(Get-AzureRmVM | where Id -In $ids | select -Unique Location).Count

#$Names = Get-AzureRmVM | Select -ExpandProperty StorageProfile | Select -ExpandProperty OsDisk | Select -ExpandProperty Name 

#foreach($name in $Names){
#	-DiskName $name 
#}

#Get-AzureRmDisk Select -Unique -ExpandProperty OwnerId


#Get-AzureRmVM -VMName saiamac1563 -ResourceGroupName iamng-rg-acc 

#Get-AzureRmDisk -DiskName saiamac1563-osDisk | Select AccountType

#Get-AzureRmVMUsage -Location westeurope


#Save-Module -Name AzureRM.Compute -Path .

#$rgs = Get-AzureRmResourceGroup 
#foreach($rg in $rgs){
#	Write-Host "Resource Group: $($rg.ResourceGroupName)"
#	Get-AzureRmAvailabilitySet -ResourceGroupName $rg.ResourceGroupName
#}

#Get-AzureRmResourceProvider
#Get-AzureRmRoleAssignment | Where ObjectType -EQ User  |  Select { Get-AzureRmADUser -UserPrincipalName $_.SignInName } | Select UserPrincipalName

#(Get-AzureRmRoleAssignment | Where Scope -Match "^/subscriptions/(?<subscriptionId>[\w-]+)$" | Select -ExpandProperty Scope).Count
## subscriptionId = [A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}
#(Get-AzureRmRoleAssignment | Where Scope -Match "^/subscriptions/(?<subscriptionId>[\w-]+)/resourceGroups/(?<resourceGroupName>[-\w\._\(\)]+)$" | Select -ExpandProperty Scope).Count

#(Get-AzureRmRoleAssignment | Where Scope -Match "^/subscriptions/(?<subscriptionId>[\w-]+)/resourceGroups/(?<resourceGroupName>[-\w\._\(\)]+)/providers/(?<resourceNamespace>[-\w\._\(\)]+)/(?<resourceType>[-\w\._\(\)]+)/(?<resourceName>[-\w\._\(\)]+)" | Select -ExpandProperty Scope).Count
#$Matches
#(Get-AzureRmRoleAssignment)[0] | Format-List * -Force | Where ResourceName -NE $null | Select -ExpandProperty Scope
##| Where DisplayName -Like "z_*"

# $secpasswd = ConvertTo-SecureString -AsPlainText -Force
# $mycreds = New-Object System.Management.Automation.PSCredential ("tibi@covaci.se", $secpasswd)

# Login-AzureRmAccount -Credential $mycreds -SubscriptionId 973c2e2e-fd88-49ed-89e9-9d2fb729bf73 # -TenantId f8be18a6-f648-4a47-be73-86d6c5c6604d

# Get-AzureRmVM | Format-List * -Force

#Get-AzureRm
#Get-AzureRmADUser | Select -Unique Type -First 2 | Format-List * -Force  # | Where UserPrincipalName -like "a7*"
#Get-AzureRmADGroup | Select -First 2 | Format-List * -Force #| Where UserPrincipalName -like "a7*"


## Get-AzureRmVm -Name CLIENTUS -ResourceGroupName CLIENTUS | Select -ExpandProperty StorageProfile | Select -ExpandProperty OsDisk | Select -ExpandProperty Vhd | Select -ExpandProperty Uri
## ([System.Uri](Get-AzureRmVm -Name CLIENTUS -ResourceGroupName CLIENTUS | Select -ExpandProperty StorageProfile | Select -ExpandProperty OsDisk | Select -ExpandProperty Vhd | Select -ExpandProperty Uri))
## Get-AzureRmStorageAccount | Select Sku -ExpandProperty PrimaryEndpoints | Where Blob -EQ "https://clientus1923.blob.core.windows.net/"  | Select -ExpandProperty Sku | Select -ExpandProperty Tier
## Get-AzureRmAvailabilitySet

#function GetUserAssignement {
#    Param([string]$fileName, [string]$outFolder, [string]$SubscriptionName)

#    $roleAssignements = Get-AzureRmRoleAssignment -IncludeClassicAdministrators | where ObjectType -eq 'User' | select  -Property DisplayName, SignInName, RoleDefinitionName, Scope
    
#    if(@($roleAssignements).Count -gt 0){
#        $roleAssignements | Export-Csv -NoTypeInformation -Path "$outFolder\UserAssignemnt\$fileName"
#    }
#    else{
#        Write-Host "Nothing to report on Subsriptions for $SubscriptionName"
#    }

#}

#function GetVpnGateways {
#    Param([string]$fileName, [string]$outFolder, [string]$SubscriptionName)

#    $gws = $()
#    $resources = Get-AzureRmResource | Where ResourceType -Like "Microsoft.Network/virtualNetworkGateways"
    

#    foreach($resource in $resources){ 
#        $gw = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $resource.ResourceGroupName -Name $resource.ResourceName | Select Name, Location, ResourceGroupName, GatewayType
#        Write-Host $gw
#        if($gw.GatewayType -ne 'ExpressRoute'){
#            $gws += @($gw)
#        }
#    }
    
#	return 

#    if($gws.Count -gt 0){
#        $gws | Export-Csv -NoTypeInformation -Path "$outFolder\VpnGateways\$fileName"
#    }
#    else{
#        Write-Host "Nothing to report on Vpn Gateways for $SubscriptionName"
#    }

#}

#function GetOutdatedResources {
#    Param([string]$fileName, [string]$outFolder, [string]$SubscriptionName)
	
#    $outdatedResources =  Get-AzureRmResource | where ResourceType -like "*Classic*" | Select -Property Name, Location, ResourceType, ResourceGroupName
 
#    if($outdatedResources.Count -gt 0){
#        $outdatedResources | Export-Csv -NoTypeInformation -Path "$outFolder\OutdatedResources\$fileName"
#    }
#    else{
#        Write-Host "Nothing to report on Outdated Resources for $SubscriptionName"
#    }
#}

#function GetResourcesInWrongRegion {
#    Param([string]$fileName, [string]$outFolder, [string]$SubscriptionName)
	
#    $wrongRegionResources = Get-AzureRmResource | where Location -NotIn @("westeurope", "northeurope", "global") | Select -Property Name, Location, ResourceType, ResourceGroupName
 
#    if($wrongRegionResources.Count -gt 0){
#        $wrongRegionResources | Export-Csv -NoTypeInformation -Path "$outFolder\WrongRegions\$fileName"
#    }
#    else{
#        Write-Host "Nothing to report on Wrong Regions for $SubscriptionName"
#    }

#}

#function GetResourceGroupsWithoutTags{
#    Param([string]$fileName, [string]$outFolder, [string]$SubscriptionName)
       
#    $requiredTags=@("creator", "costallocation", "department")

#    $groupsWithTags = Get-AzureRmResourceGroup | Where tags -ne $null | Select -ExpandProperty tags -Property ResourceId

#    foreach($requiredTag in $requiredTags){
#        $groupsWithTags = $groupsWithTags | where -Property $requiredTag -NE $null
#    }

#    $resourceGroupsWithTags = $groupsWithTags | select -ExpandProperty ResourceId 

#    $resourceGroupsWithoutTags = Get-AzureRmResourceGroup | Where ResourceId -NotIn $resourceGroupsWithTags | Select ResourceGroupName, ResourceId

#    if(@($resourceGroupsWithoutTags).Count -gt 0){
#        $resourceGroupsWithoutTags | Export-Csv -NoTypeInformation -Path "$outFolder\ResourceGroupsWithoutTags\$fileName"
#    }
#    else{
#        Write-Host "Nothing to report on Resource Groups Without Tags for $SubscriptionName"
#    }
#}

#function CreateIfNotExists {
#    Param([string]$folder)

#    $pathExists = Test-Path -LiteralPath $folder

#    if(!$pathExists){
#        New-Item -ItemType Directory -Force -Path $folder | Out-Null
#        Write-Host "Creating $folder"
#    }
#    else {
#        Write-Host "$folder Exists"
#    }   

#}

#function EnsureFolders {
#    Param([string]$rootFolder)

#    $folders=@("ResourceGroupsWithoutTags", "OutdatedResources", "WrongRegions", "UserAssignemnt", "VpnGateways")

#    CreateIfNotExists -folder $rootFolder

#    foreach($folder in $folders){
#        $fullPath = Join-Path -Path $rootFolder -ChildPath $folder
#        CreateIfNotExists -folder $fullPath
#    }
#}

#$outFolder = Join-Path -Path $PSScriptRoot -ChildPath "Output"

#EnsureFolders -rootFolder $outFolder

#$vnets = @() 

#$subs = Get-AzureRmSubscription 

#foreach($sub in $subs){

#    Write-Host "Findings for Subscription $($sub.SubscriptionName)"
#    Write-Host ""
    
#    Select-AzureRmSubscription -SubscriptionId $sub.SubscriptionId | Out-Null
    
#    $fileName = "$($sub.SubscriptionName).$($sub.SubscriptionId).csv"

#    GetUserAssignement -fileName $fileName -outFolder $outFolder -SubscriptionName $sub.SubscriptionName

    

#    GetOutdatedResources -fileName $fileName -outFolder $outFolder -SubscriptionName $sub.SubscriptionName

#    GetResourcesInWrongRegion -fileName $fileName -outFolder $outFolder -SubscriptionName $sub.SubscriptionName

#    GetResourceGroupsWithoutTags -fileName $fileName -outFolder $outFolder -SubscriptionName $sub.SubscriptionName
    
#    GetVpnGateways -fileName $fileName -outFolder $outFolder -SubscriptionName $sub.SubscriptionName
    
#    $vnets += Get-AzureRmVirtualNetwork | Select -Property @{Name = "SubscriptionName"; Expression = {$sub.SubscriptionName}}, @{Name = "SubscriptionId"; Expression = {$sub.SubscriptionId}}, Name, Location, @{ Name = "AddressPrefixes"; Expression = {$_.AddressSpace.AddressPrefixes}}

#    Write-Host ""

#    # Get-AzureRmExpressRouteCircuit | Select -ExpandProperty Authorizations | Select Name
#	#	function Test {
#	#	$func = "Write-Host"

#	#	&"$func" "Hello World"

#	#	(Get-PSCallStack)[0].Command
#	#	$res = Get-AzureRmResource
#	#	$res
#	#}

#	#Test | Select -ExpandProperty tags -Property ResourceId


#}

#$vnets | Export-Csv -NoTypeInformation -Path "$outFolder\vnets.csv"

filter Select-HostName(){
	([System.Uri]$_).Host
}

function Uri2Host {
	Param([Parameter(Position=0, Mandatory, ValueFromPipeline)][System.Uri]$diskUri)

	$diskUri.Host
	# Write-Host $diskUri.Host

	# "vapcommonprdpvhds001sa.blob.core.windows.net"
}

function Get-VMsWithManagedPremiumDisks {
	Get-AzureRmVM | Select Id -ExpandProperty StorageProfile | Select Id -ExpandProperty OsDisk | Where { $_.ManagedDisk -ne $null -and $_.ManagedDisk.StorageAccountType -EQ "PremiumLRS"} | Select -Unique -ExpandProperty Id
}

#$vmsWithoutManagedDisks = Get-AzureRmVM | Select Id -ExpandProperty StorageProfile | Select Id -ExpandProperty OsDisk | Where ManagedDisk -EQ $null |  Select Id, Vhd 

#$vmsWithoutManagedDisks | ForEach-Object { IsPremiumDisk $_.Vhd.Uri }

function Get-StorageAccountTierForVhd {
	Param([System.Uri]$uri)
	Get-AzureRmStorageAccount | Where {([System.Uri]$_.PrimaryEndpoints.Blob).Host -eq ([System.Uri]$uri).Host} | Select {$_.Sku.Tier}
	#Get-AzureRmStorageAccount | Select Sku -ExpandProperty PrimaryEndpoints | Select @{Name="Tier"; Expression ={$_.Sku.Tier}}, @{Name="Host"; Expression = {([System.Uri]$_.Blob).Host}} | ? Host -EQ $uri.Host | Select -ExpandProperty Tier
}

function Get-VMsWithUnmanagedPremiumDisks {
	Get-AzureRmVM | Select Id -ExpandProperty StorageProfile | Select Id -ExpandProperty OsDisk | Where { $_.ManagedDisk -EQ $null -and $_.Vhd -ne $null -and (Get-StorageAccountTierForVhd $_.Vhd.Uri) -EQ "Premium" } | Select -Unique -ExpandProperty Id
}

function Get-VMsWithPremiumDisks {
	# Get-AzureRmVM | Select Id -ExpandProperty StorageProfile | Select Id -ExpandProperty OsDisk | Where { ($_.ManagedDisk -ne $null -and $_.ManagedDisk.StorageAccountType -EQ "PremiumLRS") -or ($_.ManagedDisk -EQ $null -and $_.Vhd -ne $null -and (Get-TierForStorageAccount $_.Vhd.Uri) -EQ "Premium") } | Select -Unique -ExpandProperty Id
	Get-AzureRmVM | Where { ($_.StorageProfile.OsDisk.ManagedDisk -ne $null -and $_.StorageProfile.OsDisk.ManagedDisk.StorageAccountType -EQ "PremiumLRS") -or ($_.StorageProfile.OsDisk.ManagedDisk -EQ $null -and $_.StorageProfile.OsDisk.Vhd -ne $null -and (Get-TierForStorageAccount $_.StorageProfile.OsDisk.Vhd.Uri) -EQ "Premium") } | Select -Unique -ExpandProperty Id
}

	#$ids = @()

	## Get all VMs not part of a AS
	#$ids += Get-AzureRmResourceGroup | Get-AzureRmAvailabilitySet  | Select -ExpandProperty VirtualMachinesReferences | Select -ExpandProperty Id
	
	## Get all VMs with Premium disks, as those are covered by SLA
	#$ids += Get-AzureRmDisk | Where AccountType -EQ PremiumLRS | Select -ExpandProperty OwnerId

# Get-TierForStorageAccount "http://vapcommonprdpvhds001sa.blob.core.windows.net"

# Get-VMsWithUnmanagedPremiumDisks
# sadv1ci3692

Get-AzureRmVM | Select -ExpandProperty StorageProfile | gm

Get-AzureRmVM | Where { IsPremiumOsDisk $_.StorageProfile.OsDisk -and ArePremiumDataDisks $_.StorageProfile.DataDisks} | Select Name

$vms = Get-AzureRmVM | Where { ($_.AvailabilitySetReference -eq $null) -and !(IsPremiumStorageProfile -storageProfile $_.StorageProfile) } 

(($_.StorageProfile.OsDisk.ManagedDisk -ne $null -and $_.StorageProfile.OsDisk.ManagedDisk.StorageAccountType -like "Standard*") -or ($_.StorageProfile.OsDisk.ManagedDisk -eq $null -and ($_.StorageProfile.OsDisk.Vhd -eq $null -or ($_.StorageProfile.OsDisk.Vhd -ne $null -and (Get-TierForStorageAccount $_.StorageProfile.OsDisk.Vhd.Uri) -like "Standard*"))))

Get-AzureRmContext

Get-AzureRmVM | Where { ($_.AvailabilitySetReference -eq $null) -and !(IsPremiumStorageProfile -storageProfile $_.StorageProfile) }  | select Name, Location, ResourceGroupName

$vms | Select Name
(Get-AzureRmVM | Select -ExpandProperty StorageProfile)[0].GetType().FullName

Get-AzureRmStorageAccount | Select -ExpandProperty Sku | Select -ExpandProperty Name | gm

$values = 'a', 'b'

function Test-StringsArray{
	param(
		[string[]]$strings = $values
	)

	if($strings -eq $null){
		Write-Output "No data"
	}
	Write-Output $strings.Length

	foreach($string in $strings){
		Write-Output $string
	}
}

Test-StringsArray 
Test-StringsArray Tibi
Test-StringsArray Tibi, Nicoleta
