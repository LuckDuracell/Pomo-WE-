//
//  ContentView.swift
//  Pomo
//
//  Created by Luke Drushell on 1/29/23.
//

import SwiftUI
import WidgetKit
import ActivityKit
import IntentsUI
import Intents

struct ContentView: View {
    
    @State var timeRemaining = "25:00"
    @State var timerActive = false
    @State var timerEndInterval: TimeInterval = 0
    
    @State var endDate = Date()
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //current pomo, current break
    @State var currentPomos = (1, 0)
    @State var nextStep = false
    
    @State var device = (width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    
    @State var activityID: String = ""
    
    
    func startLiveActivity() {
        let pomoAttributes = PomoWidgetAttributes()
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
    
    func removeActivity() {
        if let activity = Activity.activities.first(where: { (activity: Activity<PomoWidgetAttributes>) in
            activity.id == activityID
        }){
            Task {
                await activity.end(using: activity.content.state, dismissalPolicy: .immediate)
            }
        }
    }
    
    func updateTimer() {
        if timerActive {
            let difference = endDate.timeIntervalSince1970 - Date().timeIntervalSince1970
            if difference <= 0 {
                timerActive = false
                timeRemaining = "0:00"
                if currentPomos.1 == 4 {
                    currentPomos = (1, 0)
                } else {
                    if currentPomos.1 == currentPomos.0 { currentPomos.0 += 1 } else { currentPomos.1 += 1 }
                }
                nextStep = true
                return
            }
            let timeDifference = Date(timeIntervalSince1970: difference)
            let minutes = Calendar.current.component(.minute, from: timeDifference)
            let seconds = Calendar.current.component(.second, from: timeDifference)
            timeRemaining = String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    
    func startNextTimer() {
        if currentPomos.1 == 4 {
            endDate = Date()
            timerActive = true
            endDate = Calendar.current.date(byAdding: .minute, value: 25, to: endDate)!
        } else {
            if startingBreak(currentPomos) {
                endDate = Date()
                timerActive = true
                endDate = Calendar.current.date(byAdding: .minute, value: 5, to: endDate)!
            } else {
                endDate = Date()
                timerActive = true
                endDate = Calendar.current.date(byAdding: .minute, value: 25, to: endDate)!
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            removeActivity()
            startLiveActivity()
        })
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("pomoRed")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Spacer()
                    Text(timeRemaining)
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: device.width * 0.5)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.white, lineWidth: 4)
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                        )
                    Spacer()
                    Spacer()
                    VStack(spacing: 15) {
                        Button {
                            //code to start timer
                            startNextTimer()
                        } label: {
                            Text("Start Timer")
                                .foregroundColor(timerActive ? Color(uiColor: .lightText) : .white)
                                .font(.system(size: 200, weight: .bold, design: .default))
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                        } .disabled(timerActive ? true : false)
                        Button {
                            timerActive = false
                            timeRemaining = "25:00"
                            currentPomos = (1, 0)
                            removeActivity()
                        } label: {
                            Text("Reset Timer")
                                .foregroundColor(.white)
                                .font(.system(size: 200, weight: .bold, design: .default))
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                        }
                    } .frame(width: UIScreen.main.bounds.width * 0.5)
                    Spacer()
                    Spacer()
                    VStack(spacing: 15) {
                        Text(timerActive ? (startingBreak(currentPomos) ? "On Break" : "Working") : "Not Active")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(5)
                            .background(RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 4))
                            .animation(.spring(), value: startingBreak(currentPomos))
                            .animation(.spring(), value: timerActive)
                        HStack {
                            ForEach(1...4, id: \.self, content: { i in
                                Image(currentPomos.0 >= i ? "pomo.fill" : "pomo")
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .center)
                            })
                        } .foregroundColor(.white)
                    }
                    Spacer()
                }
            } .alert(isPresented: $nextStep) {
                Alert(title: Text("Timer Complete!"), message: Text("Would you like to begin your next \(startingBreak(currentPomos) ? "break" : "focus") session?"), primaryButton: .default(Text("Begin \(startingBreak(currentPomos) ? "Break" : "Focus")"), action: {
                    startNextTimer()
                }), secondaryButton: .cancel(Text("No Thanks")))
            }
        } .onReceive(timer) { _ in
            updateTimer()
        }
        .colorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func startingBreak(_ currentPomos: (Int, Int)) -> Bool {
    if currentPomos.0 == currentPomos.1 { return true }
    return false
}
