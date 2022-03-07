//
//  PhotoAlbumView.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 31/01/2022.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumView: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var noimagesLbl: UILabel!
    @IBOutlet weak var newcollectionBtn: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    
    var lat = 0.0
    var lng = 0.0
    
    var photosArr : _Data?
    
    let vtclient = VTClient()
    var pin: Pin!
    var photoscache : [Photo] = []
    
    var dataController : DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(pin.photos, "dscdvevE")
        self.newcollectionBtn.alpha = 0.5
        self.newcollectionBtn.isEnabled = false
        self.newcollectionBtn.addTarget(self, action: #selector(getImages), for: .touchUpInside)
        mapview.delegate = self
        let initialLocation = CLLocation(latitude: lat, longitude: lng)
        centerMapOnLocation(location: initialLocation)
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pin)

        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            photoscache = result
            
            if photoscache.count == 0{
                getImages()
                
            }else{
                
                print(result[0].imageData, "Sdvfdbvde")
            }
            
        }
        
        // Do any additional setup after loading the view.
        fillMapview()
    }
    
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.collection.reloadData()
//    }
    
    @objc func getImages(){
        if photosArr?.photos.photo.count ?? 0 > 1{
            let randomPage = Int.random(in: 1..<(photosArr?.photos.pages)!)
            vtclient.getImages(latitude: lat, Longitude: lng, page: randomPage) { bool, error, data, images in
                if bool == true{
                    self.photosArr = data
                    self.collection.reloadData()
                }
            }
        }else{
            vtclient.getImages(latitude: lat, Longitude: lng, page: 1) { bool, error, data, images in
                if bool == true{
                    if data?.photos.photo.count != 0{
                        self.photosArr = data
                        self.collection.reloadData()
                        self.collection.alpha = 1
                        self.noimagesLbl.alpha = 0
                    }else{
                        self.collection.alpha = 0
                        self.noimagesLbl.alpha = 1
                    }
                    
                }
            }
        }
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
//tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)

extension PhotoAlbumView: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArr?.photos.photo.count ?? photoscache.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        switch self.photoscache.isEmpty{
        case true:
            vtclient.downloadImage(url: self.photosArr?.photos.photo[indexPath.item].url_m ?? "", image: cell.img) { bool, error, data in
                if bool == true{
                    DispatchQueue.main.sync {
                        cell.img.image = UIImage(data: data)
                        self.addImages(photos: self.photosArr!, newimg: data, at: indexPath)
                        self.newcollectionBtn.alpha = 1
                        self.newcollectionBtn.isEnabled = true
                    }
                    
                }
            }
        case false:
            cell.img.image = UIImage(data:self.photoscache[indexPath.row].imageData!)
            self.newcollectionBtn.alpha = 1
            self.newcollectionBtn.isEnabled = true
        default:
            print("Nothing to do!")
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.photosArr?.photos.photo.remove(at: indexPath.item)
        let photoToDelete = photo(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
        photoscache.remove(at: indexPath.row)
        collection.deleteItems(at: [indexPath])
        collection.reloadData()
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        return photoscache[indexPath.item]
    }
    
    func addImages(photos: _Data, newimg: Data, at indexpat: IndexPath){
        if let p = photos.photos.photo as? [PhotoDetails]{
            let image = Photo(context: self.dataController.viewContext)
            image.id = p[indexpat.row].id
            image.owner = p[indexpat.row].owner
            image.title = p[indexpat.row].title
            image.url_o = p[indexpat.row].url_m
            image.pin = self.pin
            image.imageData = newimg
                
            self.pin.addToPhotos(image)
            try? self.dataController.viewContext.save()
            self.photoscache.insert(image, at: 0)
            print(self.photoscache, "Dsvdsv")
        }
    }
    
}
