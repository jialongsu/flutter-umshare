#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint umshare.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'umshare'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'UMCommon'
  s.dependency 'UMDevice'
  s.dependency 'UMShare/Social/ReducedQQ'
  s.dependency 'UMShare/Social/ReducedSina'
  s.dependency 'UMShare/Social/AlipayShare'
  s.dependency 'UMShare/Social/DingDing'
  s.dependency 'UMShare/Social/DouYin'
  s.platform = :ios, '8.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
