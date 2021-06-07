import CoreImage
import SwiftUI

#if os(macOS)
import AppKit
extension Image {
  init(cgImage: CGImage) {
    self = Image(nsImage: NSImage(cgImage: cgImage, size: .init(width: cgImage.width, height: cgImage.height)))
  }
}
#elseif os(iOS)
import UIKit
extension Image {
  init(cgImage: CGImage) {
    self = Image(uiImage: UIImage(cgImage: cgImage))
  }
}
#endif

/// See https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIQRCodeGenerator for a primer on this
func generateQRCode(from string: String, correctionLevel: String) -> CGImage? {
  guard let data = string.data(using: .isoLatin1) else {
    return nil
  }
  let filter = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": correctionLevel as NSString])
  guard let outputImage = filter?.outputImage else {
    return nil
  }
  let context = CIContext()
  return context.createCGImage(outputImage, from: outputImage.extent)
}

struct ContentView: View {
  @State var text: String = "Here's to the crazy ones. The misfits. The rebels."
  @State var correctionLevel: String = "H"

  var body: some View {
    VStack {
      if let image = generateQRCode(from: text, correctionLevel: correctionLevel) {
        Image(cgImage: image)
          .interpolation(.none)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
      } else {
        Text("Failed to make code")
      }
      VStack {
        TextField("Data", text: $text)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        Picker("Correction Level", selection: $correctionLevel) {
          Text("L (7%)").tag("L")
          Text("M (15%)").tag("M")
          Text("Q (25%)").tag("Q")
          Text("H (30%)").tag("H")
        }
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
