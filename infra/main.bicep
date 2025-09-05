metadata name = 'Team Bicep Microservices'
metadata author = 'Team Bicep'
metadata description = 'Bicep template to deploy a microservices architecture using Azure Container Apps, including backend and frontend services, with integrated monitoring and security features.'

// !: --- Imports ---
import { LogAnalyticsSettingsType } from 'core/monitor/log-analytics.bicep'
import { ContainerRegistrySettingsType } from 'core/host/container-registry.bicep'
import { ContainerAppEnvironmentSettingsType } from 'core/host/container-app-env.bicep'
import { KeyVaultSettingsType } from 'core/security/key-vault.bicep'
import { BackendSettingsType } from 'apps/backend.bicep'
import { FrontendSettingsType } from 'apps/frontend.bicep'

// !: --- Parameters ---
@description('The location to deploy all resources')
param location string = resourceGroup().location

@description('The settings for the Log Analytics workspace that will be deployed')
param logAnalyticsSettings LogAnalyticsSettingsType

@description('The settings for the Container Registry that will be deployed')
param containerRegistrySettings ContainerRegistrySettingsType

@description('The settings for the Container App Environment that will be deployed')
param containerAppEnvironmentSettings ContainerAppEnvironmentSettingsType

@description('The settings for the Key Vault that will be deployed')
param keyVaultSettings KeyVaultSettingsType

@description('The settings for the Backend Container App that will be deployed')
param backendSettings BackendSettingsType

@description('The settings for the Frontend Container App that will be deployed')
param frontendSettings FrontendSettingsType

@description('Tags to be applied to all resources')
param tags object = {}

// !: --- Modules ---
module logAnalyticsModule 'core/monitor/log-analytics.bicep' = {
  name: 'logAnalyticsModule'
  params: {
    location: location
    settings: logAnalyticsSettings
    tags: tags
  }
}

module keyVaultModule 'core/security/key-vault.bicep' = {
  name: 'keyVaultModule'
  params: {
    location: location
    settings: keyVaultSettings
    tags: tags
  }
}

module containerRegistryModule 'core/host/container-registry.bicep' = {
  name: 'containerRegistryModule'
  params: {
    location: location
    settings: containerRegistrySettings
    tags: tags
  }
}

module containerAppEnvironmentModule 'core/host/container-app-env.bicep' = {
  name: 'containerAppEnvironmentModule'
  params: {
    location: location
    settings: containerAppEnvironmentSettings
    tags: tags
  }
  dependsOn: [
    logAnalyticsModule
    containerRegistryModule
  ]
}

module backendModule 'apps/backend.bicep' = {
  name: 'backendModule'
  params: {
    location: location
    settings: backendSettings
    tags: tags
  }
  dependsOn: [
    containerRegistryModule
    containerAppEnvironmentModule
    keyVaultModule
  ]
}

module frontendModule 'apps/frontend.bicep' = {
  name: 'frontendModule'
  params: {
    location: location
    settings: frontendSettings
    backendFqdn: backendModule.outputs.fqdn
    tags: tags
  }
  dependsOn: [
    containerRegistryModule
    containerAppEnvironmentModule
    keyVaultModule
    backendModule
  ]
}
