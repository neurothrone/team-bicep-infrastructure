using 'main.bicep'

param containerAppEnvironmentName = 'cae-team-bicep-prod'
param logAnalyticsWorkspaceName = 'law-team-bicep-prod'
param containerRegistryName = 'crteambicepprod'
param keyVaultName = 'kv-teambicepprod'

param usePlaceHolderImage = false

param backendImage = 'crteambicepprod.azurecr.io/teambicep/backend:latest'
param backendRevisionSuffix  = ''

param frontendImage = 'crteambicepprod.azurecr.io/teambicep/frontend:latest'
param frontendRevisionSuffix  = ''

param tags = {
  environment: 'prod'
  owner: 'Team Bicep'
  project: 'team-bicep'
  costCenter: 'IT'
  deployedBy: 'Bicep'
}
