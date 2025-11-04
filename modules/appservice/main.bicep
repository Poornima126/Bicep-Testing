param location string
param appServicePlanName string
param webAppName string
param skuName string = 'B1' // Basic plan

// App Service Plan (shared by web app + function app)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'Basic'
  }
  kind: 'app'
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
    }
  }
}

output appServicePlanId string = appServicePlan.id
output webAppName string = webApp.name
