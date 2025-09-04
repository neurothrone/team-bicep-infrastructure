using 'main.bicep'

param logAnalyticsSettings = {
  logAnalyticsWorkspaceName: 'law-team-bicep-prod'
}

param containerRegistrySettings = {
  containerRegistryName: 'crteambicepprod'
  usePlaceHolderImage: false
}

param containerAppEnvironmentSettings = {
  containerAppEnvironmentName: 'cae-team-bicep-prod'
  containerRegistryName: containerRegistrySettings.containerRegistryName
  logAnalyticsWorkspaceName: logAnalyticsSettings.logAnalyticsWorkspaceName
}

param keyVaultSettings = {
  keyVaultName: 'kv-teambicepprod'
}

param backendSettings = {
  backendContainerAppName: 'team-bicep-backend'
  backendImageName: 'crteambicepprod.azurecr.io/teambicep/backend:latest'
  backendRevisionSuffix: ''
  containerAppEnvironmentName: containerAppEnvironmentSettings.containerAppEnvironmentName
  containerRegistryName: containerRegistrySettings.containerRegistryName
  keyVaultName: keyVaultSettings.keyVaultName
}

param frontendSettings = {
  frontendContainerAppName: 'team-bicep-frontend'
  frontendImageName: 'crteambicepprod.azurecr.io/teambicep/frontend:latest'
  frontendRevisionSuffix: ''
  containerAppEnvironmentName: containerAppEnvironmentSettings.containerAppEnvironmentName
  containerRegistryName: containerRegistrySettings.containerRegistryName
  keyVaultName: keyVaultSettings.keyVaultName
}

param tags = {
  environment: 'prod'
  owner: 'Team Bicep'
  project: 'team-bicep'
  costCenter: 'IT'
  deployedBy: 'Bicep'
}
