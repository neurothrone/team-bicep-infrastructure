using 'main.bicep'

// param appInsightsName =  'appi-team-bicep-prod'

param BackendRevisionSuffix  = ''
param frontendRevisionSuffix  = ''

param containerAppEnvironmentName = 'cae-team-bicep-prod'

param logAnalyticsWorkspaceName = 'law-team-bicep-prod'

param containerRegistryName = 'crteambicepprod'

param usePlaceHolderImage = false

param keyVaultName = 'kv-teambicepprod'

param backendImage = 'crteambicepprod.azurecr.io/teambicep/backend:latest'

param frontendImage = 'crteambicepprod.azurecr.io/teambicep/frontend:latest'

param tags = {
  environment: 'prod'
  owner: 'Team Bicep'
  project: 'team-bicep'
  costCenter: 'IT'
  deployedBy: 'Bicep'
}
