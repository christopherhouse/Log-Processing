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

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  name: eventHubHubName
  parent: namespace
  properties: {
    partitionCount: 16
    messageRetentionInDays: 7
  }
}

resource hubSendAccessPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-01-01-preview' = {
  name: 'hubSendAccessPolicy'
  parent: eventHub
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource hubListenAccessPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-01-01-preview' = {
  name: 'hubListenAccessPolicy'
  parent: eventHub
  properties: {
    rights: [
      'Listen'
    ]
  }
}


resource eventHubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  name: eventHubConsumerGroupName
  parent: eventHub
}

output name string = namespace.name
output hubListenAccessKeyId string = hubListenAccessPolicy.id
output hubSendAccessKeyId string = hubSendAccessPolicy.id
output accessPolicyApiVersion string = hubListenAccessPolicy.apiVersion

