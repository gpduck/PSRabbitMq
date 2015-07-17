$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

. "$here\TestSetup.ps1"
. "$here\..\PSRabbitMQ\$sut"
. "$here\..\PSRabbitMQ\New-RabbitMqConnectionFactory"

Describe "Connect-RabbitMqChannel" {
    context "test parameters" {
        It "connection should be mandatory" {
            $cmd = Get-Command -Name  Connect-RabbitMqChannel
            $cmd.parameters["Connection"].ParameterSets["__AllParameterSets"].IsMandatory | Should Be $True
        }
    }

    context "Anonymous queue" {
        BeforeEach {
            $Connection = New-RabbitMqConnectionFactory -ComputerName $Server
            $ExchangeName = "ConnectExchange"
            $Key = "ConnectKey"
            Add-RabbitMqExchange -Name $ExchangeName -Type direct -AutoDelete -VirtualHost $VirtualHost -BaseUri $BaseUri
        }
        
        AfterEach {
            if($Connection) {
                $Connection.Dispose()
            }
        }
        
        It "connects using an exchange" {
            $Channel = Connect-RabbitMqChannel -Connection $Connection -Exchange $ExchangeName -Key $Key;
            $Channel | Should Not Be $null
            $Channel.IsOpen | Should Be $true
        }
    }
    
    context "named queue" {
        BeforeEach {
            $Connection = New-RabbitMqConnectionFactory -ComputerName $Server
            $ExchangeName = "ConnectExchange"
            $Key = "ConnectKey"
            Add-RabbitMqExchange -Name $ExchangeName -Type direct -AutoDelete -VirtualHost $VirtualHost -BaseUri $BaseUri
        }
        
        AfterEach {
            if($Connection) {
                $Connection.Dispose()
            }
            Get-RabbitMQQueue -BaseUri $BaseUri -Name "testqueue" | Remove-RabbitMQQueue -BaseUri $BaseUri -Confirm:$False
        }
        
        It "creates a named queue" {
            $Channel = Connect-RabbitMqChannel -Connection $Connection -Exchange $ExchangeName -Key $Key -QueueName "testqueue"
            $Channel | Should Not Be $Null
            $Channel.IsOpen | Should Be $true
            $Queue = Get-RabbitMQQueue -BaseUri $BaseUri -Name "testqueue"
            $Queue | Should Not Be $Null
        }
        
        It "sets the queue parameters correctly" {
            $Channel = Connect-RabbitMqChannel -Connection $Connection -Exchange $ExchangeName -Key $Key -QueueName "testqueue" -Durable $false -Exclusive $true -AutoDelete $True
            $Channel | Should Not Be $Null
            $Channel.IsOpen | Should Be $true
            $Queue = Get-RabbitMQQueue -BaseUri $BaseUri -Name "testqueue"
            $Queue | Should Not Be $Null
            $Queue.Durable | Should Be $false
            $Queue.auto_delete | Should Be $True
            $QUeue.owner_pid_details | Should Not BeNullOrEmpty
        }
    }
    
    context "existing queue" {
        BeforeEach {
            $Connection = New-RabbitMqConnectionFactory -ComputerName $Server
            $ExchangeName = "ConnectExchange"
            $Key = "ConnectKey"
            Add-RabbitMqExchange -Name $ExchangeName -Type direct -AutoDelete -VirtualHost $VirtualHost -BaseUri $BaseUri
            Add-RabbitMqQueue -Name "testqueue" -VirtualHost $VirtualHost -Durable -AutoDelete -BaseUri $BaseUri
        }
        
        AfterEach {
            if($Connection) {
                $Connection.Dispose()
            }
            Get-RabbitMQQueue -BaseUri $BaseUri -Name "testqueue" | Remove-RabbitMQQueue -BaseUri $BaseUri -Confirm:$False
        }
        
        It "connects to an existing queue" {
            $Channel = Connect-RabbitMqChannel -Connection $Connection -Exchange $ExchangeName -Key $Key -QueueName "testqueue"
            $Channel | Should Not Be $Null
            $Channel.IsOpen | Should Be $true
        }
    }
}
