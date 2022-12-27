param region string = resourceGroup().location
param storageAccountName string
param apiManagementName string
param apiManagementPublisherEmail string
param apiManagementPublisherName string
param logAnalyticsWorkspaceName string
param apimApplicationInsightsName string
param functionAppApplicationInsightsName string
param keyVaultName string
param adminUserId string
param cosmosAccountName string
param cosmosDatabaseName string
param cosmosContainerName string
param cosmosPartitionKey string
param eventHubNamespaceName string
param eventHubHubName string
param eventHubConsumerGroupName string

var storageAccountDeploymentName = 'storage-${storageAccountName}-${deployment().name}'
var apiManagementDeploymentName = 'apiManagement-${apiManagementName}-${deployment().name}'
var logAnalyticsWorkspaceDeploymentName = 'logAnalyticsWorkspace-${logAnalyticsWorkspaceName}-${deployment().name}'
var applicationInsightsDeploymentName = 'applicationInsights-${apimApplicationInsightsName}-${deployment().name}'
var functionAppApplicationInsightsDeploymentName = 'applicationInsights-${functionAppApplicationInsightsName}-${deployment().name}'
var keyVaultDeploymentName = 'keyVault-${keyVaultName}-${deployment().name}'
var secretsDeploymentName = 'secrets-${deployment().name}'
var apimConfigurationDeploymentName = 'apimConfiguration-${deployment().name}'
var cosmosDeploymentName = 'cosmos-${cosmosAccountName}-${deployment().name}'
var eventHubDeploymentName = 'eventHub-${eventHubNamespaceName}-${deployment().name}'

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

module logAnalyticsWorkspace './modules/logAnalyticsWorkspace.bicep' = {
  name: logAnalyticsWorkspaceDeploymentName
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    region: region
  }
}

module apimApplicationInsights './modules/applicationInsights.bicep' = {
  name: applicationInsightsDeploymentName
  params: {
    applicationInsightsName: apimApplicationInsightsName
    region: region
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

module functionAppApplicationInsights './modules/applicationInsights.bicep' = {
  name: functionAppApplicationInsightsDeploymentName
  params: {
    applicationInsightsName: functionAppApplicationInsightsName
    region: region
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }

}

module keyVault './modules/keyVault.bicep' = {
  name: keyVaultDeploymentName
  params: {
    keyVaultName: keyVaultName
    region: region
    applicationIds: [
      apiManagement.outputs.managedIdentityObjectId
    ]
    adminIds: [
      adminUserId
    ]
  }
}

module cosmos './modules/cosmosDb.bicep' = {
  name: cosmosDeploymentName
  params: {
    cosmosAccountName: cosmosAccountName
    databaseName: cosmosDatabaseName
    containerName: cosmosContainerName
    partitionKey: cosmosPartitionKey
    region: region
  }
}

module eventHub './modules/eventHub.bicep' = {
  name: eventHubDeploymentName
  params: {
    eventHubHubName: eventHubHubName
    eventHubNamespaceName: eventHubNamespaceName
    eventHubConsumerGroupName: eventHubConsumerGroupName
    region: region
  }
}

// secrets and apimConfiguration should always run towards the end of the deployment, ideally last
module secrets './modules/secrets.bicep' = {
  name: secretsDeploymentName
  params: {
    keyVaultName: keyVault.outputs.name
    apimApplicationInisightsName: apimApplicationInsights.outputs.name
    functionAppApplicationInsightsName: functionAppApplicationInsights.outputs.name
    cosmosAccountName: cosmos.outputs.name
    storageAccountName: storageAccount.outputs.name
    eventHubNamespaceName: eventHub.outputs.name
  }
}


module apimConfiguration './modules/apimConfiguration.bicep' = {
  name: apimConfigurationDeploymentName
  params: {
    apimResourceName: apiManagement.outputs.name
    appInsightsInstrumentationKeySecretUri: secrets.outputs.apimAppInsightsInstrumentationKeySecretUri
    appInsightsResourceName: apimApplicationInsights.outputs.name
  }
}

