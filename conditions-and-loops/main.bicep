@description('Regions to deploy the resources')
param locations array = [
  'westus'
  'eastus2'
  'eastasia'
]

@secure()
@description('Username for SQL Server admin')
param sqlServerAdministratorLogin string

@secure()
@description('Password for SQL Server admin')
param sqlServerAdministratorLoginPassword string

@description('IP address range for all virtual networks to use')
param virtualNetworkAddressPrefix string = '10.10.0.0/16'

@description('Name and IP address range for each subnet in the vnets')
param subnets array = [
  {
    name: 'frontend'
    ipAddressRange: '10.10.5.0/24'
  }
  {
    name: 'backend'
    ipAddressRange: '10.10.10.0/24'
  }
]

var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }
}]

module databases 'modules/database.bicep' = [for location in locations: {
  name:'database-${location}'
  params:{
    location:location
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}]

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2024-05-01' = [for location in locations: {
  name:'rp-${location}'
  location: location
  properties: {
    addressSpace:{
      addressPrefixes:[virtualNetworkAddressPrefix]
    }
    subnets: subnetProperties
  }
}]


output serverInfo array = [for i in range(0, length(locations)): {
  name: databases[i].outputs.serverName
  location: databases[i].outputs.location
  fullyQualifiedDomainName: databases[i].outputs.serverFullyQualifiedDomainName
}]
