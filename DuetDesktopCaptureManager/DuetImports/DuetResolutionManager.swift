//
//  DuetResolutionManager.swift
//  duet
//
//  Created by Cedric Pansky on 7/8/19.
//  Copyright © 2019 Duet, Inc. All rights reserved.
//

import CocoaLumberjackSwift
import DuetRemoteDisplay
import Foundation
import DuetAnalytics

@objc enum DuetResolutionSetting: Int, CaseIterable
{
	case lowest
	case low
	case medium
	case higher
	case highest

	var rawValue: Int
	{
		switch self
		{
			case .lowest: return 0
			case .low: return 1
			case .medium: return 2
			case .higher: return 3
			case .highest: return 4
		}
	}
}

@objcMembers
class DuetResolutionManager: NSObject
{
	static let shared = DuetResolutionManager()

	private var currentLock = NSLock()

	private(set) var hasRetinaResolutions: Bool = false
	private(set) var current: [DuetResolution] = []

	// Passthrough so objective-c can take advantage of the default argument on withRetina
	func generateBaseResolutions(from: CGSize) -> [DuetResolution]
	{
		generateBaseResolutions(from: from, withRetina: true)
	}

	/// Take a width, height, and ratio and move down to the next place where both are even numbers
	fileprivate static func roundToNextEvenNumbers(_ width: inout UInt32, _ height: inout UInt32, _ ratio: Double)
	{
		var x = width
		var y = height

		// See if the initial numbers work.  If not, try three passes at getting match for the aspect ratio.

		x = x & ~3 // Make x a multiple of 4.

		for _ in 1 ... 4
		{
			if (y & 3) != 0
			{
				width = x
				height = y
				return
			}

			x -= 4
			y = UInt32(Double(x) * ratio)
		}

		//    If we got here, That didn't work.  The above algorithm will fail for (according to some empirical tests I ran
		// on widths and heights between 200 and 8192) around 0.002173 of cases, at least one of which we ran into in the
		// field.  The height never settles to a multiple of four, so it loops all the way down to 0, 0, at which point below
		// we get an underflow trap when we subtract something from zero in an unsigned value.
		//
		//    So, alternate plan; let's go for a nearby resolution that's a multiple of 16 in both dimensions and closest
		// to the original aspect ratio:

		let x1 = (width & ~15) // Width rounded down to the nearest multiple of 16.
		let y1 = (height & ~15) // Height rounded down to the nearest multiple of 16.
		let x2 = x1 + 16 // Width rounded up to the nearest multiple of 16.
		let y2 = y1 + 16 // Height rounded up to the nearest multiple of 16.

		let ar11 = abs(ratio - (Double(y1) / Double(x1)))
		let ar12 = abs(ratio - (Double(y2) / Double(x1)))
		let ar21 = abs(ratio - (Double(y1) / Double(x2)))
		let ar22 = abs(ratio - (Double(y2) / Double(x2)))

		let mind = min(min(ar11, ar12), min(ar21, ar22)) // Minimum delta from the source aspect ratio.

		switch mind
		{
			case ar11: width = x1; height = y1
			case ar12: width = x1; height = y2
			case ar21: width = x2; height = y1
			default: width = x2; height = y2
		}
	}

	static func roundToNextEvenNumbers(width: Int, height: Int, ratio: Double, output: (Int, Int) -> Void)
	{
		var w = UInt32(width)
		var h = UInt32(height)

		DuetResolutionManager.roundToNextEvenNumbers(&w, &h, ratio)
		output(Int(w), Int(h))
	}

	func generateBaseResolutions(from: CGSize, withRetina: Bool) -> [DuetResolution]
	{
		generateBaseResolutions(from: from, withRetina: withRetina, withPortrait: from.width < from.height)
	}

