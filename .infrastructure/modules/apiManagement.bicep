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
@secure()
param devPortalClientId string
@secure()
param devPortalClientSecret string

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

resource identityProvider 'Microsoft.ApiManagement/service/identityProviders@2022-04-01-preview' = {
  name: 'aad'
  parent: apiManagement
  properties: {
    allowedTenants: [
      subscription().tenantId
    ]
    clientId: devPortalClientId
    clientSecret: devPortalClientSecret
    signinTenant: subscription().tenantId
    authority: 'login.windows.net'
  }
}

resource portalConfig 'Microsoft.ApiManagement/service/portalconfigs@2022-04-01-preview' = {
  name: 'portalconfig'
  parent: apiManagement
  properties: {
    enableBasicAuth: false
  }
}

output managedIdentityObjectId string = apiManagement.identity.principalId
output name string = apiManagement.name
output id string = apiManagement.id
