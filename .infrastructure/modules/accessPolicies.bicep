param keyVaultName string
param applicationIds array

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

resource appAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [for appId in applicationIds: {
      tenantId: subscription().tenantId
      objectId: appId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }]
  }
}
