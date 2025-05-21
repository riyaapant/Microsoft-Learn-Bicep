@description('Location to deploy the azure resources in')
param location string

@secure()
@description('Username for SQL admin')
param sqlServerAdministratorLogin string

@secure()
@description('Password for SQL admin')
param sqlServerAdministratorLoginPassword string

@description('Name and tier of SQL Database SKU')
param sqlDatabaseSku object ={
  name:'Standard'
  tier:'Standard'
}

@description('The name of the environment: development or production')
@allowed([
  'Development'
  'Production'
])
param environmentName string = 'Development'

@description('The name of the audit storage account SKU')
param auditStorageAccountSkuName string = 'Standard_LRS'

var sqlServerName = 'rp${location}${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'RiyaDB'

var auditingEnabled = environmentName == 'Production'
var auditStorageAccountName = take('rpaudit${location}${uniqueString(resourceGroup().id)}',24)

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview'={
  name: sqlServerName
  location:location
  properties:{
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword:sqlServerAdministratorLoginPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: sqlDatabaseSku
}

resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = if (auditingEnabled) {
  name: auditStorageAccountName
  location: location
  sku: {
    name: auditStorageAccountSkuName
  }
  kind: 'StorageV2'
}


resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2024-05-01-preview' = if (auditingEnabled) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    storageEndpoint: environmentName == 'Production' ? auditStorageAccount.properties.primaryEndpoints.blob : ''
    storageAccountAccessKey: environmentName == 'Production' ? auditStorageAccount.listKeys().keys[0].value : ''
  }
}

output serverName string = sqlServer.name
output location string = location
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
