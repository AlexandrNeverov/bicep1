@secure()

param adminPassword string
param adminUsername string = 'azureuser'

param vmSize string = 'Standard_D2s_v3'

param location string = 'centralus'
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

}
module sql './modules/sql.bicep' = {

  name: 'sql-${environment}'

  params: {

    location: location

    sqlServerName: 'neverov-sql-${environment}'

    adminUsername: adminUsername

    adminPassword: adminPassword

    dbName: 'appdb'

  }
 
} 
  module observability './modules/observability.bicep' = {

  name: 'obs-${environment}'

  params: {

    location: location

    workspaceName: 'log-${environment}'

    appInsightsName: 'appi-${environment}'

  }
  
}

resource appGw 'Microsoft.Network/applicationGateways@2023-09-01' existing = {
  name: 'appgw-${environment}'
}

resource appGwDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'appgw-diag'
  scope: appGw
  properties: {
    workspaceId: observability.outputs.workspaceId
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource vmExisting 'Microsoft.Compute/virtualMachines@2023-09-01' existing = {
  name: 'vm-${environment}-01'
}

resource amaVmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  name: 'AzureMonitorWindowsAgent'
  parent: vmExisting
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: 'dcr-${environment}-vm'
  location: location
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'perfCounters'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\Processor(_Total)\\% Processor Time'
            '\\Memory\\Available MBytes'
            '\\LogicalDisk(_Total)\\% Free Space'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'laDest'
          workspaceResourceId: observability.outputs.workspaceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Perf'
        ]
        destinations: [
          'laDest'
        ]
      }
    ]
  }
}

resource dcrAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = {
  name: 'assoc-${environment}-vm'
  scope: vmExisting
  properties: {
    dataCollectionRuleId: dcr.id
  }
}


output vnetId string = network.outputs.vnetId
output webSubnetId string = network.outputs.webSubnetId
output dbSubnetId string = network.outputs.dbSubnetId
output gatewaySubnetId string = network.outputs.gatewaySubnetId
