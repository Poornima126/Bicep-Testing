@description('Location of the Function App')
param location string

@description('Existing App Service Plan name for the Function App')
param appServicePlanName string

@description('Function App name')
param functionAppName string

@description('Storage account name to link with Function App')
param storageAccountName string

// Reference existing Function App plan
resource functionPlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: appServicePlanName
}

// Create or reference storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

// Create Function App using existing plan
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: functionPlan.id
    httpsOnly: true
    siteConfig: {
      ftpsState: 'Disabled'
      linuxFxVersion: 'NODE|20'
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
          name: 'AzureWebJobsStorage'
          value: concat('DefaultEndpointsProtocol=https;AccountName=', storageAccount.name, ';EndpointSuffix=core.windows.net')
        }
      ]
    }
  }
  dependsOn: [
    storageAccount
  ]
}

output functionAppName string = functionApp.name
output functionAppHostName string = functionApp.properties.defaultHostName
