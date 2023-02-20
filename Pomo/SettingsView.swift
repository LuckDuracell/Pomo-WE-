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
                .frame(width: UIScreen.main.bounds.width * 0.92, height: 65, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
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
                .frame(width: UIScreen.main.bounds.width * 0.92, height: 65, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                Link(destination: URL(string: UIApplication.openSettingsURLString)!, label: {
                    Label(title: {Text("Open Permissions")}, icon: {
                        Image(systemName: "hexagon.fill")
                            .rotationEffect(Angle(degrees: 30))
                    }) .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.92, height: 65, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                })
                Divider()
                NavigationLink(destination: {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text("\n   One day I found myself with a rapidly approaching deadline for a 10 Page Paper. I thought to myself, I should use the Pomodoro Technique so that I can focus better.\n")
                            Text("   When I installed a popular Pomodoro app, I found that the one feature I expected was not missing. That being the timer on my lockscreen.\n")
                            Text("   And so, I got straight to work and had a working version by the end of my weekend. A couple more weeks of refining and smoothing bugs out, and boom... Tomo is born!")
                        }
                    } .padding()
                        .font(.title2.bold())
                }, label: {
                    HStack {
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(Color("pomoRed"))
                        Text("Our Story")
                            .foregroundColor(Color("pomoRed"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    } .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.92, height: 65, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                })
                Button {
                    requestReview()
                } label: {
                    Label(title: {Text("Review App")}, icon: {Image(systemName: "star.fill")}) .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.92, height: 65, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
            }
        } .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(liveActivities: .constant(true), timerActive: .constant(true), activityID: .constant("0"), endDate: .constant(Date()), notifications: .constant(true))
    }
}

