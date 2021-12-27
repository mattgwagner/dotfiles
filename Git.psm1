git config --global init.defaultBranch main
git config --global user.name "mattgwagner"

function Execute-GitAmend
{
    git commit --amend --no-edit
}
Set-Alias amend Execute-GitAmend

function Execute-GitPullRebasePrune
{
    git stash
    git submodule update --remote --rebase
    git fetch --prune    
    git rebase $HEAD
    git stash pop
}
Set-Alias gitp Execute-GitPullRebasePrune

function Execute-GitRebaseAndPush
{
    gitp
    git push
}
Set-Alias gits Execute-GitRebaseAndPush

function Update-AllRepositories
{
    # Cycle through all of the top level folders and pull the latest

    foreach($dir in (Get-ChildItem -Directory))
    {
        Push-Location $dir

        if(Test-Path .git)
        {
            Execute-GitPullRebasePrune
        }

        Pop-Location
    }
}

function Reset-LocalRepo
{
    git clean -X -d -f
    dotnet nuget locals --clear all
    dotnet tool retore
}

if(!(Test-Path 'C:\tools\poshgit\dahlbyk-posh-git*'))
{
    $Here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    & "$Here\Ensure-Chocolatey.ps1"

    choco install poshgit
}

Import-Module (Resolve-Path 'C:\tools\poshgit\dahlbyk-posh-git*\src\posh-git.psd1')

$env:POSH_GIT_ENABLED = $true;

$env:GIT_SSH = "C:\WINDOWS\System32\OpenSSH\ssh.exe"

Start-SshAgent -Silent

Export-ModuleMember -Alias * -Function *