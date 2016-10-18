Pod::Spec.new do |s|
  s.name         = 'Uploadcare'
  s.version      = '3.0.1'
  s.summary      = 'Uploadcare iOS library.'
  s.homepage     = 'https://uploadcare.com'
  s.license      = 'MIT'
  s.authors      = { 'Ruslan Kavetsky' => 'rusya.182@gmail.com' }
  s.source       = { :git => 'https://github.com/uploadcare/uploadcare-ios.git', :tag => s.version.to_s }
  s.source_files = 'Uploadcare/UploadcareWidget/**/*.{h,m}'
  s.resources    = 'Uploadcare/UploadcareWidget/*.xcassets', 'Uploadcare/UploadcareWidget/**/*.xib'
  s.requires_arc = true
  s.platform     = :ios, '8.0'
  s.frameworks   = 'SafariServices'

  s.subspec 'Core' do |sp|
    sp.source_files         = 'Uploadcare/UploadcareKit/*.{h,m}'
    sp.private_header_files = 'Uploadcare/UploadcareKit/UCClient_Private.h'
    sp.requires_arc         = true
    sp.platform             = :ios, '8.0'
  end
end