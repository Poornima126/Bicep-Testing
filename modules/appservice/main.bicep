targetScope = 'resourceGroup'

@description('Location for all resources')
param location string

@description('Existing App Service Plan name')
param appServicePlanName string

@description('App Service name')
param webAppName string

// Reference existing App Service Plan
resource existingAppServicePlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: appServicePlanName
}

// Web App configured for .NET 8 (Windows)
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
  dependsOn: [
    existingAppServicePlan
  ]
}

// Ensure portal/runtime metadata shows .NET 8
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
output appServicePlanId string = existingAppServicePlan.id
