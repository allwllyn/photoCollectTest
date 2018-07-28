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
    
    var photoAlbum = GrabFlickr.photoAlbum
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoAlbum.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        let photo = photoAlbum[(indexPath as NSIndexPath).row]
        
        cell.imageView.image = UIImage(photo)
        
        return cell
    }
    
    
    
    
    
    
    
    
    
    
}
