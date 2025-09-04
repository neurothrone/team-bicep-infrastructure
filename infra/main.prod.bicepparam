using 'main.bicep'

param appInsightsName =  'appi-team-bicep-prod'

param containerAppEnvironmentName = 'cae-team-bicep-prod'

param logAnalyticsWorkspaceName = 'law-team-bicep-prod'

param containerRegistryName = 'crteambicepprod'

param keyVaultName = 'kv-teambicepprod'

param backendImage = 'teambicep/backend:latest'

param frontendImage = 'teambicep/frontend:latest'

param tags = {
  environment: 'prod'
  owner: 'Team Bicep'
  project: 'team-bicep'
  costCenter: 'IT'
  deployedBy: 'Bicep'
}
