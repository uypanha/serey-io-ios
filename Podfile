# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# Pods for Sharing to multiple targets
def frameworks_pods
  
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  platform :ios, '10'
  use_frameworks!
  inhibit_all_warnings!

	# Data Store
  pod 'Locksmith'
	pod 'RealmSwift'

	# Extentions
  pod 'Then'

	# Tools + Builders
  pod 'R.swift'
  pod 'SwiftGen'

	# Logger
  pod 'SwiftyBeaver'
	
	#Network Framework
  pod 'Kingfisher'
  pod 'Alamofire'
  pod 'AlamofireObjectMapper'
  pod 'ReachabilitySwift'
  pod 'Moya/RxSwift'

	# UI + Controllers
	pod 'SnapKit'
	pod 'NVActivityIndicatorView'
	pod 'NotificationBannerSwift'

	# RX
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxKeyboard'
  pod 'RxKingfisher'
  pod 'RxAlamofire'
  pod 'RxRealm'
  pod 'RxBinding'
  
  # Google SDKs
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  
  # Material Components
  pod 'MaterialComponents/Cards'
  pod 'MaterialComponents/Cards+ColorThemer'
  
end

target 'iOSTemplate' do

  # Pods for iOSTemplate
	frameworks_pods

  target 'iOSTemplateTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'iOSTemplateUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end
