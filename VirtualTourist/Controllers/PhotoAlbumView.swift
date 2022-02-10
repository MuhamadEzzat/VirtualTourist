//
//  PhotoAlbumView.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 31/01/2022.
//

import UIKit
import MapKit

class PhotoAlbumView: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var newcollectionBtn: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    
    var lat = 0.0
    var lng = 0.0
    
    var photosArr : _Data?
    var images : [UIImage]?
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        let initialLocation = CLLocation(latitude: lat, longitude: lng)
        centerMapOnLocation(location: initialLocation)
        // Do any additional setup after loading the view.
        fillMapview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(photosArr?.photos.photo.count, "ergeWG")
        self.collection.reloadData()
    }
    
    func fillMapview(){
            
          
        var annotations = [MKPointAnnotation]()
            
        let lat = CLLocationDegrees(self.lat)
        let long = CLLocationDegrees(self.lng)
            
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = ""
        annotation.subtitle = "mediaURL"
            
        annotations.append(annotation)
        
        self.mapview.addAnnotations(annotations)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: 500 , longitudinalMeters: 500)
        mapview.setRegion(coordinateRegion, animated: true)
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

    
}


extension PhotoAlbumView: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArr?.photos.photo.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        

        cell.img.downloadImage(url: self.photosArr?.photos.photo[indexPath.item].url_o ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.photosArr?.photos.photo.remove(at: indexPath.item)
        print(self.photosArr?.photos.photo.count)
        collection.reloadData()
    }
    
    
    
}
