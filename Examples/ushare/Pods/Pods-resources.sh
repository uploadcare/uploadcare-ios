#!/bin/sh

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "rsync -rp ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -rp "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      ;;
    *)
      echo "rsync -av --exclude '*/.svn/*' ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      rsync -av --exclude '*/.svn/*' "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      ;;
  esac
}
install_resource 'AQGridView/Resources/AQGridSelection.png'
install_resource 'AQGridView/Resources/AQGridSelectionGray.png'
install_resource 'AQGridView/Resources/AQGridSelectionGrayBlue.png'
install_resource 'AQGridView/Resources/AQGridSelectionGreen.png'
install_resource 'AQGridView/Resources/AQGridSelectionRed.png'
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
install_resource '../../../UploadcareWidget/resources/icon_vk.png'
install_resource '../../../UploadcareWidget/resources/icon_vk@2x.png'
install_resource '../../../UploadcareWidget/resources/thumb_from_URL_128x128.png'
install_resource '../../../UploadcareWidget/resources/UPCDrawerCellNormal.png'
install_resource '../../../UploadcareWidget/resources/UPCDrawerCellNormal@2x.png'
install_resource '../../../UploadcareWidget/resources/UPCDrawerCellSelected.png'
install_resource '../../../UploadcareWidget/resources/UPCDrawerCellSelected@2x.png'
install_resource '../../../UploadcareWidget/resources/UPCNavBar.png'
install_resource '../../../UploadcareWidget/resources/UPCNavBar@2x.png'
install_resource '../../../UploadcareWidget/resources/UPCSelectorBarItemIcon.png'
install_resource '../../../UploadcareWidget/resources/UPCSelectorBarItemIcon@2x.png'
