//
//  ViewController.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/7/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var visualeffectview: UIVisualEffectView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var sharedObjectManager = SharedObjectManager.shared
    var dispatchGroup: DispatchGroup = DispatchGroup()
    var sessionConfig: URLSessionConfiguration?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let bg = UIImageView(image: #imageLiteral(resourceName: "background_login"))
        bg.frame = self.view.frame
        self.view.addSubview(bg)
        self.view.sendSubview(toBack: bg)
        visualeffectview.frame = self.view.frame

        sessionConfig = URLSessionConfiguration.default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonPressed(_ sender: Any, forEvent event: UIEvent) {
        self.setEditing(false, animated: true)
        let auth_token = "Basic " + NSData(data: (emailField.text! + ":" + passwordField.text!).data(using: String.Encoding.utf8)!).base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        sessionConfig?.httpAdditionalHeaders = ["Authorization": auth_token]
        
        let urlSession = URLSession(configuration: sessionConfig!)
        let request = URLRequest(url: URL(string: "https://localhost:8443/api/checkauth")!)
        var loginSuccess = false
        dispatchGroup.enter()
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                print()
                self.dispatchGroup.leave()
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: [.allowFragments, .mutableLeaves]) else {
                print("ERROR")
                self.dispatchGroup.leave()
                return
            }
            let jsonDict = json as? [String: Any]
            loginSuccess = true
            self.authSuccessful(json: jsonDict!, auth_token: auth_token)
        }
        task.resume()

        dispatchGroup.notify(queue: DispatchQueue.main) {
            if loginSuccess {
                print("Login success!")
                
                self.view.addSubview(UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray))
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "WelcomeView")
                self.present(vc, animated: false, completion: {
                    print("done")
                    
                })
                
            } else {
                print("BAD LOGIN")
            }
        }
    }
    func doSegueToHome(sender: Any?) {
        print("GONNA PERFORM SEGUE")

        performSegue(withIdentifier: "ViewSegue", sender: self)

    }
    func authSuccessful(json: [String: Any], auth_token: String) {
        sharedObjectManager.auth_key = auth_token
        DispatchQueue.main.async {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.httpAdditionalHeaders = ["Authorization": SharedObjectManager.shared.auth_key!]
            
            let urlSession = URLSession(configuration: sessionConfig)
            let request = URLRequest(url: URL(string: "https://localhost:8443/api/assignments")!, cachePolicy: URLRequest.CachePolicy.reloadRevalidatingCacheData, timeoutInterval: 36000)
            
            let task = urlSession.dataTask(with: request) { (data, response, error) in
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: [.mutableContainers]) else {
                    return
                }
                let jsonAssignmentDict = json as! [[String : Any]]
                
                let assignmentArr = jsonAssignmentDict.map({ (assignmentJson) -> Assignment in
                    return Assignment(json: assignmentJson)
                })
                SharedObjectManager.shared.assignments = assignmentArr
                print("ASSIGNMENT ARRAY SET TO: \(assignmentArr)")
                self.dispatchGroup.leave()
            }
            task.resume()
        }
    }
    
}

