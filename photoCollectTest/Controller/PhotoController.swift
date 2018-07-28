//
//  PhotoController.swift
//  photoCollectTest
//
//  Created by Andrew Llewellyn on 7/28/18.
//  Copyright © 2018 Andrew Llewellyn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoController: UICollectionViewController
{
    
    
    @IBOutlet var PhotoCollection: UICollectionView!
    
    @IBOutlet weak var CollectionFlow: UICollectionViewFlowLayout!
    
    var photoAlbum = [Data]()
    
    var lat: Double?
    var lon: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let space: CGFloat = 3.0
        let widthDimension = (view.frame.size.width - (2*space)) / 3.0
        let heightDimension = (view.frame.size.height - (2*space)) / 5.0
        lat = Location.sharedInstance().latitude!
        lon = Location.sharedInstance().longitude!
        
        CollectionFlow.minimumInteritemSpacing = space
        CollectionFlow.minimumLineSpacing = space
        CollectionFlow.itemSize = CGSize(width: widthDimension, height: heightDimension)
        
        loadPhotos()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 9
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        if photoAlbum.count == 9
        {
            let photo = photoAlbum[(indexPath as NSIndexPath).row]
             cell.imageView.image = UIImage(data: photo)
             cell.activityIndicator.isHidden = true
        }
        else{
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }
       
       
        
        return cell
    }
    
    
    func loadPhotos()
    {
        GrabFlickr.sharedInstance().searchByLatLon(lat!, lon!) {
            
            self.photoAlbum = GrabFlickr.sharedInstance().photoAlbum
            
            performUIUpdatesOnMain {
                self.PhotoCollection.reloadData()
            }
        }
    }
    
    @IBAction func newSet(_ sender: Any) {
        
        loadPhotos()
        
    }
    
    
    
}
