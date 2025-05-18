param location string = 'westeurope'
param storageAccountName string = 'rpsa${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'rpapp${uniqueString(resourceGroup().id)}'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var storageAccountSkuName = environmentType == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

module appService 'module/appService.bicep' = {
  name:'appService'
  params:{appServiceAppName:appServiceAppName
  location:location
environmentType:environmentType}
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
