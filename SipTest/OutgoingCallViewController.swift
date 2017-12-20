//
//  OutgoingCallViewController.swift
//  SipTest
//
//  Created by Zhe Cui on 12/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import AVFoundation

class OutgoingCallViewController: UIViewController {

    @IBOutlet weak var calleeTextField: UITextField!
    @IBOutlet weak var callButton: UIButton!
    
    var callID = pjsua_call_id()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleCallStatusChanged), name: SIPNotification.callState.notification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleIncomingCall), name: SIPNotification.incomingCall.notification, object: nil)
        
//        let status = pjsua_set_null_snd_dev()
//        if status != PJ_SUCCESS.rawValue {
//            print("Error set null sound dev, status: \(status)")
//            fatalError()
//        }

    }

    @objc func handleCallStatusChanged(_ notification: Notification) {
        let callID: pjsua_call_id = notification.userInfo!["callID"] as! pjsua_call_id
        let state: pjsip_inv_state = notification.userInfo!["state"] as! pjsip_inv_state
        
        if callID != self.callID {
            print("Incorrect Call ID.")
            return
        }
        
        if state == PJSIP_INV_STATE_DISCONNECTED {
            callButton.setTitle("Call", for: .normal)
        } else if state == PJSIP_INV_STATE_CONNECTING {
            print("Call connecting...")
        } else if state == PJSIP_INV_STATE_CONFIRMED {
            callButton.setTitle("Hangup", for: .normal)
        }
    }
    
    @IBAction func tapToCallOrHangup(_ sender: UIButton) {
        if sender.title(for: .normal) == "Call" {
            makeCall()
        } else if sender.title(for: .normal) == "Hangup" {
            hangup()
        } else {
            fatalError()
        }
    }
    
    private func makeCall() {
        let accountID: pjsua_acc_id = pjsua_acc_id(UserDefaults.standard.integer(forKey: "loginAccountID"))
        let serverURI: String = UserDefaults.standard.string(forKey: "serverURI")!
        
        let destinationURI = "sips:\(calleeTextField.text!)@\(serverURI)"
        
        var status = pj_status_t()
        var calleeURI: pj_str_t = pj_str(UnsafeMutablePointer<Int8>(mutating: (destinationURI as NSString).utf8String))
        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, mode: AVAudioSessionModeVoiceChat)
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print(error)
//            fatalError()
//        }
//
//        var captureDeviceID: Int32 = -1000
//        var playbackDeviceID: Int32 = -1000
//
//        status = pjsua_get_snd_dev(&captureDeviceID, &playbackDeviceID)
//        if status != PJ_SUCCESS.rawValue {
//            print("Error get sound dev IDs, status: \(status)")
//            fatalError()
//        }
//
//        status = pjsua_set_snd_dev(captureDeviceID, playbackDeviceID)
//        if status != PJ_SUCCESS.rawValue {
//            print("Error set sound dev, status: \(status)")
//            fatalError()
//        }

//        switch AVAudioSession.sharedInstance().recordPermission() {
//
//        case AVAudioSessionRecordPermission.granted:
//            print("Permission granted")
//        case AVAudioSessionRecordPermission.denied:
//            print("Pemission denied")
//        case AVAudioSessionRecordPermission.undetermined:
//            print("Request permission here")
//            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
//                // Handle granted
//            })
//        }
        
//        var pf = pj_pool_factory()
//
//        status = pjmedia_aud_subsys_init(&pf)
//        if status != PJ_SUCCESS.rawValue {
//            var errorMessage: [CChar] = []
//
//            pj_strerror(status, &errorMessage, pj_size_t(PJ_ERR_MSG_SIZE))
//            print("Audio subsystem error, status: \(status), message: \(errorMessage)")
//            fatalError()
//        }
//
//        var dev_count: UInt32 = 0
//        let dev_idx = pjmedia_aud_dev_index()
//        dev_count = pjmedia_aud_dev_count()
//        print("Got \(dev_count) audio devices")
//
//        for _ in 0..<dev_count {
//            var info = pjmedia_aud_dev_info()
//            status = pjmedia_aud_dev_get_info(dev_idx, &info)
//            print(dev_idx, info.name, info.input_count, info.output_count)
//        }
        
        //var callOptions = pjsua_call_setting()
        
        status = pjsua_call_make_call(accountID, &calleeURI, nil, nil, nil, &callID)
        
        if status != PJ_SUCCESS.rawValue {
            var errorMessage: [CChar] = []
            
            pj_strerror(status, &errorMessage, pj_size_t(PJ_ERR_MSG_SIZE))
            print("Outgoing call error, status: \(status), message: \(errorMessage)")
            fatalError()
        }
    }
    
    private func hangup() {
        let status = pjsua_call_hangup(callID, 0, nil, nil)
        
        if status != PJ_SUCCESS.rawValue {
            let statusText: UnsafePointer<pj_str_t> = pjsip_get_status_text(status)
            print("Hangup error, status: \(status), message: \(statusText.pointee)")
        }
    }

    @objc func handleIncomingCall(_ notification: Notification) {
        let callID: pjsua_call_id = notification.userInfo!["callID"] as! pjsua_call_id
        let phoneNumber: String = notification.userInfo!["remoteAddress"] as! String
        
        performSegue(withIdentifier: "segueOutgoingCallToIncomingCall", sender: (callID, phoneNumber))
    }
    
    // Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueOutgoingCallToIncomingCall" {
            let destinationVC = segue.destination as! IncomingCallViewController
            
            let param = sender as! (pjsua_call_id, String)
            destinationVC.setParam(param.0, param.1)
        }
    }
    
    @IBAction func unwindToOutgoingCall(segue: UIStoryboardSegue) {
    
    }
    
}
