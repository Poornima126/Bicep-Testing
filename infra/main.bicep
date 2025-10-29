@description('Azure region for resources')
param location string = resourceGroup().location

@description('Storage account name')
param storageAccountName string = 'mynodestorage${uniqueString(resourceGroup().id)}'

@description('App Service Plan name')
param appServicePlanName string = 'my-node-funcapp-plan'

@description('Function App name')
param functionAppName string = 'my-node-funcapp-0213'

@description('App Service pricing tier')
param skuName string = 'B1'

//
// Storage Account (required for Function App)
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
// App Service Plan (Windows OS)
//
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'Basic'
    size: skuName
    capacity: 1
  }
  properties: {
    reserved: false // false = Windows
  }
}

//
// Function App (Windows + Node.js)
//
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'FtpsOnly'
      alwaysOn: true
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.listKeys().keys[0].value
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
      ]
    }
  }
  dependsOn: [
    appServicePlan
    storageAccount
  ]
}

output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
