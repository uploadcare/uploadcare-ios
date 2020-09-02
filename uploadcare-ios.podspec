Pod::Spec.new do |s|
  s.name         = 'uploadcare-ios'
  s.version      = '3.0.2'
  s.summary      = 'Uploadcare iOS library.'
  s.homepage     = 'https://uploadcare.com'
  s.license      = 'MIT'
  s.authors      = { 'Uploadcare, Inc' => 'hello@uploadcare.com' }
  s.source       = { :git => 'https://github.com/uploadcare/uploadcare-ios.git', :tag => s.version.to_s }
  s.source_files = 'Uploadcare/Sources/UploadcareWidget/**/*.{h,m}'
  s.resources    = 'Uploadcare/Sources/UploadcareWidget/Resources/**/*.{png,xib}'
  s.requires_arc = true
  s.platform     = :ios, '8.0'
  s.frameworks   = 'SafariServices'
  s.deprecated   = true
  s.deprecated_in_favor_of = 'Uploadcare'

  s.subspec 'Core' do |sp|
    sp.source_files         = 'Uploadcare/Sources/UploadcareKit/*.{h,m}'
    sp.private_header_files = 'Uploadcare/Sources/UploadcareKit/UCClient_Private.h'
    sp.requires_arc         = true
    sp.platform             = :ios, '8.0'
  end
end
