Login-AzureRMAccount

$ResourceGroup = "<Resource Group Name>"
$StorageAccountName = "<Storage Account to Upload the App definition>"

$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageAccountName

$ctx = $storageAccount.Context

New-AzureStorageContainer -Name appcontainer -Context $ctx -Permission blob

Set-AzureStorageBlobContent -File "<Zip File Path>\app.zip" `
  -Container appcontainer `
  -Blob "app.zip" `
  -Context $ctx

$id = "<Your AAD User Guid>"

$ownerID=(Get-AzureRmRoleDefinition -Name Owner).Id

$blob = Get-AzureStorageBlob -Container appcontainer -Blob app.zip -Context $ctx

New-AzureRmResourceGroup -Name appDefinitionGroup -Location eastus

New-AzureRmManagedApplicationDefinition `
  -Name "ManagedStorage" `
  -Location eastus `
  -ResourceGroupName appDefinitionGroup `
  -LockLevel ReadOnly `
  -DisplayName "Managed Storage Account" `
  -Description "Managed Azure Storage Account" `
  -Authorization "<group-id>:$ownerID" `
  -PackageFileUri $blob.ICloudBlob.StorageUri.PrimaryUri.AbsoluteUri