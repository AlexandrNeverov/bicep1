param location string
param appGwName string

param gatewaySubnetId string
param publicIpId string
param backendNicId string

resource appGw 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: appGwName
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }

    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: gatewaySubnetId
          }
        }
      }
    ]

    frontendIPConfigurations: [
      {
        name: 'frontendIp'
        properties: {
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]

    frontendPorts: [
      {
        name: 'httpPort'
        properties: {
          port: 80
        }
      }
    ]

    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: reference(backendNicId, '2023-09-01').ipConfigurations[0].properties.privateIPAddress
            }
          ]
        }
      }
    ]

    backendHttpSettingsCollection: [
      {
        name: 'httpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
        }
      }
    ]

    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'frontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'httpPort')
          }
          protocol: 'Http'
        }
      }
    ]

    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'backendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'httpSettings')
          }
        }
      }
    ]
  }
}

output appGwId string = appGw.id
