//
//  AppDelegate.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/22.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    private var locationManager:CLLocationManager!
    var currentUserID: String!
    var location: CLLocation {
        return locationManager.location
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        MAMapServices.sharedServices().apiKey = AppConfig.AMApiKey
        initLocationManager()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        NSLog("后台运行")
        setLocationBackground()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        setLocationForeground()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Mark: －定位服务
    private func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = AppConfig.LocationDistanceFilter
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    private func setLocationForeground() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setLocationBackground() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        postLocation(newLocation.coordinate)
    }
    
    private func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            postLocation(location.coordinate)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if error.code == CLError.Denied.rawValue {
            NSLog("位置访问拒绝")
        } else if error.code == CLError.LocationUnknown.rawValue {
            NSLog("无法获取地理位置信息")
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func postLocation(coordinate: CLLocationCoordinate2D) {
        let url = "http://ritacc.net/API/HL.ashx"
        let parameters = [
            "action": "sl",
            "q0": currentUserID,
            "q1": "\(coordinate.longitude)",
            "q2": "\(coordinate.latitude)"
        ]
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON {
                (req, res, data, error) in
                if error != nil {
                    NSLog("上传坐标网络错误")
                } else {
                    let json = JSON(data!)
                    if !json.isEmpty {
                        if json["Status"].boolValue {
                            NSLog("上传坐标正常")
                        } else {
                            NSLog(json["ReturnMsg"].string!)
                        }
                    }
                }
        }
    }

}

