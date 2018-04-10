//
//  WelcomeViewController.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/8/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit

class WelcomeViewController : UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var exerciseDeterminationLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var visualeffectview: UIVisualEffectView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let bg = UIImageView(image: #imageLiteral(resourceName: "background_login"))
        bg.frame = self.view.frame
        self.view.addSubview(bg)
        self.view.sendSubview(toBack: bg)
        visualeffectview.frame = self.view.frame
        let count = SharedObjectManager.shared.assignments!.count
        if  count > 0 {
            print("YOU HAVE ASSIGNMENTS")
            exerciseDeterminationLabel.text! = "You have \(count) exercises left to complete!"
            startButton.isHidden = false
        } else if count == 0 {
            print("YOU HAVE NO ASSIGNMENTS")
        } else {
            print("ERROR")
        }
    }
    
    
    @IBAction func startButtonPress(_ sender: UIButton) {
        performSegue(withIdentifier: "ViewSegue", sender: self)
    }
}
