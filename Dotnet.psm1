
function Check-DotnetUpgrade
{
    Ensure-DotnetUpgradeAssistant

    upgrade-assistant analyze
}

function Ensure-DotnetUpgradeAssistant
{
    dotnet tool install -g upgrade-assistant --ignore-failed-sources
}

Export-ModuleMember -Alias * -Function *
