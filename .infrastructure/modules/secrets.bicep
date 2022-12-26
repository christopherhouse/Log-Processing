param keyVaultName string
param apimApplicationInisightsName string
param functionAppApplicationInsightsName string

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

output apimAppInsightsInstrumentationKeySecretUri string = apimAppInsightsInstrumentationKeySecret.properties.secretUri
output apimApplicationInsightsConnectionStringSecretUri string = apimApplicationInsightsConnectionStringSecret.properties.secretUri
output funtionAppAppInsightsInstrumentationKeySecretUri string = funtionAppAppInsightsInstrumentationKeySecret.properties.secretUri
output functionAppApplicationInsightsConnectionStringSecretUri string = functionAppApplicationInsightsConnectionStringSecret.properties.secretUri
