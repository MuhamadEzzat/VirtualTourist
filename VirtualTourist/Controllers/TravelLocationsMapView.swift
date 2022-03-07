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
    var photos : _Data?
    var pin : Pin!
    var cachePhotos : [Photo]! = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mabview.delegate = self
        print(dataController.viewContext, "dsfsdfs")
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
                                                             
        gestureRecognizer.delegate = self
        mabview.addGestureRecognizer(gestureRecognizer)
            
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillMapview()
    }
    
    func fillMapview(){
        
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
        addPintoCache(latitude: annotation.coordinate.latitude, Longitude: annotation.coordinate.longitude)
        
        vtclient.getImages(latitude: mabview.centerCoordinate.latitude, Longitude: mabview.centerCoordinate.longitude, page: 1, completion: { bool, error, photos, images in
            guard let photos = photos else{
                return
            }
            self.photos = photos
            self.addImages(photos: photos)
        })
    }
    
    func addImages(photos: _Data){
        if let p = self.photos?.photos.photo{
            let image = Photo(context: self.dataController.viewContext)
            for i in p{
                image.id = i.id
                image.owner = i.owner
                image.title = i.title
                image.url_o = i.url_o
                image.pin = self.pin
                
                self.pin.addToPhotos(image)
                try? self.dataController.viewContext.save()
                self.cachePhotos.insert(image, at: 0)

            }
        }
        print(self.cachePhotos, "safewfW")
    }
    
    func addPintoCache(latitude: CLLocationDegrees, Longitude: CLLocationDegrees){
        let pin = Pin(context: dataController.viewContext)
        pin.lat = latitude
        pin.lng = Longitude
        self.pin = pin
        try? dataController.viewContext.save()
        pins.insert(pin, at: 0)
    }
    
    func pin(at indexPath: IndexPath) -> Pin {
        return pins[indexPath.row]
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let nextStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = nextStoryboard.instantiateViewController(withIdentifier: "PhotoAlbumView") as! PhotoAlbumView

        vc.photosArr = self.photos
        vc.lat = view.annotation?.coordinate.latitude ?? 0.0
        vc.lng = view.annotation?.coordinate.longitude ?? 0.0
        vc.pin = pins.last
        
        vc.dataController = dataController
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }


}

