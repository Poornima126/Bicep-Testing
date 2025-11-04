param location string = 'CentralIndia'

module appServiceModule './modules/appservice/main.bicep' = {
  name: 'appservice-deploy'
  params: {
    location: location
    appServicePlanName: 'my-demo-webapp-0213-plan'
    webAppName: 'my-demo-webapp-0213'
  }
}

module functionAppModule './modules/functionapp/main.bicep' = {
  name: 'functionapp-deploy'
  params: {
    location: location
    functionAppName: 'my-node-funcapp-0213'
    storageAccountName: 'mystorageaccountdemo'
    appServicePlanName: 'my-demo-webapp-0213-plan'
  }
}

