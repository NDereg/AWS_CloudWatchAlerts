# PowerShell 
## CloudWatch Alerts
The following script is called by `CallScript.ps1` which defines the allowed time periods for the script to execute. This feature was added due to **Auto Scaling Group - Scheduled Actions**. First, the script creates SNS Topic(s) and Subscription(s) unless they already exist provided in the *./data/data.json* file. Next, the script will remove any straggler Alarm(s) - *"straggler alarms are identified as; a(n) Alarm that doesn't have an ec2 instance associated with it"*. Then, the script creates Alarm(s) for instances in status **running** and deletes Alarm(s) for instances in status **terminated** - *"ideally terminated instance(s) disappear from the AWS console after 60 min. however, if script is executed and the ec2 is no longer visible from the AWS console, Alarm(s) created for ec2 instance(s) will become stragglers hence the added logic in the beginning of the script to remove those"*.

## Instructions
- Clone this repository:
  - https://github.com/NDereg/AWS_CloudWatchAlerts.git
- Script should be executed via `./scripts/CallScript.ps1`
- The only file that requires modification is `./data/data.json`

## Structure Overview
- Folders
  - `./vscode/`: VS code project workspace settings.
  - `./lib`: project code.
  - `./scripts`: code to publish results to AWS S3.
- Files
  - `./Main.ps1`: the main worker for this project.
  - `./data/data.json`: JSON data file.
  - `./scripts/CallScript.ps1`: entry point / allowed execution.
  - `./lib/Import-Data.ps1`: imports JSON data file.
  - `./lib/Invoke-SnsTopic.ps1`: invokes SNS;
    - Creates / subscribes topic unless topic already exist(s).
  - `./lib/Invoke-CloudWatchAlarm.ps1`: invokes CloudWatch to;
    - Create Alarm for `running` instances.
    - Deletes Alarm for `terminated` instances.