//
//  User.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/16/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation

public enum UserType: String {
    case ADMIN = "ADMIN"
    case THERAPIST = "THERAPIST"
    case PATIENT = "PATIENT"
}
class User {
    var id: String?
    var email: String
    var firstName: String
    var lastName: String
    var type: UserType
    var therapist: User?
    
    required init(id: String?, email: String, firstName: String, lastName: String, type: UserType, therapist: User?) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.type = type
        self.therapist = therapist
    }

}
extension User {
    convenience init(json: [String: Any]?) {
        
        var thpst: User?
        if let pt = json!["therapist"] as? [String: Any] {
            thpst = User(json: pt)
        } else {
            thpst = nil
        }
        self.init(id: json!["id"] as? String,
                  email: json!["email"] as! String,
                  firstName: json!["firstName"] as! String,
                  lastName: json!["lastName"] as! String,
                  type: UserType(rawValue: json!["type"] as! String)!,
                  therapist: thpst)
                    
    }
    
}
