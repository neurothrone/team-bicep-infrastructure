metadata name = 'Team Bicep Microservices'
metadata author = 'Team Bicep'
metadata description = 'Bicep template to deploy a microservices architecture using Azure Container Apps, including backend and frontend services, with integrated monitoring and security features.'

@description('The location to deploy all resources')
param location string = resourceGroup().location

@description('The name of the log analytics workspace')
param logAnalyticsWorkspaceName string

@description('The name of the Container App Environment')
param containerAppEnvironmentName string

@description('The name of the Container Registry')
param containerRegistryName string

@description('The name of the Key Vault')
param keyVaultName string

@description('The container image used by the Backend')
param backendImage string

@description('The container image used by the Frontend')
param frontendImage string

@description('The revision suffix for the Frontend deployment')
param frontendRevisionSuffix string

@description('The revision suffix for the Backend deployment')
param BackendRevisionSuffix string

@description('Whether to use a placeholder image in the Container Registry module for initial setup')
param usePlaceHolderImage bool

@description('Tags to be applied to all resources')
param tags object = {}

module logAnalyticsModule 'core/monitor/log-analytics.bicep' = {
  name: 'logAnalyticsModule'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    tags: tags
  }
}

module keyVaultModule 'core/security/key-vault.bicep' = {
  name: 'keyVaultModule'
  params: {
    location: location
    keyVaultName: keyVaultName
    tags: tags
  }
}

module containerRegistryModule 'core/host/container-registry.bicep' = {
  name: 'containerRegistryModule'
  params: {
    location: location
    containerRegistryName: containerRegistryName
    usePlaceHolderImage: usePlaceHolderImage
    tags: tags
  }
}

module containerAppEnvironmentModule 'core/host/container-app-env.bicep' = {
  name: 'containerAppEnvironmentModule'
  params: {
    location: location
    containerAppEnvironmentName: containerAppEnvironmentName
    containerRegistryName: containerRegistryModule.outputs.name
    logAnalyticsName: logAnalyticsModule.outputs.name
    tags: tags
  }
}

module backendModule 'apps/backend.bicep' = {
  name: 'backendModule'
  params: {
    location: location
    containerAppEnvironmentName: containerAppEnvironmentModule.outputs.containerAppEnvName
    containerRegistryName: containerRegistryModule.outputs.name
    keyVaultName: keyVaultModule.outputs.name
    imageName: backendImage
    BackendRevisionSuffix: BackendRevisionSuffix
    tags: tags
  }
}

module frontendModule 'apps/frontend.bicep' = {
  name: 'frontendModule'
  params: {
    location: location
    containerAppEnvironmentName: containerAppEnvironmentModule.outputs.containerAppEnvName
    containerRegistryName: containerRegistryModule.outputs.name
    keyVaultName: keyVaultModule.outputs.name
    imageName: frontendImage
    frontendRevisionSuffix: frontendRevisionSuffix
    backendFqdn: backendModule.outputs.fqdn
    tags: tags
  }
}
