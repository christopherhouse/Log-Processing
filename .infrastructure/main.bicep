param region string = resourceGroup().location
param storageAccountName string
param apiManagementName string
param apiManagementPublisherEmail string
param apiManagementPublisherName string

var storageAccountDeploymentName = 'storage-${storageAccountName}-${deployment().name}'
var apiManagementDeploymentName = 'apiManagement-${apiManagementName}-${deployment().name}'

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
    publisherEmail: apiManagementPublisherEmail
    publisherName: apiManagementPublisherName
  }
  dependsOn: [
    storageAccount
  ]
}
