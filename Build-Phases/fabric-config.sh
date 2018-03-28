FABRIC_API_KEY=$(/usr/libexec/PlistBuddy -c "Print :fabric-api-key" "${PROJECT_DIR}/TCAT/Keys.plist")

FABRIC_BUILD_SECRET=$(/usr/libexec/PlistBuddy -c "Print :fabric-build-secret" "${PROJECT_DIR}/TCAT/Keys.plist")

"${PODS_ROOT}/Fabric/run" $FABRIC_API_KEY $FABRIC_BUILD_SECRET
