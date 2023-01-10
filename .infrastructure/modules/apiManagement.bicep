param apiManagementName string
param region string
param publisherEmail string
param publisherName string

resource apiManagement 'Microsoft.ApiManagement/service@2022-04-01-preview' = {
  name: apiManagementName
  location: region
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output managedIdentityObjectId string = apiManagement.identity.principalId
output name string = apiManagement.name
output id string = apiManagement.id
