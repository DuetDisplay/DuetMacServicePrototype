//
// Created by Cedric Pansky on 7/5/18.
// Copyright (c) 2018 Duet, Inc. All rights reserved.
//

import DuetCommon
import DuetRemoteDisplay
import Foundation
import DuetAnalytics

@objc enum DuetQualityType: Int
{
	case regular
	case high
	case pixelPerfect
}

@objc enum DuetRDPQualityType: Int
{
	case auto
	case low
    case medium
    case high
    case veryhigh
}

@objc enum DuetFramerates: Int
{
	case rate30
	case rate60
	case rate120
}

@objcMembers
class DeviceTypeSettings: NSObject
{
	var name: String
	var modernResolution: DuetResolutionSetting
	var touchbar: Bool = false
	var framerate: DuetFramerates = .rate60
	var quality: DuetQualityType = .high
	var retinaEnabled: Bool = false
	var lastSetVersion: String?
	var mirroring: Bool = false

	init(name: String)
	{
		self.name = name

		modernResolution = .medium
		if name.contains("Pro")
		{
			retinaEnabled = true
		}

		super.init()
	}

	static func settingsFor(name: String) -> DeviceTypeSettings?
	{
		if let values = GeneralSettingsManager.shared.macSettings?[name] as? [String: Any]
		{
			let settings = DeviceTypeSettings(name: name)

			var touchbarDefault = false
			if name.contains("AirPlay"), !name.contains("iPhone")
			{
				touchbarDefault = true
			}
			settings.touchbar = (values["DuetTouchbar"] as? NSNumber)?.boolValue ?? touchbarDefault

			if let fr = values["DuetFramerate"] as? Int, let dfr = DuetFramerates(rawValue: fr)
			{
				settings.framerate = dfr
			}
			else if let fs = values["Framerate"] as? String
			{
				switch fs
				{
					case "30 FPS":
						settings.framerate = .rate30
					case "60 FPS":
						settings.framerate = .rate60
					default:
						settings.framerate = .rate60
				}
			}

			if let mr = values["ModernResolution"] as? Int, let dmr = DuetResolutionSetting(rawValue: mr)
			{
				settings.modernResolution = dmr
			}

			if let qs = values["DuetQualityType"] as? Int, let dqt = DuetQualityType(rawValue: qs)
			{
				settings.quality = dqt
			}
			else if let qs = values["Pixel Quality"] as? String
			{
				switch qs.lowercased()
				{
					case "pixel perfect":
						settings.quality = .pixelPerfect
					case "regular":
						settings.quality = .regular
					default:
						settings.quality = .high
				}
			}

			var retinaDefault = false
			if name.contains("Pro") || name.contains("Retina")
			{
				retinaDefault = true
			}
			settings.retinaEnabled = (values["Retina Enabled"] as? NSNumber)?.boolValue ?? retinaDefault

			settings.mirroring = (values["DuetMirroring"] as? NSNumber)?.boolValue ?? false

			return settings
		}

		let result = DeviceTypeSettings(name: name)
		result.save() // Make sure it gets saved

		return result
	}

	func save()
	{
		var mutableValues: [String: Any] = GeneralSettingsManager.shared.macSettings as? [String: Any] ?? [:]
		let dictInfo = asDictionary()

		mutableValues[name] = dictInfo
		GeneralSettingsManager.shared.macSettings = mutableValues

//		if let settings = DuetServicesManager.shared().getRemoteSettings()
//		{
//			populateRemoteSettings(remoteSettings: settings)
//		}

		NotificationCenter.default.post(name: NSNotification.Name(rawValue: kSettingsChangedNotification), object: nil, userInfo: nil)
	}

	func asDictionary() -> [String: Any]
	{
		var info: [String: Any] = [:]

		info["ModernResolution"] = NSNumber(value: modernResolution.rawValue)
		info["DuetTouchbar"] = NSNumber(booleanLiteral: touchbar)
		info["DuetFramerate"] = framerate.rawValue
		info["DuetQualityType"] = quality.rawValue
		info["Retina Enabled"] = NSNumber(booleanLiteral: retinaEnabled)

		if let lastSetVersion = lastSetVersion
		{
			info["lastSetVersion"] = lastSetVersion
		}

		info["DuetMirroring"] = NSNumber(booleanLiteral: mirroring)

		return info
	}

