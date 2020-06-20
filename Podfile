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
  
  # MARK: - RX
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxDataSources', '~> 4.0'
  pod 'RxKeyboard', '1.0.0'
  pod 'RxKingfisher', '1.0.0'
  pod 'RxAlamofire', '5.2.0'
  pod 'RxRealm', '2.0.0'
  pod 'RxBinding', '0.3.1'

	# MARK: - Data Store
  pod 'Locksmith'
	pod 'RealmSwift', '4.0'

	# MARK: - Extentions
  pod 'Then'

	# MARK: - Tools + Builders
  pod 'R.swift'
  pod 'SwiftGen'
  
  # MARK: - Coder Tools
  pod 'AnyCodable-FlightSchool', '~> 0.2.3'

	# MARK: - Logger
  pod 'SwiftyBeaver'
	
	# MARK: - Network Framework
  pod 'Kingfisher'
  pod 'Alamofire'
  pod 'AlamofireObjectMapper', :git => 'https://github.com/uypanha/AlamofireObjectMapper.git'
  pod 'ReachabilitySwift'
  pod 'Moya/RxSwift'

	# MARK: - UI + Controllers
	pod 'SnapKit'
	pod 'NVActivityIndicatorView'
	pod 'NotificationBannerSwift'
  pod 'Shimmer'
  pod 'RichEditorView', :git => 'https://github.com/uyphanha/RichEditorView.git'
  pod 'LSDialogViewController', :git => 'https://github.com/uyphanha/LSDialogViewController.git'
  
  # MARK: - Google SDKs
  pod 'Firebase/Analytics'
  pod 'Firebase/Core' 
  pod 'Firebase/Messaging'
  
  # MARK: - Material Components
  pod 'MaterialComponents/Tabs'
  pod 'MaterialComponents/PageControl'
  pod 'MaterialComponents/BottomSheet'
  pod 'MaterialComponents/Chips'
  pod 'MaterialComponents/TextControls+OutlinedTextFields'
  pod 'MaterialComponents/TextControls+OutlinedTextFieldsTheming'
  pod 'MaterialComponents/ProgressView'
  pod 'MaterialComponents/ActivityIndicator'
  
end

target 'SereyIO' do

  # Pods for SereyIO
	frameworks_pods

  target 'SereyIOTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SereyIOUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end
