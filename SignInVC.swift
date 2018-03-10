//
//  SignInVC.swift
//  astralite
//
//  Created by Mike Zhang Xunda on 8/3/18.
//  Copyright © 2018 Mike Zhang Xunda. All rights reserved.
//

import UIKit
import Parse

class SignInVC: UIViewController {

    // textfield
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    //Label
    @IBOutlet weak var appLbl: UILabel!
    
    // buttons
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    // keyboard frame size
    var keyboard = CGRect()
    var isKeyboardUp = false;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInBtn.layer.cornerRadius = 10
        usernameText.layer.cornerRadius = 10
        passwordText.layer.cornerRadius = 10
        
//        // Do any additional setup after loading the view.

//        // check notifications if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(SignInVC.showKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInVC.hideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//
//        // declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }

    @IBAction func signInBtn_click(_ sender: Any) {
        self.view.endEditing(true)
        
        if (usernameText?.text?.isEmpty)! || (passwordText?.text?.isEmpty)! {
            let alert = UIAlertController(title: "Error", message: "Please fill in all the fields", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        PFUser.logInWithUsername(inBackground: (usernameText?.text)!, password: (passwordText?.text)!) { (user, error) in
            if error == nil {
                //remember user or save in App memory did the user login
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // call login function from AppDelegate.Swift class
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }else{
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showKeyboard(_ notification: NSNotification) {
        self.view.frame.origin.y -= 50
        isKeyboardUp = true
    }
    
    @objc func hideKeyboard(_ notification: NSNotification) {
        self.view.frame.origin.y += 50
        isKeyboardUp = false
    }
    
    @objc func dismissKeyboard(_ recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
        if(isKeyboardUp){
            self.view.frame.origin.y += 50
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
