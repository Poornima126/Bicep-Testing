targetScope = 'resourceGroup'

param location string = resourceGroup().location

// App Service Parameters
param appServicePlanName string = 'my-demo-webapp-0213-plan'
param webAppName string = 'my-demo-webapp-0213'

// Function App Parameters
param functionAppName string = 'my-node-funcapp-0213'
param hostingPlanName string = 'my-funcapp-plan'
param storageAccountName string = 'funcappstorage0213'

module appServiceModule './modules/appservice/main.bicep' = {
  name: 'appServiceModule'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    webAppName: webAppName
  }
}

module functionAppModule './modules/functionapp/main.bicep' = {
  name: 'functionAppModule'
  params: {
    location: location
    functionAppName: functionAppName
    hostingPlanName: hostingPlanName
    storageAccountName: storageAccountName
  }
}
