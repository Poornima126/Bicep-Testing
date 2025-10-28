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
  kind: 'app' // Windows-based
  properties: {
    reserved: false // false = Windows, true = Linux
  }
}

/* Web App - .NET 8 Runtime */
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      alwaysOn: true
      http20Enabled: true
    }
    httpsOnly: true
  }
  dependsOn: [
    appServicePlan
  ]
}

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
