param functionAppName string
param appServicePlanName string
param storageAccountName string
@secure()
param appInsightsInstrumentationKey string
@secure()
param appInsightsConnectionString string
param cosmosDbConnectionStringSecretUri string
param eventHubSendAccessPolicySecretUri string
param eventHubListenAccessPolicySecretUri string
param eventHubName string
param eventHubConsumerGroup string
param region string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: region
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: region
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2021-04-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2021-04-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'CosmosDbConnectionString'
          value: '@Microsoft.KeyVault(SecretUri=${cosmosDbConnectionStringSecretUri})'
        }
        {
          name: 'eventHubSendConnectionString'
          value: '@Microsoft.KeyVault(SecretUri=${eventHubSendAccessPolicySecretUri})'
        }
        {
          name: 'eventHubListenConnectionString'
          value: '@Microsoft.KeyVault(SecretUri=${eventHubListenAccessPolicySecretUri})'
        }
        {
          name: 'eventHubName'
          value: eventHubName
        }
        {
          name: 'eventHubConsumerGroup'
          value: eventHubConsumerGroup
        }
      ]
    }
  }
}

output managedIdentityObjectId string = functionApp.identity.principalId
