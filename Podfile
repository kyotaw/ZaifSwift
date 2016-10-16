# Uncomment this line to define a global platform for your project
# platform :ios, ‘9.0’
# Uncomment this line if you're using Swift
 use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'ZaifSwift' do
  pod 'CryptoSwift'
  pod 'Alamofire', '~> 4.0'
  pod 'SwiftWebSocket', '2.6.5'
  pod 'SwiftyJSON'
end

target 'ZaifSwiftTests' do
  pod 'CryptoSwift'
  pod 'Alamofire', '~> 4.0'
  pod 'SwiftWebSocket', '2.6.5'
  pod 'SwiftyJSON'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0' #'2.3'
        end
    end
end
