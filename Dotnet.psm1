
function Check-DotnetUpgrade
{
    Ensure-DotnetUpgradeAssistant

    upgrade-assistant analyze
}

function Ensure-DotnetUpgradeAssistant
{
    dotnet tool install -g upgrade-assistant
}

Export-ModuleMember -Alias * -Function *
