///
//  ContentView.swift
//  ImageClassifier
//
//  Created by Moa Andersson on 2023-04-27.
//

import SwiftUI
import CoreML
import Vision


struct ContentView: View {
    
//    @State
//    var imageClass: String? = nil
//
//    let imageNames = ["Bird", "Deer", "Plane"]
    
    @StateObject
    private var viewModel: ContentViewModel
    
    @StateObject
    private var viewModelCloud: ContentViewModelCloud
    
    init() {
        _viewModel = StateObject(wrappedValue: ContentViewModel())
        _viewModelCloud = StateObject(wrappedValue: ContentViewModelCloud())
    }
    
    var body: some View {
        
        VStack {
//            if let image = viewModel.currentImage {
//                Image(uiImage: image)
//            }

            Button("Start device classification") {
                viewModel.startClassifyModel()
            }

            Spacer()
            
            Button("Start cloud classification") {
                viewModelCloud.startCloudClassification()
                
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
