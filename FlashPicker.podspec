Pod::Spec.new do |s|

  s.name        = "FlashPicker"
  s.version     = "0.1"
  s.summary     = "iOS 10 Messages app like quick image picker."

  s.description = <<-DESC
                   iOS 10 Messages app like quick image picker.
                   You can pick image quickly by FlashPicker.
                   DESC

  s.homepage    = "https://github.com/xspyhack/FlashPicker"

  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.authors           = { "xspyhack" => "xspyhack@gmail.com" }
  s.social_media_url  = "https://twitter.com/xspyhack"

  s.ios.deployment_target   = "8.0"

  s.source          = { :git => "https://github.com/xspyhack/FlashPicker.git", :tag => s.version }
  s.source_files    = "FlashPicker/*.swift"
  s.resource        = 'FlashPicker/Assets.xcassets'
  s.requires_arc    = true

end
