//
//  MapViewController.swift
//  YunweitongIOS
//
//  Created by 品佳 万 on 15/6/22.
//  Copyright (c) 2015年 润图城. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, MAMapViewDelegate {
    @IBOutlet weak var mapView: MAMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initMapView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: － 地图服务
    
    // 位置更新接口
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        
    }
    
    func initMapView() {
        self.mapView.setUserTrackingMode(MAUserTrackingMode.Follow, animated: true)
        self.mapView.showsCompass = false
        self.mapView.showsScale = true
    }
    
    func activateMapView() {
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = MAUserTrackingMode.Follow
        self.mapView.delegate = self
        
        self.mapView.setZoomLevel(16, animated: true)
    }
    
    func unactivateMapView(){
        self.mapView.showsUserLocation = false
        self.mapView.userTrackingMode = MAUserTrackingMode.None
        self.mapView.delegate = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        activateMapView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unactivateMapView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
