$mainSubscription = 'fd4767b9-b7f1-4db7-a1dd-37c5159006e7'

$resourceGroup = 'HackaTonaRG'
$clusterName = 'HackaTonaAks'
$acrName = 'hackatonacr'

$imageName = 'webapp'
$applicationVersion = 'v1'

# Login to Azure
az login
az account set --subscription $mainSubscription

az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.OperationalInsights

# Create infrastructure
az deployment sub create --location westus --template-file infra/bicep/main.bicep

# Fetch the ACR Login Server
$acrLoginServer = az acr show --name $acrName --query loginServer

# Tag the local image with the container registry url/repository/image
docker build -t "${imageName}:${applicationVersion}" .
docker tag "${imageName}:${applicationVersion}" $acrLoginServer/$imageName/"${imageName}:${applicationVersion}"

# Push image to ACR
$containerUrl = "${acrLoginServer}/${imageName}/${imageName}:${applicationVersion}".replace('"','')

az acr login -n $acrName
docker push $containerUrl

# Create local configuration file to talk to the AKS Cluster
az aks get-credentials --resource-group $resourceGroup --name $clusterName

# To avoid messing up kubectl 
Set-Alias -Name k -Value kubectl

# Create namespace for workload
k create namespace $imageName

# Create deployment from template
Get-Content ./infra/templates/deployment.yaml | ForEach-Object { $ExecutionContext.InvokeCommand.ExpandString($_) } | Set-Content ./infra/${imageName}.yaml

# Send deployment to Kubernetes
k apply -f ./infra/${imageName}.yaml

# Diagnose deployment
$firstPod = k get pod -n ${imageName} -l app=${imageName} -o jsonpath='{.items[0].metadata.name}'
k describe pod -n ${imageName} $firstPod
k logs -n ${imageName} $firstPod 
k exec -it $firstPod printenv -n ${imageName}
k port-forward -n ${imageName} deployment/${imageName} 9090:80

