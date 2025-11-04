targetScope = 'resourceGroup'

@description('Location for all resources')
param location string

@description('App Service Plan name')
param appServicePlanName string

@description('App Service name')
param webAppName string

@description('App Service pricing tier')
param skuName string = 'B1'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'Basic'
    size: skuName
    capacity: 1
  }
  kind: 'app'
  properties: {
    reserved: false
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      http20Enabled: true
      netFrameworkVersion: 'v8.0'
    }
  }
  dependsOn: [
    appServicePlan
  ]
}

resource configMetadata 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webApp
  name: 'metadata'
  properties: {
    CURRENT_STACK: 'dotnet'
    FRAMEWORK: 'dotnet'
    FRAMEWORK_VERSION: 'v8.0'
  }
}

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
