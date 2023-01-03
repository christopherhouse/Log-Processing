param iotHubName string
param region string

resource iotHub 'Microsoft.Devices/IotHubs@2022-04-30-preview' = {
  name: iotHubName
  location: region
  sku: {
    name: 'B1'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

output managedIdentityObjectId string = iotHub.identity.principalId
