inhibit_all_warnings!

platform :osx, '10.16'
project 'DuetServicePrototype.xcodeproj'


target :DuetGUI do
#	pod 'GBDeviceInfo'
	pod 'GBPing'
	pod 'CocoaAsyncSocket'
	pod 'OpenSSL-Universal'
end

target :DuetDesktopCaptureManager do
#	pod 'GBDeviceInfo'
	pod 'GBPing'
	pod 'CocoaAsyncSocket'
	pod 'OpenSSL-Universal'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '11.0'
      config.build_settings.delete 'ARCHS'
    end
  end
end
