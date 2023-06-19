
//
//  ContentViewModel.swift
//  ImageClassifier
//
//  Created by Klas Stegmayr on 2023-05-05.
//

import Foundation

final class ContentViewModelCloud: ObservableObject {
    
    public func startCloudClassification() {
        
        guard let fileURL = Bundle.main.url(forResource: "dataset", withExtension: "zip") else {
                print("Unable to locate .zip file")
                return
            }
        
        upload(fileURL: fileURL)
        
    }
    
    
    private func upload(fileURL: URL) {
        
        guard let fileData = try? Data(contentsOf: fileURL) else {
                print("Could not load .zip file")
                return
            }

        // Endpoint
        guard let url = URL(string: "http://172.26.4.69:8080/api") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set content type to form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Prepare the HTTPBody with .zip file data
        request.httpBody = createBody(parameters: [:],
                                      boundary: boundary,
                                      data: fileData,
                                      mimeType: "application/zip",
                                      filename: "dataset.zip")
        
        let start = DispatchTime.now()
        // Send POST Request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error)")
                
            } else if let _ = response as? HTTPURLResponse {
                let end = DispatchTime.now()
                let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
                let timeInterval = Double(nanoTime) / 1_000_000_000
                print("Respone Time: \(timeInterval)")
                if let data = data, let string = String(data: data, encoding: .utf8) {
                    print("Response data: \(string)")
                }
            }
        }.resume()
    }
    
    
    // Creates the body of the request
    private func createBody(parameters: [String: String],
                            boundary: String,
                            data: Data,
                            mimeType: String,
                            filename: String) -> Data {
        var body = Data()
        
        let boundaryPrefix = "--\(boundary)\r\n"

        for (key, value) in parameters {
            body.append(boundaryPrefix.data(using: .utf8, allowLossyConversion: false)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8, allowLossyConversion: false)!)
            body.append("\(value)\r\n".data(using: .utf8, allowLossyConversion: false)!)
        }

        body.append(boundaryPrefix.data(using: .utf8, allowLossyConversion: false)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8, allowLossyConversion: false)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8, allowLossyConversion: false)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8, allowLossyConversion: false)!)
        body.append("--".appending(boundary.appending("--")).data(using: .utf8, allowLossyConversion: false)!)

        return body
    }
}
