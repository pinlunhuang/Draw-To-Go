//
//  ViewController.swift
//  Draw To Go
//
//  Created by 黃品綸 on 2019/5/24.
//  Copyright © 2019 Pinlun. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var canvasView: CanvasView!
    
    var request = [VNRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupVision()
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else {
            fatalError("CANNOT load ML Model")
        }
        
        let classficationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        
        self.request = [classficationRequest]
        
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observation = request.results else {
            print("No Results"); return
        }
        
        let classification = observation.compactMap({$0 as? VNClassificationObservation})
        .filter({$0.confidence > 0.8})
        .map({$0.identifier})
        
        DispatchQueue.main.async {
            self.numberLabel.text = classification.first
        }
        
    }
    
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.clearCanvas()
        DispatchQueue.main.async {
            self.numberLabel.text = "0"
        }
    }
    
    @IBAction func recognize(_ sender: Any) {
        let image = UIImage(view: canvasView)
        let scaleImg = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaleImg.cgImage!, options: [:])
        
        do {
            try imageRequestHandler.perform(self.request)
        } catch {
            print(error)
        }
        
    }
    
    func scaleImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg!
    }
    

}

