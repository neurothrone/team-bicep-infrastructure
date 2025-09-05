// !: --- Imports ---
import { acrPullRoleId, kvSecretUserRoleId } from '../shared/roles.bicep'

@export()
type BackendSettingsType = {
  @description('The name of the Container App that will be deployed')
  backendContainerAppName: string

  @description('The container image that this Container App will use')
  backendImageName: string

  @description('The revision suffix for the Backend deployment')
  backendRevisionSuffix: string

  @description('The Container App environment that the Container App will be deployed to')
  containerAppEnvironmentName: string

  @description('The name of the Container Registry that this Container App pull images')
  containerRegistryName: string

  @description('The name of the Key Vault that this Container App will pull secrets from')
  keyVaultName: string
}

@description('The location where the Backend will be deployed to')
param location string

@description('The settings for the Backend Container App that will be deployed')
param settings BackendSettingsType

@description('The tags that will be applied to the Backend Container App')
param tags object

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-08-02-preview' existing = {
  name: settings.containerAppEnvironmentName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: settings.containerRegistryName
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: settings.keyVaultName
}

resource pullManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${uniqueString(resourceGroup().id, 'backend-pull')}'
  location: location
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, pullManagedIdentity.id, acrPullRoleId)
  scope: containerRegistry
  properties: {
    #disable-next-line use-resource-id-functions
    roleDefinitionId: acrPullRoleId
    principalId: pullManagedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, pullManagedIdentity.id, kvSecretUserRoleId)
  scope: keyVault
  properties: {
    #disable-next-line use-resource-id-functions
    roleDefinitionId: kvSecretUserRoleId
    principalId: pullManagedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource backendContainerApp 'Microsoft.App/containerApps@2024-08-02-preview' = {
  name: settings.backendContainerAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
      registries: [
        {
          server: containerRegistry.properties.loginServer
          identity: pullManagedIdentity.id
        }
      ]
    }
    template: {
      revisionSuffix: settings.backendRevisionSuffix
      containers: [
        {
          name: settings.backendContainerAppName
          image: settings.backendImageName
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Development'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${pullManagedIdentity.id}': {}
    }
  }
  dependsOn: [
    acrPullRoleAssignment
    keyVaultSecretsUser
  ]
}

@description('The FQDN for the Backend Container App')
output fqdn string = backendContainerApp.properties.configuration.ingress.fqdn
