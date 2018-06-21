//
//  ViewController.swift
//  ParticleDataPull_Particle
//
//  Created by Tychicus C Jones on 1/11/18.
//  Copyright © 2018 Tychicus C Jones. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces


class ViewController: UIViewController {

    @IBOutlet weak var coorX: UILabel!
    @IBOutlet weak var coorY: UILabel!
    @IBOutlet weak var mapView1: UIView!
    @IBOutlet weak var loggedIn: UILabel!
    @IBOutlet weak var min: UILabel!
    @IBOutlet weak var max: UILabel!
    @IBOutlet weak var batUsage: UILabel!
    var myPhoton : ParticleDevice?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        min.isHidden = true
        max.isHidden = true
        mapView1.isHidden = true
        batUsage.isHidden = true
        let sender = 0
        
        // Do any additional setup after loading the view, typically from a nib.
        ParticleCloud.sharedInstance().login(withUser: "jstancil@jardum.com", password: "jardumengineer") { (error:Error?) -> Void in
            if let _ = error {
                print("Wrong credentials or no internet connectivity, please try again")
                self.loggedIn.text = "Not logged in! Failure!"
            }
            else {
                print("Logged in")
                self.Go(sender)
                self.callFunc(sender)
            }
        }
    }
    
    func callFunc(_ sender: Any) {
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
            }
            else {
                if let d = devices {
                    for device in d {
                        if device.name == "Jardum_E_Series" {
                            self.myPhoton = device
                            let funcArgs = ["transmit"] as [Any]
                            self.myPhoton?.callFunction("transmit", withArguments: funcArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
                                if (error == nil) {
                                    print("Success")
                                }
                            }
                            //var bytesToReceive : Int64 = task.countOfBytesExpectedToReceive
                            // ..do something with bytesToReceive
                        }
                        }
                    }
                }
            }
        }

    //withUser can be (uName?.text)! while password can be (pWord?.text)! for text field entering
    //These values can also be hard coded for one occurrence or account
    
     func Go(_ sender: Any) {
        let latText : CLLocationDegrees = 0 //35.269539
        let longText : CLLocationDegrees = 0 //-95.854713
        var latText2 = Double(latText)
        var longText2 = Double(longText)
        //Choose The Device
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
            }
            else {
                if let d = devices {
                    for device in d {
                        if device.name == "Jardum_E_Series" {
                            self.myPhoton = device
                            
            //Get Data Usage
                            self.myPhoton?.getCurrentDataUsage { ( dataUsed: Float, error :Error?) in
                                if (error == nil) {
                                    //let dataUsedS = String(dataUsed)
                                    print("Device has used "+String(dataUsed)+" MBs this month")
                                    self.batUsage.text = "Device has used "+String(dataUsed)+" MBs this month"
                                    //self.bVolt.text = String(dataUsed)
                                    
            //Get Latitude Variable and convert string to double
                                    self.myPhoton!.getVariable("Latitude", completion: { (result:Any?, error:Error?) -> Void in
                                if let _ = error {
                                    print("Failed reading latitude from device")
                                    //self.coorX.text = "Failed reading latitude from device"
                                }
                                else {
                                    if let latitude = result as? NSNumber {
                                        print("The latitude is \(latitude.stringValue)")
                                        //self.coorX.text = "The latitude is \(cLat.stringValue)."
                                        latText2 = Double(latitude.stringValue)!
                                        
            //Get Longitude Variable and convert string to double
                                        self.myPhoton!.getVariable("Longitude", completion: { (result:Any?, error:Error?) -> Void in
                                            if let _ = error {
                                                print("Failed reading longitude from device")
                                                self.coorY.text = "Failed reading longitude from device"
                                            }
                                            else {
                                                if let longitude = result as? NSNumber {
                                                    print("The longitude is \(longitude.stringValue)")
                                                    //self.coorY.text = "The longitude is \(cLong.stringValue)."
                                                    longText2 = Double(longitude.stringValue)!
                                                    
            //initiate google maps with camera position set to longitude and latitude values
                                                    let camera = GMSCameraPosition.camera(withLatitude: Double(latText2),
                                                                                          longitude: Double(longText2),
                                                                                          zoom: 10)
                                                    //print("\(latText2) and \(longText2)")
                                                    let mapView = GMSMapView.map(withFrame: self.mapView1.bounds, camera: camera)
                                                    mapView.settings.myLocationButton = true
                                                    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                                    mapView.isMyLocationEnabled = true
                                                    let marker = GMSMarker()
                                                    marker.position = CLLocationCoordinate2D(latitude: latText2, longitude: longText2)
                                                    marker.title = "Owasso"
                                                    marker.snippet = "Oklahoma"
                                                    marker.map = mapView
                                                    
                                                    
            // Unhide everything once maps is complete and data filled
                                                    
                                                    self.mapView1.addSubview(mapView)
                                                    self.mapView1.isHidden = false
                                                    self.max.isHidden = false
                                                    //self.min.isHidden = false
                                                    self.batUsage.isHidden = false
                                                }
                                            }
                                        })
                                    }
                                }
                            })
                            /*        self.myPhoton!.getVariable("Charge", completion: { (result:Any?, error:Error?) -> Void in
                                if let _ = error {
                                    print("Failed reading SOC from device")
                                    //self.max.text = "Failed reading SOC max from device"
                                }
                                else {
                                    if let charge = result as? NSNumber {
                                        print("The SOC is \(charge.stringValue)")
                                        //self.max.text = "The SOC max is \(socMax.stringValue)."
                                    }
                                }
                            })
                                    self.myPhoton!.getVariable("socMin", completion: { (result:Any?, error:Error?) -> Void in
                                if let _ = error {
                                    print("Failed reading SOC min from device")
                                    self.min.text = "Failed reading SOC min from device"
                                }
                                else {
                                    if let socMin = result as? NSNumber {
                                        print("The SOC min is \(socMin.stringValue)")
                                        self.min.text = "The SOC min is \(socMin.stringValue)."

                                    }
                                }
                            })
                                    self.myPhoton!.getVariable("RPM", completion: { (result:Any?, error:Error?) -> Void in
                                        if let _ = error {
                                            print("Failed reading RPM from device")
                                        }
                                        else {
                                            if let RPM = result as? NSNumber {
                                                print("The RPM is \(RPM.stringValue)")
                                                
                                            }
                                        }
                                    })
                                    self.myPhoton!.getVariable("ambientTemp", completion: { (result:Any?, error:Error?) -> Void in
                                        if let _ = error {
                                            print("Failed reading ambient temperature from device")
                                        }
                                        else {
                                            if let ambientTemp = result as? NSNumber {
                                                print("The ambient temperature is \(ambientTemp.stringValue)")
                                                
                                            }
                                        }
                                    })
                                */
                        }
                    }
                }
            }
        }
    }
}
}
}
