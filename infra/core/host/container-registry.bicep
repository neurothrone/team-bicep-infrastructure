@description('The name applied to the Container Registry')
param containerRegistryName string

@description('The location that the Container Registry will be deployed to')
param location string

@description('The tags that will be applied to the Container Registry')
param tags object

@description('Specifies the docker container image to deploy.')
param containerImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

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
module acrImportImage 'br/public:deployment-scripts/import-acr:3.0.1' =  {
  name: 'importContainerImage'
  params: {
    acrName: containerRegistryName
    location: location
    images: array(containerImage)
  }
  dependsOn: [
    containerRegistry
  ]
}

@description('The name of the Container Registry')
output name string = containerRegistry.name
