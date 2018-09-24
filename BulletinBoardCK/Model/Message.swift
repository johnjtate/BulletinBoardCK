//
//  Message.swift
//  BulletinBoardCK
//
//  Created by John Tate on 9/24/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation
import CloudKit

class Message{
    
    static let TypeKey = "Message"
    static let textKey = "Text"
    static let timeStampKey = "Timestamp"
    
    let text: String
    let timestamp: Date
    
    //MARK: - CloudKit
    var cloudKitRecord: CKRecord {
        
        let record = CKRecord(recordType: Message.TypeKey)
        
        // Two different ways of doing the exact same thing, setValue function and dictionary subscripting
        record.setValue(text, forKey: Message.textKey)
        record[Message.timeStampKey] = timestamp as CKRecordValue
        return record
    }
    
    init(text: String, timestamp: Date = Date()) {
        self.text = text
        self.timestamp = timestamp
    }
    
    convenience init?(ckRecord: CKRecord) {
        
        guard let text = ckRecord[Message.textKey] as? String, let timestamp = ckRecord[Message.timeStampKey] as? Date else { return nil }
        
        self.init(text: text, timestamp: timestamp)
    }
}

