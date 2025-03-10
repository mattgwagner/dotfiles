$Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$Code = Join-Path $Home "Code"

if(!(test-path $Code))
{
    New-Item -Path $Code -ItemType Directory
}

# Reference https://gist.github.com/timsneath/19867b12eee7fd5af2ba

# Useful shortcuts for traversing directories
function cd...  { cd ..\.. }
function cd.... { cd ..\..\.. }

function Go-ToCode 
{
    Push-Location $Code
}

function Push-ReleaseBranch
{
    git pull origin main
    git push origin main:release
}

function New-ShellAs($user)
{
    runas.exe /netonly /savecred /user:$user pwsh
}

function Sudo($app, $user)
{
    runas.exe /netonly /savecred /user:$user $app
}

## This is based on the dotenv package https://www.powershellgallery.com/packages/dotenv

<#
.SYNOPSIS
Set-DotEnv loads from local .ENV files
#>
Function Set-DotEnv {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Object[]])]
    param(
        [switch]$recurse, #NYI
        [string]$path = './.env',
        [switch]$returnvars
    )
    $dotenv_added_vars = @() # a special var that tells us what we added
    $linecursor = 0

    $content = Get-Content $path -ErrorAction SilentlyContinue # if i doesn't exist, forget it

    $content | ForEach-Object { # go through line by line
        [string]$line = $_.trim() # trim whitespace
        if ($line -like "#*") {
            # it's a comment
            Write-Verbose "Found comment $line at line $linecursor. discarding"
        }
        elseif ($line -eq "") {
            # it's a blank line
            Write-Verbose "Found a blank line at line $linecursor, discarding"
        }
        else {
            # it's not a comment, parse it
            # find the first '='
            $eq = $line.IndexOf('=')
            $fq = $eq + 1
            $ln = $line.Length
            Write-Verbose "Found an assignment operator at position $eq in a string of length $ln on line $linecursor"

            $key = $line.Substring(0, $eq).trim()
            $value = $line.substring($fq, $line.Length - $fq).trim()
            Write-Verbose "Found $key with value $value"

            if ($value -match "`'|`"") {
                Write-Verbose "`tQuoted value found, trimming quotes"
                $value = $value.trim('"').trim("'")
                Write-Verbose "`tValue is now $value"
            }

            [System.Environment]::SetEnvironmentVariable($key, $value)

            $dotenv_added_vars += @{$key = $value }
            $env:dotnetenv_added_vars = ($dotenv_added_vars.keys -join (","))
        }
        $linecursor++
    }

    if ($returnvars) {
        Write-Verbose "returnvars was specified, returning the array of found vars"
        return $dotenv_added_vars
    }

}

Export-ModuleMember -variable * -Function *
