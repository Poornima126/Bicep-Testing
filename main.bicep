param location string = resourceGroup().location

// Parameters for App Service
param appServicePlanName string
param webAppName string

// Parameters for Function App
param functionAppName string
param storageAccountName string

// Deploy App Service Module
module appServiceModule './modules/appservice/main.bicep' = {
  name: 'appServiceModule'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    webAppName: webAppName
  }
}

// Deploy Function App Module
module functionAppModule './modules/functionapp/main.bicep' = {
  name: 'functionAppModule'
  params: {
    location: location
    functionAppName: functionAppName
    storageAccountName: storageAccountName
  }
}

