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
param functionAppName string
param appServicePlanName string
param containerRegistryName string
param iotHubName string
param maxQueueDepth int

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
var functionAppDeploymentName = 'functionApp-${functionAppName}-${deployment().name}'
var accessPoliciesDeploymentName = 'accessPolicies-${deployment().name}'
var containerRegistryDeploymentName = 'containerRegistry-${containerRegistryName}-${deployment().name}'
var iotHubDeploymentName = 'iotHub-${iotHubName}-${deployment().name}'

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
    adminId: adminUserId
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

module functionApp './modules/functionApp.bicep' = {
  name: functionAppDeploymentName
  params: {
    appInsightsConnectionString: functionAppApplicationInsights.outputs.connectionString
    appInsightsInstrumentationKey: functionAppApplicationInsights.outputs.instrumentationKey
    appServicePlanName: appServicePlanName
    functionAppName: functionAppName
    region: region
    storageAccountName: storageAccount.outputs.name
    cosmosDbConnectionStringSecretUri: secrets.outputs.cosmosDbConnectionStringSecretUri
    cosmosDbDatabaseName: cosmosDatabaseName
    cosmosDbContainerName: cosmosContainerName
    eventHubSendAccessPolicySecretUri: secrets.outputs.eventHubSendAccessPolicySecretUri
    eventHubListenAccessPolicySecretUri: secrets.outputs.eventHubListenAccessPolicySecretUri
    eventHubName: eventHubHubName
    eventHubConsumerGroup: eventHubConsumerGroupName
    maxQueueDepth: maxQueueDepth
  }
}

module registry './modules/containerRegistry.bicep' = {
  name: containerRegistryDeploymentName
  params: {
    registryName: containerRegistryName
    region: region
  }
}

module iotHub './modules/iotHub.bicep' = {
  name: iotHubDeploymentName
  params: {
    iotHubName: iotHubName
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
    eventHubAccessPolicyApiVersion: eventHub.outputs.accessPolicyApiVersion
    eventHubSendAccessPolicyId: eventHub.outputs.rootSendAccessKeyId
    eventHubListenAccessPolicyId: eventHub.outputs.hubListenAccessKeyId
  }
}


module apimConfiguration './modules/apimConfiguration.bicep' = {
  name: apimConfigurationDeploymentName
  params: {
    apimResourceName: apiManagement.outputs.name
    appInsightsInstrumentationKeySecretUri: secrets.outputs.apimAppInsightsInstrumentationKeySecretUri
    appInsightsResourceName: apimApplicationInsights.outputs.name
  }
  dependsOn: [
    accessPolicies
  ]
}

module accessPolicies './modules/accessPolicies.bicep' = {
  name: accessPoliciesDeploymentName
  params: {
    applicationIds: [
      apiManagement.outputs.managedIdentityObjectId
      functionApp.outputs.managedIdentityObjectId
    ]
    keyVaultName: keyVault.outputs.name
  }
}
