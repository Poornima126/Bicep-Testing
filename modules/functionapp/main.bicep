targetScope = 'resourceGroup'

@description('Location for resources')
param location string = resourceGroup().location

@description('Function App name')
param functionAppName string

@description('Storage Account name (must be globally unique)')
param storageAccountName string

@description('App Service Plan name')
param appServicePlanName string

@description('SKU for App Service Plan')
param skuName string = 'B1'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'Basic'
  }
  properties: {
    reserved: false
  }
}

var storageAccountKey = listKeys(storageAccount.id, '2023-01-01').keys[0].value
var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccountKey};EndpointSuffix=${environment().suffixes.storage}'

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        { name: 'FUNCTIONS_WORKER_RUNTIME'; value: 'node' }
        { name: 'FUNCTIONS_EXTENSION_VERSION'; value: '~4' }
        { name: 'AzureWebJobsStorage'; value: storageConnectionString }
        { name: 'WEBSITE_NODE_DEFAULT_VERSION'; value: '~20' }
      ]
      alwaysOn: true
      use32BitWorkerProcess: true
    }
    httpsOnly: true
  }
  dependsOn: [
    storageAccount
    appServicePlan
  ]
}

output functionAppName string = functionApp.name
output storageAccountName string = storageAccount.name
output storageConnectionString string = storageConnectionString
