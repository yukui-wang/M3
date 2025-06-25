#!/bin/sh
echo "------imkit build start ----------------"

KIT_FRAMEWORKER_PATH="./framework"
if [ ! -d "$KIT_FRAMEWORKER_PATH" ]; then
    mkdir -p "$KIT_FRAMEWORKER_PATH"
fi

KIT_EXTENSIONKIT_PATH="./ExtensionKit"
#不删除 ExtensionKit 变动不能及时追踪到
if [ ! -d "$KIT_EXTENSIONKIT_PATH" ]; then
    mkdir -p "$KIT_EXTENSIONKIT_PATH"
fi

#copy imlib
IMLIB_PATH="../imlib"
if [ -d ${IMLIB_PATH}/bin ]; then
   echo "imkit build: copy imlib"
   cp -af ${IMLIB_PATH}/bin/* ${KIT_FRAMEWORKER_PATH}/
   cp -af ${IMLIB_PATH}/RongIMLib/RCDownloadHelper.h "./RongIMKit/RCloudImageLoading/"
fi


#copy extensionkit

EXTENSIONKIT_PATH="../extensionkit/bin"
if [ -d $EXTENSIONKIT_PATH ]; then
   echo "imkit build: copy extensionkit"
   cp -af ${EXTENSIONKIT_PATH}/* ${KIT_EXTENSIONKIT_PATH}/
fi

