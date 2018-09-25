//
//  MessageController.swift
//  BulletinBoardCK
//
//  Created by John Tate on 9/24/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation
import CloudKit
import UserNotifications

class MessageController {
    
    // shared instance or singleton
    static let shared = MessageController()
    
    // create notification
    let messagesWereUpdatedNotification = Notification.Name("MessagesWereUpdated")
    
    // source of truth
    var messages: [Message] = [] {
        didSet {
            NotificationCenter.default.post(name: messagesWereUpdatedNotification, object: nil)
        }
    }
    
    // CRUD functions
    func createMessage(text: String) {
        let message = Message(text: text)
        saveMessageToCloudKit(message)
    }
    
    func saveMessageToCloudKit(_ message: Message) {
        let record = message.cloudKitRecord
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \\(error.localizedDescription)")
                return
            }
            if let record = record {
                guard let message = Message(ckRecord: record) else { return }
                // by adding the message to the SOT here, it guarantees that it has been saved to CloudKit successfully
                self.messages.append(message)
            }
        }
    }
    
    func fetchAllMessageRecordsFromCloudKit() {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Message.TypeKey, predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \(error.localizedDescription)")
                return
            }
            guard let records = records else { return }
            let messages = records.compactMap{ Message(ckRecord: $0)}
            self.messages = messages
        }
    }
    
    func subscribeToRecord(completionHandler: @escaping (CKSubscription?, Error?) -> Void) {
        
        // YES give me everything
        let predicate = NSPredicate(value: true)
        // what object you would like to subscribe to and when you would like to see the subscriptions fire while using the app
        let subscription = CKQuerySubscription.init(recordType: Message.TypeKey, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        // this is an instance to define what the user will see
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertActionLocalizationKey = "Bulletin Board Update"
        notificationInfo.alertBody = "There has been a new event posted"
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        
        // set your subscriptio info to your custom info
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().publicCloudDatabase.save(subscription) { (subscription, error) in
            
            if let error = error {
                print("error subscribing to notification \(error) \(error.localizedDescription)")
                completionHandler(nil, error); return
            }
            
            // don't want the app to continue if there is an error for the subscription
            guard let subscription = subscription else { completionHandler(nil, error!); return }
            print(subscription.subscriptionID)
            completionHandler(subscription, nil)
            
            
            
        }
    }
}

