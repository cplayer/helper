//
//  ViewController.swift
//  helper
//
//  Created by JTDX on 2018/3/27.
//  Copyright © 2018年 JTDX. All rights reserved.
//

import UIKit

import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.
        gpsTest();
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
    var mapView : MKMapView?;
    let locationManager : CLLocationManager = CLLocationManager();
    
    func gpsTest () {
        self.title = "我的位置";
        mapView = MKMapView.init();
        self.view.addSubview(mapView!);
        mapView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
        // ?
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyBest;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        mapView?.delegate = self;
        mapView?.showsUserLocation = true;
        mapView?.userTrackingMode = .follow;
        
        setupData();
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay);
            polylineRenderer.strokeColor = UIColor.black;
            polylineRenderer.lineWidth = 4.0;
            return polylineRenderer;
        } else if (overlay is MKCircle) {
            let circleRenderer = MKCircleRenderer(overlay: overlay);
            circleRenderer.strokeColor = UIColor.red;
            circleRenderer.lineWidth = 1.0;
            return circleRenderer;
        }
        return MKOverlayRenderer();
    }
    
    func setupData () {
        if (CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)) {
            let title = "test Data Point";
            let coordinate = CLLocationCoordinate2DMake(31.18467660, 121.45164569);
            let coordinateArray : Array<CLLocationCoordinate2D> = [
                CLLocationCoordinate2DMake(31.18457670, 121.45104579),
                CLLocationCoordinate2DMake(31.18477650, 121.45124569)
            ];
            let polyLine = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count);
            self.mapView?.addOverlays([polyLine]);
            let regionRadius = 300.0;
            let restaurantAnnotation = MKPointAnnotation();
            restaurantAnnotation.coordinate = coordinate;
            restaurantAnnotation.title = "\(title)";
            self.mapView?.addAnnotation(restaurantAnnotation);
            let circle = MKCircle(center: coordinate, radius: regionRadius);
            self.mapView?.add(circle);
            self.mapView?.showAnnotations([restaurantAnnotation], animated: true);
        } else {
            print("Can not track region");
        }
        
        // 增加获取经纬度代码
        locationManager.requestWhenInUseAuthorization();
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.startUpdatingLocation();
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation : CLLocation!;
        currLocation = locations.last! as CLLocation;
        // 解码具体地址待测试
        // self.reverseGeoCode(sender: currLocation, currentLocation: currLocation);
        print("经度=\(currLocation.coordinate.longitude)");
        print("纬度=\(currLocation.coordinate.latitude)");
    }
    
    func reverseGeoCode(sender: AnyObject, currentLocation: CLLocation) {
        let geocoder = CLGeocoder();
        var point : CLPlacemark?;
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            (placemarks, error) -> Void in
            if (error != nil) {
                print("ReverseGeoCode Failed!");
                return;
            }
            let pm = placemarks! as [CLPlacemark];
            if (pm.count > 0) {
                point = placemarks![0];
                guard point != nil
                    else {
                        print("Placemark is Empty!");
                        return;
                }
                let arrayForProvince : [String] = (point!.name?.components(separatedBy: ("省")))!;
                let city : String = arrayForProvince.last!;
                let arrayForCity : [String] = (city.components(separatedBy: ("市")));
                self.title = arrayForCity.first!;
            } else {
                print("No placemarks!");
            }
        }
        )
    }
    
    struct infos : Codable {
        let id: Int;
        let Title: String;
        let Author: String;
    };

    func doGetJson () {
        // var request : URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:8080/getInfos")!);
        // request.httpMethod = "GET";
        // let task = URLSession.shared.dataTask(with: request, completionHandler: {
        //     (data, response, error) in
        //     guard let data = data, error == nil else {                                                 // check for fundamental networking error
        //         print("error=\(error!)")
        //         return
        //     }
        //     let httpStatus = response as? HTTPURLResponse;
        //     if (httpStatus?.statusCode != 200) {
        //         print("Error with code \(httpStatus!.statusCode)");
        //     }

        //     let responseString = String(data: data, encoding: .utf8)!;
        //     print(responseString);
        //     let decoder = JSONDecoder();
        //     let info = try! decoder.decode([infos].self, from: data);
        //     print(info);
        //     for element in info {
        //         print(element);
        //     }
        // });
        // task.resume();
        
        let url = URL(string: "http://127.0.0.1:8080/getInfosById")!;
        var request = URLRequest(url: url);
        request.httpMethod = "POST";
        var data = Dictionary<String, Int>();
        data["id"] = 1;
        var dataBody : String = "";
        for (key, value) in data {
            dataBody += "\(key)=\(value)&";
        }
        request.httpBody = dataBody.data(using: .utf8);
        let task_post = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Error with code \(httpStatus.statusCode)");
            }
            print(data);
            let responseString = String(data: data, encoding: .utf8)!;
            print(responseString);
        });
        task_post.resume();
        
    }
    

}

