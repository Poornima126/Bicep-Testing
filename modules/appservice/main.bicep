targetScope = 'resourceGroup'

@description('Location for all resources')
param location string

@description('App Service Plan name')
param appServicePlanName string

@description('App Service name')
param webAppName string

@description('App Service pricing tier')
param skuName string = 'B1'

// App Service Plan - Windows
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'Basic'
    size: skuName
    capacity: 1
  }
  kind: 'app' // Windows plan
  properties: {
    reserved: false // false = Windows
  }
}

// Web App configured for .NET 8 (Windows)
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
      netFrameworkVersion: 'v8.0' // ✅ Enables .NET 8 runtime
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'DOTNET_VERSION'
          value: '8.0'
        }
      ]
    }
  }
  dependsOn: [
    appServicePlan
  ]
}

// Optional metadata for correct display in Azure Portal
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
output appServicePlanId string = appServicePlan.id
