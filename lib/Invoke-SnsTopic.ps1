function Invoke-SnsTopic {
    [CmdLetBinding()]
    Param(
        [PSObject] $CloudWatchConfig
    )
 
    $data = $CloudWatchConfig.default
    $env = $data.env

    Set-AWSCredentials -ProfileName $env.prod
    Set-DefaultAWSRegion -Region $env.rgn

    $sns = $data.sns
    $array = @()
    foreach ($tpc in $sns) {
        $arn = "arn:aws:sns:$($env.rgn):$($env.acct):$($tpc.tpc)"
        $topic = $null
        try {
            $topic = Get-SNSTopicAttribute -TopicArn $arn
        } 
        catch [System.InvalidOperationException] {
            # Empty try/catch, expected error Write-Error $_
            # If SNS Topic doesn't exist, create new topic
            if ($topic -ne $null) {
                Continue
            }
            $newTpc = New-SNSTopic -Name $tpc.tpc
            Connect-SNSNotification -TopicArn $newTpc -Protocol "email" -Endpoint $tpc.ept
        }
        $array += $arn
    }
    return $array
}