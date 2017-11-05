# Customise this file, documentation can be found here:
# https://github.com/fastlane/fastlane/tree/master/fastlane/docs
# All available actions: https://docs.fastlane.tools/actions
# can also be listed using the `fastlane actions` command

# Change the syntax highlighting to Ruby
# All lines starting with a # are ignored when running `fastlane`

# If you want to automatically update fastlane if a new version is available:
# update_fastlane

# This is the minimum version number required.
# Update this, if you use features of a newer version
fastlane_version "2.62.0"

default_platform :ios

platform :ios do
  before_all do
    
  end

  desc "Runs all the tests"
  lane :test do
    scan
  end

  desc "Creating a code signing certificate and provisioning profile"
  lane :provision do

    produce(
      username: ENV["APPLE_ID"],
      app_identifier: ENV["IDENTIFIER"],
      app_name: ENV["APP_NAME"],
      language: 'English',
      app_version: ENV["VERSION"],
      sku: '123',
    )

    cert(
      username: ENV["APPLE_ID"]
    )

    sigh(
      username: ENV["APPLE_ID"],
      app_identifier: ENV["IDENTIFIER"],
      force: true
    )

  end

  desc "Submit a new Beta Build to Apple TestFlight"
  desc "This will also make sure the profile is up to date"
  lane :beta do |options|

    # match(type: "appstore") # more information: https://codesigning.guide

    cocoapods

    if options[:initial]
      provision
    end

    gym(scheme: ENV["SCHEME_NAME"]) # Build your app - more options available

    increment_build_number

    pilot(
       username: ENV["APPLE_ID"],
       changelog: options[:changelog], 
       distribute_external: true,
       groups: ["Beta Testers"],
       beta_app_feedback_email: ENV["FEEDBACK_EMAIL"]
    )

    slack(
      slack_url: ENV["SLACK_URL"],
      message: "Build #{get_build_number} has been released on TestFlight! 🚀",
      success: true
    )

    # sh "your_script.sh"
    # You can also use other beta testing services here (run `fastlane actions`)
  end

  desc "Deploy a new version to the App Store"
  lane :release do

    # match(type: "appstore")
    # snapshot

    gym # Build your app - more options available
    deliver(force: true)

    # frameit

  end

  # You can define as many lanes as you want

  after_all do |lane|
    # This block is called, only if the executed lane was successful

    # slack(
    #   slack_url: ENV["SLACK_URL"],
    #   message: "Successfully deployed new App Update.",
    #   success: true
    # )

  end

  error do |lane, exception|

    # slack(
    #    slack_url: ENV["SLACK_URL"],
    #    message: exception.message,
    #    success: false
    # )

  end

end


# More information about multiple platforms in fastlane: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
# All available actions: https://docs.fastlane.tools/actions

# fastlane reports which actions are used. No personal data is recorded. 
# Learn more at https://github.com/fastlane/fastlane#metrics
