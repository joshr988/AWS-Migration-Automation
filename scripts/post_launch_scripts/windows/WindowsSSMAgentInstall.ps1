Invoke-WebRequest https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe -OutFile $env:USERPROFILE\Downloads\SSMAgent_latest.exe
Start-Process -FilePath $env:USERPROFILE\Downloads\SSMAgent_latest.exe -ArgumentList "/S"
rm -Force $env:USERPROFILE\Downloads\SSMAgent_latest.exe
Restart-Service AmazonSSMAgent