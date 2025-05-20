# Configure Firebase credentials for ArgentEnveloppes app
#
# This script helps set up the Firebase configuration credentials for the application.
# It updates the firebase_options.dart file and index.html with the correct values.
#
# Usage: 
#   ./update_firebase_config.ps1 -ProjectId "your-project-id" -WebApiKey "your-web-api-key" -WebAppId "your-web-app-id" -AuthDomain "your-auth-domain"

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$true)]
    [string]$WebApiKey,
    
    [Parameter(Mandatory=$true)]
    [string]$WebAppId,
    
    [Parameter(Mandatory=$true)]
    [string]$AuthDomain,
    
    [Parameter(Mandatory=$true)]
    [string]$MessagingSenderId,
    
    [Parameter(Mandatory=$true)]
    [string]$StorageBucket,
    
    [Parameter(Mandatory=$false)]
    [string]$AndroidApiKey = "",
    
    [Parameter(Mandatory=$false)]
    [string]$AndroidAppId = "",
    
    [Parameter(Mandatory=$false)]
    [string]$IosApiKey = "",
    
    [Parameter(Mandatory=$false)]
    [string]$IosAppId = "",
    
    [Parameter(Mandatory=$false)]
    [string]$IosClientId = "",
    
    [Parameter(Mandatory=$false)]
    [string]$IosBundleId = ""
)

# Function to update Firebase options in Dart file
function Update-FirebaseOptionsDart {
    $filePath = "lib/firebase_options.dart"
    $content = Get-Content $filePath -Raw
    
    # Update Web options
    $content = $content -replace "apiKey: 'YOUR_WEB_API_KEY'", "apiKey: '$WebApiKey'"
    $content = $content -replace "appId: 'YOUR_WEB_APP_ID'", "appId: '$WebAppId'"
    $content = $content -replace "messagingSenderId: 'YOUR_WEB_MESSAGING_SENDER_ID'", "messagingSenderId: '$MessagingSenderId'"
    $content = $content -replace "projectId: 'YOUR_PROJECT_ID'", "projectId: '$ProjectId'"
    $content = $content -replace "authDomain: 'YOUR_AUTH_DOMAIN'", "authDomain: '$AuthDomain'"
    $content = $content -replace "storageBucket: 'YOUR_STORAGE_BUCKET'", "storageBucket: '$StorageBucket'"
    
    # Update Android options if provided
    if ($AndroidApiKey -ne "") {
        $content = $content -replace "apiKey: 'YOUR_ANDROID_API_KEY'", "apiKey: '$AndroidApiKey'"
    }
    if ($AndroidAppId -ne "") {
        $content = $content -replace "appId: 'YOUR_ANDROID_APP_ID'", "appId: '$AndroidAppId'"
    }
    
    # Update iOS options if provided
    if ($IosApiKey -ne "") {
        $content = $content -replace "apiKey: 'YOUR_IOS_API_KEY'", "apiKey: '$IosApiKey'"
    }
    if ($IosAppId -ne "") {
        $content = $content -replace "appId: 'YOUR_IOS_APP_ID'", "appId: '$IosAppId'"
    }
    if ($IosClientId -ne "") {
        $content = $content -replace "iosClientId: 'YOUR_IOS_CLIENT_ID'", "iosClientId: '$IosClientId'"
    }
    if ($IosBundleId -ne "") {
        $content = $content -replace "iosBundleId: 'YOUR_IOS_BUNDLE_ID'", "iosBundleId: '$IosBundleId'"
    }
    
    # Save the updated content
    Set-Content -Path $filePath -Value $content
    Write-Host "Updated Firebase options in $filePath"
}

# Function to update Firebase config in index.html
function Update-IndexHtml {
    $filePath = "index.html"
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        
        # Find the Firebase config section
        $pattern = '(?s)const firebaseConfig = \{.*?\};'
        $replacement = @"
const firebaseConfig = {
      apiKey: "$WebApiKey",
      authDomain: "$AuthDomain",
      projectId: "$ProjectId",
      storageBucket: "$StorageBucket",
      messagingSenderId: "$MessagingSenderId",
      appId: "$WebAppId"
    };
"@
        
        # Replace the Firebase config
        $content = $content -replace $pattern, $replacement
        
        # Save the updated content
        Set-Content -Path $filePath -Value $content
        Write-Host "Updated Firebase config in $filePath"
    } else {
        Write-Host "Warning: $filePath not found. Skipping update."
    }
}

# Main execution
Write-Host "Starting Firebase configuration update..."
Update-FirebaseOptionsDart
Update-IndexHtml
Write-Host "Firebase configuration updated successfully!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Create a Firebase project at https://console.firebase.google.com/"
Write-Host "2. Enable Authentication methods (Email/Password and Google)"
Write-Host "3. For web deployment, add your GitHub Pages domain to authorized domains"
Write-Host "   in Firebase Console > Authentication > Settings > Authorized domains"
Write-Host ""
