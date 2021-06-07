import CoreImage
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
typealias PlatformImage = NSImage
import AppKit
extension PlatformImage {
  convenience init(cgImage: CGImage) {
    self.init(cgImage: cgImage, size: .init(width: cgImage.width, height: cgImage.height))
  }
}
extension PlatformImage: NSItemProviderWriting {
  public static var writableTypeIdentifiersForItemProvider: [String] {
    [UTType.tiff.identifier]
  }

  public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
    completionHandler(tiffRepresentation, nil)
    return nil
  }
}
extension Image {
  init(cgImage: CGImage) {
    self = Image(nsImage: PlatformImage(cgImage: cgImage))
  }
}
#elseif os(iOS)
typealias PlatformImage = UIImage
import UIKit
extension Image {
  init(cgImage: CGImage) {
    self = Image(uiImage: PlatformImage(cgImage: cgImage))
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
          .onDrag({
            NSItemProvider(object: PlatformImage(cgImage: image))
          })
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
