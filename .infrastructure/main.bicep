param apimResourceName string
param location string = resourceGroup().location

var theName = '${apimResourceName}-${location}'

resource apim 'Microsoft.ApiManagement/service@2019-01-01' = {
  name: theName
  location: location
  sku: {
    name: 'Developer'
    capacity: 1
  }
  properties: {
    publisherEmail: 'chhouse@microsoft.com'
    publisherName: 'chhouse'
  }
}
