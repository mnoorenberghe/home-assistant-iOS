//
//  PushNotification.swift
//  HomeAssistant
//
//  Created by Robert Trencheny on 1/10/17.
//  Copyright © 2017 Robbie Trencheny. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class PushNotification: Object, Mappable {
    dynamic var requestID: String = ""
    dynamic var title: String = ""
    dynamic var subtitle: String = ""
    dynamic var body: String = ""
    dynamic var badge: Int = 0
    dynamic var sound: String = ""
    dynamic var userInfo: [String:Any] {
        get {
            guard let dictionaryData = userData else {
                return [String: Any]()
            }
            do {
                let dict = try JSONSerialization.jsonObject(with: dictionaryData, options: []) as? [String: Any]
                return dict!
            } catch {
                return [String: Any]()
            }
        }

        set {
            do {
                let data = try JSONSerialization.data(withJSONObject: newValue, options: [])
                userData = data
            } catch {
                userData = nil
            }
        }
    }
    fileprivate dynamic var userData: Data?

    func mapping(map: Map) {
        requestID         <- map["request_id"]
        title             <- map["title"]
        subtitle          <- map["subtitle"]
        body              <- map["body"]
        badge             <- map["badge"]
        sound             <- map["sound"]
        userInfo          <- map["userInfo"]
    }

    override static func primaryKey() -> String? {
        return "requestID"
    }

    override class func ignoredProperties() -> [String] {
        return ["userInfo"]
    }
}
