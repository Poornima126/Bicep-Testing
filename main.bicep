targetScope = 'resourceGroup'

@description('Location')
param location string = resourceGroup().location

// ---------- App Service ----------
module appService 'modules/appservice/main.bicep' = {
  name: 'deploy-appservice'
  params: {
    location: location
    appServicePlanName: 'my-demo-webapp-0213-plan'
    webAppName: 'my-demo-webapp-0213'
    skuName: 'B1'
  }
}

// ---------- Function App ----------
module functionApp 'modules/functionapp/main.bicep' = {
  name: 'deploy-functionapp'
  params: {
    location: location
    functionAppName: 'my-node-funcapp-0213'
    storageAccountName: 'mynodestorage12345'
    appServicePlanName: 'my-node-funcapp-0213-plan'
    skuName: 'B1'
  }
  dependsOn: [
    appService
  ]
}

output webAppUrl string = appService.outputs.webAppUrl
output functionAppName string = functionApp.outputs.functionAppName
output storageConnectionString string = functionApp.outputs.storageConnectionString
