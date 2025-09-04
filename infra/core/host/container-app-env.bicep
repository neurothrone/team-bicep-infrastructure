@description('The name of the Container App Environment that will be deployed')
param containerAppEnvironmentName string

@description('The name of the Log Analytics workspace that this Container App environment sends logs to')
param logAnalyticsName string

@description('The location that the Container App Environment will be deployed')
param location string

@description('The tags that will be applied to the Container App Environment')
param tags object

param containerRegistryName string

var acrPullRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
)

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-08-02-preview' = {
  name: containerAppEnvironmentName
  location: location
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
    principalId: containerAppEnvironment.identity.principalId
    roleDefinitionId: acrPullRoleId
    principalType: 'ServicePrincipal'
  }
}

@description('The name of the Container App Environment')
output containerAppEnvName string = containerAppEnvironment.name

@description('The resource Id of the Container App Environment')
output containerAppEnvId string = containerAppEnvironment.id
