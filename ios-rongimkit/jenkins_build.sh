#!/bin/sh

#  build-imkit.sh
#  RongIMKit
#
#  Created by xugang on 4/8/15.
#  Copyright (c) 2015 RongCloud. All rights reserved.

BUILD_SIMULATOR_ARCHITECTURE="true"
CONFIGURATION="Release"
for((options_index = 1; options_index < $#; options_index=$[$options_index+2])) do
params_index=$[$options_index+1]
PFLAG=`echo $@|cut -d ' ' -f ${options_index}`
PPARAM=`echo $@|cut -d ' ' -f ${params_index}`
if [[ $PPARAM =~ ^- ]]; then
    PPARAM=""
    options_index=$[$options_index-1]
fi
if [ $PFLAG == "-configuration" ]
then
CONFIGURATION=$PPARAM
elif [ $PFLAG == "-version" ]
then
VER_FLAG=$PPARAM
elif [ ${PFLAG} == "-simulator" ]
then
BUILD_SIMULATOR_ARCHITECTURE=$PPARAM
fi
done

PROJECT_NAME="RongIMKit.xcodeproj"
targetName="RongIMKit"
TARGET_DECIVE="iphoneos"
TARGET_I386="iphonesimulator"


xcodebuild clean -configuration $CONFIGURATION -sdk $TARGET_DECIVE
xcodebuild clean -configuration $CONFIGURATION -sdk $TARGET_I386

echo "***开始Build ${targetName} Framework ${CONFIGURATION}****"

if [ ${BUILD_SIMULATOR_ARCHITECTURE} = "true" ]; then
    echo "***开始build iphonesimulator文件***"
    xcodebuild -project ${PROJECT_NAME} -target "$targetName" -configuration $CONFIGURATION  -sdk $TARGET_I386 build
fi
echo "***开始build iphoneos文件***"
xcodebuild -project ${PROJECT_NAME} -target "$targetName" -configuration $CONFIGURATION  -sdk $TARGET_DECIVE build
echo "***完成Build ${targetName} Framework ${CONFIGURATION}****"
