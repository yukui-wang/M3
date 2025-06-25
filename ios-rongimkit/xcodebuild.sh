#!/bin/sh

BIN_DIR="bin"
if [ ! -d "$BIN_DIR" ]; then
mkdir -p "$BIN_DIR"
fi

BIN_DIR_TMP="bin_tmp"
if [ ! -d "$BIN_DIR_TMP" ]; then
mkdir -p "$BIN_DIR_TMP"
fi

DST_DIR15="./../CMPCore/Reference/RongCloud/IMKit"
if [ ! -d "$DST_DIR15" ]; then
mkdir -p "$DST_DIR15"
fi


cp -af ./${TARGET_NAME}/Resource/RongCloud.bundle ${BIN_DIR}/
cp -af ./ExtensionKit/Resource/RongExtensionKit.bundle/* ${BIN_DIR}/RongCloud.bundle/
cp -af ./ExtensionKit/Resource/Emoji.plist ${BIN_DIR}/
cp -af ./ExtensionKit/Resource/RCColor.plist ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/en.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/zh-Hans.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/zh-Hant.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/ko.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/ru.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/ja.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/ms.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/ar.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/lo.lproj ${BIN_DIR}/
cat ./ExtensionKit/Resource/en.lproj/RongExtensionKit.strings >> ${BIN_DIR}/en.lproj/RongCloudKit.strings
cat ./ExtensionKit/Resource/zh-Hans.lproj/RongExtensionKit.strings >> ${BIN_DIR}/zh-Hans.lproj/RongCloudKit.strings


cp -af ${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.framework/ ${BIN_DIR_TMP}/${PLATFORM_NAME}-${TARGET_NAME}.framework
cp -af ${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.framework/ ${BIN_DIR}/${TARGET_NAME}.framework
lipo -create $BIN_DIR_TMP/*-${TARGET_NAME}.framework/${TARGET_NAME} -output ${BIN_DIR}/${TARGET_NAME}.framework/${TARGET_NAME}


#cp -af ${BIN_DIR}/* ${DST_DIR}/
#cp -af ${BIN_DIR}/* ${DST_DIR2}/
#cp -af ${BIN_DIR}/* ${DST_DIR3}/
#cp -af ${BIN_DIR}/* ${DST_DIR4}/
#cp -af ${BIN_DIR}/* ${DST_DIR5}/
#cp -af ${BIN_DIR}/* ${DST_DIR6}/
#cp -af ${BIN_DIR}/* ${DST_DIR7}/
#cp -af ${BIN_DIR}/* ${DST_DIR8}/
#cp -af ${BIN_DIR}/* ${DST_DIR9}/
#cp -af ${BIN_DIR}/* ${DST_DIR10}/
#cp -af ${BIN_DIR}/* ${DST_DIR11}/
#cp -af ${BIN_DIR}/* ${DST_DIR12}/
#cp -af ${BIN_DIR}/* ${DST_DIR13}/
#cp -af ${BIN_DIR}/* ${DST_DIR14}/
cp -af ${BIN_DIR}/* ${DST_DIR15}/
