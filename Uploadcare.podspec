Pod::Spec.new do |s|
  s.name         = 'Uploadcare'
  s.version      = '3.0.0'
  s.summary      = 'Uploadcare iOS library.'
  s.homepage     = 'https://uploadcare.com'
  s.license      = 'MIT'
  s.authors      = { 'Iurii Nechaev' => 'nechaev.main@gmail.com' }
  s.source       = { :git => 'https://github.com/uploadcare/uploadcare-ios.git', :tag => s.version.to_s }
  s.source_files = 'UploadcareWidget/**/*.{h,m}'
  s.resources    = 'UploadcareWidget/*.xcassets', 'UploadcareWidget/**/*.xib'
  s.requires_arc = true
  s.platform     = :ios, '8.0'
  s.frameworks   = 'SafariServices'

  s.subspec 'Core' do |sp|
    sp.source_files = 'UploadcareKit'
    sp.requires_arc = true
    sp.platform     = :ios, '8.0'
  end
end