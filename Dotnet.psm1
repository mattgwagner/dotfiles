## Yes, I know these are two distinct different versions

$Vs2019 = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe"

$Vs2022 = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"


function Check-DotnetUpgrade($Project)
{
    Ensure-DotnetUpgradeAssistant

    upgrade-assistant analyze $Project
}

function Ensure-DotnetUpgradeAssistant
{
    dotnet tool install -g upgrade-assistant --ignore-failed-sources
}

Export-ModuleMember -Alias * -Function * -Variable
