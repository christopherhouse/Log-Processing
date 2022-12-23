param deploymentTime string = utcNow('MMddyyyyHHmmss')
param region string = resourceGroup().location
param storageAccountName string
param apiManagementName string
param apiMangagementPublisherEmail string
param apiManagementPublisherName string

var storageAccountDeploymentName = 'storage-${storageAccountName}-${deploymentTime}'
var apiManagementDeploymentName = 'apiManagement-${apiManagementName}-${deploymentTime}'

module storageAccount './modules/storageAccount.bicep' = {
  name: storageAccountDeploymentName
  params: {
    storageAccountName: storageAccountName
    region: region
  }
}

module apiManagement './modules/apiManagement.bicep' = {
  name: apiManagementDeploymentName
  params: {
    apiManagementName: apiManagementName
    region: region
    publisherEmail: apiMangagementPublisherEmail
    publisherName: apiManagementPublisherName
  }
  dependsOn: [
    storageAccount
  ]
}
