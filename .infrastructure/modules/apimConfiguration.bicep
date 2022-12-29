param apimResourceName string
param appInsightsInstrumentationKeySecretUri string
param appInsightsResourceName string

var appInsightsInstrumentationKeyNamedValueName = 'appInsightsInstrumentationKey'

resource apim 'Microsoft.ApiManagement/service@2022-04-01-preview' existing = {
  name: apimResourceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsResourceName
}

resource apppInsightsInstrumentationKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-04-01-preview' = {
  name: appInsightsInstrumentationKeyNamedValueName
  parent: apim
  properties: {
    displayName: 'appInsightsInstrumentationKey'
    keyVault: {
      secretIdentifier: appInsightsInstrumentationKeySecretUri
    }
    secret: true
  }
}

resource appInsightsLogger 'Microsoft.ApiManagement/service/loggers@2022-04-01-preview' = {
  name: 'appInsightsLogger'
  parent: apim
  properties: {
    resourceId: appInsights.id
    loggerType: 'applicationInsights'
    description: 'Application Insights logger'
    credentials: {
      instrumentationKey: '{{${appInsightsInstrumentationKeyNamedValueName}}}'
    }
  }
}
