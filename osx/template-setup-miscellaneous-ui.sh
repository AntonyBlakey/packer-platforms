#!/bin/sh -eux

systemsetup -settimezone "PACKER-OSX-TIMEZONE"
systemsetup -setsleep "Never"

sudo -u vagrant defaults write NSGlobalDomain AppleLanguages -array 'PACKER-LOCALE-WITH-HYPHEN' 'en'
sudo -u vagrant defaults write NSGlobalDomain AppleLocale 'PACKER-LOCALE-WITH-UNDERSCORE'
sudo -u vagrant defaults write NSGlobalDomain NSPreferredSpellServerLanguage 'PACKER-LOCALE-WITH-UNDERSCORE'

sudo -u vagrant defaults  write com.apple.menuextra.clock DateFormat 'PACKER-OSX-DATEFORMAT'
sudo -u vagrant defaults write NSGlobalDomain AppleICUForce24HourTime -boolean 'true'

sudo -u vagrant defaults write NSGlobalDomain AppleMetricUnits -boolean 'PACKER-OSX-METRIC'
sudo -u vagrant defaults write NSGlobalDomain AppleMeasurementUnits 'PACKER-OSX-MEASUREMENT-UNITS'

sudo -u vagrant defaults write NSGlobalDomain AppleShowScrollBars 'Always'
sudo -u vagrant defaults write NSGlobalDomain AppleEnableMenuBarTransparency -boolean 'false'
