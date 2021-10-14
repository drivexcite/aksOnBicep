param location string
param prefix string = 'dev'
param clusterName string

@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
  'Premium'
])
param workspaceTier string = 'PerGB2018'
param nodeCount int = 3
param osDiskSizeGB int = 64
param vmSize string = 'Standard_B2ms'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${prefix}-oms-${clusterName}-${resourceGroup().location}'
  location: location
  properties: {
    sku: {
      name: workspaceTier
    }
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'linux1'
        count: nodeCount
        vmSize: vmSize
        osType: 'Linux'
        osDiskSizeGB: osDiskSizeGB
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }      
    ]
    addonProfiles: {
      azurepolicy: {
        enabled: false
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      }   
    }
  }  
}

output managedIdentity object = aks.identity
output managedIdentityId string = aks.properties.identityProfile.kubeletidentity.objectId
