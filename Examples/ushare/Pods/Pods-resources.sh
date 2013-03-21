#!/bin/sh

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "rsync -rp ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -rp "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *)
      echo "cp -R ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      cp -R "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      ;;
  esac
}
install_resource 'AQGridView/Resources/AQGridSelection.png'
install_resource 'AQGridView/Resources/AQGridSelectionGray.png'
install_resource 'AQGridView/Resources/AQGridSelectionGrayBlue.png'
install_resource 'AQGridView/Resources/AQGridSelectionGreen.png'
install_resource 'AQGridView/Resources/AQGridSelectionRed.png'
install_resource '../../../UploadcareWidget/Resources/icon_dropbox.png'
install_resource '../../../UploadcareWidget/Resources/icon_dropbox@2x.png'
install_resource '../../../UploadcareWidget/Resources/icon_facebook.png'
install_resource '../../../UploadcareWidget/Resources/icon_facebook@2x.png'
install_resource '../../../UploadcareWidget/Resources/icon_flickr.png'
install_resource '../../../UploadcareWidget/Resources/icon_flickr@2x.png'
install_resource '../../../UploadcareWidget/Resources/icon_google_drive.png'
install_resource '../../../UploadcareWidget/Resources/icon_google_drive@2x.png'
install_resource '../../../UploadcareWidget/Resources/icon_instagram.png'
install_resource '../../../UploadcareWidget/Resources/icon_instagram@2x.png'
install_resource '../../../UploadcareWidget/Resources/icon_picasa.png'
install_resource '../../../UploadcareWidget/Resources/icon_picasa@2x.png'
install_resource '../../../UploadcareWidget/Resources/icon_url.png'
install_resource '../../../UploadcareWidget/Resources/icon_url@2x.png'
install_resource '../../../UploadcareWidget/Resources/thumb_from_URL_128x128.png'
install_resource '../../../UploadcareWidget/Resources/UPCDrawerCellNormal.png'
install_resource '../../../UploadcareWidget/Resources/UPCDrawerCellNormal@2x.png'
install_resource '../../../UploadcareWidget/Resources/UPCDrawerCellSelected.png'
install_resource '../../../UploadcareWidget/Resources/UPCDrawerCellSelected@2x.png'
install_resource '../../../UploadcareWidget/Resources/UPCNavBar.png'
install_resource '../../../UploadcareWidget/Resources/UPCNavBar@2x.png'
install_resource '../../../UploadcareWidget/Resources/UPCSelectorBarItemIcon.png'
install_resource '../../../UploadcareWidget/Resources/UPCSelectorBarItemIcon@2x.png'
