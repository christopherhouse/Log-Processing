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

output managedIdentityObjectId string = apiManagement.identity.principalId
