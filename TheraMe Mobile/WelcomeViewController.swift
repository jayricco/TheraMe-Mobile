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
    @IBOutlet weak var hasAssignmentsView: UIView!
    @IBOutlet weak var hasNoAssignmentsView: UIView!
    
    @IBOutlet weak var noAssignWelcome: UILabel!
    
    @IBOutlet weak var assignWelcome: UILabel!
    @IBOutlet weak var assignOutline: UILabel!
    
    override func viewDidLoad() {
        hasAssignmentsView.center = view.center
        hasNoAssignmentsView.center = view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let bg = UIImageView(image: #imageLiteral(resourceName: "background_login"))
        bg.frame = self.view.frame
        self.view.addSubview(bg)
        self.view.sendSubview(toBack: bg)
    
        let count = SharedObjectManager.shared.fin_unfin_count.1
        if  count > 0 {
            print("YOU HAVE ASSIGNMENTS")
            let userName = SharedObjectManager.shared.principalUser!.firstName
            view.addSubview(hasAssignmentsView)
            assignWelcome.text! = "Welcome, \(userName)!"
            assignOutline.text! = "You have \(count) exercises left to complete!"
            //startButton.isHidden = false
        } else if count == 0 {
            print("YOU HAVE NO ASSIGNMENTS")
            let userName = SharedObjectManager.shared.principalUser!.firstName
            view.addSubview(hasNoAssignmentsView)
            noAssignWelcome.text! = "Welcome, \(userName)!"
            
        } else {
            print("ERROR")
        }
    }
    
    @IBAction func startButtonPress(_ sender: UIButton) {
        performSegue(withIdentifier: "ViewSegue", sender: self)
    }
    
    @IBAction func noExercisesPress(_ sender: UIButton) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
        present(vc, animated: true) {
            SharedObjectManager.shared.reset()
        }
    }
}

