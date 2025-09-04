# Team Bicep Infrastructure

## Commands

```shell
az deployment group create \
  --resource-group rg-team-bicep \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.prod.bicepparam \
  --confirm-with-what-if \
  --debug
```
