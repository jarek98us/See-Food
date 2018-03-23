//
//  ViewController.swift
//  See Food
//
//  Created by Jarek on 23/03/2018.
//  Copyright © 2018 Jarek. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImagePicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading ML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error loading classification results")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hot Dog!"
                } else {
                    self.navigationItem.title = "Not Hot Dog!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("Error permorming ML request: \(error)")
        }
    }
    
    @IBAction func cameraButtonClicked(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func configureImagePicker() {
        imagePicker.delegate = self
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .photoLibrary
        } else {
            imagePicker.sourceType = .camera
        }
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let takenPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoImageView.image = takenPhoto
            guard let ciImage = CIImage(image: takenPhoto) else {
                fatalError("Could not convert photo to CIImage")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

