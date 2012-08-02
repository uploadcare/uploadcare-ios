#!/bin/sh

die() {
    echo ""
    echo "$*" >&2
    exit 1
}

# The Xcode bin path
if [ -d "/Developer/usr/bin" ]; then
   # < XCode 4.3.1
  XCODEBUILD_PATH=/Developer/usr/bin
else
  # >= XCode 4.3.1, or from App store
  XCODEBUILD_PATH=/Applications/XCode.app/Contents/Developer/usr/bin
fi
XCODEBUILD=$XCODEBUILD_PATH/xcodebuild
test -x "$XCODEBUILD" || die "Could not find xcodebuild in $XCODEBUILD_PATH"

# Get the script path and set the relative directories used
# for compilation
cd $(dirname $0)
SCRIPTPATH=`pwd`
cd $SCRIPTPATH/../

# The home directory where the SDK is installed
PROJECT_HOME=`pwd`

echo "Project Home: $PROJECT_HOME"

SRCPATH=$PROJECT_HOME/UploadcareKit

BUILDDIR=$PROJECT_HOME/build

LIBOUTPUTDIR=$PROJECT_HOME/lib/uploadcarekit-ios-sdk

echo "Start Universal Generation"

echo "Step 1 : Build Library for simulator and device architecture"

cd $SRCPATH

$XCODEBUILD -target "UploadcareKit" -sdk "iphonesimulator" -configuration "Release" SYMROOT=$BUILDDIR clean build || die "iOS Simulator build failed"
$XCODEBUILD -target "UploadcareKit" -sdk "iphoneos" -configuration "Release" SYMROOT=$BUILDDIR clean build || die "iOS Device build failed"

echo "Step 2 : Remove older SDK Directory"

\rm -rf $LIBOUTPUTDIR

echo "Step 3 : Create new SDK Directory Version"

mkdir -p $LIBOUTPUTDIR

echo "Step 4 : Create combine lib files for various platforms into one"

# combine lib files for various platforms into one
lipo -create $BUILDDIR/Release-iphonesimulator/libUploadcareKit.a $BUILDDIR/Release-iphoneos/libUploadcareKit.a -output $LIBOUTPUTDIR/libUploadcareKit.a || die "Could not create static output library"

echo "Step 5 : Copy headers Needed"
\cp $SRCPATH/UploadcareKit/*.h $LIBOUTPUTDIR/

echo "Finished Universal SDK Generation"
echo ""
echo "You can now use the static library that can be found at:"
echo ""
echo $LIBOUTPUTDIR
echo ""
echo "Just drag the uploadcarekit-ios-sdk directory into your project to include the UploadcareKit iOS SDK static library"
echo ""
echo ""

exit 0
