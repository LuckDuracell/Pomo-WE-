//
//  PomoWidgetAttributes.swift
//  Pomo
//
//  Created by Luke Drushell on 1/29/23.
//

import SwiftUI
import ActivityKit
import WidgetKit

struct PomoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var endDate: Date
    }
}
