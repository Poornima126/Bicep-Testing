param location string
param appServicePlanName string
param functionAppName string
param storageAccountName string
param skuName string = 'B1'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

var storageAccountKey = listKeys(storageAccount.id, '2023-01-01').keys[0].value
var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccountKey};EndpointSuffix=${environment().suffixes.storage}'

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    httpsOnly: true
    siteConfig: {
      appSettings: [
        { name: 'FUNCTIONS_WORKER_RUNTIME'; value: 'node' }
        { name: 'FUNCTIONS_EXTENSION_VERSION'; value: '~4' }
        { name: 'AzureWebJobsStorage'; value: storageConnectionString }
        { name: 'WEBSITE_NODE_DEFAULT_VERSION'; value: '~20' }
      ]
      alwaysOn: true
    }
  }
  dependsOn: [
    storageAccount
  ]
}

output functionAppName string = functionApp.name
output storageAccountName string = storageAccount.name
output storageConnectionString string = storageConnectionString
