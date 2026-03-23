Pod::Spec.new do |s|
  s.name             = 'crypto_module'
  s.version          = '1.0.0'
  s.summary          = 'Precompiled dynamic framework for Flutter FFI'
  s.description      = 'secp256k1 wrapper for use with Flutter FFI.'
  s.homepage         = 'https://gist.github.com/AlexeyYuPopkov/6d82ec78592c4150ce219fc0d91af3f9'
  s.license          = { :type => 'MIT', :text => 'MIT License' }
  s.author           = { 'Your Name' => 'alexey.yu.popkov@gmail.com' }

  s.source           = { :path => '.' } 
  s.vendored_frameworks = 'crypto_module.xcframework'

  s.platform         = :ios, '15.0'
  s.requires_arc     = false

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'FRAMEWORK_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)'  
  }

  s.static_framework = false
end
