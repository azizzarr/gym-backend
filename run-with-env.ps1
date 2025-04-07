# Load environment variables from .env file
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $name = $matches[1]
            $value = $matches[2]
            [Environment]::SetEnvironmentVariable($name, $value, 'Process')
            Write-Host "Set environment variable: $name"
        }
    }
} else {
    Write-Host "Warning: .env file not found. Using default values from application.properties."
}

# Run the application
& 'C:\Program Files\apache-maven-3.8.5\bin\mvn.cmd' spring-boot:run "-Dspring.profiles.active=prod" 