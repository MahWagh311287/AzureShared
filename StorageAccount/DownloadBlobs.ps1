### *** This script is to download blobs from an Azure storage account. *** ###

$subscriptionId = "cf434qdvqdhqdqdh"
$storageAccountName = "devordersa"
$storageAccountKey = "q5nuu84RYsqhwdvhqwdh"
$containerName = "orders"
$downloadLocation = "/users/shared/"

# Login
Connect-AzAccount

# Set Subscription
Set-AzContext -Subscription $subscriptionId 

# Create storage context
$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Download the blobs
DownloadBlobs -storageContext $storageContext  -containerName $containerName -downloadLocation $downloadLocation -lastModifedInDays -2

# Function to download the blobs
function DownloadBlobs() {
    param(
        
        [Parameter(Mandatory=$true)][Object]$storageContext,
        [Parameter(Mandatory=$true)][string]$containerName,
        [Parameter(Mandatory=$true)][string]$downloadLocation,
        [Parameter(Mandatory=$true)][Int32][ValidateScript({$_ -lt 0})] [int]$lastModifedInDays
    )

    $throttleLimit = 4

    # Get the list of blobs
    $blobList = Get-AzStorageBlob -Container $containerName -Context $storageContext
    Write-Output "Total blobs in the container: " $blobList.Count
    
    # Select blobs that has been modifed in last $lastModifedInDays days
    $filteredBlobs = $blobList | Where-Object { $_.LastModified -gt ((Get-Date).Date).AddDays($days) }
    Write-Output "Total blobs matching criteria: " $filteredBlobs.Count

    Write-Output "Downloading...."
    $filteredBlobs | ForEach-Object -Parallel {
        Get-AzStorageBlobContent -Container $using:containerName -Blob $_.Name -Context $using:storageContext -Destination $using:downloadLocation
    } -ThrottleLimit $throttleLimit

    Write-Output "Download Complete"
}


