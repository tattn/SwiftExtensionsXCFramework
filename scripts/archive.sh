VERSION=3.0.0-beta.1

if [ ! -e SwiftExtensions ]; then
	git clone https://github.com/tattn/SwiftExtensions
	cd SwiftExtensions
	git switch $VERSION
else
	cd SwiftExtensions
	git switch $VERSION
	git pull origin $VERSION
fi
swift package generate-xcodeproj

CONFIGURATION=Release
PROJECT_NAME=SwiftExtensions-Package
OUTPUT_DIR=./../output
OUTPUT_PACKAGE_SWIFT=./../Package.swift
DERIVED_DIR=${OUTPUT_DIR}/${CONFIGURATION}-derived
ARCHIVE_DIR=${OUTPUT_DIR}/${CONFIGURATION}-archive
XCFRAMEWORK_DIR=${OUTPUT_DIR}/${CONFIGURATION}-xcframework
ARCHIVE_FILE_IOS=${ARCHIVE_DIR}/ios.xcarchive
ARCHIVE_FILE_IOS_SIMULATOR=${ARCHIVE_DIR}/iossimulator.xcarchive
ARCHIVE_FILE_MACOS=${ARCHIVE_DIR}/macos.xcarchive
ARCHIVE_FILE_WATCHOS=${ARCHIVE_DIR}/watchos.xcarchive
ARCHIVE_FILE_WATCHOS_SIMULATOR=${ARCHIVE_DIR}/watchossimulator.xcarchive
ARCHIVE_FILE_TVOS=${ARCHIVE_DIR}/tvos.xcarchive
ARCHIVE_FILE_TVOS_SIMULATOR=${ARCHIVE_DIR}/tvossimulator.xcarchive

rm -rf ${OUTPUT_DIR}
mkdir -p ${DERIVED_DIR} ${ARCHIVE_DIR} ${XCFRAMEWORK_DIR}

archive() {
	xcodebuild archive -scheme ${PROJECT_NAME} -destination="$1" -sdk $2 -archivePath "$3" -derivedDataPath $DERIVED_DIR SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES APPLICATION_EXTENSION_API_ONLY=YES $4
}

# Make archives
archive "generic/platform=iOS" "iphoneos" "$ARCHIVE_FILE_IOS" "EXCLUDED_ARCHS=armv7"
archive "generic/platform=iOS Simulator" "iphonesimulator" "$ARCHIVE_FILE_IOS_SIMULATOR" "-arch arm64 -arch x86_64"
archive "generic/platform=macOS" "macosx" "$ARCHIVE_FILE_MACOS" ""
archive "generic/platform=watchOS" "watchos" "$ARCHIVE_FILE_WATCHOS"
archive "generic/platform=watchOS Simulator" "watchsimulator" "$ARCHIVE_FILE_WATCHOS_SIMULATOR"
archive "generic/platform=tvOS" "appletvos" "$ARCHIVE_FILE_TVOS"
archive "generic/platform=tvOS Simulator" "appletvsimulator" "$ARCHIVE_FILE_TVOS_SIMULATOR"

make_xcframework() {
	xcodebuild -create-xcframework \
		-framework $ARCHIVE_FILE_IOS/Products/Library/Frameworks/$1.framework \
		-framework $ARCHIVE_FILE_IOS_SIMULATOR/Products/Library/Frameworks/$1.framework \
		-framework $ARCHIVE_FILE_MACOS/Products/Library/Frameworks/$1.framework \
		-framework $ARCHIVE_FILE_WATCHOS/Products/Library/Frameworks/$1.framework \
		-framework $ARCHIVE_FILE_WATCHOS_SIMULATOR/Products/Library/Frameworks/$1.framework \
		-framework $ARCHIVE_FILE_TVOS/Products/Library/Frameworks/$1.framework \
		-framework $ARCHIVE_FILE_TVOS_SIMULATOR/Products/Library/Frameworks/$1.framework \
		-output $XCFRAMEWORK_DIR/$1.xcframework
}

FRAMEWORK_NAMES=(SwiftExtensions SwiftExtensionsUI SwiftExtensionsUIKit)

for name in "${FRAMEWORK_NAMES[@]}"; do
	make_xcframework $name
done

pushd $XCFRAMEWORK_DIR
for framework in "${FRAMEWORK_NAMES[@]}"; do
	echo "CHECK: $framework"
	for arch in ios-arm64 ios-arm64_x86_64-simulator macos-arm64_x86_64 tvos-arm64 tvos-arm64_x86_64-simulator watchos-arm64_32_armv7k watchos-arm64_i386_x86_64-simulator; do
		XCFRAMEWORK=$framework.xcframework
		if [ -e $XCFRAMEWORK/$arch/$framework.framework/$framework ]; then
			zip -r $framework.xcframework.zip ./$XCFRAMEWORK -x "*.DS_Store" "*__MACOSX*"
			echo "$arch: success"
		else
			echo "$arch: failed"
			exit 1
		fi
	done
done
popd

cp ../scripts/template/Package.swift $XCFRAMEWORK_DIR/
cp ../scripts/template/ReleasePackage.swift $OUTPUT_PACKAGE_SWIFT

cat <<EOS  >> $OUTPUT_PACKAGE_SWIFT
package.targets = [
EOS

for name in "${FRAMEWORK_NAMES[@]}"; do
	cat <<EOS  >> $OUTPUT_PACKAGE_SWIFT
    .binaryTarget(
        name: "$name",
        url: "https://github.com/tattn/SwiftExtensionsXCFramework/releases/download/$VERSION/$name.xcframework.zip",
        checksum: "`swift package compute-checksum $XCFRAMEWORK_DIR/$name.xcframework.zip`"
    ),
EOS
done

cat <<EOS  >> $OUTPUT_PACKAGE_SWIFT
]

package.products = package.targets
    .filter { !\$0.isTest }
    .map { Product.library(name: \$0.name, targets: [\$0.name]) }
EOS
