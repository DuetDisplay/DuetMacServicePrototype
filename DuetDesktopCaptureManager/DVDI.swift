//
//  DuetVirtualDisplay.swift
//  duet
//
//  Created by Cedric Pansky on 10/25/18.
//  Copyright © 2018 Duet, Inc. All rights reserved.
//

import CocoaLumberjackSwift
import DuetRemoteDisplay
import Foundation

typealias DVDIVirtualDisplay = DuetX__vdi__
typealias DVDIVirtualDisplayDescriptor = DuetX__vdi_d__
typealias DVDIVirtualDisplayMode = DuetX__vdi_m__
typealias DVDIVirtualDisplaySettings = DuetX__vdi_s__

@objc class DVDI: NSObject
{
	@objc static var disabled: Bool = false

	private var display: DVDIVirtualDisplay?
	@objc public var displayId: CGDirectDisplayID = 0
	private let displayQueue = DispatchQueue(label: "display queue")

	@objc static func ecn() -> String?
	{
		var data = Data()

		// CGVirtualDisplay
		data.append(0x43)
		data.append(0x47)
		data.append(0x56)
		data.append(0x69)
		data.append(0x72)
		data.append(0x74)
		data.append(0x75)
		data.append(0x61)
		data.append(0x6C)
		data.append(0x44)
		data.append(0x69)
		data.append(0x73)
		data.append(0x70)
		data.append(0x6C)
		data.append(0x61)
		data.append(0x79)

		return String(data: data, encoding: .utf8)
	}

	@objc static func available() -> Bool
	{
		true
	}

	override init()
	{
	}

	deinit
	{
		#if DEBUG
			print("DVDI Destroyed")
		#endif
	}

	@available(OSX 10.14.4, *) @objc func setup(resolutions: [DuetResolution], plusRetina: Bool = true, noPortraitGeneration: Bool = true, serialNumber: UInt32 = 0, completion: @escaping () -> Void)
	{
		DDLogVerbose("[Display] DVDI setup display with resolutions \(resolutions)")

		let description = DVDIVirtualDisplayDescriptor()
		description.vendorID = 4400
		description.productID = 0
		description.serialNum = serialNumber
		description.name = "Duet"

		guard let largest = resolutions.sorted(by: { r1, r2 -> Bool in
			r1.width > r2.width
		}).first
		else
		{
			DDLogVerbose("[Display] Sort error on resolutions, could not find one")
			completion()
			return
		}

		var largestSize = UInt32(largest.size.width > largest.size.height ? largest.size.width : largest.size.height)

		if plusRetina
		{
			// If we don't give it a *very* high size, it won't believe us that we want retina... yes, this is stupid
			if largestSize > 7680
			{ // Limit the size though to the resolution on shipping 8k monitors
				largestSize = 7680
			}

			description.maxPixelsWide = largestSize * 2
			description.maxPixelsHigh = largestSize * 2
		}
		else
		{
			description.maxPixelsWide = largestSize
			description.maxPixelsHigh = largestSize
		}

		if !(resolutions.first?.portrait ?? false)
		{
			description.sizeInMillimeters = CGSize(width: (largest.size.width / 144) * 25, height: (largest.size.height / 144) * 25)
		}
		else
		{
			description.sizeInMillimeters = CGSize(width: (largest.size.height / 144) * 25, height: (largest.size.width / 144) * 25)
		}

		description.queue = displayQueue

		description.terminationHandler = { [weak self] _ in
			DDLogVerbose("[Display] display terminated")
			self?.display = nil
			self?.displayId = 0
		}

		guard let display = display ?? DVDIVirtualDisplay(descriptor: description) else {
			DDLogError("[Display] Could not create display with \(description)")
			completion();
			return
		}
		DDLogDebug("[Display] Display \(display.displayID) created with \(description)")
		self.display = display

		/// Setup our standard possible modes.  These may not all work, these may not all be what we need, and
		/// most importantly despite the range I'm not seeing the HiDPI modes get synthesized
		var modes: [DVDIVirtualDisplayMode] = []
		var modeSizes: [CGSize] = []
		for r in resolutions
		{
			modes.append(DVDIVirtualDisplayMode(width: UInt32(r.size.width), height: UInt32(r.size.height), refreshRate: 60.0))
			modeSizes.append(r.size)

			if plusRetina, r.retina, !modeSizes.contains(r.retinaSize)
			{
				modes.append(DVDIVirtualDisplayMode(width: UInt32(r.retinaSize.width), height: UInt32(r.retinaSize.height), refreshRate: 60.0))
				modeSizes.append(r.retinaSize)
			}
		}

		let settings = DVDIVirtualDisplaySettings()
		if #available(macOS 11.0, *) {
			settings.rotation = .disable
		}

		settings.modes = modes.sorted
		{
			$0.width > $1.width
		}

		DDLogVerbose("[Display] Display Mode List for display \(display.displayID)")
		modes.forEach { DDLogVerbose("[Display] \($0) \($0.width)x\($0.height)") }

		if plusRetina
		{
			settings.hiDPI = .hidpiEnable
		}
		else
		{
			settings.hiDPI = .hidpiDisable
		}

		// When creating a new virtual display (VD), it remembers the last state of the VD when it was created the last time.
		// If it was part of a mirroring set, it will automatically mirror the same display as before.
		// It can cause complications in our code (HW mirrored displays won't appear in activeDisplayList CG call results), so when we create a VD,
		//it has to be forcibly removed from any potential mirroring sets.
		// There was a bug here - All display config code must be wrapped in CGBeginDisplayConfiguration(&conf) ... CGCompleteDisplayConfiguration(conf, .permanently),
		// but it seems that some calls have to be applied separately - display.applySettings(settings) and CGConfiguraDisplayMIrrorOfDisplay() calls were colliding,
		// so I separated them into two distinct CGBegin...CGComplete blocks.
		var mirrorConfig: CGDisplayConfigRef?
		CGBeginDisplayConfiguration(&mirrorConfig)
		display.applySettings(settings)
		displayId = display.displayID
		var err = CGCompleteDisplayConfiguration(mirrorConfig, .permanently)
		DDLogVerbose("[Display] Apply settings for display \(displayId). Error: \(err)")

		CGBeginDisplayConfiguration(&mirrorConfig)
		CGConfigureDisplayMirrorOfDisplay(mirrorConfig, display.displayID, kCGNullDirectDisplay)
		err = CGCompleteDisplayConfiguration(mirrorConfig, .permanently)

		DDLogVerbose("[Display] Disabling mirroring for display \(displayId). Error: \(err)")

		completion()
	}
}
