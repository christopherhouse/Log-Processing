param registryName string
param region string

resource registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: registryName
  location: region
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
  }
}
