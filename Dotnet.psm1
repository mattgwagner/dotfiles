
function Check-DotnetUpgrade($Project)
{
    Ensure-DotnetUpgradeAssistant

    upgrade-assistant analyze $Project
}

function Ensure-DotnetUpgradeAssistant
{
    dotnet tool install -g upgrade-assistant --ignore-failed-sources
}

Export-ModuleMember -Alias * -Function *
