//
//  LocalNotificationCenter.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 11/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import UserNotifications


class LocalNotificationCenter {
    
    static let shared = LocalNotificationCenter()
    
    private let center = UNUserNotificationCenter.current()
    private let notificationsIds = [
        "notificaiton_0",
        "notificaiton_1"
    ]
    private var notificationsIdIndex = 0
    
    func requestPermission() {
        center.requestAuthorization(options: [.alert]) { granted, error in
            if let error = error {
                print("\(Date.d) Notifications error \(error)")
            }
        }
    }
    
    func send(_ title: String, _ body: String, _ image: URL? = nil) {
        center.getNotificationSettings(completionHandler: { [weak self] settings in
            guard (settings.authorizationStatus == .authorized) ||
              (settings.authorizationStatus == .provisional) else { return }
            guard settings.alertSetting == .enabled else { return }
            self?.send(title: title, body: body, image: image)
        })
    }
    
    private func send(title: String, body: String, image: URL?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let url = image, let attachment = try? UNNotificationAttachment(identifier: "image", url: url) {
            content.attachments = [ attachment ]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let index = notificationsIdIndex % notificationsIds.count
        notificationsIdIndex += 1
        let id = notificationsIds[index]
        let request = UNNotificationRequest(identifier: id,
                                            content: content,
                                            trigger: trigger)

        center.add(request) { (error) in
           if let error = error {
                print("error \(error)")
           }
        }
    }
}
