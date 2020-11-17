# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

load 'remove_unsupported_libraries.rb'

target 'Remembrances' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Remembrances

pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'GoogleSignIn'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        end
    end
end

def unsupported_pods   
    ['Firebase/Crashlytics', 'Firebase/Analytics', ...]
end
def supported_pods   
    ['SwiftLint', 'Firebase/Auth', 'KeychainSwift', ...]
end
post_install do |installer|   
    $verbose = true # remove or set to false to avoid printing
    installer.configure_support_catalyst(supported_pods, unsupported_pods)
end