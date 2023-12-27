# Uncomment this line to define a global platform for your project
platform :ios, '15.0'

# Comment this line if you're not using Swift and don't want to use dynamic frameworks

use_frameworks!
inhibit_all_warnings!

# Pods for TCAT
target 'TCAT' do
    
    # Location
    pod 'GoogleMaps'
    
    # Networking + Data
    pod 'SwiftyJSON', '~> 5.0'
    pod 'FutureNova', :git => 'https://github.com/cuappdev/ios-networking.git'
    pod 'Wormholy', :configurations => ['Debug']
    
    # Analytics
    pod 'Firebase'
    pod 'FirebaseCrashlytics'
    
    # File Management
    pod 'Zip', '~> 1.1'
    
    # UI Frameworks
    pod 'DZNEmptyDataSet', :git=> 'https://github.com/cuappdev/DZNEmptyDataSet.git'
    pod 'NotificationBannerSwift', '~> 3.0.0'
    pod 'Pulley', '~> 2.7'
    pod 'Presentation', :git=> 'https://github.com/cuappdev/Presentation.git'
    pod 'SnapKit', '~> 5.0'
    pod 'WhatsNewKit', '~> 1.1'

    # Other
    pod 'AppDevAnnouncements', :git => 'https://github.com/cuappdev/appdev-announcements.git'
    pod 'SwiftLint'
    
    target 'TCATTests' do
        inherit! :search_paths
        # Pods for testing
    end
    
end


# Added for NotificationBannerSwift build issue
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
