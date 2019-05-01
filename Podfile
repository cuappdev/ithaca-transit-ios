# Uncomment this line to define a global platform for your project
platform :ios, '10.0'

# Comment this line if you're not using Swift and don't want to use dynamic frameworks

use_frameworks!
inhibit_all_warnings!

# Pods for TCAT
target 'TCAT' do
    
    # Location
    pod 'GoogleMaps', '~> 3.1'
    pod 'GooglePlaces', '~>  3.1'
    
    # Networking + Data
    pod 'Alamofire', '~> 4.7'
    pod 'TRON', '~> 4.2'
    pod 'SwiftyJSON', '~> 4.0'
    
    # Analytics
    pod 'Crashlytics', '~> 3.12'
    pod 'Fabric', '~> 1.9'
    pod 'Firebase/Core'
    
    # File Management
    pod 'Zip', '~> 1.1'
    
    # UI Frameworks
    pod 'DZNEmptyDataSet', :git=> 'https://github.com/cuappdev/DZNEmptyDataSet.git'
    pod 'NotificationBannerSwift', :git=> 'https://github.com/cuappdev/NotificationBanner.git'
    pod 'Pulley', '~> 2.7'
    pod 'Presentation', :git=> 'https://github.com/cuappdev/Presentation.git'
    pod 'SnapKit', '~> 5.0'
    pod 'WhatsNewKit', '~> 1.1'

    # Other
    pod 'SwiftLint'
    
    target 'TCATTests' do
        inherit! :search_paths
        # Pods for testing
    end
    
    target 'TCATUITests' do
        inherit! :search_paths
        # Pods for testing
    end
end

# Pods for Today Extension
target 'Today Extension' do
    # Pods for Today Extension

    # UI Frameworks	
    pod 'SnapKit', '~> 5.0'

    # Networking + Data
    pod 'TRON', '~> 4.2'
    pod 'Alamofire', '~> 4.7'
    pod 'SwiftyJSON', '~> 4.0'
 
    # Analytics
    pod 'Crashlytics', '~> 3.12'
end 
