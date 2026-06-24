#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_native_view'
  s.version          = '0.0.1'
  s.summary          = 'Native SwiftUI Liquid Glass widgets for Flutter.'
  s.description      = <<-DESC
Authentic Apple Liquid Glass controls (button, toggle) rendered by SwiftUI on
iOS 26+, embedded into Flutter via platform views. Graceful fallback below iOS 26.
                       DESC
  s.homepage         = 'https://github.com/winterzxzz/flutter_native_view'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'winterzxzz' => 'Phanlinh129198@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  # glassEffect (iOS 26) is compiled behind #available guards, so a lower
  # deployment target still installs on older devices.
  s.platform = :ios, '14.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
