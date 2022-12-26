param keyVaultName string
param apimApplicationInisightsName string

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: apimApplicationInisightsName
  scope: resourceGroup()
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

resource appInsightsInstrumentationKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'apimApplicationInsightsInstrumentationKey'
  parent: keyVault
  properties: {
    value: appInsights.properties.InstrumentationKey
  }
}

resource apimApplicationInsightsConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'apimApplicationInsightsConnectionString'
  parent: keyVault
  properties: {
    value: appInsights.properties.ConnectionString
  }
}
