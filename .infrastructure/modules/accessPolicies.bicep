param keyVaultName string
param applicationIds array

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

resource appAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = [for appId in applicationIds: {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: appId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}]
