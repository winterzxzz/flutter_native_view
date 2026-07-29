#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'liquid_glass_native'
  s.version          = '1.0.0'
  s.summary          = 'Authentic SwiftUI Liquid Glass controls for Flutter.'
  s.description      = <<-DESC
Authentic Apple Liquid Glass controls rendered by SwiftUI on iOS 26+, embedded
into Flutter with typed configuration and graceful native fallbacks on iOS 15-25.
                       DESC
  s.homepage         = 'https://github.com/winterzxzz/flutter_native_view'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'winterzxzz' => 'Phanlinh129198@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  # iOS 26 symbols are compiled behind availability guards. iOS 15-25 receive
  # real SwiftUI controls with deliberate non-glass styling.
  s.platform = :ios, '15.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
