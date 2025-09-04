// !: --- Imports ---
import { acrPullRoleId, kvSecretUserRoleId } from '../shared/roles.bicep'

@description('The location where the Frontend will be deployed to')
param location string

@description('The Container App environment that the Container App will be deployed to')
param containerAppEnvironmentName string

@description('The name of the Container Registry that this Container App pull images')
param containerRegistryName string

@description('The name of the Key Vault that this Container App will pull secrets from')
param keyVaultName string

@description('The container image that this Container App will use')
param imageName string

@description('The revision suffix for the Frontend deployment')
param frontendRevisionSuffix string

@description('The Backend API FQDN that this Frontend will communicate with')
param backendFqdn string

@description('The tags that will be applied to the Frontend UI')
param tags object

var containerAppName = 'team-bicep-frontend'

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-08-02-preview' existing = {
  name: containerAppEnvironmentName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}

resource pullManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${uniqueString(resourceGroup().id, 'backend-pull')}'
  location: location
}

resource acrPullRoleAssigment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
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

resource frontendContainerApp 'Microsoft.App/containerApps@2024-08-02-preview' = {
  name: containerAppName
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
      revisionSuffix: frontendRevisionSuffix
      containers: [
        {
          name: containerAppName
          image: imageName
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Development'
            }
            {
              name: 'BackendApi'
              value: 'https://${backendFqdn}'
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
    acrPullRoleAssigment
    keyVaultSecretsUser
  ]
}
