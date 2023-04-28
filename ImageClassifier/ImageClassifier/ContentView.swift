////
//  ContentView.swift
//  ImageClassifier
//
//  Created by Moa Andersson on 2023-04-27.
//

import SwiftUI

struct ContentView: View {
    
    @State
    var imageClass: String? = nil
    
    let imageNames = ["Bird", "Deer", "Plane"]
    
    var body: some View {
        VStack {
            HStack(spacing: 32) {
                ForEach(imageNames, id: \.self) { imageName in
                    Button {
                        
                        classifyImage(imageName)
                        
                    } label: {
                        
                        // Image as button, triggers classifyImage() with the clicked images name
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
                    }

                }
            }

            Text(imageClass ?? "")
                .font(.system(size: 16))
        }
        .padding()
    }
    
    func classifyImage(_ imageName: String) {
        
        imageClass = imageNames.randomElement()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
