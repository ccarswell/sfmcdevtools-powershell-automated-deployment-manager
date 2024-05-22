#Script builds definition for Solution A

# Must be executed from the folder in which the script resides: .src/packagedSolutions/solutionA/solutionA_deployment.ps1
# No need to copy the solution to '/template' folder first, the script takes care of that

#CONFIG-A: Configure the items that should be deployed below
$asset_List = @(
    'MessageA'
)

$dataExtension_List = @(
    'DataExtensionA'
)

$query_List = @(
    'QueryA'
)

$emailSend_List = @(
    'EmailSendA'
)

$script_List = @(
    'ScriptA'
)

$automation_List = @(
    'AutomationA'
)

function RunCommand($Command) {
    Write-Output $Command
    Invoke-Expression $Command
}

function RunCommandWithItemList($prefix, $commandType, $items, $suffix = $null) {
    $itemString = $items -join ', '
    $command = if ($null -ne $suffix) {
        "$prefix $commandType `"$itemString`" $suffix"
    }
    else {
        "$prefix $commandType `"$itemString`""
    }
    RunCommand $command
}

#CONFIG-B: Configure the items that should be deployed below
function BuildItemsForList($marketList) {
    $prefix = "mcdev bdb $marketList"
    RunCommandWithItemList $prefix 'asset' $asset_List
    RunCommandWithItemList $prefix 'dataExtension' $dataExtension_List
    RunCommandWithItemList $prefix 'query' $query_List
    RunCommandWithItemList $prefix 'emailSend' $emailSend_List
    RunCommandWithItemList $prefix 'script' $script_List
    RunCommandWithItemList $prefix 'automation' $automation_List
}

#CONFIG-B: Configure the items that should be deployed below
function BuildItems($market, $bu) {
    $prefix = "mcdev bd $bu"
    $suffix = $market
    RunCommandWithItemList $prefix 'asset' $asset_List $suffix
    RunCommandWithItemList $prefix 'dataExtension' $dataExtension_List $suffix
    RunCommandWithItemList $prefix 'query' $query_List $suffix
    RunCommandWithItemList $prefix 'emailSend' $emailSend_List $suffix
    RunCommandWithItemList $prefix 'script' $script_List $suffix
    RunCommandWithItemList $prefix 'automation' $automation_List $suffix
}


function ShowDeploymentMessage($message) {
    Write-Host ""
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    Write-Host "$message"
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    Write-Host ""
}

function CopyToTemplateDirectory($currentDirectory) {

    # Go two levels up in the directory hierarchy to get to the 'root' folder of the project
    #CONFIG-C: Configure here depending on hierarchy
    $parentDirectory = (Split-Path -Path $currentDirectory -Parent)
    $parentDirectory = (Split-Path -Path $parentDirectory -Parent)
    $parentDirectory = (Split-Path -Path $parentDirectory -Parent)

    # Construct the destination path by appending "template" to the parent directory
    $destinationPath = Join-Path -Path $parentDirectory -ChildPath "template"

    # Check if the destination directory exists
    if (Test-Path -Path $destinationPath) {
        # If it exists, remove all folders and files
        Remove-Item -Path $destinationPath -Recurse -Force
        Write-Host "Deleting folder: $destinationPath"
    }
    else {
        # If it doesn't exist, show a message indicating that it doesn't need to be deleted
        Write-Host "The destination directory $destinationPath does not exist."
    }

    # Create the destination directory if it doesn't exist
    New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null
    Write-Host "Creating folder: $destinationPath"

    # Get all items in the source directory except the "template" folder
    $itemsToCopy = Get-ChildItem -Path $currentDirectory
    Write-Host "Copying these items: $itemsToCopy" to $destinationPath

    # Copy each item to the destination directory
    foreach ($item in $itemsToCopy) {
        Copy-Item -Path $item.FullName -Destination $destinationPath -Recurse -Force
    }
    # Change the current working directory to the root folder before executing mcdevtools commands
    Set-Location -Path $parentDirectory
}

ShowDeploymentMessage "Step 0: Prepping the template folder"

# Get the current directory
$currentDirectory = (Get-Location).Path

# Copying everything over to the /template folder before executing mcdevtools. This way we avoid a few manual steps which normally has to be taken and allows for only working from the src folder
CopyToTemplateDirectory($currentDirectory)

# Removing the deploy folder before executing mcdevtool commands
if (Test-Path -Path deploy) {
    Write-Host "Deleting everything from mcdev 'deploy' directory before executing mcdevtools commands"
    rmdir deploy -r
}

# Executing command
#./solutionA_deployment PRD prod/BusinessUnitA deploy
if ($args.Length -eq 3 -and $args[2] -eq 'deploy') {
    $json = Get-Content ".\.mcdevrc.json " | ConvertFrom-Json
    $marketList = $args[0]
    $bu = $args[1]
    $market = $json.marketList.$marketList.$bu

    # Check if the market selected exists before continuing
    if ($market -eq $null) {
        ShowDeploymentMessage "Error: Market or MarketList not found."
    }
    else {
        ShowDeploymentMessage "Step 1: Building definition for Market: $market"
        BuildItems $market $bu
        ShowDeploymentMessage "Step 2: Deploying Market: $market to Marketing Cloud"
        mcdev d * #Performs deployment to Business Unit
        ShowDeploymentMessage "Success: Deployed Market: $market to Marketing Cloud"

    }
}
#./solutionA_deployment PRD prod/BusinessUnitA
elseif ($args.Length -eq 2 -and $args[1] -ne 'deploy') {
    $json = Get-Content ".\.mcdevrc.json " | ConvertFrom-Json
    $marketList = $args[0]
    $bu = $args[1]
    $market = $json.marketList.$marketList.$bu

    # Check if the market selected exists before continuing
    if ($market -eq $null) {
        ShowDeploymentMessage "Error: Market or MarketList not found."
    }
    else {
        ShowDeploymentMessage "Step 1: Building definition for Market: $market"
        BuildItems $market $bu
        ShowDeploymentMessage "Success: Deployment definition build completed for Market: $market. Not deployed to Marketing Cloud yet"
    }
}
#./solutionA_deployment PRD deploy
elseif ($args.Length -eq 2 -and $args[1] -eq 'deploy') {
    $marketList = $args[0]
    ShowDeploymentMessage "Step 1: Building definition for Market List: $marketList"
    BuildItemsForList $marketList
    ShowDeploymentMessage "Step 2: Deploying Market List: $marketList to Marketing Cloud"
    mcdev d * #Performs deployment to Business Unit
    ShowDeploymentMessage "Success: Deployed Market List: $marketList to Marketing Cloud"
}
#./solutionA_deployment PRD
elseif ($args.Length -eq 1) {
    $marketList = $args[0]
    ShowDeploymentMessage "Step 1: Building definition for Market List: $marketList"
    BuildItemsForList $marketList
    ShowDeploymentMessage "Success: Deployment definition build completed for Market List: $marketList. Not deployed to Marketing Cloud yet"
}
else {
    ShowDeploymentMessage "Error: Missing arguments - refer to script for more information"
}
# Final Step: Change the current working directory back to previous folder for simpler re-execution
Set-Location -Path $currentDirectory


