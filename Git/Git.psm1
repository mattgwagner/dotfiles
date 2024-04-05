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
    git pull --rebase $HEAD
    git stash pop
}
Set-Alias gitp Execute-GitPullRebasePrune

function Execute-GitFetchPrune
{
    git stash
    git submodule update --remote --rebase
    git fetch --prune
    git stash pop
}
Set-Alias gitf Execute-GitFetchPrune

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
            Write-Host "Updating $($dir.FullName)"

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

if (!(Get-InstalledModule posh-git))
{
    PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
}

if($IsWindows)
{
    $env:POSH_GIT_ENABLED = $true;

    $env:GIT_SSH = "C:\WINDOWS\System32\OpenSSH\ssh.exe"

    Start-SshAgent -Silent
}

Import-Module posh-git

Export-ModuleMember -Alias * -Function *