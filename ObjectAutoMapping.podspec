Pod::Spec.new do |s|

  s.name         = "ObjectAutoMapping"

  s.version      = "0.1.2"

  s.summary      = "Magical Data Modelling Framework."

  s.homepage     = "https://github.com/DongZai/ObjectAutoMapping"

  s.license      = "MIT"
  s.author       = { "DongZai" => "839235027@qq.com" }

  s.source       = { :git => "https://github.com/DongZai/ObjectAutoMapping.git", :tag => "0.1.2" }

  s.ios.deployment_target = '5.0'

  s.source_files  = 'ObjectAutoMapping/**/*.{m,h}'

  s.requires_arc  = true


end

