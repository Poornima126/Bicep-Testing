targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = resourceGroup().location

@description('App Service Plan name')
param appServicePlanName string = 'my-demo-webapp-0213-plan'

@description('App Service name')
param webAppName string = 'my-demo-webapp-0213'

@description('App Service SKU')
param appSkuName string = 'B1'

@description('Function App name')
param functionAppName string = 'my-node-funcapp-0213'

@description('Function App Plan name')
param functionAppPlanName string = 'my-node-funcapp-0213-plan'

@description('Storage Account name for Function App')
param storageAccountName string = 'mynodestorage12345'

module appService 'modules/appservice/main.bicep' = {
  name: 'appServiceModule'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    webAppName: webAppName
    skuName: appSkuName
  }
}

module functionApp 'modules/functionapp/main.bicep' = {
  name: 'functionAppModule'
  params: {
    location: location
    functionAppName: functionAppName
    appServicePlanName: functionAppPlanName
    storageAccountName: storageAccountName
    skuName: appSkuName
  }
}

output webAppUrl string = appService.outputs.webAppUrl
output functionAppName string = functionApp.outputs.functionAppName
