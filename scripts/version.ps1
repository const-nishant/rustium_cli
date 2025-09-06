# PowerShell versioning script for Rustium CLI
# Usage: .\scripts\version.ps1 [patch|minor|major|set <version>]

param(
  [Parameter(Position = 0)]
  [ValidateSet("patch", "minor", "major", "set")]
  [string]$Action = "patch",
    
  [Parameter(Position = 1)]
  [string]$Version = ""
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$White = "White"

function Write-ColorOutput {
  param([string]$Message, [string]$Color = $White)
  Write-Host $Message -ForegroundColor $Color
}

function Get-CurrentVersion {
  $cargoToml = Get-Content "Cargo.toml" -Raw
  if ($cargoToml -match 'version = "([^"]+)"') {
    return $matches[1]
  }
  throw "Could not find version in Cargo.toml"
}

function Set-Version {
  param([string]$NewVersion)
    
  Write-ColorOutput "🔄 Updating version to $NewVersion..." $Cyan
    
  # Update Cargo.toml
  $cargoToml = Get-Content "Cargo.toml" -Raw
  $cargoToml = $cargoToml -replace 'version = "[^"]+"', "version = `"$NewVersion`""
  Set-Content "Cargo.toml" $cargoToml -NoNewline
    
  # Update Cargo.lock
  Write-ColorOutput "📦 Updating Cargo.lock..." $Yellow
  cargo update
    
  Write-ColorOutput "✅ Version updated to $NewVersion" $Green
}

function Get-NextVersion {
  param([string]$CurrentVersion, [string]$BumpType)
    
  $versionParts = $CurrentVersion -split '\.'
  $major = [int]$versionParts[0]
  $minor = [int]$versionParts[1]
  $patch = [int]$versionParts[2]
    
  switch ($BumpType) {
    "major" {
      $major++
      $minor = 0
      $patch = 0
    }
    "minor" {
      $minor++
      $patch = 0
    }
    "patch" {
      $patch++
    }
  }
    
  return "$major.$minor.$patch"
}

function Test-GitStatus {
  $gitStatus = git status --porcelain
  if ($gitStatus) {
    Write-ColorOutput "❌ Working directory is not clean. Please commit or stash changes first." $Red
    Write-ColorOutput "Uncommitted changes:" $Yellow
    Write-Host $gitStatus
    exit 1
  }
}

function Test-GitBranch {
  $currentBranch = git branch --show-current
  if ($currentBranch -ne "main" -and $currentBranch -ne "master") {
    Write-ColorOutput "⚠️  Warning: You're not on main/master branch (current: $currentBranch)" $Yellow
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
      exit 1
    }
  }
}

function New-GitTag {
  param([string]$Version)
    
  $tagName = "v$Version"
    
  Write-ColorOutput "🏷️  Creating git tag: $tagName" $Cyan
  git tag -a $tagName -m "Release version $Version"
    
  Write-ColorOutput "📤 Pushing tag to remote..." $Cyan
  git push origin $tagName
    
  Write-ColorOutput "✅ Tag $tagName created and pushed" $Green
}

function New-GitCommit {
  param([string]$Version)
    
  $commitMessage = "chore: bump version to $Version"
    
  Write-ColorOutput "📝 Committing version change..." $Cyan
  git add Cargo.toml Cargo.lock
  git commit -m $commitMessage
    
  Write-ColorOutput "📤 Pushing commit to remote..." $Cyan
  git push origin HEAD
    
  Write-ColorOutput "✅ Version commit pushed" $Green
}

function Show-Help {
  Write-ColorOutput "🦀 Rustium CLI Version Manager" $Cyan
  Write-ColorOutput ""
  Write-ColorOutput "Usage: .\scripts\version.ps1 [patch|minor|major|set <version>]" $White
  Write-ColorOutput ""
  Write-ColorOutput "Commands:" $Yellow
  Write-ColorOutput "  patch     Increment patch version (0.1.0 -> 0.1.1)" $White
  Write-ColorOutput "  minor     Increment minor version (0.1.0 -> 0.2.0)" $White
  Write-ColorOutput "  major     Increment major version (0.1.0 -> 1.0.0)" $White
  Write-ColorOutput "  set       Set specific version (e.g., set 1.2.3)" $White
  Write-ColorOutput ""
  Write-ColorOutput "Examples:" $Yellow
  Write-ColorOutput "  .\scripts\version.ps1 patch" $White
  Write-ColorOutput "  .\scripts\version.ps1 minor" $White
  Write-ColorOutput "  .\scripts\version.ps1 set 2.0.0" $White
}

# Main execution
try {
  Write-ColorOutput "🦀 Rustium CLI Version Manager" $Cyan
  Write-ColorOutput "================================" $Cyan
    
  # Get current version
  $currentVersion = Get-CurrentVersion
  Write-ColorOutput "📋 Current version: $currentVersion" $White
    
  # Determine new version
  $newVersion = ""
  if ($Action -eq "set") {
    if (-not $Version) {
      Write-ColorOutput "❌ Error: Version required when using 'set' action" $Red
      Write-ColorOutput "Usage: .\scripts\version.ps1 set 1.2.3" $White
      exit 1
    }
    $newVersion = $Version
  }
  else {
    $newVersion = Get-NextVersion $currentVersion $Action
  }
    
  Write-ColorOutput "🎯 New version: $newVersion" $Green
    
  # Validate version format
  if (-not ($newVersion -match '^\d+\.\d+\.\d+$')) {
    Write-ColorOutput "❌ Error: Invalid version format. Use semantic versioning (e.g., 1.2.3)" $Red
    exit 1
  }
    
  # Check git status
  Test-GitStatus
  Test-GitBranch
    
  # Confirm action
  Write-ColorOutput ""
  Write-ColorOutput "🚀 Ready to:" $Yellow
  Write-ColorOutput "  1. Update version from $currentVersion to $newVersion" $White
  Write-ColorOutput "  2. Commit changes" $White
  Write-ColorOutput "  3. Create and push tag v$newVersion" $White
  Write-ColorOutput "  4. Trigger GitHub Actions release workflow" $White
  Write-ColorOutput ""
    
  $confirm = Read-Host "Continue? (y/N)"
  if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-ColorOutput "❌ Operation cancelled" $Red
    exit 1
  }
    
  # Update version
  Set-Version $newVersion
    
  # Commit changes
  New-GitCommit $newVersion
    
  # Create and push tag
  New-GitTag $newVersion
    
  Write-ColorOutput ""
  Write-ColorOutput "🎉 Version $newVersion released successfully!" $Green
  Write-ColorOutput "📦 GitHub Actions will now build and publish the release" $Cyan
  Write-ColorOutput "🔗 Check the Actions tab in your GitHub repository" $Cyan
    
}
catch {
  Write-ColorOutput "❌ Error: $($_.Exception.Message)" $Red
  exit 1
}
