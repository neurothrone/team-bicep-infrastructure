using 'main.bicep'

param logAnalyticsSettings = {
  logAnalyticsWorkspaceName: 'law-team-bicep-prod'
}

param containerRegistrySettings = {
  containerRegistryName: 'crteambicepprod'
}

param containerAppEnvironmentSettings = {
  containerAppEnvironmentName: 'cae-team-bicep-prod'
  containerRegistryName: containerRegistrySettings.containerRegistryName
  logAnalyticsWorkspaceName: logAnalyticsSettings.logAnalyticsWorkspaceName
}

param keyVaultSettings = {
  keyVaultName: 'kv-teambicepprod'
}

param usePlaceHolderImage = true

param backendSettings = {
  backendContainerAppName: 'team-bicep-backend'
  backendImageName: 'crteambicepprod.azurecr.io/azuredocs/containerapps-helloworld:latest'
  backendRevisionSuffix: ''
  containerAppEnvironmentName: containerAppEnvironmentSettings.containerAppEnvironmentName
  containerRegistryName: containerRegistrySettings.containerRegistryName
  keyVaultName: keyVaultSettings.keyVaultName
}

param frontendSettings = {
  frontendContainerAppName: 'team-bicep-frontend'
  frontendImageName: 'crteambicepprod.azurecr.io/azuredocs/containerapps-helloworld:latest'
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
