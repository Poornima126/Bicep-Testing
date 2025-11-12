targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Existing App Service Plan for Web App')
param webAppPlanName string

// Commented out for now – only creating App Service
// @description('Existing App Service Plan for Function App')
// param functionAppPlanName string

@description('App Service name')
param webAppName string

// Commented out for now – only creating App Service
// @description('Function App name')
// param functionAppName string

// @description('Existing Storage Account name')
// param storageAccountName string

// =======================================================
// Deploy Web App using existing App Service Plan
// =======================================================
module appService 'modules/appservice/main.bicep' = {
  name: 'deployAppService'
  params: {
    location: location
    appServicePlanName: webAppPlanName
    webAppName: webAppName
  }
}

// =======================================================
// Function App deployment commented out temporarily
// =======================================================
// module functionApp 'modules/functionapp/main.bicep' = {
//   name: 'deployFunctionApp'
//   params: {
//     location: location
//     appServicePlanName: functionAppPlanName
//     functionAppName: functionAppName
//     storageAccountName: storageAccountName
//   }
//   dependsOn: [
//     appService
//   ]
// }
