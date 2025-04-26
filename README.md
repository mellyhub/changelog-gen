# Changelog Generator

A simple command-line application to generate changelogs from Git repositories using LibGit2Sharp.

## Features

- Generates a changelog in Markdown format from Git commit history
- Groups commits by date
- Includes commit message, author, and short hash
- Saves the output to a changelog.md file

## Usage

```
dotnet run [repository-path]
```

- `repository-path`: Path to the Git repository

## Examples

Generate changelog for the current directory:
```
dotnet run
```

Generate changelog for a specific repository:
```
dotnet run C:\path\to\repository
```

For convenience, you can use the provided `run-loggenerator` file:

## Requirements

- .NET 8.0 or higher
- LibGit2Sharp (automatically installed via NuGet) 