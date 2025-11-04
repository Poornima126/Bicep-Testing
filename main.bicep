targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Shared App Service Plan name')
param appServicePlanName string

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
    appServicePlanName: appServicePlanName
    functionAppName: functionAppName
    storageAccountName: storageAccountName
  }
  dependsOn: [
    appService
  ]
}

