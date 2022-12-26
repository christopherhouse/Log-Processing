param keyVaultName string
param region string
param applicationIds array
param adminIds array

var adminAccessPolicies = [for admin in adminIds: {
  tenantId: subscription().tenantId
  objectId: admin
  permissions: {
    secrets: [
      'all'
    ]
    certificates: [
      'all'
    ]
    keys: [
      'all'
    ]
  }
}]

var appAccessPolicies = [for appId in applicationIds: {
  tenantId: subscription().tenantId
  objectId: appId
  permissions: {
    secrets: [
      'get'
      'list'
    ]
  }
}]

var accessPolicies = union(adminAccessPolicies, appAccessPolicies)

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: region
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: accessPolicies
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
  }
}

output name string = keyVault.name
output id string = keyVault.id
