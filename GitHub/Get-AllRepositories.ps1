param (
    $Organization
)

$Repos = [System.Collections.ArrayList]@()

$Retrieved = 0;

do
{
    $Results = gh api "https://api.github.com/orgs/$Organization/repos?per_page=100"

    $FromJson = ConvertFrom-Json $Results

    foreach($Repo in $FromJson)
    {
        $Repos.Add($Repo)
    }

    $Retrieved = $FromJson.Count

    Write-Output "Retrieved $Retrieved more repos, $($Repos.Count) so far"
}
while($Retrieved -gt 0);

return $Repos