param applicationInsightsName string
param region string
param logAnalyticsWorkspaceId string

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

output name string = applicationInsights.name
output id string = applicationInsights.id
