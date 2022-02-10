//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 30/01/2022.
//

import UIKit
import MapKit

class TravelLocationsMapView: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mabview: MKMapView!
    
    var anotationsArr : [CLLocationCoordinate2D]? = []
    var photos : _Data?
    override func viewDidLoad() {
        super.viewDidLoad()
        mabview.delegate = self
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
                                                             
        gestureRecognizer.minimumPressDuration = 2.0
        gestureRecognizer.delegate = self
        mabview.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(mabview.centerCoordinate, "SSSSS")
    }
    
    func fillMapview(){
        getCoordinate(addressString: "" ) { coordinates, error in
            
          
            var annotations = [MKPointAnnotation]()
            
            let lat = CLLocationDegrees(coordinates.latitude)
            let long = CLLocationDegrees(coordinates.longitude)
            
            
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
        
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = ""
            annotation.subtitle = "mediaURL"
            
            annotations.append(annotation)
            
            self.mabview.addAnnotations(annotations)
        }
    }
    
    
    
    func getCoordinate( addressString : String,
            completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                        
                    completionHandler(location.coordinate, nil)
                    self.mabview.setRegion(MKCoordinateRegion(center: location.coordinate, span: self.mabview.region.span), animated: true)
                }
            }else{
                let alertController = UIAlertController(title: "Alert!", message: "Location Place is not found!", preferredStyle: .alert)

               let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("OK Pressed")
                }
                
                alertController.addAction(okAction)

                self.present(alertController, animated: true, completion: nil)

            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
            
        }
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
        let touchPoint = gestureRecognizer.location(in: mabview)
        let newCoordinates = mabview.convert(touchPoint, toCoordinateFrom: mabview)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        self.anotationsArr?.append(annotation.coordinate)
        mabview.addAnnotation(annotation)
        
        getImages(latitude: mabview.centerCoordinate.latitude, Longitude: mabview.centerCoordinate.longitude, completion: { bool, error, photos, images in
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

