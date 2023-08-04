//
//  DuetRefreshWindow.swift
//  duet
//
//  Created by Cedric Pansky on 6/27/19.
//  Copyright © 2019 Duet, Inc. All rights reserved.
//

import Foundation
import AppKit

@objc class DuetRefreshWindowManager: NSObject
{
	private var strongSelf: DuetRefreshWindowManager?
	private var refreshWindow: NSWindow?
	private var alphaValue: CGFloat = 0.0
	private var refreshing = false
	private var refreshedCount = 0

	@objc init(screen: NSScreen)
	{
		refreshWindow = HiddenWindow(contentRect: NSRect(x: screen.frame.origin.x + 1, y: screen.frame.origin.y + 1, width: 2, height: 2), styleMask: .borderless, backing: .buffered, defer: false, screen: nil)
		refreshWindow?.isReleasedWhenClosed = false
		refreshWindow?.isOpaque = true
		refreshWindow?.backgroundColor = NSColor.white.withAlphaComponent(alphaValue)
		refreshWindow?.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
	}

	@objc func forceDisplayRefresh()
	{
		refreshedCount += 1
		guard refreshedCount < (60 * 5)
		else
		{
			refreshWindow?.close()
			refreshWindow = nil
			strongSelf = nil
			return
		}

		refreshWindow?.backgroundColor = NSColor.white.withAlphaComponent(alphaValue)

		if alphaValue > 0
		{
			alphaValue = 0
		}
		else
		{
			alphaValue = 0.2
		}

		if refreshing
		{
			DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.01)
			{
				self.forceDisplayRefresh()
			}
		}
	}

	@objc func startRefresh()
	{
		strongSelf = self
		refreshing = true

		refreshWindow?.orderFront(self)
		DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.01)
		{
			self.forceDisplayRefresh()
		}
	}

	deinit
	{
	}
}
