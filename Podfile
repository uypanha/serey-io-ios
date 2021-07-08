# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# MARK: - Pods for Sharing to multiple targets
install! 'cocoapods',
:deterministic_uuids => false

def frameworks_pods
  
  # MARK: - Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  platform :ios, '11'
  use_frameworks!
  inhibit_all_warnings!
  
  # MARK: - RX
  pod 'RxSwift', '~> 6.0'
  pod 'RxCocoa', '~> 6.0'
  pod 'RxDataSources', '~> 5.0.0'
  pod 'RxBinding', '0.5'
  pod 'RxKeyboard', '2.0.0'
  pod 'RxKingfisher', :git => 'https://github.com/uypanha/RxKingfisher.git'
  pod 'RxAlamofire', '~> 6.1.0'
  pod 'RxRealm', '5.0.1'
  pod 'RxReachability', '1.2.1'

	# MARK: - Data Store
  pod 'Locksmith', :git => 'https://github.com/uypanha/Locksmith.git'

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
  pod 'Alamofire', '~> 5.4'
  pod 'AlamofireObjectMapper', :git => 'https://github.com/uypanha/AlamofireObjectMapper.git'
  pod 'Moya/RxSwift', :git => 'https://github.com/uypanha/Moya.git'
  pod 'AlamofireObjectMapper', :git => 'https://github.com/uypanha/AlamofireObjectMapper.git'
  pod 'AlamofireNetworkActivityLogger', :git => 'https://github.com/uypanha/AlamofireNetworkActivityLogger.git'

	# MARK: - UI + Controllers
	pod 'SnapKit'
  pod 'NVActivityIndicatorView', '~> 5.1.1'
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
            config.build_settings['LD_NO_PIE'] = 'NO'
            config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
            # Suppress warning of minimum development target
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10'
        end
    end
end
