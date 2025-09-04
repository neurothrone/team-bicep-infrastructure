using 'main.bicep'

// param appInsightsName =  'appi-team-bicep-prod'

param containerAppEnvironmentName = 'cae-team-bicep-prod'

param logAnalyticsWorkspaceName = 'law-team-bicep-prod'

param usePlaceHolderImage = true

param containerRegistryName = 'crteambicepprod'

param keyVaultName = 'kv-teambicepprod'

param backendImage = 'crteambicepprod.azurecr.io/azuredocs/containerapps-helloworld:latest'

param frontendImage = 'crteambicepprod.azurecr.io/azuredocs/containerapps-helloworld:latest'
param tags = {
  environment: 'prod'
  owner: 'Team Bicep'
  project: 'team-bicep'
  costCenter: 'IT'
  deployedBy: 'Bicep'
}
