//
//  ContentView.swift
//  InstaFilter
//
//  Created by Sanviraj Zahin Haque on 11/8/21.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins


struct ContentView: View {
    
    @State private var image : Image?
    @State private var showingImagePicker = false
    @State private var filterIntensity = 0.0
    @State private var inputRadius = 100.0
    @State private var inputImage: UIImage?
    @State private var noImageError = false
    @State private var showingFilterActionSheet = false
    @State private var showImageSourceType = false
    @State private var sourceType = ""
    @State var currentFilter : CIFilter = CIFilter.sepiaTone()
    @State private var processedImage : UIImage?
    let context = CIContext()
    
    var body: some View {
        
        return NavigationView{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(Color.secondary)
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    }
                    else{
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    //image selection
                    self.showImageSourceType = true
                }
                
                
                HStack{
                    
                    Button("Save"){
                        
                        guard self.image != nil else{
                            self.noImageError = true
                            return
                        }
                        
                        guard let processedImage = self.processedImage else{return}
                        let imageSaver = ImageSaver()
                        imageSaver.successHandler = {
                            print("Success")
                        }
                        imageSaver.errorHandler = {
                            print("Oops : \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeTophotosAlbum(image: processedImage)
                        
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding([.horizontal,.bottom])
            .navigationBarTitle("Hypo-Ai")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage){
                ImagePicker(image: self.$inputImage,sourceType: sourceType )
            }
            .actionSheet(isPresented: $showImageSourceType, content: {
                ActionSheet(title: Text("Select a Source"), message: nil,buttons: [
               .default(Text("Camera")){
                   self.sourceType = "camera"
                   self.showingImagePicker = true
                },
                .default(Text("Photo Library")){
                    self.sourceType = "gallery"
                    self.showingImagePicker = true
                },
                .cancel()
                ])
            })
    
            .alert(isPresented: $noImageError, content: {
                Alert(title: Text("No Image Selected"), message: Text("Select a image to apply and save please"), dismissButton: .default(Text("OK")))
            })
        }
    }
    
    func loadImage(){
        guard let inputImage = inputImage else {return}
        
        let beginImage = CIImage(image: inputImage)
        
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
        
    }
    
    func applyProcessing(){
        let inputKeys = currentFilter.inputKeys
        if  inputKeys.contains(kCIInputIntensityKey){
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey){
            currentFilter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey){
            currentFilter.setValue(filterIntensity*10, forKey: kCIInputScaleKey)
        }
        guard let outPutImage = currentFilter.outputImage else{
            return
        }
        
        if let cgimg = context.createCGImage(outPutImage, from: outPutImage.extent){
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter : CIFilter){
        currentFilter = filter
        
        loadImage()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
