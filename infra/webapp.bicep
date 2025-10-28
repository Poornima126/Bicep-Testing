targetScope = 'resourceGroup'

param location string
param appServicePlanName string
param webAppName string

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    capacity: 1
  }
  kind: 'app'
  properties: {
    reserved: false // false = Windows
  }
}

// Web App (.NET 8)
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0' // .NET 8 runtime
      alwaysOn: true
    }
  }
}

output webAppUrl string = 'https://${webAppName}.azurewebsites.net'
