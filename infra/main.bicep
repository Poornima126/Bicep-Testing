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
// Create a Storage Account (required by Function App)
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
// Create an App Service Plan (Windows)
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
// Retrieve storage account key for Function App
//
var storageAccountKey = listKeys(storageAccount.id, '2023-01-01').keys[0].value
var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccountKey};EndpointSuffix=${environment().suffixes.storage}'

//
// Create Function App
//
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
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
output storageAccountName string = storageAccount.name
output storageConnectionString string = storageConnectionString
