//
//  SideMenuController.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/7/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit

class SideMenuController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let assignments = SharedObjectManager.shared.assignments {
            return assignments.count
        } else {
            
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(tableView)
        print(indexPath)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if SharedObjectManager.shared.assignments![indexPath.item].state == .completed {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCellDone", for: indexPath) as! AssignmentCellDone
            let thisAssignment = SharedObjectManager.shared.assignments![indexPath.item]
            let thisExercise = thisAssignment.exercise
            let image = MediaHandler.sharedInstance.getExerciseThumbnail(exercise: thisExercise)
                cell.thumbnailView.image = image
                cell.runtimeLabel.text! = thisExercise.runTime
                cell.titleLabel.text! = thisExercise.title
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCellNotDone", for: indexPath) as! AssignmentCellNotDone
            let thisExercise = SharedObjectManager.shared.assignments![indexPath.item].exercise
            let image = MediaHandler.sharedInstance.getExerciseThumbnail(exercise: thisExercise)
            cell.thumbnailView.image = image
            cell.runtimeLabel.text! = thisExercise.runTime
            cell.titleLabel.text! = thisExercise.title
            return cell
        }
        
        
    }

}
