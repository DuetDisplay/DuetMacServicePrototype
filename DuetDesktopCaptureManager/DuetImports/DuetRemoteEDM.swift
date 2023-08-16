//
//  DuetRemoteEDM.swift
//  duet
//
//  Created by Cedric Pansky on 9/4/19.
//  Copyright © 2019 Duet, Inc. All rights reserved.
//

import CocoaLumberjackSwift
import DuetRemoteDisplay
import DuetVideo
import Foundation


@objcMembers
class DuetRemoteEDMResolutionManager: NSObject, DuetRDSExtendedDisplayResolutionManager
{
	private(set) var hasRetinaResolutions: Bool = false
	private(set) var current: [DuetRDSExtendedDisplayResolution]?

	func generateBaseResolutions(from: CGSize) -> [DuetRDSExtendedDisplayResolution]
	{
		generateBaseResolutions(from: from, withRetina: true)
	}

	func generateBaseResolutions(from: CGSize, withRetina retina: Bool) -> [DuetRDSExtendedDisplayResolution]
	{
		generateBaseResolutions(from: from, withRetina: retina, withPortrait: from.width < from.height)
	}

	func generateBaseResolutions(from: CGSize, withRetina retina: Bool, withPortrait portrait: Bool) -> [DuetRDSExtendedDisplayResolution]
	{
		//		if HEVCVideoType.videoTypeRangeLimit > 0 {
		//			var ratio: CGFloat
		//			var size: CGSize
		//			if from.width > from.height {
		//				ratio = from.height / from.width
		//				size = CGSize(width: CGFloat(HEVCVideoType.videoTypeRangeLimit), height: CGFloat(HEVCVideoType.videoTypeRangeLimit)*ratio)
		//			}
		//			else {
		//				ratio = from.width / from.height
		//				size = CGSize(width: CGFloat(HEVCVideoType.videoTypeRangeLimit)*ratio, height: CGFloat(HEVCVideoType.videoTypeRangeLimit))
		//			}
		//			return DuetResolutionManager.shared.generateBaseResolutions(from: size, withRetina: retina, withPortrait: portrait)
		//		}

		DuetResolutionManager.shared.generateBaseResolutions(from: from, withRetina: retina, withPortrait: portrait)
	}

	func apply(_ resolutions: [DuetRDSExtendedDisplayResolution])
	{
		try? DuetResolutionManager.shared.apply(resolutions: resolutions as! [DuetResolution])

		current = resolutions

		hasRetinaResolutions = false
		for r in resolutions
		{
			if r.retina
			{
				hasRetinaResolutions = true
				break
			}
		}
	}
}

// TODO: this class redirects the calls to the XPC interface of the capture/display manager module, and then transforms back the return values so it complies with the protocol
@objcMembers
class DuetRemoteEDMDisplayManagerProxy: NSObject, DuetRDSExtendedDisplayManager {
	var displayId: UInt32 = 0
	
	var isPortrait: Bool = false
	
	var currentResolution: DuetRDSExtendedDisplayResolution?
	
	func setup(with resolutions: [DuetRDSExtendedDisplayResolution], retina: Bool, portrait: Bool, completion: @escaping DuetRDSExtendedDisplaySetupCompletion) {
		// TODO
	}
	
	func setup(with resolutions: [DuetRDSExtendedDisplayResolution], retina: Bool, portrait: Bool, includeSelection: Bool, completion: @escaping DuetRDSExtendedDisplaySetupCompletion) {
		// TODO
	}
	
	func destroy(_ display: UInt32) {
		// TODO
	}
	
	func destroyAll() {
		// TODO
	}
	
	func select(_ resolution: DuetRDSExtendedDisplayResolution, retinaEnabled: Bool) -> Bool {
		// TODO
		return true
	}
	
	func selectResolution(withWidth width: Int32, height: Int32, retinaEnabled: Bool, forDisplay display: CGDirectDisplayID) -> Bool {
		// TODO
		return true
	}
	
	func mirrorContents(ofDisplay sourceDisplayId: UInt32, toDisplay destinationDisplayId: UInt32, completion: @escaping DuetRDSMirrorDisplaySetupCompletion) {
		// TODO
	}
	
	func swapMirroring(completion: @escaping DuetRDSMirrorDisplaySetupCompletion) {
		// TODO
	}
	
}

@objcMembers
class DuetRemoteEDMDisplayManager: NSObject, DuetRDSExtendedDisplayManager
{
//	private(set) var displayList: [NSNumber] = []
	private var displayManager: DVDI?

	private(set) var displayId: UInt32 = 0
	private(set) var isPortrait: Bool = false
	private(set) var currentResolution: DuetRDSExtendedDisplayResolution?

	func setup(with resolutions: [DuetRDSExtendedDisplayResolution], retina: Bool, portrait: Bool, completion: @escaping DuetRDSExtendedDisplaySetupCompletion)
	{
		setup(with: resolutions, retina: retina, portrait: portrait, includeSelection: true, completion: completion)
	}

