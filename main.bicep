param location string = 'CentralIndia'

var appServicePlanName = 'my-demo-webapp-0213-plan'
var webAppName = 'my-demo-webapp-0213'
var functionAppName = 'my-node-funcapp-0213'
var storageAccountName = 'mystorageaccountdemo'

module appServiceModule './modules/appservice/main.bicep' = {
  name: 'appservice-deploy'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    webAppName: webAppName
  }
}

module functionAppModule './modules/functionapp/main.bicep' = {
  name: 'functionapp-deploy'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    functionAppName: functionAppName
    storageAccountName: storageAccountName
  }
}

