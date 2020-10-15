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
  pod 'RxRealm', '3.1.0'
  pod 'RxBinding', '0.3.1'

	# MARK: - Data Store
  pod 'Locksmith'
	pod 'RealmSwift', '5.2'

	# MARK: - Extentions
  pod 'Then'

	# MARK: - Tools + Builders
  pod 'R.swift'
  pod 'SwiftGen'
  pod 'SwiftOTP'
  
  # MARK: - Coder Tools
#  pod 'AnyCodable-FlightSchool', '~> 0.2.3'

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
  pod 'NVActivityIndicatorView/Extended'
	pod 'NotificationBannerSwift'
  pod 'Shimmer'
  pod 'RichEditorView', :git => 'https://github.com/uyphanha/RichEditorView.git'
  pod 'LSDialogViewController', :git => 'https://github.com/uyphanha/LSDialogViewController.git'
  pod 'PinCodeTextField', :git => 'https://github.com/uypanha/PinCodeTextField.git'
  
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
  pod 'MaterialComponents/Snackbar'
  
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

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
