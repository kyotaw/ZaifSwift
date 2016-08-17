Pod::Spec.new do |s|
  s.name         = "ZaifSwift"
  s.version      = "0.0.1"
  s.summary      = "Zaif Exchange API wrappers for Swift"

  s.description  = <<-DESC
                   For easy access to Zaif APIs from Swift
                   DESC

  s.homepage     = "https://github.com/kyotaw/ZaifSwift"
  s.license      = "MIT"
  s.author             = { "kyotaw" => "httg1326@gmail.com" }

  s.platform     = :ios

  s.source       = { :git => "https://github.com/kyotaw/ZaifSwift.git", :commit => "c4c490696352f7cc87d613c9fff8a45bac9389c6" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "ZaifSwift/**/*.{swift}"
  s.requires_arc = true
  s.dependency 'CryptoSwift', '~>0.5'
  s.dependency 'Alamofire', '~>3.4'
  s.dependency 'SwiftWebSocket'
  s.dependency 'SwiftyJSON'

end
