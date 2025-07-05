# Podfile for apus iOS Camera App

platform :ios, '18.5'

target 'apus' do
  use_frameworks!

  # TensorFlow Lite for object detection
  pod 'TensorFlowLiteSwift'
  
  # Optional: GPU acceleration support
  # pod 'TensorFlowLiteSwift/CoreML'
  # pod 'TensorFlowLiteSwift/Metal'

  target 'apusTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'apusUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.5'
    end
  end
end