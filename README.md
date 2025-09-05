# Team Bicep Infrastructure

## Commands

### MacOS/Linux

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

### Windows

```shell
# Initial deployment
az deployment group create `
  --resource-group rg-team-bicep `
  --template-file ./infra/main.bicep `
  --parameters ./infra/setup.bicepparam `
  --confirm-with-what-if `
  --debug

# Continuous deployment
az deployment group create `
  --resource-group rg-team-bicep `
  --template-file ./infra/main.bicep `
  --parameters ./infra/main.prod.bicepparam `
  --confirm-with-what-if `
  --debug
```