	override var debugDescription: String
	{
		"\(asDictionary())"
	}

	private func alternateResolution(of duetDevice: DuetDeviceType) -> Bool
	{
		if duetDevice == DuetDeviceiPadRetinaLandscape ||
			duetDevice == DuetDeviceiPadRetinaPortrait ||
			duetDevice == DuetDeviceiPadMiniRetinaLandscape ||
			duetDevice == DuetDeviceiPadMiniRetinaPortrait ||
			duetDevice == DuetDeviceiPadLandscape ||
			duetDevice == DuetDeviceiPadPortrait ||
			duetDevice == DuetDeviceiPadMiniLandscape ||
			duetDevice == DuetDeviceiPadMiniPortrait ||
			duetDevice == DuetDeviceiPadProLandscape ||
			duetDevice == DuetDeviceiPadProPortrait
		{
			return false
		}

		return false
	}

	func resolutionWidth(for type: Int) -> Int
	{
		Int(DuetResolutionManager.shared.resolutionFor(option: modernResolution, portrait: false).width)
	}

	func resolutionHeight(for type: Int) -> Int
	{
		Int(DuetResolutionManager.shared.resolutionFor(option: modernResolution, portrait: false).height)
	}

	func populateRemoteSettings(remoteSettings: DuetRemoteSettings)
	{
		remoteSettings.mirrored = mirroring
	}

	func useRemoteSettings(remoteSettings: DuetRemoteSettings)
	{
		if mirroring != remoteSettings.mirrored
		{
			mirroring = remoteSettings.mirrored
			save()
			DispatchQueue.main.async
			{
				self.applyMirrorSettingChange()
			}
		}
	}

	// act on mirror setting change that comes from the client (applies only for regular, not RDP)
	func applyMirrorSettingChange()
	{
//		let duetDelegate = NSApplication.shared.delegate as! AppDelegate
//		let manager = duetDelegate.duetManager
//		if let duetInstances = manager?.duetInstances() as? [DuetInstance]
//		{
//			if mirroring
//			{
//				let primaryDisplay: CGDirectDisplayID = CGMainDisplayID()
//
//				for instance in duetInstances
//				{
//					instance.enableHardwareMirroringDisplay(primaryDisplay)
//				}
//			} // extended
//			else
//			{
//				for instance in duetInstances
//				{
//					instance.disableHardwareMirroringDisplay()
//				}
//			}
//		}
	}
//
}

@objcMembers class DeviceSpecificSettings: NSObject
{
	var deviceUuid: String
	var deviceName: String?
	var airAutoConnect: DuetAutoConnectOption = .notSet
	var deviceType: Int = 0
	var deviceExpandedType: DuetReceiverDeviceType
	var resolution: DuetResolutionKeys = .duetiPadResolutionKey
	var nativeSize: CGSize
	var scale: Double

	init(uuid: String)
	{
		deviceUuid = uuid
		deviceExpandedType = DuetReceiveriOS
		scale = 2
		nativeSize = .zero
	}

	static func allDeviceSettings() -> [DeviceSpecificSettings]
	{
		var settings: [DeviceSpecificSettings] = []

		if let values = GeneralSettingsManager.shared.macDeviceSettings as? [String: [String: Any]]
		{
			for v in values.keys
			{
				guard let info = values[v] else { continue }

				let setting = DeviceSpecificSettings(uuid: v)

				fill(settings: setting, fromValues: info)

				settings.append(setting)
			}
		}

		return settings.sorted(by: { ds1, ds2 -> Bool in
			ds1.deviceUuid < ds2.deviceUuid
		})
	}

	static func settingsFor(uuid: String) -> DeviceSpecificSettings?
	{
		if let values = GeneralSettingsManager.shared.macDeviceSettings?[uuid] as? [String: Any]
		{
			let settings = DeviceSpecificSettings(uuid: uuid)

			fill(settings: settings, fromValues: values)

			return settings
		}

		return DeviceSpecificSettings(uuid: uuid)
	}

	func save()
	{
		var mutableValues: [String: Any] = GeneralSettingsManager.shared.macDeviceSettings as? [String: Any] ?? [:]
		let dictInfo = asDictionary()

		mutableValues[deviceUuid] = dictInfo
		GeneralSettingsManager.shared.macDeviceSettings = mutableValues
	}

