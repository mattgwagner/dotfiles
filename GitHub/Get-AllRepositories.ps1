param (
    $Organization
)

$Repos = gh api "https://api.github.com/orgs/$Organization/repos?per_page=100"

return ConvertFrom-Json $Repos