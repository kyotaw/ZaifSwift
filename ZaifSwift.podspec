Pod::Spec.new do |s|
  s.name         = "ZaifSwift"
  s.version      = "0.1.0"
  s.summary      = "Zaif Exchange API wrappers for Swift"
  s.description  = <<-DESC
                   For easy access to Zaif APIs from Swift
                   DESC
  s.homepage     = "https://github.com/kyotaw/ZaifSwift"
  s.license      = "MIT"
  s.author             = { "kyotaw" => "httg1326@gmail.com" }

  s.platform     = :ios, '10.0'

  s.source       = { :git => "https://github.com/kyotaw/ZaifSwift.git", :commit => "17b775151f9898fecf1ab9662491e68ff4aaface", :tag => "0.1.0" }
  s.source_files  = "ZaifSwift/**/*.{swift}"
  s.requires_arc = true
  s.dependency 'CryptoSwift'
  s.dependency 'Alamofire', '~>4.0'
  s.dependency 'SwiftWebSocket', '2.6.5'
  s.dependency 'SwiftyJSON'

end
