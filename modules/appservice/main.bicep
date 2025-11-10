targetScope = 'resourceGroup'

@description('Location for all resources')
param location string

@description('Existing App Service Plan name')
param appServicePlanName string

@description('App Service name')
param webAppName string

// Reference the existing App Service Plan
resource existingAppServicePlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: appServicePlanName
}

// Create the Web App
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: existingAppServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      http20Enabled: true
      netFrameworkVersion: 'v8.0'
    }
  }
}

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
