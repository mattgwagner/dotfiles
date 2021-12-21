param (
    $Organization
)

$Repos = [System.Collections.ArrayList]@()

$Retrieved = 0;

$Page = 0;

do
{
    Write-Output "Getting Repository Page $Page..."

    $Results = gh api "https://api.github.com/orgs/$Organization/repos?page=$Page"

    $FromJson = ConvertFrom-Json $Results

    foreach($Repo in $FromJson)
    {
        $Repos.Add($Repo)
    }

    $Retrieved = $FromJson.Count

    $Page += 1

    Write-Output "Retrieved $Retrieved more repos, $($Repos.Count) so far"
}
while($Retrieved -gt 0);

return $Repos