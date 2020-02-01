# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# MARK: - Pods for Sharing to multiple targets
install! 'cocoapods',
:deterministic_uuids => false

def frameworks_pods
  
  # MARK: - Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  platform :ios, '10'
  use_frameworks!
  inhibit_all_warnings!

	# MARK: - Data Store
  pod 'Locksmith'
	pod 'RealmSwift'

	# MARK: - Extentions
  pod 'Then'

	# MARK: - Tools + Builders
  pod 'R.swift'
  pod 'SwiftGen'

	# MARK: - Logger
  pod 'SwiftyBeaver'
	
	# MARK: - Network Framework
  pod 'Kingfisher'
  pod 'Alamofire'
  pod 'AlamofireObjectMapper'
  pod 'ReachabilitySwift'
  pod 'Moya/RxSwift'

	# MARK: - UI + Controllers
	pod 'SnapKit'
	pod 'NVActivityIndicatorView'
	pod 'NotificationBannerSwift'

	# MARK: - RX
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxKeyboard'
  pod 'RxKingfisher'
  pod 'RxAlamofire'
  pod 'RxRealm'
  pod 'RxBinding'
  
  # MARK: - Google SDKs
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  
  # MARK: - Material Components
  pod 'MaterialComponents/Cards'
  pod 'MaterialComponents/Cards+ColorThemer'
  pod 'MaterialComponents/Tabs'
  pod 'MaterialComponents/BottomSheet'
  pod 'MaterialComponents/PageControl'
  
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
