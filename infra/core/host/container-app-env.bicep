// !: --- Imports ---
import { acrPullRoleId } from '../../shared/roles.bicep'

@export()
type ContainerAppEnvironmentSettingsType = {
  @description('The name of the Container App Environment that will be deployed')
  containerAppEnvironmentName: string

  @description('The name of the Container Registry that this Container App environment will pull images from')
  containerRegistryName: string

  @description('The name of the Log Analytics workspace that this Container App environment sends logs to')
  logAnalyticsWorkspaceName: string
}

@description('The location that the Container App Environment will be deployed')
param location string

@description('The settings for the Container App Environment that will be deployed')
param settings ContainerAppEnvironmentSettingsType

@description('The tags that will be applied to the Container App Environment')
param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: settings.logAnalyticsWorkspaceName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: settings.containerRegistryName
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-08-02-preview' = {
  location: location
  name: settings.containerAppEnvironmentName
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, containerAppEnvironment.id, acrPullRoleId)
  scope: containerRegistry
  properties: {
    #disable-next-line use-resource-id-functions
    roleDefinitionId: acrPullRoleId
    principalId: containerAppEnvironment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

@description('The name of the Container App Environment')
output containerAppEnvName string = containerAppEnvironment.name

@description('The resource Id of the Container App Environment')
output containerAppEnvId string = containerAppEnvironment.id
