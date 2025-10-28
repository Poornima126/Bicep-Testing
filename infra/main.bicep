targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = resourceGroup().location

@description('App Service Plan name')
param appServicePlanName string = 'my-demo-webapp-0213-plan'

@description('App Service name')
param webAppName string = 'my-demo-webapp-0213'

@description('App Service pricing tier')
param skuName string = 'B1'

/* App Service Plan - Windows */
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

/* Web App - .NET 8 Runtime Stack */
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
      netFrameworkVersion: 'v8.0' // ✅ Defines .NET 8 runtime
    }
  }
  dependsOn: [
    appServicePlan
  ]
}

/* Explicitly set the runtime stack metadata so portal shows .NET 8 */
resource configMetadata 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: webApp
  name: 'metadata'
  properties: {
    CURRENT_STACK: 'dotnet'    // ✅ Show ".NET" in portal
    FRAMEWORK: 'dotnet'
    FRAMEWORK_VERSION: 'v8.0'  // ✅ Show ".NET 8"
  }
}

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'

