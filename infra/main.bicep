@secure()

param adminPassword string
param adminUsername string = 'azureuser'

param vmSize string = 'Standard_D2s_v3'

param location string = 'eastus'
param environment string = 'dev'

param allowedSshSource string = '*'

param vnetName string = 'vnet-${environment}'
param addressPrefix string = '10.0.0.0/16'

param webSubnetName string = 'web-subnet'
param webSubnetPrefix string = '10.0.1.0/24'

param dbSubnetName string = 'db-subnet'
param dbSubnetPrefix string = '10.0.2.0/24'

param gatewaySubnetName string = 'appgw'
param gatewaySubnetPrefix string = '10.0.3.0/24'

module nsg './modules/nsg.bicep' = {
  name: 'web-nsg-${environment}'
  params: {
    location: location
    nsgName: 'web-nsg-${environment}'
    allowedSshSource: allowedSshSource
  }
}

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
    webNsgId: nsg.outputs.nsgId
  }
}

module nic './modules/nic.bicep' = {
  name: 'nic-${environment}-vm01'
  params: {
    location: location
    nicName: 'nic-${environment}-vm01'
    subnetId: network.outputs.webSubnetId
  }
}

module vm './modules/vm.bicep' = {
  name: 'vm-${environment}-01'
  params: {
    location: location
    vmName: 'vm-${environment}-01'
    nicId: nic.outputs.nicId
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
  }
}

module appGwPublicIp './modules/public_ip.bicep' = {

  name: 'appgw-pip-${environment}'

  params: {

    location: location

    publicIpName: 'pip-${environment}-appgw'

  }

}

module appGateway './modules/app_gateway.bicep' = {

  name: 'appgw-${environment}'

  params: {

    location: location

    appGwName: 'appgw-${environment}'

    gatewaySubnetId: network.outputs.gatewaySubnetId

    publicIpId: appGwPublicIp.outputs.publicIpId

    backendNicId: nic.outputs.nicId

  }
module sql './modules/sql.bicep' = {

  name: 'sql-${environment}'

  params: {

    location: location

    sqlServerName: 'sql-${environment}'

    adminUsername: adminUsername

    adminPassword: adminPassword

    dbName: 'appdb'

  }

}

}



output vnetId string = network.outputs.vnetId
output webSubnetId string = network.outputs.webSubnetId
output dbSubnetId string = network.outputs.dbSubnetId
output gatewaySubnetId string = network.outputs.gatewaySubnetId
