//
//  ImagePredictor.swift
//  TextRecognition
//
//  Created by Dmitriy Soloshenko on 26.05.2024.
//

import UIKit
import Vision
import CoreML

class ImagePredictor {

    /// Stores a classification name and confidence for an image classifier's prediction.
    /// - Tag: Prediction
    struct Prediction {
        let names: [String]
    }

    /// The function signature the caller must provide as a completion handler.
    typealias ImagePredictionHandler = (_ prediction: Prediction) -> Void

    /// A dictionary of prediction handler functions, each keyed by its Vision request.
    private var predictionHandler:ImagePredictionHandler?

    func doOCR(_ cgImage:CGImage?) {
        guard let cgImage = cgImage else { return }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest {[weak self] request, error in
            guard let observations = request.results?.compactMap({ $0 as? VNRecognizedTextObservation }),
                  error == nil else {return}
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            print(text)
            self?.handleResult(text)
        }
        
        request.recognitionLevel = .fast
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print ("Error")
            }
        }
    }

    private func handleResult(_ text: String) {
        DispatchQueue.main.async {
            let prediction = Prediction(names: [text])
            self.predictionHandler?(prediction)
        }
    }
    
    
    func makePredictions(for image: UIImage, completionHandler: @escaping ImagePredictionHandler) {
        self.predictionHandler = completionHandler
        self.doOCR(image.cgImage)
    }
}
