#!/bin/bash

# Webcamoid, webcam capture application.
# Copyright (C) 2023  Gonzalo Exequiel Pedone
#
# Webcamoid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Webcamoid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Webcamoid. If not, see <http://www.gnu.org/licenses/>.
#
# Web-Site: http://webcamoid.github.io/

export PACKAGES_DIR=${PWD}/webcamoid-packages/linux

if [ "${GITHUB_SHA}" != "" ]; then
    branch=${GITHUB_REF##*/}
else
    branch=${CIRRUS_BASE_BRANCH}
fi

if [ "${DAILY_BUILD}" = 1 ]; then
    version=daily-${branch}
else
    verMaj=$(grep VER_MAJ libAvKys/cmake/ProjectCommons.cmake | awk '{print $2}' | tr -d ')' | head -n 1)
    verMin=$(grep VER_MIN libAvKys/cmake/ProjectCommons.cmake | awk '{print $2}' | tr -d ')' | head -n 1)
    verPat=$(grep VER_PAT libAvKys/cmake/ProjectCommons.cmake | awk '{print $2}' | tr -d ')' | head -n 1)
    version=${verMaj}.${verMin}.${verPat}
fi

architecture="${DOCKERIMG%%/*}"

case "$architecture" in
    arm64v8)
        packageArch=arm64
        ;;
    arm32v7)
        packageArch=arm32
        ;;
    *)
        packageArch=amd64
        ;;
esac

package=webcamoid-installer-linux_${version}_${packageArch}.snap
packagePath=${PACKAGES_DIR}/${package}

echo "Running packaging"
echo
echo "Formats: Snap"

mkdir -p "${PACKAGES_DIR}"
mv -f "webcamoid_${version}_${packageArch}.snap" "${packagePath}"

if [ -e "${packagePath}" ]; then
    fileSize=$(stat --format="%s" "${packagePath}" | numfmt --to=iec-i --suffix=B --format='%.2f')
    md5=$(md5sum "${packagePath}" | awk '{print $1}')

    echo
    echo "Packages created:"
    echo "    ${package} ${fileSize}"
    echo "        md5sum: ${md5}"
fi
