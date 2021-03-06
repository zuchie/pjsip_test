//
//  ViewController.swift
//  SipTest
//
//  Created by Zhe Cui on 12/17/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var serverURITextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(tapToDismissKeyboard)))
        
        serverURITextField.text = "siptest.butterflymx.com"
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRegistrationStatus), name: SIPNotification.registrationState.notification, object: nil)        
    }
    
//    @objc func tapToDismissKeyboard() {
//        view.endEditing(true)
//    }
    
    @IBAction func tapLoginButton(_ sender: UIButton) {
        var accountID = pjsua_acc_id()
        var accountConfig = pjsua_acc_config()
        
        pjsua_acc_config_default(&accountConfig)
        
        let fullURL = ("sips:\(usernameTextField.text!)@\(serverURITextField.text!)" as NSString).utf8String
        let uri = ("sips:\(serverURITextField.text!)" as NSString).utf8String
        let realm = ("\(serverURITextField.text!)" as NSString).utf8String
        let username = ("\(usernameTextField.text!)" as NSString).utf8String
        //let password = ("\(passwordTextField.text!)" as NSString).utf8String
        
        var password: UnsafePointer<Int8>
        if usernameTextField.text! == "6728" {
            password = ("123456" as NSString).utf8String!
        } else if usernameTextField.text! == "panel_4" {
            password = ("123" as NSString).utf8String!
        } else {
            fatalError()
        }
        
        accountConfig.id = pj_str(UnsafeMutablePointer<Int8>(mutating: fullURL))
        accountConfig.reg_uri = pj_str(UnsafeMutablePointer<Int8>(mutating: uri))
        accountConfig.reg_retry_interval = 0
        accountConfig.cred_count = 1
        accountConfig.cred_info.0.realm = pj_str(UnsafeMutablePointer<Int8>(mutating: realm))
        accountConfig.cred_info.0.username = pj_str(UnsafeMutablePointer<Int8>(mutating: username))
        accountConfig.cred_info.0.data_type = Int32(PJSIP_CRED_DATA_PLAIN_PASSWD.rawValue)
        accountConfig.cred_info.0.data = pj_str(UnsafeMutablePointer<Int8>(mutating: password))
        
        let status: pj_status_t = pjsua_acc_add(&accountConfig, pj_bool_t(PJ_TRUE.rawValue), &accountID)
        
        if status != PJ_SUCCESS.rawValue {
            print("Register error, status: \(status)")
        }
    }
    
    @objc func handleRegistrationStatus(_ notification: Notification) {
        let accountID: pjsua_acc_id = notification.userInfo!["accountID"] as! pjsua_acc_id
        let status: pjsip_status_code = notification.userInfo!["status"] as! pjsip_status_code
        let statusText: String = notification.userInfo!["statusText"] as! String
        
        if status != PJSIP_SC_OK {
            print("Registration failed, status: \(status, statusText) ")
            
            return
        }
        
        UserDefaults.standard.set(accountID, forKey: "loginAccountID")
        UserDefaults.standard.set(self.serverURITextField.text, forKey: "serverURI")
        UserDefaults.standard.synchronize()
        
        performSegue(withIdentifier: "segueLoginToOutgoingCall", sender: self)
    }

}

