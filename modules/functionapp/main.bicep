param location string
param appServicePlanName string
param functionAppName string
param storageAccountName string

// Storage account for Function App
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// Function App using same App Service Plan
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        // Added two custom environment variables
        {
          name: 'ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'TEAM'
          value: 'DevOps'
        }
      ]
    }
  }
  dependsOn: [
    storageAccount
  ]
}

output functionAppName string = functionApp.name
output storageAccountName string = storageAccount.name
