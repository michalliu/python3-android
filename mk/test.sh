#!/usr/bin/env bash
set -x
source ./env

#ln -sf ~/Library/Android/sdk sdk/android-sdk-r24.0.2
pushd "$BASE/sdk/android-sdk-r${SDK_REV}" > /dev/null

# TODO: Figure out an appropriate port number.
PORT=5554

# Boot the emulator, wait for it.
./tools/emulator -avd "${ANDROID_VM_NAME}-${TEST_IDENTIFIER}" -port "${PORT}" -no-snapshot-save ${ANDROID_EMULATOR_OPTIONS} &
./platform-tools/adb -s "emulator-${PORT}" wait-for-device

# Copy the files over.
./platform-tools/adb -s "emulator-${PORT}" push "${ANDROID_PREFIX}/${BUILD_IDENTIFIER}" "${ANDROID_EMULATOR_TESTDIR}"
# Run the tests!
./platform-tools/adb -s "emulator-${PORT}" shell <<-EOF
	cd "${ANDROID_EMULATOR_TESTDIR}"
	bin/python3.4 -m test
	exit
EOF
# Stop the emulator.
./platform-tools/adb -s "emulator-${PORT}" emu kill

popd > /dev/null
