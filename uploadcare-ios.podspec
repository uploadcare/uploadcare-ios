Pod::Spec.new do |s|
  s.name         = 'uploadcare-ios'
  s.version      = '3.0.0'
  s.summary      = 'iOS library for Uploadcare.'
  s.homepage     = 'https://uploadcare.com'
  s.license      = 'MIT'
  s.authors      = { 'Iurii Nechaev' => 'nechaev.main@gmail.com' }
  s.source       = { :git => 'https://github.com/uploadcare/uploadcare-ios.git', :tag => s.version.to_s }
  s.source_files = 'UploadcareKit', 'UploadcareWidget/**/*.{h,m}'
  s.resources    = 'UploadcareWidget/*.xcassets', 'UploadcareWidget/**/*.xib'
  s.requires_arc = true
  s.platform     = :ios, '8.0'
  s.frameworks   = 'SafariServices'
end
