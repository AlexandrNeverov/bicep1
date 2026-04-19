param location string
param environment string

param vnetName string = 'vnet-${environment}'
param addressPrefix string = '10.0.0.0/16'

param webSubnetName string = 'web-subnet'
param webSubnetPrefix string = '10.0.1.0/24'

param dbSubnetName string = 'db-subnet'
param dbSubnetPrefix string = '10.0.2.0/24'

param gatewaySubnetName string = 'appgw'
param gatewaySubnetPrefix string = '10.0.3.0/24'

param nsgName string = 'web-nsg-${environment}'
param allowedSshSource string = '*'

param publicIpName string = 'pip-${environment}'
param nicName string = 'nic-${environment}-vm01'
param vmName string = 'vm-${environment}-01'

param adminUsername string
@secure()
param adminPassword string

param vmSize string = 'Standard_NV4as_v4'

param sqlServerName string = 'neverov-sql-${environment}'
param dbName string = 'appdb'

param sqlAdminUsername string
@secure()
param sqlAdminPassword string

module network './modules/network.bicep' = {
  name: 'network-${environment}'
  params: {
    location: location
    vnetName: vnetName
    addressPrefix: addressPrefix
    webSubnetName: webSubnetName
    webSubnetPrefix: webSubnetPrefix
    dbSubnetName: dbSubnetName
    dbSubnetPrefix: dbSubnetPrefix
    gatewaySubnetName: gatewaySubnetName
    gatewaySubnetPrefix: gatewaySubnetPrefix
  }
}

module nsg './modules/nsg.bicep' = {
  name: 'nsg-${environment}'
  params: {
    location: location
    nsgName: nsgName
    allowedSshSource: allowedSshSource
  }
  dependsOn: [
    network
  ]
}

module publicIp './modules/public_ip.bicep' = {
  name: 'pip-${environment}'
  params: {
    location: location
    publicIpName: publicIpName
  }
  dependsOn: [
    network
  ]
}

module nic './modules/nic.bicep' = {
  name: 'nic-${environment}'
  params: {
    location: location
    nicName: nicName
    subnetId: network.outputs.webSubnetId
    publicIpId: publicIp.outputs.publicIpId
  }
  dependsOn: [
    network
    nsg
    publicIp
  ]
}

module vm './modules/vm.bicep' = {
  name: 'vm-${environment}'
  params: {
    location: location
    vmName: vmName
    nicId: nic.outputs.nicId
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
  }
  dependsOn: [
    publicIp
    nic
  ]
}

module sql './modules/sql.bicep' = {
  name: 'sql-${environment}'
  params: {
    location: location
    sqlServerName: sqlServerName
    adminUsername: sqlAdminUsername
    adminPassword: sqlAdminPassword
    dbName: dbName
  }
  dependsOn: [
    vm
  ]
}

output vnetId string = network.outputs.vnetId
output webSubnetId string = network.outputs.webSubnetId
output dbSubnetId string = network.outputs.dbSubnetId
output gatewaySubnetId string = network.outputs.gatewaySubnetId

output nsgId string = nsg.outputs.nsgId
output publicIpId string = publicIp.outputs.publicIpId
output nicId string = nic.outputs.nicId
output vmId string = vm.outputs.vmId

output sqlServerName string = sql.outputs.sqlServerName
output sqlDbName string = sql.outputs.sqlDbName
