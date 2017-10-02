# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'


def pods()
  pod 'XMPPFramework', :git => "https://github.com/frajaona/XMPPFramework.git", :branch => 'master'
  pod 'RxSwift', '~> 3.0'
  pod 'RxCocoa', '~> 3.0'
  pod 'RxTest', '~> 3.0'
  pod 'SwiftyBeaver', '~> 1.4'
end

def test_pods()
  
end

target 'HarmonySwiftKitiOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HarmonySwiftKitiOS
  pods()

  target 'HarmonySwiftKitiOSTests' do
    inherit! :search_paths
    # Pods for testing
	test_pods()
  end

end

target 'HarmonySwiftKitMacOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HarmonySwiftKitMacOS
  pods()

  target 'HarmonySwiftKitMacOSTests' do
    inherit! :search_paths
    # Pods for testing
	test_pods()
    pod 'RxTest', '~> 3.0'
  end

end

# For now, it is not compatible for tvOS because of XMPPFramework
target 'HarmonySwiftKitTvOS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HarmonySwiftKitTvOS
  #pods()

  target 'HarmonySwiftKitTvOSTests' do
    inherit! :search_paths
    # Pods for testing
	#test_pods()
  end

end
