@description('Location for resources')
param location string = resourceGroup().location

@description('Function App name')
param functionAppName string = 'my-node-funcapp-0213'

@description('Storage Account name')
param storageAccountName string = 'mynodestorage12345'

@description('App Service Plan name')
param appServicePlanName string = 'my-node-funcapp-0213-plan'

@description('SKU for App Service Plan')
param skuName string = 'B1'

//
// Storage Account
//
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

//
// App Service Plan (Windows - Basic tier)
//
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'Basic'
  }
  properties: {
    reserved: false // false = Windows
  }
}

//
// Function App (Node.js 20 on Windows)
//
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        // Required settings
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.getConnectionString()
        }
      ]
      alwaysOn: true
      use32BitWorkerProcess: true
    }
    httpsOnly: true
  }
  dependsOn: [
    appServicePlan
    storageAccount
  ]
}

//
// Outputs
//
output functionAppName string = functionApp.name
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
output storageAccountName string = storageAccount.name
