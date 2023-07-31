#!/bin/bash
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2021-2023 The Foundation for Public Code <info@publiccode.net>, https://standard.publiccode.net/AUTHORS

if [ "_${VERBOSE}_" != "__" ] && [ "$VERBOSE" -gt 0 ]; then
	set -x
fi

set -e

GIT_HASH=$( git log -n1 --pretty='%h' )

RELEASE_NAME=$1
if [ "_${RELEASE_NAME}_" == "__" ]; then
	GIT_TAG=$( git describe --exact-match --tags "${GIT_HASH}" \
		2>/dev/null \
		| head -n1 )
	if [ "_${GIT_TAG}_" != "__" ]; then
		RELEASE_NAME="$GIT_TAG"
	else
		RELEASE_NAME=$GIT_HASH
	fi
fi

echo  bundle-install
bundle install

echo  install-fonts
script/ensure-font.sh

echo  update-changelog-date
script/update-changelog-date.sh

echo  update-publiccode-yml-date
sed -i -e"s/^releaseDate.*/releaseDate: '$(date --utc +%Y-%m-%d)'/" \
	publiccode.yml

echo  update-publiccode-yml-version
sed -i -e"s@^softwareVersion: .*@softwareVersion: ${RELEASE_NAME}@" \
	publiccode.yml

echo  update-published-version-numbers
sed -i -e"s@<span class=\"standard-version\">[^<]*</span>@<span class=\"standard-version\">${RELEASE_NAME}</span>@" \
	docs/review-template.html \
	docs/checklist.html \
	print-cover.html \
	standard-print.html

echo  update-readme-version
sed -i -e"s@\[version [^]]*\](assets/version-badge\.svg)@[version ${RELEASE_NAME}](assets/version-badge.svg)@" \
	README.md

echo  update-version-badge.sh
script/make-version-badge.sh ${RELEASE_NAME}

echo  build-pdf
script/pdf.sh ${RELEASE_NAME}

echo "files:"
# git diff || true
ls -l \
	CHANGELOG.md \
	README.md \
	publiccode.yml \
	assets/version-badge.svg \
	docs/review-template.html \
	docs/checklist.html \
	print-cover.html \
	standard-print.html

echo "artefacts"
ls -l standard-*.pdf standard-*.epub
