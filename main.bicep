targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Existing App Service Plan name for Web App')
param appServicePlanName string

@description('Existing App Service Plan name for Function App')
param functionAppPlanName string

@description('App Service name')
param webAppName string

@description('Function App name')
param functionAppName string

@description('Storage Account name')
param storageAccountName string

module appService 'modules/appservice/main.bicep' = {
  name: 'deployAppService'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    webAppName: webAppName
  }
}

module functionApp 'modules/functionapp/main.bicep' = {
  name: 'deployFunctionApp'
  params: {
    location: location
    appServicePlanName: functionAppPlanName
    functionAppName: functionAppName
    storageAccountName: storageAccountName
  }
  dependsOn: [
    appService
  ]
}

