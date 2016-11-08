source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'BondVoyage' do

pod 'Parse'
pod 'ParseUI'
pod 'AsyncImageView'
pod 'Crashlytics'
pod 'Fabric'
pod 'ParseFacebookUtilsV4'
pod 'PKHUD'
pod 'QuickBlox'
  pod 'QMChatViewController'
  pod 'QMServices'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

