#!/bin/sh

#  ci_post_clone.sh
#  TCAT
#
#  Created by Jayson  Hahn on 2/23/24.
#  Copyright © 2024 cuappdev. All rights reserved.

echo "Installing Pods"

# Install CocoaPods using Homebrew
brew install cocoapods

# Install dependencies with CocoaPods
pod install

echo "Downloading Secrets"

# Install wget using Homebrew
brew install wget

# Change directory to ci_scripts
cd $CI_PRIMARY_REPOSITORY_PATH/ci_scripts

# Create directories
mkdir ../TransitSecrets

# Download files
wget -O ../TransitSecrets/uplift-codegen-config-dev.json "$UPLIFT_CODEGEN_DEV"
wget -O ../TransitSecrets/uplift-codegen-config-prod.json "$UPLIFT_CODEGEN_PROD"
wget -O ../TransitSecrets/Keys.plist "$KEYS_PLIST"
wget -O ../TransitSecrets/GoogleService-Info.plist "$GOOGLE_PLIST"

# Generate API file via Apollo
echo "Generating API file"
../Pods/Apollo/apollo-ios-cli generate -p "TransitSecrets/uplift-codegen-config-prod.json" -f
