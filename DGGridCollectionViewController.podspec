Pod::Spec.new do |s|
s.name         = "DGGridCollectionViewController"
s.version      = "1.0.2"
s.summary      = "Component that allows you to display collection of data in different format easily."
 s.homepage     = "https://github.com/Digipolitan/grid-collection-view-controller.git"
s.license      = { :type => "BSD", :file => "LICENSE" }
s.author       = { "Digipolitan" => "contact@digipolitan.com" }
s.source       = { :git => "https://github.com/Digipolitan/grid-collection-view-controller.git", :tag => "v#{s.version}" }
s.source_files = 'Sources/**/*.{swift,h}'
s.ios.deployment_target = '8.0'
s.tvos.deployment_target = '9.0'
s.requires_arc = true
end
