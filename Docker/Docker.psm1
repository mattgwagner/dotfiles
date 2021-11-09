
function Execute-DockerComposeUp
{
    docker-compose up -d
}
Set-Alias up Execute-DockerComposeUp

function Execute-DockerComposeDown
{
    docker-compose down
}
Set-Alias down Execute-DockerComposeDown