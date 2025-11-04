param location string = resourceGroup().location
param appServicePlanName string
param appServiceName string
param functionAppName string
param storageAccountName string

// Storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// App Service module
module appServiceModule './modules/appservice/main.bicep' = {
  name: 'appServiceModule'
  params: {
    appServicePlanName: appServicePlanName
    appServiceName: appServiceName
    location: location
  }
}

// Function App module
module functionAppModule './modules/functionapp/main.bicep' = {
  name: 'functionAppModule'
  params: {
    functionAppName: functionAppName
    location: location
    appServicePlanId: appServiceModule.outputs.appServicePlanId
    storageAccountName: storageAccount.name
    storageConnectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
}
