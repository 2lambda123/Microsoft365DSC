[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $CmdletModule = (Join-Path -Path $PSScriptRoot `
            -ChildPath "..\Stubs\Office365.psm1" `
            -Resolve)
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
        -ChildPath "..\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-O365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "EXODkimSigningConfig"
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        $secpasswd = ConvertTo-SecureString "test@password1" -AsPlainText -Force
        $GlobalAdminAccount = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)
        Mock -CommandName Close-SessionsAndReturnError -MockWith {

        }

        Mock -CommandName Connect-ExchangeOnline -MockWith {

        }

        Mock -CommandName Confirm-ImportedCmdletIsAvailable -MockWith {
            return $true
        }

        Mock -CommandName Get-PSSession -MockWith {

        }

        Mock -CommandName Remove-PSSession -MockWith {

        }

        Mock -CommandName New-DkimSigningConfig -MockWith {

        }

        Mock -CommandName Set-DkimSigningConfig -MockWith {

        }

        Mock -CommandName Remove-DkimSigningConfig -MockWith {

        }

        # Test contexts
        Context -Name "DkimSigningConfig creation." -Fixture {
            $testParams = @{
                Ensure                 = 'Present'
                Identity               = 'contoso.com'
                GlobalAdminAccount     = $GlobalAdminAccount
                AdminDisplayName       = 'contoso.com DKIM Config'
                BodyCanonicalization   = 'Relaxed'
                Enabled                = $false
                HeaderCanonicalization = 'Relaxed'
                KeySize                = 1024
            }

            Mock -CommandName Get-DkimSigningConfig -MockWith {
                return @{
                    Identity = 'SomeOtherPolicy'
                }
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
            }
        }

        Context -Name "DkimSigningConfig update not required." -Fixture {
            $testParams = @{
                Ensure                 = 'Present'
                Identity               = 'contoso.com'
                GlobalAdminAccount     = $GlobalAdminAccount
                AdminDisplayName       = 'contoso.com DKIM Config'
                BodyCanonicalization   = 'Relaxed'
                Enabled                = $false
                HeaderCanonicalization = 'Relaxed'
                KeySize                = 1024
            }

            Mock -CommandName Get-DkimSigningConfig -MockWith {
                return @{
                    Ensure                 = 'Present'
                    Identity               = 'contoso.com'
                    GlobalAdminAccount     = $GlobalAdminAccount
                    AdminDisplayName       = 'contoso.com DKIM Config'
                    BodyCanonicalization   = 'Relaxed'
                    Enabled                = $false
                    HeaderCanonicalization = 'Relaxed'
                    KeySize                = 1024
                }
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "DkimSigningConfig update needed." -Fixture {
            $testParams = @{
                Ensure                 = 'Present'
                Identity               = 'contoso.com'
                GlobalAdminAccount     = $GlobalAdminAccount
                AdminDisplayName       = 'contoso.com DKIM Config'
                BodyCanonicalization   = 'Relaxed'
                Enabled                = $true
                HeaderCanonicalization = 'Relaxed'
                KeySize                = 1024
            }

            Mock -CommandName Get-DkimSigningConfig -MockWith {
                return @{
                    Ensure                 = 'Present'
                    Identity               = 'contoso.com'
                    GlobalAdminAccount     = $GlobalAdminAccount
                    AdminDisplayName       = 'contoso.com DKIM Config'
                    BodyCanonicalization   = 'Simple'
                    Enabled                = $false
                    HeaderCanonicalization = 'Simple'
                    KeySize                = 1024
                }
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
            }
        }

        Context -Name "DkimSigningConfig removal." -Fixture {
            $testParams = @{
                Ensure             = 'Absent'
                Identity           = 'contoso.com'
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName Get-DkimSigningConfig -MockWith {
                return @{
                    Identity = 'contoso.com'
                }
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
