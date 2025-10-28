@description('Location for all resources')
param location string = resourceGroup().location

@description('Storage account name for Function App')
param storageAccountName string = 'funcappstorage0213'

@description('App Service plan name')
param appServicePlanName string = 'my-node-funcapp-0213-plan'

@description('Function App name')
param functionAppName string = 'my-node-funcapp-0213'

@description('App Service pricing tier')
param skuName string = 'B1'

/* --------------------------
   Create Storage Account
--------------------------- */
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

/* --------------------------
   Create App Service Plan
--------------------------- */
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'Basic'
    size: skuName
    capacity: 1
  }
  properties: {
    reserved: false // Windows plan
  }
}

/* --------------------------
   Create Function App
--------------------------- */
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=core.windows.net'
        }
      ]
      alwaysOn: true
      linuxFxVersion: ''
    }
    httpsOnly: true
  }
  dependsOn: [
    appServicePlan
    storageAccount
  ]
}

/* --------------------------
   Outputs
--------------------------- */
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'

