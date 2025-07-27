//
//  SwordRPCTests.swift
//  SwordRPC
//
//  Created by sjalkote on 7/27/25.
//

import Testing
import Foundation
@testable import SwordRPC

@Suite("SwordRPCTests") struct SwordRPCTests {
    let rpc: SwordRPC = SwordRPC(appId: "1396688551273566208")

    init() {
        switch rpc.connect() {
        case .success:
            print("[Test] RPC started successfully")
        case .failure(let failure):
            print("[Test] RPC failed to start, is Discord running? \(failure)")
        }
    }

    @Test("does rich presence appear in discord") func doesRPCAppear() {
        var presence = RichPresence()
        presence.type = .playing
        presence.state = "Test (state)"
        presence.details = "Test (details)"
        presence.assets.largeImage = "xcode"
        presence.assets.largeText = "Xcode"
        presence.assets.smallImage = "swift"
        presence.assets.smallText = "Swift"
        presence.timestamps.start = Date()
        presence.timestamps.end = Date().advanced(by: 60)
        // discord is kinda goofy and doesn't let you see buttons on your own profile :(
        presence.buttons = [
            RichPresence.Button(label: "Test 1", url: "xcode://"),
            RichPresence.Button(label: "Test 2", url: "https://swift.org")
        ]
        rpc.setPresence(presence)
        // check discord during this time, once the test is done the presence will be cleared.
        Thread.sleep(forTimeInterval: 15)
    }
    
    // TODO: need to work on this
    @Test("does rich presence show playing/listening time bar") func doesRPCShowTimeBar() {
        var presence = RichPresence()
        presence.type = .streaming
        presence.state = "Test (state)"
        presence.details = "Test (details)"
        presence.assets.largeImage = "xcode"
        presence.assets.largeText = "Xcode"
        presence.assets.smallImage = "swift"
        presence.assets.smallText = "Swift"
        presence.timestamps.start = Date()
        presence.timestamps.end = Date().advanced(by: 60)
        // discord is kinda goofy and doesn't let you see buttons on your own profile :(
        presence.buttons = [
            RichPresence.Button(label: "Test 1", url: "xcode://"),
            RichPresence.Button(label: "Test 2", url: "https://swift.org")
        ]
        rpc.setPresence(presence)
        // check discord during this time, once the test is done the presence will be cleared.
        Thread.sleep(forTimeInterval: 15)
    }
}
