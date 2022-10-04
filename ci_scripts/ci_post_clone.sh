#!/bin/sh

#  ci_post_clone.sh
#  RmaDriver
#
#  Created by Panha Uy on 28/9/22.
#  Copyright © 2022 RMA Group. All rights reserved.

# Install CocoaPods using Homebrew.
brew install cocoapods

# Install dependencies you manage with CocoaPods.
pod install
