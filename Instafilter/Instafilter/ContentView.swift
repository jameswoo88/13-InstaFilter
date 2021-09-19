//
//  ContentView.swift
//  Instafilter
//
//  Created by James Chun on 9/5/21.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    // Properties
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    @State private var showingFilterSheet = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    
                    //display the image
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    //select an image
                    self.showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") {
                        //change filter
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        //save image
                        guard let processedImage = self.processedImage else { return }
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Success")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystalize"), action: {
                        self.setFilter(CIFilter.crystallize())
                    }),
                    .default(Text("Edges"), action: {
                        self.setFilter(CIFilter.edges())
                    }),
                    .default(Text("Gaussian Blur"), action: {
                        self.setFilter(CIFilter.gaussianBlur())
                    }),
                    .default(Text("Pixellate"), action: {
                        self.setFilter(CIFilter.pixellate())
                    }),
                    .default(Text("Sepia Tone"), action: {
                        self.setFilter(CIFilter.sepiaTone())
                    }),
                    .default(Text("Unsharp Mask"), action: {
                        self.setFilter(CIFilter.unsharpMask())
                    }),
                    .default(Text("Vignette"), action: {
                        self.setFilter(CIFilter.vignette())
                    }),
                    .cancel()
                ])
            }
        }
    }//End of body
    
    //Functions
    func loadImage() {
        guard let inputImage = inputImage else { return }
//        image = Image(uiImage: inputImage)
        let beginImage = CIImage(image: inputImage)
        
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
//        currentFilter.intensity = Float(filterIntensity)
//        currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            processedImage = uiImage

            image = Image(uiImage: uiImage)
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
    }
    
}//End of struct

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
