#!/bin/sh

#  ci_post_clone.sh
#  TCAT
#
#  Created by Jayson  Hahn on 2/23/24.
#  Copyright © 2024 cuappdev. All rights reserved.

echo "Installing Pods"

# Install CocoaPods using Homebrew.
brew install cocoapods

# Install dependencies you manage with CocoaPods.
pod install

echo "Downloading Secrets"

# Install wget using Homebrew.
brew install wget

# Create directories if they don't exist.
mkdir -p $CI_WORKSPACE/TCAT/Firebase
mkdir -p $CI_WORKSPACE/TCAT/Firebase/Prod
mkdir -p $CI_WORKSPACE/TCAT/Firebase/Dev

# Change directory to ci_scripts
cd $CI_WORKSPACE/ci_scripts

# Download files
wget -O ../TCAT/Firebase/Prod/GoogleService-Info.plist "$DEV_GOOGLE_SERVICE_PLIST"
wget -O ../TCAT/Firebase/Dev/GoogleService-Info.plist "$PROD_GOOGLE_SERVICE_PLIST"
wget -O ../TCAT/Supporting\ Files/Keys.plist "$KEYS"