	/**
	 * For new native resolution support, can instead use this directly like
	 * [DuetResolutionManager.shared applyWithResolutions:[DuetResolutionManager.shared generateBaseResolutionsFrom:CGSizeMake(width, height) withRetina:YES]];
	 */
	func generateBaseResolutions(from: CGSize, withRetina: Bool, withPortrait: Bool) -> [DuetResolution]
	{
		NSLog("[Display] Generating base resolutions size \(from) retina: \(withRetina) portrait: \(withPortrait)")

		if from.width == 0 || from.height == 0
		{
			// A sane default in case we had a modern client not get a width and height properly
			return generateResolutionsFor(type: DuetDeviceiPadRetinaLandscape)
		}

		// The from is the largest native resolution
		let maxWidth = UInt32(from.width)
		let maxHeight = UInt32(from.height)

		var scaleFactor = 1.0

		if (Double(maxWidth) * 3.0 / 8.0) < 800
		{
			// Due to issue in Mac 12.4, resolutions below 800x600 don't work well
			// so if minimum resolution will be less than that, need to scale everything up

			scaleFactor = 800.0 / (Double(maxWidth) * 3.0 / 8.0)

			NSLog("Lowest resoulution is less than 800x600, set scale factor = \(scaleFactor)")

			AnalyticManager.shared.trackEvent("Resolution Rescale", properties: ["maxWidth": UInt(maxWidth), "maxHeight": UInt(maxHeight)])
		}

		let ratio = Double(from.height / from.width)

		if ratio.isInfinite || ratio.isNaN
		{
			// If the width and height were bad (Device detection not getting a proper size from iOS?) then we can fail to here, this returns a sane default
			return generateResolutionsFor(type: DuetDeviceiPadRetinaLandscape)
		}

		var step4Width = UInt32(Double(maxWidth) - (Double(maxWidth) / 4.0) / scaleFactor)
		var step4Height = UInt32(Double(step4Width) * ratio)

		DuetResolutionManager.roundToNextEvenNumbers(&step4Width, &step4Height, ratio)

		let step3Width = UInt32(Double(maxWidth / 2) * scaleFactor)
		let step3Height = UInt32(Double(maxHeight / 2) * scaleFactor)

		var step2Width = UInt32(Double(step3Width - (maxWidth / 16)))
		var step2Height = UInt32(Double(step2Width) * ratio)

		DuetResolutionManager.roundToNextEvenNumbers(&step2Width, &step2Height, ratio)

		var step1Width = UInt32(Double(step2Width - (maxWidth / 16)))
		var step1Height = UInt32(Double(step1Width) * ratio)

		DuetResolutionManager.roundToNextEvenNumbers(&step1Width, &step1Height, ratio)

		let landscape: [DuetResolution] = [
			DuetResolution(width: maxWidth, height: maxHeight, retina: false),
			DuetResolution(width: step4Width, height: step4Height, retina: false),
			DuetResolution(width: step3Width, height: step3Height, retina: withRetina).markDefault(),
			DuetResolution(width: step2Width, height: step2Height, retina: withRetina),
			DuetResolution(width: step1Width, height: step1Height, retina: withRetina),
		] as! [DuetResolution]
		NSLog("[Display] generated landscape resolutions: \(landscape)")
		let portrait: [DuetResolution] = [
			// Portrait
			DuetResolution(width: maxHeight, height: maxWidth, retina: false, portrait: true),
			DuetResolution(width: step4Height, height: step4Width, retina: false, portrait: true),
			DuetResolution(width: step3Height, height: step3Width, retina: withRetina, portrait: true).markDefault(),
			DuetResolution(width: step2Height, height: step2Width, retina: withRetina, portrait: true),
			DuetResolution(width: step1Height, height: step1Width, retina: withRetina, portrait: true),
		].sorted
		{ r1, r2 -> Bool in
			r1.width > r2.width
		} as! [DuetResolution]
		NSLog("[Display] generated portrait resolutions: \(portrait)")

		if (withPortrait) {
			return portrait
		} else {
			return landscape
		}
	}

