## SFMC DevTools Powershell Automated Deployment Manager
### Description
The SFMC DevTools Powershell Automated Deployment Manager make use of [Accenture SFMC DevTools](https://github.com/Accenture/sfmc-devtools) and it's ability to bulk create and update solutions across multiple Business Units and instances with a single powerful command.

### Features
- Unified creation and updating of solutions across many Business Units and instances with a single script
- Essential for enterprise deployments solutions of Salesforce Marketing Cloud to ensure correct versioning across all Business Unit
- Version control can be applied as per usual as the script will automatically execute itself in a way that doesn't require manually copying to the ./template directory for the execution
- Incredible possibilities to expand automations for any solutions when the SFMC DevTools Powershell Automated Deployment Manager is combined with the merge fields functionality of [Accenture SFMC DevTools](https://github.com/Accenture/sfmc-devtools).

### Incredible Possibilities for Automated Deployment
Using this PowerShell Automated Deployment Manager along with [Accenture SFMC DevTools](https://github.com/Accenture/sfmc-devtools) merge field functionality, there are endless possibilities to expand and replace any metadata available such as:
- Query activity source and target Data Extensions
- Automation timezone start times (such as starting at 7am in the local timezone)
- Dynamic folder naming
- Dynamic Email content such as displaying images/colour/translations specific to the Business Unit

The options are practically limitless, as long as it's editable (and replaceable) within the metadata. [Instructions below](#advanced-scenarios).

### Pre-requisites
- Working knowledge of [Accenture SFMC DevTools](https://github.com/Accenture/sfmc-devtools), specifically the `mcdev retrieve` and `mcdev deploy` functionality.

### Preparation
1. Install [Accenture SFMC DevTools](https://github.com/Accenture/sfmc-devtools) and setup authorisation correctly as per usual.
2. Copy the `src` directory of this solution into your local project directory which has [Accenture SFMC DevTools](https://github.com/Accenture/sfmc-devtools) installed like this:

    ````
    [local project]\src\packagedSolutions\solutionA
    ````

### Configuration
4. Configure the `markets` and `marketlists` as required in `.mcdevrc.json` - see below for [examples](#example-markets-configuration)
    
    ````
    [local project]\.mcdevrc.json
    ````
5. The script will allow targeting of the solution per market (Business Unit), or per marketlist (list of Business Units, even across instances)
    1. Configuring the market list will allow for bulk deployment to as many Business Units as listed


### Usage
6. Use `mcdev retrieve` to retrieve the items you would like to package for deployment.
    1. The items will now be in the `[local project]\retrieve` directory
7. Copy the items you need for your solution to the `solutionA` subdirectories (`asset`, `automation`, `emailSend` etc.)
    1. See [example deployment](#example-deployment) below for more info
    2. Blank sample files of these are already in the SolutionA directory for example, but should be deleted
    
8. In the script file, make the following configurations:
    1. #CONFIG-A: list out the items that should be deployed at the top of the file (must match the name of the file itself)
    2. #CONFIG-B: indicate the types of items that should be deployed (`asset`, `automation`, `emailSend` etc.)
    3. #CONFIG-C: adjust depending on how many levels from the script file to the project directory `[local project]` (default: 3)


### Execution
Open the terminal from your project directory `[local project]` and navigate to: 

````
cd src\packagedSolutions\solutionA
````
### Option A
Builds definition for all markets in given market list. The items will appear in the `[local project]/deploy` directory
````
[SCRIPT] [MARKET_LIST]
````

#### Example:

````
./solutionA_deployment.ps1 SolutionA
````

### Option B
Builds definition for given market in given list. The items will appear in the `[local project]/deploy` directory
````
[SCRIPT] [MARKET_LIST] [BUSINESS_UNIT]
````

#### Examples:
````
./solutionA_deployment.ps1 SolutionA prod/BusinessUnitA
./solutionA_deployment.ps1 SolutionA prod/BusinessUnitB
````


### Option C
Add the 'deploy' argument to deploy to Salesforce Marketing Cloud. The items will appear in the `[local project]/deploy` directory and also be deployed directly to Salesforce Marketing Cloud
````
[SCRIPT] [MARKET_LIST] [BUSINESS_UNIT] deploy
````

#### Examples:
````
./solutionA_deployment.ps1 SolutionA deploy
./solutionA_deployment.ps1 SolutionA prod/BusinessUnitA deploy
````


### Notes
- The solution will automatically move the deployment package to the `.[local project]\template` directory for `mcdev bdb` deployment
- This allows tracking of the script and related packaged items in your `[local project]\src\packagedSolutions\solutionA` directory for source control, while keeping the `[local project]\template` directory free for deployment purposes.
- Multiple projects can work concurrently in this way

### Tips
- Feel free to place this in a subdirectory, but adjust #CONFIG-C accordingly
- Feel free to rename `src`, `packagedSolutions` and `solutionA` to anything you like
- Review the items in the `[local project]\deploy` directory first to ensure the items are correct before deploying to Salesforce Marketing Cloud 
- Because the solution automatically removes and copies the package to `[local project]\template` directory each time, it's not necessary to apply version control to this directory, so ensure to add it to the `[local project]\.gitignore` file
- For only deploying a subset of items, and not all at once, simply comment out the items not required and run the script. This allows for quicker iterative deployment

#### Example:
````
$dataExtension_List = @(
    'DataExtensionA'
    #'DataExtensionB',
    #'DataExtensionB'
)
````

## Configuration Examples
### Example Markets Configuration
List all your Business Units here across all your instances
````
"markets": {
    "BusinessUnitA ": {
        "buName": "BusinessUnitA"
    },
    "BusinessUnitB ": {
        "buName": "BusinessUnitB"
    }        
}
````
Create a configuration for a grouping (marketlist) of Business Units (markets)

#### MarketList Example A
- Grouping solution specific Business Units together (even across instances)
- Useful when only some Business Units require (or are ready) for a specific solution

````
"marketList": {
    "SolutionA": {
        "description": "Business Units that require SolutionA",
        "prod/BusinessUnitA": ["BusinessUnitA"]
        "prod/BusinessUnitB": ["BusinessUnitB"]
    }
}
````
#### MarketList Example B
- Grouping all Production Business Units together (even across instances)
- Useful for when updating to all Business Units at once

````
"marketList": {
    "PRD": {
        "description": "Production Business Units",
        "prod/BusinessUnitA": ["BusinessUnitA"]
        "prod/BusinessUnitB": ["BusinessUnitB"]
    }
}
````
## Deployment Examples
### Automation Deployment
To create a packaged solution of a Query Activity, Automation and Data Extension, follow these steps
1. Go to the `[local project]` directory and open up the Terminal
2. Run `mcdev retrieve`
3. Follow the prompts to retrieve from the Business Unit as necessary
4. Copy the directory and metadata of the items you need for your solution (query, automation, dataExtension)
5. Paste these into the `[local project]\src\packagedSolutions\solutionA` directory like this:
    ````
    1.[local project]\src\packagedSolutions\solutionA\query
        [metadata of file(s)].sql
        [metadata of file(s)].json
    2.[local project]\src\packagedSolutions\solutionA\dataExtension
        [metadata of file(s)].json
    3.[local project]\src\packagedSolutions\solutionA\automation
        [metadata of file(s)].json
    ````
6. Modify your solution in the metadata as necessary (updating names, metadata etc.)
7. Now your solution is ready for deployment!
8. Deploy by navigating to the script in the terminal with `cd src\packagedSolutions\solutionA`
9. Execute the script with `./solutionA_deployment.ps1 SolutionA`. This will deploy your packaged solution to all the Business Unit (markets) part of `SolutionA` market list
10. The script will build all configuration as necessary and place them in the `[local project]\deploy` directory. 
11. Review as necessary.
12. When ready to deploy to Salesforce Marketing Cloud, use `./solutionA_deployment.ps1 SolutionA deploy`
13. This will rebuild the packaged solution again, and place once again in the `[local project]\deploy` directory, but now will `deploy` directly to Salesforce Marketing Cloud 


## Advanced Scenarios

### Merge Fields for Naming
A great use case is the way that each Business Unit can have it's own customised deployment, which using the packaged solution as a 'template'. To perform this, you would use 'merge field's as part of the market configuration in `.mcdevrc.json`

#### Merge Field Example
````
"markets": {
    "BusinessUnitA ": {
        "buName": "BusinessUnitA",
        "prefix": "BU_A"
    },
    "BusinessUnitB ": {
        "buName": "BusinessUnitB",
        "prefix": "BU_B"
    }        
}
````
Notice how we added the `prefix` property to the market configuration.  This can now be used dynamically within the packaged solution metadata like this:

#### Merge Field Data Extension Example

````
{
    "CustomerKey": "{{{prefix}}}_DataExtensionA",
    "Name": "{{{prefix}}}_DataExtensionA",
    "Description": "",
    "IsSendable": "false",
    "IsTestable": "false",
    "Fields": [
        {
            "Name": "SubscriberKey",
            "DefaultValue": "",
            "MaxLength": "255",
            "IsRequired": "true",
            "IsPrimaryKey": "true",
            "FieldType": "Text"
        }
    ],
    "r__folder_ContentType": "dataextension",
    "r__folder_Path": "Data Extensions"
}
````
Notice how the `{{{prefix}}}` was added to the CustomerKey and Name fields.
Now when we run the script, the merge fields will replaced by the values from the Business Unit we are deploying against. If we applied the script to two markets as per our configuration above, the following would be created:

#### Merge Field Deploy Example

File: `[local project]\deploy\prod\BusinessUnitA\dataExtension\DataExtensionA.dataExtension-meta.json`

````
{
    "CustomerKey": "BU_A_DataExtensionA",
    "Name": "BU_A_DataExtensionA",
    "Description": "",
    "IsSendable": "false",
    "IsTestable": "false",
    "Fields": [
        {
            "Name": "SubscriberKey",
            "DefaultValue": "",
            "MaxLength": "255",
            "IsRequired": "true",
            "IsPrimaryKey": "true",
            "FieldType": "Text"
        }
    ],
    "r__folder_ContentType": "dataextension",
    "r__folder_Path": "Data Extensions"
}
````

File: `[local project]\deploy\prod\BusinessUnitB\dataExtension\DataExtensionA.dataExtension-meta.json`

````
{
    "CustomerKey": "BU_B_DataExtensionA",
    "Name": "BU_B_DataExtensionA",
    "Description": "",
    "IsSendable": "false",
    "IsTestable": "false",
    "Fields": [
        {
            "Name": "SubscriberKey",
            "DefaultValue": "",
            "MaxLength": "255",
            "IsRequired": "true",
            "IsPrimaryKey": "true",
            "FieldType": "Text"
        }
    ],
    "r__folder_ContentType": "dataextension",
    "r__folder_Path": "Data Extensions"
}
````

Note how the package has been created for two Business Units, and each Data Extension has their own `CustomerKey` and `Name`.

