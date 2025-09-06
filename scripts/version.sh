#!/bin/bash

# Bash versioning script for Rustium CLI
# Usage: ./scripts/version.sh [patch|minor|major|set <version>]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to get current version from Cargo.toml
get_current_version() {
    grep -oP 'version = "\K[^"]+' Cargo.toml | head -1
}

# Function to set version in Cargo.toml
set_version() {
    local new_version=$1
    
    print_color $CYAN "🔄 Updating version to $new_version..."
    
    # Update Cargo.toml
    sed -i.bak "s/version = \"[^\"]*\"/version = \"$new_version\"/" Cargo.toml
    rm Cargo.toml.bak
    
    # Update Cargo.lock
    print_color $YELLOW "📦 Updating Cargo.lock..."
    cargo update
    
    print_color $GREEN "✅ Version updated to $new_version"
}

# Function to get next version based on bump type
get_next_version() {
    local current_version=$1
    local bump_type=$2
    
    IFS='.' read -ra VERSION_PARTS <<< "$current_version"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}
    
    case $bump_type in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Function to check git status
check_git_status() {
    if ! git diff-index --quiet HEAD --; then
        print_color $RED "❌ Working directory is not clean. Please commit or stash changes first."
        print_color $YELLOW "Uncommitted changes:"
        git status --porcelain
        exit 1
    fi
}

# Function to check git branch
check_git_branch() {
    local current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "main" && "$current_branch" != "master" ]]; then
        print_color $YELLOW "⚠️  Warning: You're not on main/master branch (current: $current_branch)"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to create git tag
create_git_tag() {
    local version=$1
    local tag_name="v$version"
    
    print_color $CYAN "🏷️  Creating git tag: $tag_name"
    git tag -a "$tag_name" -m "Release version $version"
    
    print_color $CYAN "📤 Pushing tag to remote..."
    git push origin "$tag_name"
    
    print_color $GREEN "✅ Tag $tag_name created and pushed"
}

# Function to create git commit
create_git_commit() {
    local version=$1
    local commit_message="chore: bump version to $version"
    
    print_color $CYAN "📝 Committing version change..."
    git add Cargo.toml Cargo.lock
    git commit -m "$commit_message"
    
    print_color $CYAN "📤 Pushing commit to remote..."
    git push origin HEAD
    
    print_color $GREEN "✅ Version commit pushed"
}

# Function to show help
show_help() {
    print_color $CYAN "🦀 Rustium CLI Version Manager"
    echo
    print_color $WHITE "Usage: ./scripts/version.sh [patch|minor|major|set <version>]"
    echo
    print_color $YELLOW "Commands:"
    print_color $WHITE "  patch     Increment patch version (0.1.0 -> 0.1.1)"
    print_color $WHITE "  minor     Increment minor version (0.1.0 -> 0.2.0)"
    print_color $WHITE "  major     Increment major version (0.1.0 -> 1.0.0)"
    print_color $WHITE "  set       Set specific version (e.g., set 1.2.3)"
    echo
    print_color $YELLOW "Examples:"
    print_color $WHITE "  ./scripts/version.sh patch"
    print_color $WHITE "  ./scripts/version.sh minor"
    print_color $WHITE "  ./scripts/version.sh set 2.0.0"
}

# Main execution
main() {
    local action=${1:-"patch"}
    local version=$2
    
    print_color $CYAN "🦀 Rustium CLI Version Manager"
    print_color $CYAN "================================"
    
    # Get current version
    local current_version=$(get_current_version)
    print_color $WHITE "📋 Current version: $current_version"
    
    # Determine new version
    local new_version=""
    if [[ "$action" == "set" ]]; then
        if [[ -z "$version" ]]; then
            print_color $RED "❌ Error: Version required when using 'set' action"
            print_color $WHITE "Usage: ./scripts/version.sh set 1.2.3"
            exit 1
        fi
        new_version=$version
    else
        new_version=$(get_next_version "$current_version" "$action")
    fi
    
    print_color $GREEN "🎯 New version: $new_version"
    
    # Validate version format
    if [[ ! $new_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_color $RED "❌ Error: Invalid version format. Use semantic versioning (e.g., 1.2.3)"
        exit 1
    fi
    
    # Check git status
    check_git_status
    check_git_branch
    
    # Confirm action
    echo
    print_color $YELLOW "🚀 Ready to:"
    print_color $WHITE "  1. Update version from $current_version to $new_version"
    print_color $WHITE "  2. Commit changes"
    print_color $WHITE "  3. Create and push tag v$new_version"
    print_color $WHITE "  4. Trigger GitHub Actions release workflow"
    echo
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_color $RED "❌ Operation cancelled"
        exit 1
    fi
    
    # Update version
    set_version "$new_version"
    
    # Commit changes
    create_git_commit "$new_version"
    
    # Create and push tag
    create_git_tag "$new_version"
    
    echo
    print_color $GREEN "🎉 Version $new_version released successfully!"
    print_color $CYAN "📦 GitHub Actions will now build and publish the release"
    print_color $CYAN "🔗 Check the Actions tab in your GitHub repository"
}

# Handle help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Run main function
main "$@"
