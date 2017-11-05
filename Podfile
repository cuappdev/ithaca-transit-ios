# Uncomment this line to define a global platform for your project
platform :ios, '9.3'

target 'TCAT' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TCAT
  pod 'GoogleMaps', '~> 2.2'
  pod 'GooglePlaces', '~> 2.2'
  pod 'SwiftyJSON', '~> 3.1.4'
  pod 'Alamofire', '~> 4.4'
  pod 'TRON', '~> 3.0.0'
  pod 'Fuzzywuzzy_swift', :git=> 'https://github.com/AAAstorga/Fuzzywuzzy_swift.git', :commit => '7f51e2b3c0eef8e5b46291f7ea3d483093b5ade9'
  pod 'DZNEmptyDataSet'
  pod 'MYTableViewIndex', :git => 'https://github.com/mindz-eye/MYTableViewIndex.git', :commit => 'ef6119e2b0cd5968e2e24397cd59ab8080858054'
  pod 'NotificationBannerSwift'
  pod 'Fabric'
  pod 'Crashlytics'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['NotificationBannerSwift', 'SnapKit', 'MarqueeLabel', 'Fuzzywuzzy_swift'].include? target.name
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
