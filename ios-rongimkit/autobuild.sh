#!/bin/sh

#  build-imkit.sh
#  RongIMKit
#
#  Created by xugang on 4/8/15.
#  Copyright (c) 2015 RongCloud. All rights reserved.

configuration="Release"
DEV_FLAG=""
VER_FLAG=""
VOIP_FLAG=""

Build_Arm_Flag="0"

for i in "$@"
do
PFLAG=`echo $i|cut -b1-2`
PPARAM=`echo $i|cut -b3-`
if [ $PFLAG == "-b" ]
then
DEV_FLAG=$PPARAM
elif [ $PFLAG == "-v" ]
then
VER_FLAG=$PPARAM
elif [ $PFLAG == "-o" ]
then
VOIP_FLAG=$PPARAM
elif [ $PFLAG == "-s" ]
then
Build_Arm_Flag=$PPARAM
fi
done

sed -i ""  -e '/CFBundleShortVersionString/{n;s/[0-9]\.[0-9]\.[0-9]\{1,2\}/'"$VER_FLAG"'/; }' ./RongIMKit/Info.plist

if [ ${DEV_FLAG} == "debug" ]
then
configuration="Debug"
else
configuration="Release"
fi

PROJECT_NAME="RongIMKit.xcodeproj"
targetName="RongIMKit"
TARGET_DECIVE="iphoneos"
TARGET_I386="iphonesimulator"

xcodebuild clean -configuration $configuration -sdk $TARGET_DECIVE
xcodebuild clean -configuration $configuration -sdk $TARGET_I386

echo "***开始build iphoneos文件***"
xcodebuild -project ${PROJECT_NAME} -target "$targetName" -configuration $configuration  -sdk $TARGET_DECIVE build

if [ ${Build_Arm_Flag} != '1' ]; then
echo "***开始build iphonesimulator文件***"
xcodebuild -project ${PROJECT_NAME} -target "$targetName" -configuration $configuration  -sdk $TARGET_I386 build
fi

echo "***完成Build ${targetName}静态库${configuration}****"
