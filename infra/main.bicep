targetScope = 'subscription'

@description('Resource Group name')
param resourceGroupName string = 'test'

@description('Location for the resources')
param location string = 'Central India'

@description('App Service Plan name')
param appServicePlanName string = 'my-demo-webapp-0213-plan'

@description('Web App name')
param webAppName string = 'my-demo-webapp-0213'

// Create Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Deploy App Service and Plan inside the RG
module webappModule 'webapp.bicep' = {
  name: 'webappDeployment'
  scope: rg
  params: {
    location: location
    appServicePlanName: appServicePlanName
    webAppName: webAppName
  }
}

output webAppUrl string = webappModule.outputs.webAppUrl
