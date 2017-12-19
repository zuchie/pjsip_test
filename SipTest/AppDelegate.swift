//
//  AppDelegate.swift
//  SipTest
//
//  Created by Zhe Cui on 12/17/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        var status: pj_status_t
        
        status = pjsua_create()
        
        if status != PJ_SUCCESS.rawValue {
            print("Error creating pjsua, status: \(status)")
            return false
        }
        
        var pjsuaConfig = pjsua_config()
        var pjsuaMediaConfig = pjsua_media_config()
        var pjsuaLoggingConfig = pjsua_logging_config()
        
        pjsua_config_default(&pjsuaConfig)
        
        pjsuaConfig.cb.on_incoming_call = onIncomingCall
        pjsuaConfig.cb.on_call_media_state = onCallMediaState
        pjsuaConfig.cb.on_call_state = onCallState
        pjsuaConfig.cb.on_reg_state = onRegState
        
        pjsua_media_config_default(&pjsuaMediaConfig)
        pjsuaMediaConfig.clock_rate = 16000
        pjsuaMediaConfig.snd_clock_rate = 16000
        pjsuaMediaConfig.ec_tail_len = 0
        
        pjsua_logging_config_default(&pjsuaLoggingConfig)
        pjsuaLoggingConfig.msg_logging = pj_bool_t(PJ_TRUE.rawValue)
        pjsuaLoggingConfig.console_level = 4
        pjsuaLoggingConfig.level = 5
        
        status = pjsua_init(&pjsuaConfig, &pjsuaLoggingConfig, &pjsuaMediaConfig)
        
        if status != PJ_SUCCESS.rawValue {
            print("Error initializing pjsua, status: \(status)")
            
            return false
        }
        
        var pjsuaTransportConfig = pjsua_transport_config()
        
        pjsua_transport_config_default(&pjsuaTransportConfig)
        
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &pjsuaTransportConfig, nil)
        if status != PJ_SUCCESS.rawValue {
            print("Error creating UDP transport, status: \(status)")
            return false
        }

        //let transportID: pjsua_transport_id = -1

        pjsuaTransportConfig.port = 5061
        status = pjsua_transport_create(PJSIP_TRANSPORT_TLS, &pjsuaTransportConfig, nil)
        
        if status != PJ_SUCCESS.rawValue {
            print("Error creating TLS transport, status: \(status)")
            return false
        }

        status = pjsua_start()
        if status != PJ_SUCCESS.rawValue {
            print("Error starting pjsua, status: \(status)")
            return false
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

