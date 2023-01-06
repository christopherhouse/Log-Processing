param keyVaultName string
param apimApplicationInisightsName string
param functionAppApplicationInsightsName string
param cosmosAccountName string
param storageAccountName string
param eventHubSendAccessPolicyId string
param eventHubListenAccessPolicyId string
param eventHubAccessPolicyApiVersion string

var eventHubSendConnectionString = listKeys(eventHubSendAccessPolicyId, eventHubAccessPolicyApiVersion).primaryConnectionString
var eventHubListenConnectionString = listKeys(eventHubListenAccessPolicyId, eventHubAccessPolicyApiVersion).primaryConnectionString

resource apimAppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: apimApplicationInisightsName
  scope: resourceGroup()
}

resource functionAppAppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: functionAppApplicationInsightsName
  scope: resourceGroup()
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

resource apimAppInsightsInstrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'apimApplicationInsightsInstrumentationKey'
  parent: keyVault
  properties: {
    value: apimAppInsights.properties.InstrumentationKey
  }
}

resource apimApplicationInsightsConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'apimApplicationInsightsConnectionString'
  parent: keyVault
  properties: {
    value: apimAppInsights.properties.ConnectionString
  }
}

resource funtionAppAppInsightsInstrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'functionAppApplicationInsightsInstrumentationKey'
  parent: keyVault
  properties: {
    value: functionAppAppInsights.properties.InstrumentationKey
  }
}

resource functionAppApplicationInsightsConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'functionAppApplicationInsightsConnectionString'
  parent: keyVault
  properties: {
    value: functionAppAppInsights.properties.ConnectionString
  }
}

resource cosmosDbConnectionStringSecret 'Microsoft.Keyvault/vaults/secrets@2022-07-01' = {
  name: 'cosmosDbConnectionString'
  parent: keyVault
  properties: {
    value: listConnectionStrings(resourceId('Microsoft.DocumentDb/databaseAccounts', cosmosAccountName), '2022-08-15').connectionStrings[0].connectionString
  }
}

resource storageAccountConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'storageAccountConnectionString'
  parent: keyVault
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2022-09-01').keys[0].value};EndpointSuffix=core.windows.net'
  }
}

resource eventHubSendAccessPolicySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'eventHubSendAccessPolicy'
  parent: keyVault
  properties: {
    value: eventHubSendConnectionString
  }
}

resource eventHubListenAccessPolicySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'eventHubListenAccessPolicy'
  parent: keyVault
  properties: {
    value: eventHubListenConnectionString
  }
}

output apimAppInsightsInstrumentationKeySecretUri string = apimAppInsightsInstrumentationKeySecret.properties.secretUriWithVersion
output apimApplicationInsightsConnectionStringSecretUri string = apimApplicationInsightsConnectionStringSecret.properties.secretUriWithVersion
output funtionAppAppInsightsInstrumentationKeySecretUri string = funtionAppAppInsightsInstrumentationKeySecret.properties.secretUriWithVersion
output functionAppApplicationInsightsConnectionStringSecretUri string = functionAppApplicationInsightsConnectionStringSecret.properties.secretUriWithVersion
output cosmosDbConnectionStringSecretUri string = cosmosDbConnectionStringSecret.properties.secretUriWithVersion
output storageAccountConnectionStringSecretUri string = storageAccountConnectionStringSecret.properties.secretUriWithVersion
output eventHubSendAccessPolicySecretUri string = eventHubSendAccessPolicySecret.properties.secretUriWithVersion
output eventHubListenAccessPolicySecretUri string = eventHubListenAccessPolicySecret.properties.secretUriWithVersion
