# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# MARK: - Pods for Sharing to multiple targets
install! 'cocoapods',
:deterministic_uuids => false

def frameworks_pods
  
  # MARK: - Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  platform :ios, '12'
  use_frameworks!
  inhibit_all_warnings!

	# MARK: - Data Store
  pod 'Locksmith', :git => 'https://github.com/uypanha/Locksmith.git'

	# MARK: - Tools + Builders
  pod 'R.swift'
  pod 'SwiftGen'
  pod 'SwiftOTP'

	# MARK: - Logger
  pod 'SwiftyBeaver'

	# MARK: - UI + Controllers
  pod 'NVActivityIndicatorView', '~> 5.1.1'
  pod 'NVActivityIndicatorView/Extended'
	pod 'NotificationBannerSwift'
  pod "AlignedCollectionViewFlowLayout"
  pod 'Shimmer'
  pod 'RichEditorView', :git => 'https://github.com/uyphanha/RichEditorView.git'
  pod 'LSDialogViewController', :git => 'https://github.com/uyphanha/LSDialogViewController.git'
  pod 'PinCodeTextField', :git => 'https://github.com/uypanha/PinCodeTextField.git'
  
  # MARK: - Material Components
  pod 'MaterialComponents/Tabs'
  pod 'MaterialComponents/Tabs+TabBarView'
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
      # Needed for building for simulator on M1 Macs
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings['LD_NO_PIE'] = 'NO'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      # Suppress warning of minimum development target
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12'
    end
  end
end
