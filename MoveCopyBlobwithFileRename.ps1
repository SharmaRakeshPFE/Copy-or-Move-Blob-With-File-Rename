
##*******************************************************************************##

# Description:-Copy\Move and Rename Blob from one container to another ##

## Example - Prefix Blob with characters to ensure file name of 15 Characters ##
## Author - Rakesh Sharma - sharma_rakesh@msn.com

##*******************************************************************************##

#**Connect to Azure**#
##Login-AzAccount
###Logout-AzAccount
###Connect-AzureRmAccount
###Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
##Import-Module -Name AzureRM
##Import-Module -Name Azure.Storage



## Function to Copy\Move Blob to another containet with new name ##
function Rename-AzureStorageBlob 
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob]$Blob,[Parameter(Mandatory = $true, Position = 1)]
        [string]$NewName,
        [string]$DestContainer

    )

Process 
        {
            

            $blobCopyAction = Start-AzureStorageBlobCopy  `
            -ICloudBlob $Blob.ICloudBlob `
            -DestBlob $NewName `
            -Context $Blob.Context `
            -DestContainer $DestContainer -Force

            $status = $blobCopyAction | Get-AzureStorageBlobCopyState

            while ($status.Status -ne 'Success') 
                {
                    $status = $blobCopyAction | Get-AzureStorageBlobCopyState
                    Start-Sleep -Milliseconds 50
        
        
                }

        ## **Comment below line to make this script Copy and Delete** ##
       
        $Blob | Remove-AzureStorageBlob -Force ## This will overwite the content remove -Force for prompt\warning ##
    }
}


##Pass credential to read the blobs from the container##

## Pass Storage Account Name below ##
$StorageAccountName = "YourStorageAccountName"
# Pass Storage Key - Copy from the Azure Portal #
$StorageAccountKey = "xPiz+WPCyfe <**Your Storage Key**> 1tPEySwr6F866Q=="

#Container name - change if different
$containerName = "imageraw" ##<Source Container Name>##
$destcontainer="imagefinal" ##<Destination Container Name>##
$connectionStringvar = ''+'DefaultEndpointsProtocol=https;AccountName='+ $StorageAccountName + ';' + 'AccountKey='+ $StorageAccountKey +''
write-host $connectionStringvar

## Acquiring the blob context ##

$Ctx = New-AzureStorageContext $StorageAccountName -StorageAccountKey $StorageAccountKey

$ListBlobs = Get-AzureStorageBlob -context $Ctx -Container $containerName
 
 ## Count the total Nunber of Blobs in the Container ##
  Write-Host ("Blob Count: " + $ListBlobs.Count + "`n")
 
  foreach($bl in $ListBlobs)
 
   {

        ##Write-Host "Blob: " 
        #Write-Host ("File Full Path: " + $bl.Name)
        #Write-Host ("Folder Path: " + $bl.Name.Substring( 0, $bl.Name.LastIndexOf("/")+1) )
        #Extract file name from full path
      
        write-Host ("File Name: " + $bl.Name.Substring( $bl.Name.LastIndexOf("/") + 1, $bl.Name.Length - $bl.Name.LastIndexOf("/")-1 ) )
      
            if ($bl.name.Length -lt 15)

                {
                    #Write-Host  Write-Host $bl.Name , "-" $bl.name.Length  " File is Short"
                    $shortchar = 15 - $bl.name.Length  
                    $nameonly=$bl.name
                    Write-Host "Filename is short by character count of "$shortchar 
                    Write-Host "Adjusting File Name Length"
                    
                    $replicate="x"*$shortchar
                    #Write-Host $replicate
                    $newname=  $replicate+$nameonly
                    Write-Host "New File Name on Destination Container" $newname
                    Write-Host "##############################################"
                                         
                    Write-Host $connectionStringvar
                    $storageContext = New-AzureStorageContext -ConnectionString $connectionStringvar
                    
                    ##Calling Funciton here and retrieve items one by one
                    
                    
                    Get-AzureStorageBlob -Container $containerName -Context $storageContext -Blob $nameonly |
                    Write-Host "Copying blob to final container with defined naming convention"
                    Rename-AzureStorageBlob -NewName $newname -DestContainer $destcontainer
                }
                
                else
                
                {
                    write-host  Write-Host $bl.Name , "-" $bl.name.Length  " File naming convention is in compliance"   
                }
   }
