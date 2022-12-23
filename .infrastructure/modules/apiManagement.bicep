param apiManagementName string
param region string
param publisherEmail string
param publisherName string
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param skuName string = 'Developer'
param skuCount int = 1
param appInsightsInstrumentationKeySecretUri string

resource apiManagement 'Microsoft.ApiManagement/service@2022-04-01-preview' = {
  name: apiManagementName
  location: region
  sku: {
    name: skuName
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource applicationInsightsInstrumentationKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-04-01-preview' = {
  name: 'appInsightsInstrumentationKey'
  parent: apiManagement
  properties: {
    displayName: 'Application Insights Instrumentation Key'
    secret: true
    keyVault: {
      secretIdentifier: appInsightsInstrumentationKeySecretUri
    }
    tags: [
    ]
  }
}

resource appInsightsLogger 'Microsoft.ApiManagement/service/loggers@2022-04-01-preview' = {
  name: 'appInsightsLogger'
  parent: apiManagement
  properties: {
    loggerType: 'applicationInsights'
    description: 'Application Insights logger'
    credentials: {
      instrumentationKey: '{{appInsightsInstrumentationKey}}'
    }
  }
  dependsOn: [
    applicationInsightsInstrumentationKeyNamedValue
  ]
}

output managedIdentityObjectId string = apiManagement.identity.principalId
