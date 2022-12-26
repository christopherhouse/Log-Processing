param apimResourceName string
param appInsightsInstrumentationKeySecretUri string

resource apim 'Microsoft.ApiManagement/service@2022-04-01-preview' existing = {
  name: apimResourceName
}

resource apppInsightsInstrumentationKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-04-01-preview' = {
  name: 'appInsightsInstrumentationKey'
  parent: apim
  properties: {
    displayName: 'appInsightsInstrumentationKey'
    keyVault: {
      secretIdentifier: appInsightsInstrumentationKeySecretUri
    }
    secret: true
  }
}
