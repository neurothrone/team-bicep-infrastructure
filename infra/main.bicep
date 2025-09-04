metadata name = 'Team Bicep Microservices'
metadata author = 'Team Bicep'
metadata description = 'Bicep template to deploy a microservices architecture using Azure Container Apps, including backend and frontend services, with integrated monitoring and security features.'

@description('The location to deploy all resources')
param location string = resourceGroup().location

@description('The name of the log analytics workspace')
param logAnalyticsWorkspaceName string

// @description('The name of the Application Insights workspace')
// param appInsightsName string

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
    keyVaultName: keyVaultName
    location: location
    tags: tags
  }
}

// module appInsightsModule 'core/monitor/app-insights.bicep' = {
//   name: 'appInsightsModule'
//   params: {
//     appInsightsName: appInsightsName
//     keyVaultName: keyVaultModule.outputs.name
//     location: location
//     logAnalyticsName: logAnalyticsModule.outputs.name
//     tags: tags
//   }
// }

module containerRegistryModule 'core/host/container-registry.bicep' = {
  name: 'containerRegistryModule'
  params: {
    containerRegistryName: containerRegistryName
    location: location
    tags: tags
  }
}

module containerAppEnvironmentModule 'core/host/container-app-env.bicep' = {
  name: 'containerAppEnvironmentModule'
  params: {
    // appInsightsName: appInsightsModule.outputs.name
    containerRegistryName: containerRegistryModule.outputs.name
    containerAppEnvironmentName: containerAppEnvironmentName
    location: location
    logAnalyticsName: logAnalyticsModule.outputs.name
    tags: tags
  }
}

module backendModule 'apps/backend.bicep' = {
  name: 'backendModule'
  params: {
    containerAppEnvironmentName: containerAppEnvironmentModule.outputs.containerAppEnvName
    containerRegistryName: containerRegistryModule.outputs.name
    keyVaultName: keyVaultModule.outputs.name
    location: location
    tags: tags
    imageName: backendImage
  }
}

module frontendModule 'apps/frontend.bicep' = {
  name: 'frontendModule'
  params: {
    containerAppEnvironmentName: containerAppEnvironmentModule.outputs.containerAppEnvName
    containerRegistryName: containerRegistryModule.outputs.name
    keyVaultName: keyVaultModule.outputs.name
    location: location
    tags: tags
    imageName: frontendImage
    backendFqdn: backendModule.outputs.fqdn
  }
}