	func removeSetting()
	{
		var mutableValues: [String: Any] = GeneralSettingsManager.shared.macDeviceSettings as? [String: Any] ?? [:]
		mutableValues.removeValue(forKey: deviceUuid)
		GeneralSettingsManager.shared.macDeviceSettings = mutableValues
	}

	func asDictionary() -> [String: Any]
	{
		var info: [String: Any] = [:]

		info["DuetResolution"] = resolution.rawValue
		info["Air Auto-Connect"] = airAutoConnect.rawValue
		info["Device Type"] = deviceType
		info["Device Name"] = deviceName
		info["Device UUID"] = deviceUuid
		info["Device Expanded"] = deviceExpandedType.rawValue
		info["Device Scale"] = scale
		info["Native Size"] = nativeSize.dictionaryRepresentation

		return info
	}

	fileprivate static func fill(settings: DeviceSpecificSettings, fromValues values: [String: Any])
	{
		let aacVal = (values["Air Auto-Connect"] as? NSNumber)?.intValue ?? -1
		settings.airAutoConnect = DuetAutoConnectOption(rawValue: aacVal) ?? DuetAutoConnectOption.notSet
		settings.deviceType = (values["Device Type"] as? NSNumber)?.intValue ?? 0
		settings.resolution = DuetResolutionKeys(rawValue: (values["Device Type"] as? NSNumber)?.intValue ?? 0) ?? DuetResolutionKeys.duetiPadResolutionKey
		settings.deviceName = (values["Device Name"] as? String)
		settings.deviceExpandedType = DuetReceiverDeviceType(rawValue: (values["Device Expanded"] as? NSNumber)?.uint32Value ?? 0)

		if let ns = values["Native Size"]
		{
			settings.nativeSize = CGSize(dictionaryRepresentation: ns as! CFDictionary) ?? .zero
		}
		settings.scale = (values["Device Scale"] as? NSNumber)?.doubleValue ?? 2.0
	}
}

@objcMembers
class GeneralSettingsManager: NSObject
{
	static let shared = GeneralSettingsManager()

	override init()
	{
		if let value = UserDefaults.standard.safeReadObject(forKey: "dfog") as? NSNumber
		{
			forceDriver = value.boolValue
		}

		cachedAndroidUSBDisable = (UserDefaults.standard.safeReadObject(forKey: "androidUsbDisabled") as? NSNumber)?.boolValue ?? true
	}

	func migrateFromDefaults()
	{
		debugPrint("Attempting initial migration of settings")
	}

	var remoteDesktopEnabled: Bool
	{
		get
		{
			UserDefaults.standard.remoteDesktopEnabled
		}
		set
		{
			UserDefaults.standard.remoteDesktopEnabled = newValue
		}
	}

