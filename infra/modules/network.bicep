param location string
param vnetName string
param addressPrefix string

param webSubnetName string
param webSubnetPrefix string

param dbSubnetName string
param dbSubnetPrefix string

param gatewaySubnetName string = 'appgw'
param gatewaySubnetPrefix string = '10.0.3.0/24'

param webNsgId string

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: webSubnetName
        properties: {
          addressPrefix: webSubnetPrefix
          networkSecurityGroup: {
            id: webNsgId
          }
        }
      }
      {
        name: dbSubnetName
        properties: {
          addressPrefix: dbSubnetPrefix
        }
      }
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output webSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, webSubnetName)
output dbSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, dbSubnetName)
output gatewaySubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, gatewaySubnetName)
