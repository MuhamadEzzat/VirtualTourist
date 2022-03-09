//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 30/01/2022.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mabview: MKMapView!
    
    var dataController:DataController!
    var pins : [Pin] = []
    let vtclient = VTClient()
    var anotationsArr : [CLLocationCoordinate2D]? = []
    var pin : Pin!
    var cachePhotos : [Photo]! = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
                                                             
        gestureRecognizer.delegate = self
        mabview.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillMapview()
    }
    
    func fillMapview(){
//        for pin in pins{
//            dataController.viewContext.delete(pin)
//        }
//        try? dataController.viewContext.save()
        var annotations = [MKPointAnnotation]()
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lat", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            for i in result {
                let lat = CLLocationDegrees(i.lat)
                let long = CLLocationDegrees(i.lng)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = coordinate
                
                annotations.append(annotation)
            }
        }
        
        self.mabview.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .purple
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    @objc func longPress(gestureRecognizer:UIGestureRecognizer){
//        if gestureRecognizer.state != .began{
//            return
//        }
        let touchPoint = gestureRecognizer.location(in: mabview)
        let newCoordinates = mabview.convert(touchPoint, toCoordinateFrom: mabview)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        self.anotationsArr?.append(annotation.coordinate)
        
        
        if gestureRecognizer.state == .began {
            // add a PIN to the map
            mabview.addAnnotation(annotation)
        } else if gestureRecognizer.state == .changed {
            // update the PIN to the new location
        } else if gestureRecognizer.state == .ended {
            // Save this PIN to CoreData
            addPintoCache(latitude: annotation.coordinate.latitude, Longitude: annotation.coordinate.longitude)
        }
    }
    
    func addPintoCache(latitude: CLLocationDegrees, Longitude: CLLocationDegrees){
        let pin = Pin(context: dataController.viewContext)
        pin.lat = latitude
        pin.lng = Longitude
        self.pin = pin
        try? dataController.viewContext.save()
        pins.insert(pin, at: 0)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let nextStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = nextStoryboard.instantiateViewController(withIdentifier: "PhotoAlbumView") as! PhotoAlbumView

        for item in self.pins {
            if let lat = view.annotation?.coordinate.latitude, let lng = view.annotation?.coordinate.longitude {
                if item.lat == lat && item.lng == lng{
                    vc.pin = item
                    break
                }
            }
        }
        
        
        print(vc.pin.lat, vc.pin.lng, "FdvervrE")
        vc.dataController = dataController
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    


}

