import ArgumentParser
import AVFoundation
import Foundation

enum ThumbnailFormat: String, CaseIterable, ExpressibleByArgument {
    case png
    case jpeg
    case jpg
    var utType: UTType { self == .jpg || self == .jpeg ? .jpeg : .png }
    var fileExtension: String { self == .jpg || self == .jpeg ? "jpg" : "png" }
}

@main
struct ThumbnailGeneratorTool: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "vtg", version: "0.0.1")
    
    @Argument(
        help: "Path to the input video file.",
        transform: { arg in
            URL(filePath: NSString(string: arg).expandingTildeInPath)
        }
    )
    var input: URL
    
    @Option(
        name: .shortAndLong,
        help: "Timestamp in seconds to extract. Defaults to the middle of the video if omitted."
    )
    var timestamp: Double?
    
    @Option(
        name: .long,
        help: "<png|jpg>\nOutput image format override.\nIf the output path has a supported extension (png, jpg, jpeg), that extension determines the format.\nIf omitted, PNG format is used by default.",
        transform: { arg in
            let format = if arg.hasPrefix(".") {
                String(arg.dropFirst())
            } else {
                arg
            }
            
            guard let format = ThumbnailFormat(rawValue: format) else {
                throw ValidationError("'\(arg)' is not a supported format. Supported formats are 'png', 'jpg', and 'jpeg'.")
            }
            return format
        }
    )
    var format: ThumbnailFormat = .png
    
    // TODO: JPEGの圧縮品質
    // Option(name. long, help: "JPEGの圧縮品質。(0.0〜1.0)")
    // var quality: Double?
    
    @Option(
        name: .shortAndLong,
        help: "Path to the output image file (must include a supported extension).",
        transform: { arg in
            let url = URL(filePath: NSString(string: arg).expandingTildeInPath)
            let ext = url.pathExtension.lowercased()
            let supportedFormats = Set(ThumbnailFormat.allCases.map { $0.rawValue })
            
            guard !ext.isEmpty else {
                throw ValidationError("Output path must include a file extension (e.g. .png or .jpg).")
            }
            
            guard supportedFormats.contains(ext) else {
                throw ValidationError("'\(ext)' is not a supported extension. Supported extensions are: png, jpg, jpeg.")
            }
            
            return url
        }
    )
    var output: URL?
    
    func thumbnailData() async -> CGImage? {
        let asset = AVURLAsset(url: input)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        generator.appliesPreferredTrackTransform = true
        
        let duration = try! await asset.load(.duration)
        
        let cmTime = CMTime(seconds: timestamp ?? duration.seconds / 2, preferredTimescale: 600)
        
        return try? await generator.image(at: cmTime).image
    }
    
    mutating func writeImage(_ image: CGImage) -> Bool {
        guard let data = image.toData(format) else {
            return false
        }
        
        output = resolvedOutputURL()
        
        do {
            try data.write(to: output!, options: [.atomic])
            return true
        } catch {
            print("Failed to write image: \(error.localizedDescription)")
            return false
        }
    }
    
    func resolvedOutputURL() -> URL {
        let fm = FileManager.default
        
        let url = if let output {
            output
        } else {
            input.deletingLastPathComponent()
                .appendingPathComponent(
                    input.deletingPathExtension().lastPathComponent,
                    conformingTo: format.utType
                )
        }
        
        if !fm.fileExists(atPath: url.path(percentEncoded: false)) {
            return url
        }
        
        let dir = url.deletingLastPathComponent()
        let baseName = url.deletingPathExtension().lastPathComponent
        let ext = UTType(filenameExtension: url.pathExtension) ?? .png
        
        var i = 2
        while true {
            let candidate = dir.appendingPathComponent("\(baseName) \(i)", conformingTo: ext)
            
            if !fm.fileExists(atPath: candidate.path(percentEncoded: false)) {
                return candidate
            }
            
            i += 1
        }
    }
    
    mutating func run() async throws {
        guard
            let image = await thumbnailData(),
            writeImage(image)
        else {
            print("Failed to generate thumbnail.")
            return
        }
        
        print("Generated thumbnail successfully.")
        print("output: \(output?.path(percentEncoded: false) ?? "")")
    }
}

extension CGImage {
    func toData(_ format: ThumbnailFormat) -> Data? {
        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(
                mutableData, format.utType.identifier as CFString, 1, nil)
        else {
            return nil
        }
        
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return mutableData as Data
    }
}