	var remoteHasSignedIn: Bool
	{
		get
		{
			UserDefaults.standard.bool(forKey: "RemoteHasSignedIn")
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "RemoteHasSignedIn")
		}
	}

	var enableAir: Bool
	{
		get
		{
			UserDefaults.standard.enableAir?.boolValue ?? true
		}
		set
		{
			UserDefaults.standard.enableAir = NSNumber(booleanLiteral: newValue)
		}
	}

	var launchAtLogin: Bool
	{
		get
		{
			if let value = UserDefaults.standard.launchAtLogin
			{
				return value.boolValue
			}
			else
			{
				UserDefaults.standard.launchAtLogin = true
				return true
			}
		}
		set
		{
			UserDefaults.standard.launchAtLogin = NSNumber(booleanLiteral: newValue)
		}
	}

	var disableAWDL: NSNumber?
	{
		get
		{
			if let legacyValue = UserDefaults.standard.legacyDisableAWDL
			{
				if legacyValue.boolValue == true
				{
					UserDefaults.standard.disableAWDL = legacyValue
					UserDefaults.standard.legacyDisableAWDL = nil
				}
			}
			return UserDefaults.standard.disableAWDL
		}
		set
		{
			UserDefaults.standard.disableAWDL = newValue
			AnalyticManager.shared.setTag(newValue?.boolValue ?? false ? "true" : "false", forKey: "AWDLToolEnabled")
		}
	}

	var lastRetinaVerifyDate: Date?
	{
		get
		{
			UserDefaults.standard.lastRetinaVerifyDate
		}
		set
		{
			UserDefaults.standard.lastRetinaVerifyDate = newValue
		}
	}

	var retinaEnabled: Bool
	{
		get
		{
			UserDefaults.standard.retinaEnabled
		}
		set
		{
			UserDefaults.standard.retinaEnabled = newValue
		}
	}

	var isReduceMotionOpen: Bool
	{
		get
		{
			UserDefaults.standard.isReduceMotionOpen
		}
		set
		{
			UserDefaults.standard.isReduceMotionOpen = newValue
		}
	}

	var reduceMotionRestore: String?
	{
		get
		{
			UserDefaults.standard.reduceMotionRestore
		}
		set
		{
			UserDefaults.standard.reduceMotionRestore = newValue
		}
	}

	var controlStripCacheOpen: Bool
	{
		get
		{
			UserDefaults.standard.controlStripCacheOpen
		}
		set
		{
			UserDefaults.standard.controlStripCacheOpen = newValue
		}
	}

	var controlStripCache: String?
	{
		get
		{
			UserDefaults.standard.controlStripCache
		}
		set
		{
			UserDefaults.standard.controlStripCache = newValue
		}
	}

	var forceReflectorRequired: Bool
	{
		UserDefaults.standard.forceReflectorRequired
	}

	var forceNextGeneration: Bool
	{
		get
		{
			if let value = UserDefaults.standard.safeReadObject(forKey: "dfng") as? NSNumber, value.boolValue
			{
				return DVDI.available()
			}

			return false
		}
		set
		{
			UserDefaults.standard.safeSetObject(NSNumber(booleanLiteral: newValue), forKey: "dfng")
		}
	}

	var forceDriver: Bool = false

	private var connectedLock = NSLock()
	private var _successfullyConnectedToAir: Bool = true
	var successfullyConnectedToAir: Bool
	{
		get
		{
			connectedLock.lock()
			defer { connectedLock.unlock() }

			return _successfullyConnectedToAir
		}
		set
		{
			connectedLock.lock()
			defer { connectedLock.unlock() }

			_successfullyConnectedToAir = newValue
		}
	}

	var forceHighPerformanceGPU: NSNumber?
	{
		get
		{
			UserDefaults.standard.forceHighPerformanceGPU
		}
		set
		{
			UserDefaults.standard.forceHighPerformanceGPU = newValue
		}
	}

	var didShowPhotoshopTutorial: Date?
	{
		get
		{
			UserDefaults.standard.didShowPhotoshopTutorial
		}
		set
		{
			UserDefaults.standard.didShowPhotoshopTutorial = newValue
		}
	}

	// TODO: remove this
	var lastOpenViewForSettingsWindow: DuetPanelLastSelected
	{
		get
		{
			UserDefaults.standard.lastOpenViewForSettingsWindow
		}
		set
		{
			UserDefaults.standard.lastOpenViewForSettingsWindow = newValue
		}
	}

