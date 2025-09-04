using 'main.bicep'

param containerAppEnvironmentName = 'cae-team-bicep-prod'
param logAnalyticsWorkspaceName = 'law-team-bicep-prod'
param containerRegistryName = 'crteambicepprod'
param keyVaultName = 'kv-teambicepprod'

param usePlaceHolderImage = true

param backendImage = 'crteambicepprod.azurecr.io/azuredocs/containerapps-helloworld:latest'
param backendRevisionSuffix  = ''

param frontendImage = 'crteambicepprod.azurecr.io/azuredocs/containerapps-helloworld:latest'
param frontendRevisionSuffix  = ''

param tags = {
  environment: 'prod'
  owner: 'Team Bicep'
  project: 'team-bicep'
  costCenter: 'IT'
  deployedBy: 'Bicep'
}
