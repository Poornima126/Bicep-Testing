targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Existing App Service Plan for Web App')
param webAppPlanName string

@description('Existing App Service Plan for Function App')
param functionAppPlanName string

@description('App Service name')
param webAppName string

@description('Function App name')
param functionAppName string

@description('Existing Storage Account name')
param storageAccountName string

// Deploy Web App using existing App Service Plan
module appService 'modules/appservice/main.bicep' = {
  name: 'deployAppService'
  params: {
    location: location
    appServicePlanName: webAppPlanName
    webAppName: webAppName
  }
}

// Deploy Function App using existing Function Plan + existing Storage Account
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
