//
//  ImageSaver.swift
//  Hypno-Ai
//
//  Created by Sanviraj Zahin Haque on 4/4/23.
//

import UIKit

class ImageSaver : NSObject{
    
    var successHandler : (() -> Void)?
    var errorHandler : ((Error) -> Void)?
    
    func writeTophotosAlbum(image : UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image : UIImage, didFinishSavingWithError error : Error? , contextInfo : UnsafeRawPointer){
        
        //save complete
        if let error = error{
            errorHandler?(error)
        }
        else{
            successHandler?()
        }
    }
}
