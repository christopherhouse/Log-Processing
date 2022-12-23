param logAnalyticsWorkspaceName string
param region string

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: region
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output id string = workspace.id
