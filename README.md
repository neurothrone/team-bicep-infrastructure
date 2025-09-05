# Team Bicep Infrastructure

## Commands

```shell
# Initial deployment
az deployment group create \
  --resource-group rg-team-bicep \
  --template-file ./infra/main.bicep \
  --parameters ./infra/setup.bicepparam \
  --confirm-with-what-if \
  --debug

# Continuous deployment
az deployment group create \
  --resource-group rg-team-bicep \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.prod.bicepparam \
  --confirm-with-what-if \
  --debug
```