	func setup(with resolutions: [DuetRDSExtendedDisplayResolution], retina: Bool, portrait: Bool, includeSelection: Bool, completion: @escaping DuetRDSExtendedDisplaySetupCompletion)
	{
		DDLogVerbose("[Display] \(#function)")
		DispatchQueue.main.async {
			guard DVDI.available() else { completion(0, NSError(domain: "display.error", code: 404, userInfo: nil)); return }
			
			self.isPortrait = portrait
			
			if #available(OSX 10.14.4, *) {
				let dm: DVDI = (self.displayManager ?? DVDI())
				self.displayManager = dm
			
				DDLogVerbose("[Display] Calling Setup with \(resolutions) \(portrait)")
				
				dm.setup(resolutions: (resolutions as! [DuetResolution])/*.filter({ $0.portrait == portrait })*/, plusRetina: retina) { [weak self] in
					guard let self = self else { return }
					if let did = self.displayManager?.displayId {
						DDLogVerbose("[Display] ID Found: \(did)")
						
						self.displayId = did

                  // Default to the highest resolution and then the user can dial it back if necessary.
						let defaultResolutionSetting: DuetResolutionSetting
						if let resolutionRawValue = UserDefaults.standard.object(forKey: "DefaultRDPResolution") as? Int {
							defaultResolutionSetting = DuetResolutionSetting(rawValue: resolutionRawValue)!
						} else {
							defaultResolutionSetting = DuetResolutionSetting.medium
						}
						let defaultResolution = DuetResolutionManager.shared.resolutionFor(option: defaultResolutionSetting, portrait: portrait)
                  _ = self.select(defaultResolution, retinaEnabled: retina)
						
						var screen: NSScreen?
						for s in NSScreen.screens {
							if let sn = s.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber, sn.intValue == did {
								screen = s
								break
							}
						}
						
						if let screen = screen {
							let refreshWindow = DuetRefreshWindowManager(screen: screen)
							refreshWindow.startRefresh()
						}
	//
						////						NSApp.setActivationPolicy(.regular)
//						NotificationCenter.default.post(name: NSNotification.Name(kDuetRemoteDisplayAddedDisplay), object: nil)
						completion(did, nil)
					}
					else {
						DDLogVerbose("[Display] ID Not Generated")
						completion(0, NSError(domain: "display.error", code: 1000, userInfo: nil))
					}
				}
			}
		}
	}

	func destroy(_ display: UInt32)
	{
		var mirrorConfig: CGDisplayConfigRef?
		CGBeginDisplayConfiguration(&mirrorConfig)
		CGConfigureDisplayMirrorOfDisplay(mirrorConfig, display, kCGNullDirectDisplay)
		CGCompleteDisplayConfiguration(mirrorConfig, .permanently)
		displayManager = nil
		displayId = 0

		//		NSApp.setActivationPolicy(.accessory)
		DispatchQueue.main.async
		{
//			NotificationCenter.default.post(name: NSNotification.Name(kDuetRemoteDisplayRemovedDisplay), object: nil)
		}
	}

	func destroyAll()
	{
		if displayId != 0
		{
			destroy(displayId)
		}
	}

    func select(_ resolution: DuetRDSExtendedDisplayResolution, retinaEnabled retina: Bool) -> Bool
    {
        guard displayId != 0 else { return false }

        return selectResolution(withWidth: Int32(resolution.width), height: Int32(resolution.height), retinaEnabled: resolution.retina ? retina : false, forDisplay: displayId)
    }

    func selectResolution(withWidth width: Int32, height: Int32, retinaEnabled: Bool, forDisplay display: CGDirectDisplayID) -> Bool
    {
        let newResolution = DuetResolution(width: UInt32(width), height: UInt32(height), retina: retinaEnabled, portrait: width < height)

        let choices: [DuetResolutionSetting] = [.lowest, .low, .medium, .higher, .highest]
		DDLogVerbose("[Display] Looking for resolution \(width)x\(height) retina: \(retinaEnabled)")

        for choice in choices
        {
            let size = DuetResolutionManager.shared.resolutionFor(option: choice, portrait: false)

			DDLogVerbose("[Display] \(size) r:\(size.retina) == \(width)x\(height) r:\(retinaEnabled)")

			if size.width == width, size.height == height, retinaEnabled == size.retina
            {
                UserDefaults.standard.set(choice.rawValue, forKey: "DefaultRDPResolution")
                break
            }
        }

        let result = UtilsReplacement.setResolutionWithWidth(Int32(width), andHeight: Int32(height), andRetinaEnabled: retinaEnabled, forDisplay: display)
        if (result == true) {
            DDLogInfo("[Display] Setting the resolution to \(width)x\(height) retina:\(retinaEnabled) display: \(display) success")
            currentResolution = newResolution
			NotificationCenter.default.post(name: NSNotification.Name("DisplayManagerResolutionChanged"), object: self, userInfo: nil)
        } else {
            DDLogError("[Display] Setting the resolution to \(width)x\(height) retina:\(retinaEnabled) display: \(display) failure!")
        }
        return result
    }

    func mirrorContents(ofDisplay sourceDisplayId: UInt32, toDisplay destinationDisplayId: UInt32, completion: @escaping DuetRDSMirrorDisplaySetupCompletion) {
		var mirrorConfig: CGDisplayConfigRef?
        CGBeginDisplayConfiguration(&mirrorConfig)
        CGConfigureDisplayMirrorOfDisplay(mirrorConfig, destinationDisplayId, sourceDisplayId)
        let err = CGCompleteDisplayConfiguration(mirrorConfig, .permanently)
        DDLogInfo("[Display] Mirroring display \(sourceDisplayId) to \(destinationDisplayId) results: err = \(err)")

        if err == .success {
            completion(sourceDisplayId, destinationDisplayId, nil)
            NotificationCenter.default.post(name: NSNotification.Name("DisplayManagerMirroringChanged"), object: self, userInfo: ["source":sourceDisplayId, "destination":destinationDisplayId])
        } else {
            let error = NSError(domain: "edm", code: 500)
            completion(sourceDisplayId, destinationDisplayId, error)
        }
    }
    
    func swapMirroring(completion: @escaping DuetRDSMirrorDisplaySetupCompletion) {
        NSLog("[Display] swap starting resolution \(currentResolution?.width) x \(currentResolution?.height) \(currentResolution)")
        NSLog("[Display] swap start displayId: \(self.displayId)")
        let primaryDisplayId = CGDisplayMirrorsDisplay(self.displayId)
        NSLog("[Display] swap primary display \(primaryDisplayId)")
        //self.displayId is mirroring primaryDisplayId, let's swap it
        if primaryDisplayId != kCGNullDirectDisplay {
            self.mirrorContents(ofDisplay: self.displayId, toDisplay: primaryDisplayId) { [weak self] source, destination, error in
                guard let self = self, error == nil else {
                    completion(kCGNullDirectDisplay, kCGNullDirectDisplay, error)
                    return
                }
                NSLog("[Display] ending resolution \(self.currentResolution?.width) x \(self.currentResolution?.height) \(self.currentResolution)")
                if let currentResolution = self.currentResolution {
                    NSLog("[Display] swap resetting virtual display resolution (intel workaround)")
                    _ = self.select(currentResolution, retinaEnabled: currentResolution.retina)
                }
                NSLog("[Display] swap calling completion")
                
                completion(self.displayId, primaryDisplayId, error)
                // done swapping
            }
        } else {
            //find out if anything is mirroring self.displayId
            let maxDisplays: UInt32 = 32
            var onlineDisplays = Array<CGDirectDisplayID>.init(repeating: 0, count: Int(maxDisplays))
            var displayCount: UInt32 = 0

            let dErr = CGGetOnlineDisplayList(maxDisplays, &onlineDisplays, &displayCount)
            var mirroringDisplay = kCGNullDirectDisplay
            for displayId in onlineDisplays {
                if CGDisplayMirrorsDisplay(displayId) == self.displayId {
                    mirroringDisplay = displayId
                    break
                }
            }
            guard mirroringDisplay != kCGNullDirectDisplay else {
                //self.displayId is not mirrored by anything
                completion(kCGNullDirectDisplay, kCGNullDirectDisplay, nil)
                return
            }

            self.mirrorContents(ofDisplay: mirroringDisplay, toDisplay: self.displayId) { [weak self] source, destination, error in
                guard let self = self, error == nil else {
                    completion(kCGNullDirectDisplay, kCGNullDirectDisplay, error)
                    return
                }
                completion(mirroringDisplay, self.displayId, error)
                // done swapping
            }
        }
    }
	
	deinit
	{
		self.destroyAll()
	}
}

// I'm not sure if this class is needed, but for now let's use it - the initializer creates the proxy classes
@objcMembers
class DuetRemoteEDMProxy: NSObject, DuetRDSExtendedDisplayProvider
{
	var resolutionManager: DuetRDSExtendedDisplayResolutionManager
	var displayManager: DuetRDSExtendedDisplayManager

	override init()
	{
		resolutionManager = DuetRemoteEDMResolutionManager()
		displayManager = DuetRemoteEDMDisplayManagerProxy()
	}
}

@objcMembers
class DuetRemoteEDM: NSObject, DuetRDSExtendedDisplayProvider
{
	var resolutionManager: DuetRDSExtendedDisplayResolutionManager
	var displayManager: DuetRDSExtendedDisplayManager

	override init()
	{
		resolutionManager = DuetRemoteEDMResolutionManager()
		displayManager = DuetRemoteEDMDisplayManager()
	}
}
