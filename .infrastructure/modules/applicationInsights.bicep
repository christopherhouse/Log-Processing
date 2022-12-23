param applicationInsightsName string
param region string
param logAnalyticsWorkspaceId string
param keyVaultName string
param instrumentationKeySecretName string
param connectionStringSecretName string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: region
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'IbizaAIExtension'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource instrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: instrumentationKeySecretName
  properties: {
    value: applicationInsights.properties.InstrumentationKey
  }
}

resource connectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: connectionStringSecretName
  properties: {
    value: applicationInsights.properties.ConnectionString
  }
}
