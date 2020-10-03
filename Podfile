project 'Project/Universal.xcodeproj'

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Universal' do
  use_frameworks!
  
  #Networking
  pod 'Alamofire', '~> 4.5'
  pod 'SDWebImage', '~> 4.0'
  pod 'OhhAuth'
  pod 'OneSignal', '>= 2.11.1', '< 3.0'
  
  #Parsers
  pod 'SwiftyJSON', '~> 4.0'
  pod 'ObjectMapper', '~> 3.3'
  pod 'FeedKit', '~> 8.0'
  #pod 'FHSTwitterEngine'
  pod 'Swifter', :git => 'https://github.com/mattdonnelly/Swifter.git'
  
  #Google
  pod 'GoogleMaps'
  pod 'Google-Mobile-Ads-SDK'
  
  #Views
  pod "CollieGallery", :git => 'https://github.com/gmunhoz/CollieGallery.git' #Customised
  pod 'LPSnackbar'
  #pod 'ILTranslucentView'
  pod 'Cosmos', '~> 15.0'
  pod 'KILabel', '1.0.0'
  pod 'UITableView+FDTemplateLayoutCell'
  pod 'AMScrollingNavbar'
  
  #Media Playback
  pod 'XCDYouTubeKit', '~> 2.5'
  pod 'BMPlayer', '~> 1.2.1'
  pod 'FRadioPlayer'
  
  #Utility
  pod 'KVOController'
  pod 'SideMenu'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
    end
  end
end