	/**
	 * For old style device types.  Set the resolutions using code like
	 * [DuetResolutionManager.shared applyWithResolutions:[DuetResolutionManager.shared generateResolutionsForType:(DuetDeviceType)self.duetDevice] error:nil];
	 */
	func generateResolutionsFor(type: DuetDeviceType) -> [DuetResolution]
	{
		DDLogVerbose("[SIZE] [Display] \(type)")

		let portrait: [DuetResolution]
		let landscape: [DuetResolution]

		let isPortrait = UtilsReplacement.portraitTag(type.rawValue)

		switch type
		{
			case DuetDeviceiPad11ProLandscape, DuetDeviceiPad11ProPortrait:
				//			return [
				//				DuetResolution(width: 2388, height: 1668, retina: false),
				//				DuetResolution(width: 1791, height: 1251, retina: false),
				//				DuetResolution(width: 1592, height: 1112, retina: true),
				//				DuetResolution(width: 1296, height: 905, retina: true),
				//				DuetResolution(width: 1194, height: 834, retina: true),
				//
				//				// And portrait
				//				DuetResolution(width: 1668, height: 2388, retina: false, portrait: true),
				//				DuetResolution(width: 1251, height: 1791, retina: false, portrait: true),
				//				DuetResolution(width: 1112, height: 1592, retina: true, portrait: true),
				//				DuetResolution(width: 905, height: 1296, retina: true, portrait: true),
				//				DuetResolution(width: 834, height: 1194, retina: true, portrait: true)
				//			]
				return generateBaseResolutions(from: CGSize(width: 2388, height: 1668), withRetina: true, withPortrait: isPortrait)
			case DuetDeviceiPadLandscape, DuetDeviceiPadPortrait, DuetDeviceiPadMiniLandscape, DuetDeviceiPadMiniPortrait:
				landscape = [
					DuetResolution(width: 1024, height: 768, retina: false),
					DuetResolution(width: 1228, height: 921, retina: false),
					DuetResolution(width: 1432, height: 1074, retina: false).markDefault(),
					DuetResolution(width: 1636, height: 1227, retina: false),
					DuetResolution(width: 1840, height: 1380, retina: false),
				] as! [DuetResolution]

				portrait = [
					// And portrait
					DuetResolution(width: 768, height: 1024, retina: false, portrait: true),
					DuetResolution(width: 921, height: 1228, retina: false, portrait: true),
					DuetResolution(width: 1074, height: 1432, retina: false, portrait: true).markDefault(),
					DuetResolution(width: 1227, height: 1636, retina: false, portrait: true),
					DuetResolution(width: 1380, height: 1840, retina: false, portrait: true),
				] as! [DuetResolution]

			//			return self.generateBaseResolutionsForiOS(from: CGSize(width: 1024, height: 768), withRetina: false)
			case DuetDeviceiPadMiniRetinaPortrait, DuetDeviceiPadMiniRetinaLandscape, DuetDeviceiPadMiniTwoRetinaLandscape, DuetDeviceiPadMiniTwoRetinaPortrait, DuetDeviceiPadThreeRetinaPortrait, DuetDeviceiPadThreeRetinaLandscape,
			     DuetDeviceiPadRetinaLandscape, DuetDeviceiPadRetinaPortrait:
				landscape = [
					DuetResolution(width: 1024, height: 768, retina: true),
					DuetResolution(width: 1228, height: 921, retina: true),
					DuetResolution(width: 1432, height: 1074, retina: true).markDefault(),
					DuetResolution(width: 1636, height: 1227, retina: false),
					DuetResolution(width: 1840, height: 1380, retina: false),
				] as! [DuetResolution]

				portrait = [
					// And portrait
					DuetResolution(width: 768, height: 1024, retina: true, portrait: true),
					DuetResolution(width: 921, height: 1228, retina: true, portrait: true),
					DuetResolution(width: 1074, height: 1432, retina: true, portrait: true).markDefault(),
					DuetResolution(width: 1227, height: 1636, retina: false, portrait: true),
					DuetResolution(width: 1380, height: 1840, retina: false, portrait: true),
				] as! [DuetResolution]
			//			return self.generateBaseResolutions(from: CGSize(width: 2048, height: 1536))
			case DuetDeviceiPadProLandscape, DuetDeviceiPadProPortrait:
				//			return [
				//				DuetResolution(width: 1024, height: 768, retina: true),
				//				DuetResolution(width: 1228, height: 921, retina: true),
				//				DuetResolution(width: 1432, height: 1074, retina: true),
				//				DuetResolution(width: 1636, height: 1227, retina: false),
				//				DuetResolution(width: 1840, height: 1380, retina: false),
				//
				//				// And portrait
				//				DuetResolution(width: 768, height: 1024, retina: true, portrait: true),
				//				DuetResolution(width: 921, height: 1228, retina: true, portrait: true),
				//				DuetResolution(width: 1074, height: 1432, retina: true, portrait: true),
				//				DuetResolution(width: 1227, height: 1636, retina: false, portrait: true),
				//				DuetResolution(width: 1380, height: 1840, retina: false, portrait: true)
				//			]
				return generateBaseResolutions(from: CGSize(width: 2732, height: 2048), withRetina: true, withPortrait: isPortrait)
			case DuetDeviceiPhoneThreeRetinaPortrait, DuetDeviceiPhoneThreeRetinaLandscape, DuetDeviceiPhoneFourRetinaPortrait, DuetDeviceiPhoneFourRetinaLandscape, DuetDeviceiPhoneFivePortrait, DuetDeviceiPhoneFiveLandscape,
			     DuetDeviceiPhoneFiveRetinaPortrait, DuetDeviceiPhoneFourRetinaLandscape, DuetDeviceiPhoneSixRetinaPortrait, DuetDeviceiPhoneSixRetinaLandscape, DuetDeviceiPhoneSixPortrait, DuetDeviceiPhoneSixLandscape:
				landscape = [
					DuetResolution(width: 1920, height: 1080, retina: false),
					DuetResolution(width: 1600, height: 900, retina: false),
					DuetResolution(width: 1334, height: 750, retina: true).markDefault(),
					DuetResolution(width: 1136, height: 640, retina: true),
					DuetResolution(width: 1080, height: 608, retina: true),
				] as! [DuetResolution]

				portrait = [
					// And portrait
					DuetResolution(width: 1080, height: 1920, retina: false, portrait: true),
					DuetResolution(width: 900, height: 1600, retina: false, portrait: true),
					DuetResolution(width: 750, height: 1334, retina: true, portrait: true).markDefault(),
					DuetResolution(width: 640, height: 1136, retina: true, portrait: true),
					DuetResolution(width: 608, height: 1080, retina: true, portrait: true),
				] as! [DuetResolution]
			//			return self.generateBaseResolutions(from: CGSize(width: 1136, height: 640))
			case DuetDeviceiPhoneSixPlusPortrait, DuetDeviceiPhoneSixPlusLandscape, DuetDeviceiPhoneSixPlusRetinaPortrait, DuetDeviceiPhoneSixPlusRetinaLandscape:
				landscape = [
					DuetResolution(width: 1920, height: 1080, retina: false),
					DuetResolution(width: 1600, height: 900, retina: false),
					DuetResolution(width: 1334, height: 750, retina: true).markDefault(),
					DuetResolution(width: 1136, height: 640, retina: true),
					DuetResolution(width: 1080, height: 608, retina: true),
				] as! [DuetResolution]

				portrait = [
					// And portrait
					DuetResolution(width: 1080, height: 1920, retina: false, portrait: true),
					DuetResolution(width: 900, height: 1600, retina: false, portrait: true),
					DuetResolution(width: 750, height: 1334, retina: true, portrait: true).markDefault(),
					DuetResolution(width: 640, height: 1136, retina: true, portrait: true),
					DuetResolution(width: 608, height: 1080, retina: true, portrait: true),
				] as! [DuetResolution]

			//			return self.generateBaseResolutions(from: CGSize(width: 2208, height: 1242))
			default:
				return generateBaseResolutions(from: CGSize(width: 2732, height: 2048), withRetina: true, withPortrait: isPortrait)
		}

		if !isPortrait
		{
			DDLogVerbose("[Display] Built Landscape Resolution List")
			return landscape
		}
		else
		{
			DDLogVerbose("[Display] Built Portrait Resolution List")
			return portrait
		}
	}

