//
//  SearchableRecord.swift
//  BulletinBoardCK
//
//  Created by John Tate on 9/25/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
