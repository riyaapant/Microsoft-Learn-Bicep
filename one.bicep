resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'rpsa001'
  location: 'westeurope'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'rpasp001'
  location: 'westeurope'
  sku: {
    name: 'F1'
  }
}

resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = {
  name: 'rpapp001'
  location: 'westeurope'
  properties: { serverFarmId: appServicePlan.id, httpsOnly: true }
}
