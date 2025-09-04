@description('The location where the Backend will be deployed to')
param location string

@description('The Container App environment that the Container App will be deployed to')
param containerAppEnvironmentName string

@description('The name of the Container Registry that this Container App pull images')
param containerRegistryName string

@description('The name of the Key Vault that this Container App will pull secrets from')
param keyVaultName string

@description('The container image that this Container App will use')
param imageName string

@description('The tags that will be applied to the Backend Container App')
param tags object

var containerAppName = 'team-bicep-backend'
var acrPullRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
) // AcrPull
var kvSecretUserRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '4633458b-17de-408a-b874-0445c86b69e6'
) // Key Vault Secrets User

resource env 'Microsoft.App/managedEnvironments@2024-08-02-preview' existing = {
  name: containerAppEnvironmentName
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}

resource pullMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${uniqueString(resourceGroup().id, 'backend-pull')}'
  location: location
}
resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, pullMi.id, acrPullRoleId)
  scope: acr
  properties: {
    roleDefinitionId: acrPullRoleId
    principalId: pullMi.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource kvSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kv.id, pullMi.id, kvSecretUserRoleId)
  scope: kv
  properties: {
    roleDefinitionId: kvSecretUserRoleId
    principalId: pullMi.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource backend 'Microsoft.App/containerApps@2024-08-02-preview' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        external: false
        targetPort: 8080
        transport: 'http'
      }
      registries: [
        {
          server: acr.properties.loginServer
          identity: pullMi.id
        }
      ]
      // secrets: [
      //   {
      //     name: 'app-insights-key'
      //     keyVaultUrl: 'https://${keyVault.name}.vault.azure.net/secrets/appinsightsinstrumentationkey'
      //     identity: 'system'
      //   }
      //   {
      //     name: 'app-insights-connection-string'
      //     keyVaultUrl: 'https://${keyVault.name}.vault.azure.net/secrets/appinsightsconnectionstring'
      //     identity: 'system'
      //   }
      // ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: imageName
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Development'
            }
            // {
            //   name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
            //   secretRef: 'app-insights-key'
            // }
            // {
            //   name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            //   secretRef: 'app-insights-connection-string'
            // }
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
      '${pullMi.id}': {}
    }
  }
  dependsOn: [ 
    acrPull
    kvSecretsUser
  ]
}

@description('The FQDN for the Backend Container App')
output fqdn string = backend.properties.configuration.ingress.fqdn
