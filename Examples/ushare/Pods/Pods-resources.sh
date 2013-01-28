#!/bin/sh

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *)
      echo "cp -R ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      cp -R "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      ;;
  esac
}
install_resource 'Facebook-iOS-SDK/src/FacebookSDKResources.bundle'
install_resource 'objectiveflickr/BridgeSupport'
install_resource '../../../UploadcareWidget/resources/icon_dropbox.png'
install_resource '../../../UploadcareWidget/resources/icon_dropbox@2x.png'
install_resource '../../../UploadcareWidget/resources/icon_facebook.png'
install_resource '../../../UploadcareWidget/resources/icon_facebook@2x.png'
install_resource '../../../UploadcareWidget/resources/icon_flickr.png'
install_resource '../../../UploadcareWidget/resources/icon_flickr@2x.png'
install_resource '../../../UploadcareWidget/resources/icon_google_drive.png'
install_resource '../../../UploadcareWidget/resources/icon_google_drive@2x.png'
install_resource '../../../UploadcareWidget/resources/icon_instagram.png'
install_resource '../../../UploadcareWidget/resources/icon_instagram@2x.png'
install_resource '../../../UploadcareWidget/resources/icon_picasa.png'
install_resource '../../../UploadcareWidget/resources/icon_picasa@2x.png'
install_resource '../../../UploadcareWidget/resources/icon_url.png'
install_resource '../../../UploadcareWidget/resources/icon_url@2x.png'
install_resource '../../../UploadcareWidget/resources/thumb_from_URL_128x128.png'
install_resource '../../../UploadcareWidget/UCPhotosListCell.xib'
install_resource '../../../UploadcareWidget/UCPhotosList.xib'
