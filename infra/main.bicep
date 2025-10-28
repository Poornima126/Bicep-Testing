targetScope = 'subscription'

@description('Resource Group name')
param rgName string = 'test'

@description('Location for the resources')
param location string = 'Central India'

@description('App Service Plan name')
param appServicePlanName string = 'my-demo-webapp-0213-plan'

@description('App Service Plan SKU (B1 = Basic tier)')
param skuName string = 'B1'

@description('Web App name')
param webAppName string = 'my-demo-webapp-0213'

@description('Runtime stack version')
param netVersion string = 'v8.0'

/* Step 1: Create Resource Group */
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}

/* Step 2: Create App Service Plan (Windows, Basic Tier) */
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'Basic'
    capacity: 1
  }
  kind: 'app'
  properties: {
    reserved: false // false => Windows
  }
  scope: rg
}

/* Step 3: Create Web App (.NET 8, Windows) */
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      netFrameworkVersion: netVersion
      alwaysOn: true
      use32BitWorkerProcess: true
      http20Enabled: true
      managedPipelineMode: 'Integrated'
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '0'
        }
      ]
    }
    httpsOnly: true
  }
  scope: rg
}

/* Output Web App URL */
output webAppUrl string = 'https://${webAppName}.azurewebsites.net'
