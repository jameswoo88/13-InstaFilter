//
//  ImageSaver.swift
//  Instafilter
//
//  Created by James Chun on 9/18/21.
//

import UIKit

class ImageSaver: NSObject {
    //Properties
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    //Functions
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}//End of class
