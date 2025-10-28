// =======================================
// Deployment Scope
// =======================================
targetScope = 'subscription'

// =======================================
// Parameters
// =======================================
@description('Resource Group name')
param resourceGroupName string = 'test'

@description('Location for the resources')
param location string = 'Central India'

@description('App Service Plan name')
param appServicePlanName string = 'my-demo-webapp-0213-plan'

@description('Web App name')
param webAppName string = 'my-demo-webapp-0213'

// =======================================
// Create Resource Group
// =======================================
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// =======================================
// App Service Plan (Windows - Basic)
// =======================================
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  scope: rg
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
  dependsOn: [rg]
}

// =======================================
// Web App (.NET 8)
// =======================================
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  scope: rg
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0' // .NET 8 runtime
      alwaysOn: true
    }
  }
  dependsOn: [appServicePlan]
}

output webAppUrl string = 'https://${webAppName}.azurewebsites.net'
