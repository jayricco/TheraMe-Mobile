//
//  ViewController.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/7/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {


    @IBOutlet weak var visualeffectview: UIVisualEffectView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: LoginButton!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonPressed(_ sender: Any, forEvent event: UIEvent) {
        self.setEditing(false, animated: true)

        
        let auth_token = "Basic " + NSData(data: (emailField.text! + ":" + passwordField.text!).data(using: String.Encoding.utf8)!).base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        sessionConfig?.httpAdditionalHeaders = ["Authorization": auth_token]
        
        let protectionSpace = URLProtectionSpace(host: "localhost", port: 8443, protocol: "https", realm: "TheraMe", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
        
        let credential = URLCredential(user: emailField.text!, password: passwordField.text!, persistence: .forSession)
        
        URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
        
        let urlSession = URLSession(configuration: sessionConfig!)
        let request = URLRequest(url: URL(string: SharedObjectManager.shared.mainURL + "/api/checkauth")!)
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
            if !(jsonDict!.isEmpty) {
                loginSuccess = true
                self.authSuccessful(json: jsonDict!, auth_token: auth_token)
            }
            
        }
        task.resume()

        dispatchGroup.notify(queue: DispatchQueue.main) {
            if loginSuccess {
                print("Login success!")
                self.loginButton.animate(duration: 1){
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "WelcomeView")
                    vc.transitioningDelegate = self

                    self.present(vc, animated: true, completion: nil)
                }
                
                
            } else {
                print("Invalid Login")
            }
        }
    }
    func doSegueToHome(sender: Any?) {
        print("GONNA PERFORM SEGUE")

        performSegue(withIdentifier: "ViewSegue", sender: self)

    }
    func authSuccessful(json: [String: Any], auth_token: String) {
        SharedObjectManager.shared.principalUser = User(json: json)
        SharedObjectManager.shared.auth_key = auth_token
        DispatchQueue.main.async {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.httpAdditionalHeaders = ["Authorization": SharedObjectManager.shared.auth_key!]
            
            let urlSession = URLSession(configuration: sessionConfig)
            let request = URLRequest(url: URL(string: SharedObjectManager.shared.mainURL + "/api/assignments")!, cachePolicy: URLRequest.CachePolicy.reloadRevalidatingCacheData, timeoutInterval: 36000)
            
            let task = urlSession.dataTask(with: request) { (data, response, error) in
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: [.mutableContainers]) else {
                    return
                }
                let jsonAssignmentDict = json as! [[String : Any]]
                
                let assignmentArr = jsonAssignmentDict.map({ (assignmentJson) -> Assignment in
                    return Assignment(json: assignmentJson)
                })
                SharedObjectManager.shared.assignments = assignmentArr
                SharedObjectManager.shared.fin_unfin_count = (0, assignmentArr.count)
                print("ASSIGNMENT ARRAY SET TO: \(assignmentArr)")
                self.dispatchGroup.leave()
            }
            task.resume()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.subviews.forEach { (uiview) in

            uiview.layer.removeFromSuperlayer()
        }
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInAnimator(transitionDuration: 0.5, startingAlpha: 0.8)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
extension Timer {
    class func schedule(_ delay: TimeInterval,  handler: @escaping (CFRunLoopTimer?) -> Void) -> Timer {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)!
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        return timer
    }
    
    class func schedule(repeatInterval interval: TimeInterval, handler: @escaping (CFRunLoopTimer?) -> Void) -> Timer {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)!
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        return timer
    }
    
}
extension CGRect {
    var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self = CGRect(x: newValue, y: self.minY, width: self.width, height: self.height)
        }
    }
    
    var y: CGFloat {
        get {
            return self.origin.y
        }
        set {
            self = CGRect(x: self.x, y: newValue, width: self.size.width, height: self.size.height)
        }
    }
    
    var width: CGFloat {
        get {
            return self.size.width
        }
        set {
            self = CGRect(x: self.x, y: self.width, width: newValue, height: self.height)
        }
    }
    
    var height: CGFloat {
        get {
            return self.size.height
        }
        set {
            self = CGRect(x: self.x, y: self.minY, width: self.width, height: newValue)
        }
    }
    
    var top: CGFloat {
        get {
            return self.origin.y
        }
        set {
            y = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.origin.y + self.size.height
        }
        set {
            self = CGRect(x: self.x, y: newValue - self.height, width: self.width, height: self.height)
        }
    }
    var center: CGPoint {
        get{
            return CGPoint(x: self.midX, y: self.midY)
        }
        set {
            self = CGRect(x: newValue.x - width / 2, y: newValue.y - height / 2, width: width, height: height)
        }
    }
}
