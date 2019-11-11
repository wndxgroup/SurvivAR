# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
$:.unshift("~/.rubymotion/rubymotion-templates")

# ===========================================================================================
# 1. Be sure to read `readme.md`.
# ===========================================================================================

require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  define_icon_defaults!(app)

  app.name = 'SurvivAR'

  # version for your app
  app.version = '1.0'

  app.identifier = 'com.wndx.SurvivAR'

  app.development do
    app.codesign_certificate = MotionProvisioning.certificate(
        type: :development,
        platform: :ios)

    app.provisioning_profile = MotionProvisioning.profile(
        bundle_identifier: app.identifier,
        app_name: app.name,
        platform: :ios,
        type: :development)
  end

  app.release do
    app.codesign_certificate = MotionProvisioning.certificate(
        type: :distribution,
        platform: :ios,
        free: true)

    app.provisioning_profile = MotionProvisioning.profile(
        bundle_identifier: app.identifier,
        app_name: app.name,
        platform: :ios,
        type: :distribution,
        free: true)
  end

  app.frameworks << 'SceneKit' << 'ARKit' << 'GameplayKit'
  app.frameworks << 'UserNotifications' << 'AudioToolbox' << 'ReplayKit' << 'AVFoundation'
  app.vendor_project('vendor/PositionUpdater', :static)

  # reasonable defaults
  app.device_family = [:iphone, :ipad]
  app.interface_orientations = [:portrait]
  app.info_plist['UIRequiresFullScreen'] = true
  app.info_plist['ITSAppUsesNonExemptEncryption'] = false
  app.info_plist['NSCameraUsageDescription'] = 'It is needed for AR'
  app.info_plist['NSLocationWhenInUseUsageDescription'] = 'So we can update the mini-map in the battleground'
end

def define_icon_defaults!(app)
  # This is required as of iOS 11.0 (you must use asset catalogs to
  # define icons or your app will be rejected. More information in
  # located in the readme.

  app.info_plist['CFBundleIcons'] = {
    'CFBundlePrimaryIcon' => {
      'CFBundleIconName' => 'AppIcon',
      'CFBundleIconFiles' => ['AppIcon60x60']
    }
  }

  app.info_plist['CFBundleIcons~ipad'] = {
    'CFBundlePrimaryIcon' => {
      'CFBundleIconName' => 'AppIcon',
      'CFBundleIconFiles' => ['AppIcon60x60', 'AppIcon76x76']
    }
  }

end
task :"build:simulator" => :"schema:build"
