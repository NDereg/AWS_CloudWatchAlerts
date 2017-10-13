function Invoke-CloudWatchAlarm {
    [CmdLetBinding()]
    Param(
        [PSObject]$CloudWatchConfig,
        [PSObject[]]$Sns
    )
    
    $data = $CloudWatchConfig.default
    $env = $data.env

    Set-AWSCredentials -ProfileName $env.prod
    Set-DefaultAWSRegion -Region $env.rgn

    $alarms = $data.alarms
    $cpu = $data.cpuMetrics

    foreach ($alarm in $alarms) {
        Get-CloudWatchAlarm $cpu $alarm
    }
}

function Get-CloudWatchAlarm {
    [CmdLetBinding()]
    Param($cpu, $alarm)
    
    $prefix = "$($alarm.srv)" + "-" + "$($cpu.dim)" + "-" + "$($alarm.thr)"
    $awsAlarms = Get-CWAlarm | Where-Object {$_.AlarmName -like "$prefix*"}
    $awsEc2 = Get-EC2Instance -Filter @{Name = "tag-value"; Values = $alarm.srv}
    $instances = $awsEc2.Instances
    foreach ($awsAlarm in $awsAlarms) {
        Get-InsufficientAlarm $instances $awsAlarm
    }
    foreach ($instance in $instances) {
        Set-CloudWatchAlarm $instance $prefix $awsAlarms $cpu $alarm
    }
}

function Get-InsufficientAlarm {
    [CmdLetBinding()]
    Param($instances, $awsAlarm)
    $instanceIdArray = @()
    foreach ($instance in $instances) {
        $instanceIdArray += $instance.InstanceId
    }
    $alarmId = $awsAlarm.Dimensions.Value
    # Delete straggler Alarm (alarm exists but Ec2 doesn't)
    if ($alarmId -notin $instanceIdArray) {
        $alarmName = $awsAlarm.AlarmName
        Remove-CloudWatchAlarm $alarmName
    }
}

function Set-CloudWatchAlarm {
    [CmdLetBinding()]
    Param($instance, $prefix, $awsAlarms, $cpu, $alarm)
    
    $date = Get-Date
    $delay = $cpu.delay
    $id = $instance.InstanceId
    $launch = $instance.LaunchTime
    $time = $launch + $delay
    $running = $instance.State.Name
    $alarmName = $prefix + "-" + $id
    $alarmAvail = $awsAlarms.AlarmName | Where-Object {$_ -like $alarmName }
    # If (ec2 is not running) and (alarm exists) and (launched within 15 mins) the following loop will not execute
    if ($running -eq "running" -and ([string]::IsNullOrEmpty($alarmAvail)) -and $date -gt $time) {
        Add-CloudWatchAlarm $dim $cpu $id $alarm $alarmName
    }
    # If (ec2 is terminated) the following loop will execute
    elseif ($running -eq "terminated") {
        Remove-CloudWatchAlarm $alarmName
    }
}

function Add-CloudWatchAlarm {
    [CmdLetBinding()]
    Param($dim, $cpu, $id, $alarm, $alarmName)
    
    $dim = New-Object "Amazon.CloudWatch.Model.Dimension"
    $dim.Name = "InstanceId"
    $dim.Value = $id

    $action = $Sns | Where-Object {$_ -like "*$($alarm.tpc)"}
    Write-CWMetricAlarm -AlarmName $alarmName -AlarmDescription ($cpu.desc + " " + $alarm.thr) -Dimension `
        $dim -Namespace $cpu.name -MetricName $cpu.metr -Unit $cpu.unit -Statistic $cpu.stat -Period `
        $alarm.per -EvaluationPeriod $alarm.eval -Threshold $alarm.thr -ComparisonOperator $cpu.comp -AlarmAction $action
}

function Remove-CloudWatchAlarm {
    [CmdLetBinding()]
    Param($alarmName)
    
    Remove-CWAlarm -AlarmName $alarmName -Force
}