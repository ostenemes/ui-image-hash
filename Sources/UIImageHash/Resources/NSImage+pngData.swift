import AppKit

extension NSImage {
    func pngData() -> Data? {
        let mutableData = CFDataCreateMutable(nil, 0)
        guard let destination = CGImageDestinationCreateWithData(mutableData!, kUTTypePNG, 1, nil) else { return nil }
        
        CGImageDestinationAddImage(destination, self.cgImage(forProposedRect: nil, context: nil, hints: nil)!, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return mutableData as? Data
    }
}
