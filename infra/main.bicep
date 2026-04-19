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

param nicName string = 'nic-${environment}-vm01'

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
    publicIpName: 'pip-${environment}'
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
}

output vnetId string = network.outputs.vnetId
output nsgId string = nsg.outputs.nsgId
output nicId string = nic.outputs.nicId
output publicIpId string = publicIp.outputs.publicIpId
