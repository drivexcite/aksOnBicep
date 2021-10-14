targetScope = 'subscription'

param resourceGroupName string = 'HackaTonaRG'
param acrName string = 'hackatonacr'
param aksClusterName string = 'HackaTonaAks'

module rg 'modules/resource-group/resourceGroup.bicep' = {
  name: resourceGroupName
  params: {
    name: resourceGroupName
    location: deployment().location
  }
}

module aks 'modules/kubernetes/aks.bicep' = {
  scope: resourceGroup(rg.name)
  name: aksClusterName
  params: {
    location: deployment().location
    clusterName: aksClusterName    
  }
}

module acr 'modules/container-registry/acr.bicep' = {
  scope: resourceGroup(rg.name)
  name: acrName
  params: {
    name: acrName
    aksPrincipalId: aks.outputs.managedIdentityId
  }
}
