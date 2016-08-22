source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'reader' do
    pod 'Kanna', '~> 1.1.0'
    pod 'Moya', '~> 7.0.0'
    pod 'Moya/RxSwift'
    pod 'DTCoreText'
    pod 'SnapKit', '~> 0.15.0'
    pod 'MBProgressHUD', '~> 1.0.0'
    # Fuck Swift For its poor support for regexp
    pod 'CrossroadRegex'
end

post_install do |installer|
    `rm -rf Pods/Headers/Private`
end
