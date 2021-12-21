param (
    $Organization
)

$Repos = gh api "https://api.github.com/orgs/$Organization/repos"

return Convert-FromJson $Repos