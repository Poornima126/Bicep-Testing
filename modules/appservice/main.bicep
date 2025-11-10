@description('Location of the App Service')
param location string

@description('Existing App Service Plan name')
param appServicePlanName string

@description('Web App name')
param webAppName string

// Reference existing App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: appServicePlanName
}

// Create Web App under existing plan
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      ftpsState: 'Disabled'
      # For Windows App Service Plan, we use netFrameworkVersion
      netFrameworkVersion: 'v8.0'
      use32BitWorkerProcess: false
    }
  }
}

output webAppName string = webApp.name
output webAppDefaultHostName string = webApp.properties.defaultHostName
