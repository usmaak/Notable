//
//  Note.swift
//  Notable
//
//  Created by Scott Kilbourn on 7/1/18.
//  Copyright © 2018 Scott Kilbourn. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var noteText: String = ""
    @objc dynamic var dateCreated: Date?
    @objc dynamic var dateLastUpdated: Date?
}
