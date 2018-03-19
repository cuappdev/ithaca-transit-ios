# Uncomment this line to define a global platform for your project
platform :ios, '10.0'

target 'TCAT' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TCAT
  
  # Location
  pod 'GoogleMaps', '~> 2.6'
  pod 'GooglePlaces', '~> 2.6'
  
  # Networking + Data
  pod 'Alamofire', '~> 4.7'
  pod 'TRON', '~> 4.1.2', :inhibit_warnings => true
  pod 'SwiftyJSON', '~> 4.0'
  
  # Analytics
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SwiftRegister', :git => 'https://github.com/cuappdev/register-client-ios.git', :branch => 'master'

  # UI Frameworks
  pod 'Fuzzywuzzy_swift', :git=> 'https://github.com/AAAstorga/Fuzzywuzzy_swift.git', :commit => '9c94253b2e83abffcce5014808fe1a22c6b97d90'
  pod 'DZNEmptyDataSet'
  pod 'NotificationBannerSwift'
  pod 'Pulley', :git=> 'https://github.com/52inc/Pulley.git', :branch => 'master'
  pod 'Presentation'
  
  pod 'SnapKit'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['NotificationBannerSwift', 'SnapKit', 'Fuzzywuzzy_swift', 'TRON', 'SwiftyJSON'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] =  '4.0'
            end
        end
    end
end

  target 'TCATTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TCATUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
