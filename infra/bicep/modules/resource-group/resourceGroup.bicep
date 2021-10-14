targetScope = 'subscription'

param location string = deployment().location
param name string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  location: location
  name: name
}
output resourceGroupId string = resourceGroup.id
output resourceGroupName string = resourceGroup.name
