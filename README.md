# Team Bicep Infrastructure

## Commands

```shell
# Use the Azure CLI to deploy the Bicep template with json parameters file
az deployment group create \
  --resource-group rg-team-bicep \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.parameters.prod.json

# Use the Azure CLI to deploy the Bicep template with bicep parameters file
az deployment group create \
  --resource-group rg-team-bicep \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.prod.bicepparam
```
