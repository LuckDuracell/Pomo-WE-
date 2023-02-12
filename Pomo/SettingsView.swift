//
//  SettingsView.swift
//  Pomo
//
//  Created by Luke Drushell on 2/11/23.
//

import SwiftUI
import ActivityKit
import StoreKit

struct SettingsView: View {
    
    @Binding var liveActivities: Bool
    @Binding var timerActive: Bool
    @Binding var activityID: String
    @Binding var endDate: Date
    
    @Binding var notifications: Bool
    
    @Environment(\.requestReview) var requestReview
    
    func startLiveActivity() {
        let activityEntitlements = ActivityAuthorizationInfo()
        let pomoAttributes = PomoWidgetAttributes()
        if activityEntitlements.areActivitiesEnabled && liveActivities {
            let initalContentState = PomoWidgetAttributes.ContentState(endDate: endDate)
            let staleDate = Calendar.current.date(byAdding: .minute, value: 30, to: endDate)!
            let activityContent = ActivityContent(state: initalContentState, staleDate: staleDate)
            do {
                let activity = try Activity<PomoWidgetAttributes>.request(attributes: pomoAttributes, content: activityContent)
                print("Activity Added Successfully. ID: \(activity.id)")
                activityID = activity.id
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                Toggle(isOn: $liveActivities, label: {
                    Label(title: { Text("Show Live Activities") }, icon: { Image(systemName: "bolt.fill") })
                        .foregroundColor(Color("pomoRed"))
                })
                .tint(Color("pomoRed"))
                .onChange(of: liveActivities) { newActivity in
                    UserDefaults.standard.set(newActivity, forKey: "liveActivities")
                    if timerActive {
                        if newActivity {
                            //start a live activity
                            startLiveActivity()
                        } else {
                            //clear the current live activity
                            removeLiveActivity(activityID)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.top)
                Toggle(isOn: $notifications, label: {
                    Label(title: { Text("Show Notifications") }, icon: { Image(systemName: "bell.badge.fill") })
                        .foregroundColor(Color("pomoRed"))
                })
                .tint(Color("pomoRed"))
                .onChange(of: notifications) { notification in
                    UserDefaults.standard.set(notification, forKey: "notifications")
                    if timerActive {
                        if notification {
                            //schedule a notification
                            scheduleNotification(endDate)
                        } else {
                            //clear notifications
                            clearNotifications()
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
                Divider()
                Button {
                    requestReview()
                } label: {
                    Label(title: {Text("Review App")}, icon: {Image(systemName: "star.fill")})
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
            }
        } .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(liveActivities: .constant(true), timerActive: .constant(true), activityID: .constant("0"), endDate: .constant(Date()), notifications: .constant(true))
    }
}

