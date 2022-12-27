param eventHubNamespaceName string
param eventHubHubName string
param eventHubConsumerGroupName string
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

resource rootSendAccessPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: 'rootSendAccessPolicy'
  parent: namespace
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource rootListenAccessPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: 'rootListenAccessPolicy'
  parent: namespace
  properties: {
    rights: [
      'Listen'
    ]
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

resource eventHubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  name: eventHubConsumerGroupName
  parent: eventHub
}

output name string = namespace.name
