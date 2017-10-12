# PowerShell 
## CloudWatch Alerts
- The following PowerShell script create's SNS Topic(s) and Subscription(s). The `Invoke-CloudWatch.ps1` create's Alarm for defined `running` instances and delete's Alarm for defined `terminated` instances from the `./data/data.json` file.  

## Instructions
- Clone this repository.
- The only file that requires modification is `./data/data.json`

## Structure Overview
- Folders
  - `./vscode/`: VS code project workspace settings.
  - `./lib`: project code.
  - `./scripts`: code to publish results to AWS S3.
- Files
  - `./Main.ps1`: the main worker for this project.
  - `./data/data.json`: JSON data file.
  - `./lib/Import-Data.ps1`: imports JSON data file.
  - `./lib/Invoke-SnsTopic.ps1`: invokes SNS;
    - Creates / subscribes topic unless topic already exist(s).
  - `./lib/Invoke-CloudWatchAlarm.ps1`: invokes CloudWatch to;
    - Create Alarm for `running` instances.
    - Deletes Alarm for `terminated` instances.