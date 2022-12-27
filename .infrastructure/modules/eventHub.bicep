param eventHubNamespaceName string
param eventHubHubName string
param region string

resource namespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: eventHubNamespaceName
  location: region
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  name: eventHubHubName
  parent: namespace
  properties: {
    partitionCount: 16
    messageRetentionInDays: 7
  }
}
