param region string = resourceGroup().location
param storageAccountName string
param apiManagementName string
param apiManagementPublisherEmail string
param apiManagementPublisherName string
param logAnalyticsWorkspaceName string
param apimApplicationInsightsName string
param functionAppApplicationInsightsName string

var storageAccountDeploymentName = 'storage-${storageAccountName}-${deployment().name}'
var apiManagementDeploymentName = 'apiManagement-${apiManagementName}-${deployment().name}'
var logAnalyticsWorkspaceDeploymentName = 'logAnalyticsWorkspace-${logAnalyticsWorkspaceName}-${deployment().name}'
var applicationInsightsDeploymentName = 'applicationInsights-${apimApplicationInsightsName}-${deployment().name}'
var functionAppApplicationInsightsDepliymentName = 'applicationInsights-${functionAppApplicationInsightsName}-${deployment().name}'

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
  name: functionAppApplicationInsightsDepliymentName
  params: {
    applicationInsightsName: functionAppApplicationInsightsName
    region: region
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}
