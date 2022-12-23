param keyVaultName string
param region string
param applicationIds array

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: region
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [for applicationId in applicationIds: {
      tenantId: subscription().tenantId
      objectId: applicationId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
  }]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
  }
}