	/**
	 * Make the list of resolutions the current list
	 */
	func apply(resolutions: [DuetResolution]) throws
	{
		currentLock.lock()
		defer { currentLock.unlock() }

		hasRetinaResolutions = false
		for r in resolutions
		{
			if r.retina
			{
				hasRetinaResolutions = true
				break
			}
		}

		current = resolutions
	}

	func resolutionsAvailable(_ reses: [DuetResolution]) -> Bool
	{
		false
	}

	func allowed(size: CGSize) -> Bool
	{
		false
	}

	func nearest(to size: CGSize) -> DuetResolution
	{
		DuetResolution(width: 1024, height: 768, retina: true)
	}

	func resolutionFor(option: DuetResolutionSetting, portrait: Bool) -> DuetResolution
	{
		currentLock.lock()
		defer { currentLock.unlock() }

		guard current.count >= 5 else {
			return DuetResolution(width: 1024, height: 768, retina: true)
		}
		let sr: [DuetResolution]

		if !portrait
		{
			sr = current.filter {
				$0.portrait == portrait
			}.sorted { $0.width < $1.width }
		}
		else
		{
			sr = current.filter { $0.portrait == portrait }.sorted { $0.height < $1.height }
		}

		guard sr.count >= 5 else { return DuetResolution(width: 1024, height: 768, retina: true) }
		switch option
		{
			case .lowest:
				return sr[0]
			case .low:
				return sr[1]
			case .medium:
				return sr[2]
			case .higher:
				return sr[3]
			case .highest:
				return sr[4]
		}
	}
}
