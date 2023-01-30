//
//  PomoWidgetLiveActivity.swift
//  PomoWidget
//
//  Created by Luke Drushell on 1/29/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PomoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomoWidgetAttributes.self) { context in
            LiveWidgetView(context: context)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("")
                    // more content
                }
            } compactLeading: {
                Text("")
            } compactTrailing: {
                Text("")
            } minimal: {
                Text("")
            }
        }
    }
}

struct PomoWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = PomoWidgetAttributes()
    static let contentState = PomoWidgetAttributes.ContentState(endDate: Date())

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}

struct LiveWidgetView: View {
    
    let context: ActivityViewContext<PomoWidgetAttributes>
    
    var body: some View {
        HStack {
            Text(timerInterval: Date()...context.state.endDate)
                .font(.system(size: 45, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 6)
            Spacer()
            Text("Pomo")
                .font(.title.bold())
                .foregroundColor(.white)
            Image("pomo.fill")
                .resizable()
                .frame(width: 35, height: 35, alignment: .center)
                .scaledToFit()
                .foregroundColor(.green)
        } .padding(.horizontal)
        .activityBackgroundTint(Color("pomoRed").opacity(0.6))
        .activitySystemActionForegroundColor(.white)
    }
}
