$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Server = "localhost"
$RabbitPort = 5672
$MgmtPort = 15672
$VirtualHost = "/"
$BaseUri = "http://localhost:$MgmtPort"

$RabbitAssembly = Join-Path $Here "..\PSRabbitMQ\lib\RabbitMQ.Client.dll"
Add-Type -Path $RabbitAssembly

#For now just assume this is available
Import-Module RabbitMQTools -ErrorAction Stop

