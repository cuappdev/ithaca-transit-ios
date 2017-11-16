# Uncomment this line to define a global platform for your project
platform :ios, '9.3'

target 'TCAT' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TCAT
  pod 'GoogleMaps', '~> 2.2'
  pod 'GooglePlaces', '~> 2.2'
  pod 'SwiftyJSON', '~> 4.0.0'
  pod 'Alamofire', '~> 4.4'
  pod 'TRON', '~> 4.0.0', :inhibit_warnings => true
  pod 'Fuzzywuzzy_swift', :git=> 'https://github.com/AAAstorga/Fuzzywuzzy_swift.git', :commit => '9c94253b2e83abffcce5014808fe1a22c6b97d90'
  pod 'DZNEmptyDataSet'
  pod 'NotificationBannerSwift'
  pod 'Fabric'
  pod 'Crashlytics'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['NotificationBannerSwift', 'SnapKit', 'MarqueeLabel', 'Fuzzywuzzy_swift', 'TRON', 'SwiftyJSON'].include? target.name
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
