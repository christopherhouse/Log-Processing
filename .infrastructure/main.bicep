param deploymentTime string = utcNow('MMddyyyyHHmmss')
param region string = resourceGroup().location
param storageAccountName string

var storageAccountDeploymentName = 'storage-${storageAccountName}-${deploymentTime}'

module storageAccount './modules/storageAccount.bicep' = {
  name: storageAccountDeploymentName
  params: {
    storageAccountName: storageAccountName
    region: region
  }
}
