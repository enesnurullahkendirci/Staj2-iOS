//
//  ViewController.swift
//  staj2
//
//  Created by Enes Nurullah Kendirci on 13.02.2021.
//

import FirebaseDatabase
import UIKit
import Foundation
import CoreML
import Vision
class ViewController: UIViewController {
    @IBOutlet weak var classificationLabel: UILabel!
    var detectImage: UIImage?
    private let database = Database.database().reference()
    var keyArray = [String]()
    var dataArray: [String] = []
    lazy var classificationRequest: VNCoreMLRequest = {
            do {
                /*
                 Use the Swift class `MobileNet` Core ML generates from the model.
                 To use a different Core ML classifier model, add it to the project
                 and replace `MobileNet` with that model's generated Swift class.
                 */
                let model = try VNCoreMLModel(for: stajmama().model)
                
                let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                    self?.processClassifications(for: request, error: error)
                })
                request.imageCropAndScaleOption = .centerCrop
                return request
            } catch {
                fatalError("Failed to load Vision ML model: \(error)")
            }
        }()

    @IBOutlet weak var myImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        DispatchQueue.main.async {
            self.database.child("esp32-cam").observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    print("else")
                    return
                }
                self.keyArray = Array(value.keys).sorted(by: <)
                
                
                let parent = self.keyArray.last!
                var path = ""
                
                path = parent + "/photo"
                
                self.database.child("esp32-cam").child(path).observeSingleEvent(of: .value, with: { snapshot in
                    guard let valueData = snapshot.value as? String else {
                        print("else")
                        return
                    }
                    //print(valueData)
                    //burdan itibaren
                    do{
                        let data = try Data(contentsOf: URL(string: valueData)!)
                        self.myImageView.image = UIImage(data: data)
                        self.updateClassifications(for: UIImage(data: data)!)
                    }catch{
                        
                    }
                    
                })
            
            })
        }
        
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
            DispatchQueue.main.async {
                guard let results = request.results else {
                    self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                    return
                }
                // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
                let classifications = results as! [VNClassificationObservation]
            
                if classifications.isEmpty {
                    self.classificationLabel.text = "Nothing recognized."
                } else {
                    // Display top classifications ranked by confidence in the UI.
                    let topClassifications = classifications.prefix(2)
                    let descriptions = topClassifications.map { classification in
                        // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                       return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                    }
                    self.classificationLabel.text = descriptions[0]
                    //print("oldu mu" + descriptions.joined(separator: "\n"))
                    print(descriptions[0])
                }
            }
        }
    func updateClassifications(for image: UIImage) {
            classificationLabel.text = "Classifying..."
            
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
            guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation!)
                do {
                    try handler.perform([self.classificationRequest])
                } catch {
                    /*
                     This handler catches general image processing errors. The `classificationRequest`'s
                     completion handler `processClassifications(_:error:)` catches errors specific
                     to processing that request.
                     */
                    print("Failed to perform classification.\n\(error.localizedDescription)")
                }
            }
        }
}




