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
    var pins = PinCoreData.getData().0
    let vtclient = VTClient()
    var anotationsArr : [CLLocationCoordinate2D]? = []
    var photos : _Data?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mabview.delegate = self
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
                                                             
        gestureRecognizer.delegate = self
        mabview.addGestureRecognizer(gestureRecognizer)
            
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillMapview()
    }
    
    func fillMapview(){
        
        var annotations = [MKPointAnnotation]()
        
        for i in pins {
            
            let lat = CLLocationDegrees(i.lat)
            let long = CLLocationDegrees(i.lng)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            
            annotations.append(annotation)
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
        if gestureRecognizer.state != .began{
            return
        }
        
        let touchPoint = gestureRecognizer.location(in: mabview)
        let newCoordinates = mabview.convert(touchPoint, toCoordinateFrom: mabview)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        self.anotationsArr?.append(annotation.coordinate)
        mabview.addAnnotation(annotation)
        
        //Save to Coredata
        PinCoreData.addData(lat: annotation.coordinate.latitude, long: annotation.coordinate.longitude)
        
        vtclient.getImages(latitude: mabview.centerCoordinate.latitude, Longitude: mabview.centerCoordinate.longitude, completion: { bool, error, photos, images in
            guard let photos = photos else{
                return
            }
            
            self.photos = photos
        })
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(mabview.centerCoordinate.latitude, "SSSSS")
        let nextStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = nextStoryboard.instantiateViewController(withIdentifier: "PhotoAlbumView") as! PhotoAlbumView
//        self.performSegue(withIdentifier: "openPhotos", sender: self)
        vc.photosArr = self.photos
        self.navigationController?.pushViewController(vc, animated: true)
        
    }


}

