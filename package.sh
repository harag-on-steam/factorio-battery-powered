#!/usr/bin/sh
version_tag=$1
git archive --prefix battery-powered/ -o battery-powered-${version_tag}.zip ${version_tag}

