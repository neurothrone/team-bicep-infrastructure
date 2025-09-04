@description('The location that the Container Registry will be deployed to')
param location string

@description('The name applied to the Container Registry')
param containerRegistryName string

@description('Whether to use a placeholder image in the Container Registry for initial setup')
param usePlaceHolderImage bool

@description('The tags that will be applied to the Container Registry')
param tags object

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: containerRegistryName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
  identity: {
    type: 'SystemAssigned'
  }
}

@description('This module seeds the ACR with the public version of the app')
module acrImportImage 'br/public:deployment-scripts/import-acr:3.0.1' = if (usePlaceHolderImage) {
  name: 'importContainerImageModule'
  params: {
    acrName: containerRegistryName
    location: location
    images: array('mcr.microsoft.com/azuredocs/containerapps-helloworld:latest')
  }
  dependsOn: [
    containerRegistry
  ]
}

@description('The name of the Container Registry')
output name string = containerRegistry.name
