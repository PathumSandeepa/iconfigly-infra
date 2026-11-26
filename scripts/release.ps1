param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$Normalized = $Version.TrimStart("v")

foreach ($envFile in @(".env", ".env.example")) {
    $path = Join-Path $RepoRoot $envFile
    if (Test-Path $path) {
        $content = Get-Content $path -Raw
        if ($content -match "(?m)^ICONFIGLY_VERSION=.*$") {
            $updated = $content -replace "(?m)^ICONFIGLY_VERSION=.*$", "ICONFIGLY_VERSION=$Normalized"
        } else {
            $updated = $content.TrimEnd() + "`nICONFIGLY_VERSION=$Normalized`n"
        }
        Set-Content -Path $path -Value $updated -NoNewline
    }
}

git -C $RepoRoot config user.name "Pathum Sandeepa"
git -C $RepoRoot config user.email "pathumsandeepa13@gmail.com"

git -C $RepoRoot add .env.example
$status = git -C $RepoRoot status --porcelain .env.example
if ($status) {
    git -C $RepoRoot commit -m "chore(release): bump ICONFIGLY_VERSION to $Normalized"
    git -C $RepoRoot push origin HEAD
}

git -C $RepoRoot tag -a $Version -m "Release $Version"
git -C $RepoRoot push origin $Version

Write-Host "Pushed tag '$Version' to iconfigly-infra. GitHub Actions will propagate v$Normalized across all repos."
