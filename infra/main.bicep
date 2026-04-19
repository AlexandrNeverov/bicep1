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

output vnetId string = network.outputs.vnetId
