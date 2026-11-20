#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint blue_core.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'blue_core'
  s.version          = '1.0.0'
  s.summary          = 'Blue Core application metadata bridge.'
  s.description      = <<-DESC
Blue Core application metadata bridge.
                       DESC
  s.homepage         = 'https://github.com/ysfgrl/f_model_factory'
  s.license          = { :file => '../LICANSE' }
  s.author           = { 'Blue Core' => 'https://github.com/ysfgrl' }
  s.source           = { :path => '.' }
  s.source_files = 'blue_core/Sources/blue_core/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'blue_core_privacy' => ['blue_core/Sources/blue_core/PrivacyInfo.xcprivacy']}
end
