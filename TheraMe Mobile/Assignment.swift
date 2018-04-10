//
//  Assignment.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/8/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation

class Assignment {
    var id: String?
    var exercise: Exercise
    var dateAssigned: TimeInterval
    var order: Int
    var last_completed: String?
    var complete: Bool
    
    required init(exercise: Exercise, dateAssigned: TimeInterval, order: Int) {
        self.id = nil
        self.exercise = exercise
        self.dateAssigned = dateAssigned
        self.order = order
        self.last_completed = nil
        self.complete = false
    }
    
    init(id: String, exercise: Exercise, dateAssigned: TimeInterval, order: Int, last_completed: String?) {
        self.id = id
        self.exercise = exercise
        self.dateAssigned = dateAssigned
        self.order = order
        self.last_completed = last_completed
        self.complete = false
    }
}
extension Assignment {
    convenience init(json: [String: Any]) {

        self.init(id: json["id"] as! String,
                  exercise: Exercise(json: json["exercise"] as! [String: Any]),
                  dateAssigned: json["dateAssigned"] as! TimeInterval,
                  order: json["order"] as! Int,
                  last_completed: json["last_completed"] as? String)
    }
}
