//
//  GrabFlickr.swift
//  photoCollectTest
//
//  Created by Andrew Llewellyn on 7/28/18.
//  Copyright © 2018 Andrew Llewellyn. All rights reserved.
//

import Foundation
import UIKit


class GrabFlickr: NSObject
{
    
    var photoAlbum = [Data]()
    
    func isTextFieldValid(_ number: Double, forRange: (Double, Double)) -> Bool
    {
        if number != nil
        {
            return isValueInRange(number, min: forRange.0, max: forRange.1)
        } else {
            return false
        }
    }
    
    func isValueInRange(_ value: Double, min: Double, max: Double) -> Bool
    {
        return !(value < min || value > max)
    }
    
    func refresh(_ lat: Double, _ lon: Double) {
        
        self.photoAlbum = []
        
        searchByLatLon(lat, lon){print("completing")}
    }
    
    func searchByLatLon( _ lat: Double, _ lon: Double, _ completion: @escaping ()-> Void)
    {
        
        self.photoAlbum = []
        
        if isTextFieldValid(lat, forRange: Constants.Flickr.SearchLatRange) && isTextFieldValid(lon, forRange: Constants.Flickr.SearchLonRange)
        {
            // TODO: Set necessary parameters!
            let methodParameters = [
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.BoundingBox: bboxString(lat, lon),
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ]
            displayImageFromFlickrBySearch(methodParameters as [String:AnyObject])
            {
                (success) in
                if success
                {
                    print("there are 9 photos now")
                    completion()
                }
            }
        }
        else {
            return
        }
    }
    
    
    private func bboxString(_ lat: Double?, _ lon: Double?) -> String
    {
        if let latitude = lat, let longitude = lon {
            let minLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maxLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maxLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
        }
        else
        {
            return "0,0,0,0"
        }
    }
    
    // MARK: Flickr API
    
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], _ completionHandler: @escaping (_ success: Bool) -> Void)
    {
        
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task =  session.dataTask(with: request)
        {
            (data, response, error) in
            if error == nil
            {
                print(data)
            }
            else
            {
                print(error!.localizedDescription)
            }
            
            func displayError(_ error: String)
            {
                print(error)
              
            }
            /* GUARD: Was there an error? */
            guard (error == nil) else
            {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else
            {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else
            {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do
            {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            }
            catch
            {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else
            {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                return
            }
            
            // select a random photo
            
            
            
            //MARK: Loop to append random photos to collection
            
            for i in (1...9)
            {
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                print(photoArray)
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else
                {
                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return
                }
            
                // if an image exists at the url, set the image and title
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!)
                {
                    performUIUpdatesOnMain
                        {
                            let image = UIImage(data: imageData)
                            let imageBinary = UIImageJPEGRepresentation(image! , 1)
                            self.photoAlbum.append(imageBinary!)
                            print("Album: \(self.photoAlbum)")
                            
                            if self.photoAlbum.count == 9
                            {
                                completionHandler(true)
                            }
                    
                    }
                }
                else
                {
                    displayError("Image does not exist at \(imageURL)")
                }
            }
        }
        task.resume()
        
        print(flickrURLFromParameters(methodParameters))
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL
    {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

    class func sharedInstance() -> GrabFlickr
    {
        struct Singleton
        {
            static var sharedInstance = GrabFlickr()
        }
        return Singleton.sharedInstance
        
    }






}
