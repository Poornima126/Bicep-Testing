// ==========================
// Parameters
// ==========================
param location string = 'Central India'
param rgName string = 'test'
param appServicePlanName string = 'my-demo-webapp-0213-plan'
param webAppName string = 'my-demo-webapp-0213'

// ==========================
// Resource Group (if not exists)
// ==========================
// Note: Resource Group is usually created outside the template in Azure CLI task,
// but if your pipeline runs at subscription scope, this will create it.
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

// ==========================
// App Service Plan (Basic - Windows)
// ==========================
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

// ==========================
// Web App (.NET 8 on Windows)
// ==========================
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      netFrameworkVersion: 'v8.0' // .NET 8 runtime
    }
    httpsOnly: true
  }
  dependsOn: [
    appServicePlan
  ]
}

output webAppUrl string = 'https://${webAppName}.azurewebsites.net'