//	var lastOpenTabForMainWindow: MainMenuTab
//	{
//		get
//		{
//			MainMenuTab(rawValue: UserDefaults.standard.lastOpenedTab) ?? MainMenuTab(rawValue: 0)!
//		}
//		set
//		{
//			UserDefaults.standard.lastOpenedTab = newValue.rawValue
//		}
//	}

	var didShowLightroomTutorial: Date?
	{
		get
		{
			UserDefaults.standard.didShowLightroomTutorial
		}
		set
		{
			UserDefaults.standard.didShowLightroomTutorial = newValue
		}
	}

	var didShowPremiereTutorial: Date?
	{
		get
		{
			UserDefaults.standard.didShowPremiereTutorial
		}
		set
		{
			UserDefaults.standard.didShowPremiereTutorial = newValue
		}
	}

	var disabledMirrorInitially: NSNumber?
	{
		get
		{
			UserDefaults.standard.disabledMirrorInitially
		}
		set
		{
			UserDefaults.standard.disabledMirrorInitially = newValue
		}
	}


	var skipAccessibilityCheck: Bool
	{
		get
		{
			UserDefaults.standard.skipAccessibilityCheck
		}
		set
		{
			UserDefaults.standard.skipAccessibilityCheck = newValue
		}
	}

	var highResolutionEnabled: Bool
	{
		get
		{
			UserDefaults.standard.highResolutionEnabled?.boolValue ?? false
		}
		set
		{
			UserDefaults.standard.highResolutionEnabled = NSNumber(booleanLiteral: newValue)
		}
	}

	var hoverKey: NSNumber?
	{
		get
		{
			UserDefaults.standard.hoverKey
		}
		set
		{
			UserDefaults.standard.hoverKey = newValue
		}
	}

	var installDate: NSNumber?
	{
		get
		{
			UserDefaults.standard.installDate
		}
		set
		{
			UserDefaults.standard.installDate = newValue
		}
	}

	var updateAppAutomatically: NSNumber?
	{
		get
		{
			UserDefaults.standard.updateAppAutomatically ?? 1
		}
		set
		{
         let v: NSNumber = newValue ?? 1 // Default to yes, updates unless the user explicitly says no.
			UserDefaults.standard.updateAppAutomatically = v
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateAutomaticallyChanged"), object: nil, userInfo: ["value": v])
		}
	}

	var lastConnectionReminder: NSNumber?
	{
		get
		{
			UserDefaults.standard.lastConnectionReminder
		}
		set
		{
			UserDefaults.standard.lastConnectionReminder = newValue
		}
	}

	var lastConnectTime: NSNumber?
	{
		get
		{
			UserDefaults.standard.lastConnectTime
		}
		set
		{
			DispatchQueue.main.async
			{
				UserDefaults.standard.lastConnectTime = newValue
			}
		}
	}

	var notificationGroup: NSNumber?
	{
		get
		{
			UserDefaults.standard.notificationGroup
		}
		set
		{
			UserDefaults.standard.notificationGroup = newValue
		}
	}

	var proEnabled: NSNumber?
	{
		get
		{
			UserDefaults.standard.proEnabled
		}
		set
		{
			UserDefaults.standard.proEnabled = newValue
		}
	}

	var lastProfileSubmissionDate: Date?
	{
		get
		{
			UserDefaults.standard.lastProfileSubmissionDate
		}
		set
		{
			UserDefaults.standard.lastProfileSubmissionDate = newValue
		}
	}

	var installedDuetVersion: String?
	{
		get
		{
			UserDefaults.standard.installedDuetVersion
		}
		set
		{
			UserDefaults.standard.installedDuetVersion = newValue
		}
	}

	var lastUpdate: Date?
	{
		get
		{
			UserDefaults.standard.lastUpdate
		}
		set
		{
			UserDefaults.standard.lastUpdate = newValue
		}
	}

	var acceleratedDisplayPossible: Bool
	{
		get
		{
			UserDefaults.standard.acceleratedDisplayPossible
		}
		set
		{
			UserDefaults.standard.acceleratedDisplayPossible = newValue
		}
	}

	var didShowMissionControl: Date?
	{
		get
		{
			UserDefaults.standard.didShowMissionControl
		}
		set
		{
			UserDefaults.standard.didShowMissionControl = newValue
		}
	}

	var resolutionQuality: NSNumber?
	{
		get
		{
			UserDefaults.standard.resolutionQuality
		}
		set
		{
			UserDefaults.standard.resolutionQuality = newValue
		}
	}

	var firstLaunch: NSNumber
	{
		get
		{
			UserDefaults.standard.firstLaunch ?? NSNumber(value: true)
		}
		set
		{
			UserDefaults.standard.firstLaunch = newValue
		}
	}

	var lastMoreSpaceReset: Date?
	{
		get
		{
			UserDefaults.standard.lastMoreSpaceReset
		}
		set
		{
			UserDefaults.standard.lastMoreSpaceReset = newValue
		}
	}

	var macSettings: [AnyHashable: Any]?
	{
		get
		{
			UserDefaults.standard.macSettings
		}
		set
		{
			UserDefaults.standard.macSettings = newValue
		}
	}

	var macDeviceSettings: [AnyHashable: Any]?
	{
		get
		{
			UserDefaults.standard.macDeviceSettings
		}
		set
		{
			UserDefaults.standard.macDeviceSettings = newValue
		}
	}

	var verboseLoggingEnabled: Bool
	{
		get // Default to verbose disabled.
		{
			(UserDefaults.standard.safeReadObject(forKey: "LogVerbose") as? NSNumber)?.boolValue ?? false
		}
		set
		{
			guard verboseLoggingEnabled != newValue else {
				return
			}
			UserDefaults.standard.safeSetObject(NSNumber(booleanLiteral: newValue), forKey: "LogVerbose")
		}
	}

	var fileLoggingEnabled: Bool
	{
		get // Default to log file enabled.
		{
			(UserDefaults.standard.safeReadObject(forKey: "LogToFile") as? NSNumber)?.boolValue ?? true
		}
		set
		{
			UserDefaults.standard.safeSetObject(NSNumber(booleanLiteral: newValue), forKey: "LogToFile")
		}
	}

   var fileLoggingMaxSize: Int
   {
		get // Default to 20MiB.
		{
			UserDefaults.standard.integer(forKey: "LogFileMaxSize") ?? (20 * 1024 * 1024)
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "LogFileMaxSize")
		}
   }

	var displayViewStatsEnabled: Bool
	{
		get
		{
			UserDefaults.standard.bool(forKey: "duetDisplayViewStatsEnabled")
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "duetDisplayViewStatsEnabled")
		}
	}

	var rdpServerPort: Int
	{
		get
		{
			UserDefaults.standard.integer(forKey: "rdpServerPort")
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "rdpServerPort")
		}
	}

	var rdpServerLastPort: Int
	{
		get
		{
			UserDefaults.standard.integer(forKey: "rdpServerLastPort")
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "rdpServerLastPort")
		}
	}

	var displayPermissionRequested: Bool
	{
		get
		{
			UserDefaults.standard.bool(forKey: "displayPermRequested")
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "displayPermRequested")
		}
	}

	var provideUnscaledRetina: Bool
	{
		get
		{
			(UserDefaults.standard.safeReadObject(forKey: "unscaledRetina") as? NSNumber)?.boolValue ?? false
		}
		set
		{
			UserDefaults.standard.safeSetObject(NSNumber(booleanLiteral: newValue), forKey: "unscaledRetina")
		}
	}

	var allowUDPLightup: Bool
	{
		get
		{
			(UserDefaults.standard.safeReadObject(forKey: "allowUDPLightup") as? NSNumber)?.boolValue ?? true
		}
		set
		{
			UserDefaults.standard.safeSetObject(NSNumber(booleanLiteral: newValue), forKey: "allowUDPLightup")
		}
	}

   var embeddedCursor: Bool
   {
		get
		{
			UserDefaults.standard.bool(forKey: "embeddedCursor")
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "embeddedCursor")
		}
   }

	private var cachedAndroidUSBDisable: Bool = true
	var androidUSBDisabled: Bool
	{
		get
		{
			cachedAndroidUSBDisable
		}
		set
		{
			cachedAndroidUSBDisable = newValue
			UserDefaults.standard.safeSetObject(NSNumber(booleanLiteral: newValue), forKey: "androidUsbDisabled")
		}
	}
	
	var enableExpertSettings: Bool
	{
		 get
		 {
			 UserDefaults.standard.bool(forKey: "expertSettings")
		 }
		 set
		 {
			 UserDefaults.standard.set(newValue, forKey: "expertSettings")
		 }
	}
	
	var forceH264: Bool
	{
		get
		{
			UserDefaults.standard.bool(forKey: "forceH264")
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "forceH264")
		}
	}
	
	var forceRDPProxy: Bool
	{
		get
		{
			UserDefaults.standard.bool(forKey: "forceRDPProxy")
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "forceRDPProxy")
		}
	}
	
	var forceWireless: Bool
	{
		get
		{
			UserDefaults.standard.bool(forKey: "forceWireless")
		}
		set
		{
			UserDefaults.standard.set(newValue, forKey: "forceWireless")
		}
	}
	
	var adaptiveRDPQuality: Bool
	{
		get
		{
			return FeatureFlags.shared.evaluateRollout(forKey: FeatureFlags.featureFlagRDPAdaptiveQualityControllerEnabled, defaultRolloutValue: .disabledCompletely)
		}
	}
}
