//
//  ContentViewModel.swift
//  ImageClassifier
//
//  Created by Klas Stegmayr on 2023-05-05.
//

import Foundation
import CoreML
import SwiftUI
import Vision

final class ContentViewModel: ObservableObject {
    
    var request: VNCoreMLRequest?
    
    @Published
    var currentImage: UIImage?
    
    public func startClassifyModel() {
        
        let visionModel = createImageClassifier()
        
        let imageClassificationRequest = VNCoreMLRequest(model: visionModel) { request, error in
            if let error = error {
                print(error)
                return
            }
        }
        
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        
        let classFolders = ["airplane", "automobile", "bird", "cat", "deer", "dog", "frog", "horse", "ship", "truck"]
        
        let dispatchGroup = DispatchGroup()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            for folder in classFolders {
                autoreleasepool {
                    dispatchGroup.enter()
                    DispatchQueue.global(qos: .userInitiated).async {
                        var imagesAndLabels = self.requestImagesAndLabels(folder: folder)
                        let start = DispatchTime.now()
                        self.classify(imagesAndLabels: imagesAndLabels, request: imageClassificationRequest)
                        let end = DispatchTime.now()
                        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
                        let timeInterval = Double(nanoTime) / 1_000_000_000
                        print("Time for all: \(timeInterval)")
                        imagesAndLabels.removeAll()
//                        DispatchQueue.main.async {
//                            print(folder)
//                        }
                        dispatchGroup.leave()
                    }
                    dispatchGroup.wait()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                
            }
        }
    }
    
    func createImageClassifier() -> VNCoreMLModel {
        
        var cifar: _300E?
        do {
            cifar = try _300E(configuration: MLModelConfiguration())
            print(cifar?.model.modelDescription)
            
        } catch {
            print("Failed to load model: \(error)")
        }
  
        guard let imageClassifier = cifar else {
            fatalError("App failed to create an image classifier model instance.")
        }

        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model

        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        
        return imageClassifierVisionModel
    }

    
    public func requestImagesAndLabels(folder: String) -> [(image: UIImage, label: String)] {
        var imagesAndLabels: [(image: UIImage, label: String)] = []

        guard let classURL = Bundle.main.url(forResource: folder, withExtension: nil, subdirectory: "dataset") else {
            fatalError("Failed to find class folder: \(folder)")
        }

        do {
            let imagesInClass = try FileManager.default.contentsOfDirectory(at: classURL, includingPropertiesForKeys: nil, options: [])
            let uiImagesAndLabels = imagesInClass.compactMap { URL -> (image: UIImage, label: String)? in
                guard let image = UIImage(contentsOfFile: URL.path) else { return nil }
                return (image, folder)
            }
            imagesAndLabels.append(contentsOf: uiImagesAndLabels)
        } catch {
            print("Error reading contents of class folder '\(folder)':", error)
        }
        return imagesAndLabels
    }

    

    func classify(imagesAndLabels: [(image: UIImage, label: String)], request: VNCoreMLRequest) {
        
//        guard let firstLabel = imagesAndLabels.first?.label else {
//                print("No labels found") // Print a default message if no labels are available
//                return
//            }
            
//        print("Starting classification with label: \(firstLabel) SIZE: \(imagesAndLabels.count)")
        
//        let start = DispatchTime.now()
        
        var correctPredictions = 0
        let totalImages = imagesAndLabels.count

        for (image, trueLabel) in imagesAndLabels {
//            currentImage = image
//            print("Image size: \(image.size)")
            let handler = VNImageRequestHandler(cgImage: image.cgImage!)

            do {
                try handler.perform([request])

                if let observation = request.results?.first as? VNClassificationObservation {
                    let predictedLabel = observation.identifier

                    if predictedLabel == trueLabel {
                        correctPredictions += 1
                    }
//                       print("\(trueLabel),\(predictedLabel),\(observation.confidence)")
                }
                
            } catch {
                print("Error performing classification request:", error)
            }
        }

//        let accuracy = Double(correctPredictions) / Double(totalImages)
//        print("Accuracy: \(accuracy * 100)%")

//        let end = DispatchTime.now()   // get the end time
//
//        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // difference in nanoseconds
//        let timeInterval = Double(nanoTime) / 1_000_000_000
//
//        print("Time: \(timeInterval)")
    }
}
