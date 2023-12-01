//
//  MP4Avc1Box.swift
//
//
//  Created by Matteo Ludwig on 19.11.23.
//

import Foundation
import CoreMedia


public class MP4Avc1Box: MP4ParsableBox {
    public static let typeName: String = "avc1"
    
    public var reserved1: Data
    
    public var dataReferenceIndex: UInt16
    
    public var version: UInt16
    public var revisionLevel: UInt16
    public var vendor: UInt32
    public var temporalQuality: UInt32
    public var spatialQuality: UInt32
    
    public var width: UInt16
    public var height: UInt16
    
    public var horizontalResolution: UInt32
    public var verticalResolution: UInt32
    public var entryDataSize: UInt32
    
    public var framesPerSample: UInt16
    
    public var compressorName: String // 32-byte

    public var bitDepth: UInt16
    public var colorTableIndex: Int16
    
    public var children: [MP4Box]
    
    public var reserved2: Data
    
    required public init(reader: any MP4Reader) async throws {
        
        self.reserved1 = try await reader.readData(count: 6)
        
        self.dataReferenceIndex = try await reader.readInteger(byteOrder: .bigEndian)
        
        self.version = try await reader.readInteger(byteOrder: .bigEndian)
        self.revisionLevel = try await reader.readInteger(byteOrder: .bigEndian)
        self.vendor = try await reader.readInteger(byteOrder: .bigEndian)
        
        self.temporalQuality = try await reader.readInteger(byteOrder: .bigEndian)
        self.spatialQuality = try await reader.readInteger(byteOrder: .bigEndian)
        
        self.width = try await reader.readInteger(byteOrder: .bigEndian)
        self.height = try await reader.readInteger(byteOrder: .bigEndian)
        
        self.horizontalResolution = try await reader.readInteger(byteOrder: .bigEndian)
        self.verticalResolution = try await reader.readInteger(byteOrder: .bigEndian)
        self.entryDataSize = try await reader.readInteger(byteOrder: .bigEndian)
        
        self.framesPerSample = try await reader.readInteger(byteOrder: .bigEndian)
        
        self.compressorName = try await reader.readAscii(byteCount: 32)

        self.bitDepth = try await reader.readInteger(byteOrder: .bigEndian)
        self.colorTableIndex = try await reader.readInteger(byteOrder: .bigEndian)
        
        assert(reader.offset == 78)
        self.children = try await MP4BoxParser(reader: reader).readBoxes()
        
        self.reserved2 = try await reader.readAllData()
    }

    public func writeContent(to writer: any MP4Writer) async throws {
        try await writer.write(reserved1)
        
        try await writer.write(dataReferenceIndex, byteOrder: .bigEndian)
        
        try await writer.write(version, byteOrder: .bigEndian)
        try await writer.write(revisionLevel, byteOrder: .bigEndian)
        try await writer.write(vendor, byteOrder: .bigEndian)
        
        try await writer.write(temporalQuality, byteOrder: .bigEndian)
        try await writer.write(spatialQuality, byteOrder: .bigEndian)
        
        try await writer.write(width, byteOrder: .bigEndian)
        try await writer.write(height, byteOrder: .bigEndian)
        
        try await writer.write(horizontalResolution, byteOrder: .bigEndian)
        try await writer.write(verticalResolution, byteOrder: .bigEndian)
        try await writer.write(entryDataSize, byteOrder: .bigEndian)
        
        try await writer.write(framesPerSample, byteOrder: .bigEndian)
        
        try await writer.write(compressorName, encoding: .ascii, length: 32)
        
        try await writer.write(bitDepth, byteOrder: .bigEndian)
        try await writer.write(colorTableIndex, byteOrder: .bigEndian)
        
        try await writer.write(children)
        
        try await writer.write(reserved2)
    }
}


extension MP4Avc1Box {
    public func makeFormatDescription() throws -> CMFormatDescription {
        // TODO: Missing Extensions:
        // Do i need them all?
        // CVImageBufferChromaLocationBottomField, VerbatimISOSampleEntry, CVImageBufferChromaLocationTopField, CVFieldCount, CVPixelAspectRatio, FullRangeVideo
        
        var extensions: CMFormatDescription.Extensions = .init()
        
        extensions[.formatName] = .string("avc1")
        extensions[.version] = .number(version)
        extensions[.revisionLevel] = .number(revisionLevel)
        extensions[.temporalQuality] = .number(temporalQuality)
        extensions[.spatialQuality] = .number(spatialQuality)
        extensions[.depth] = .number(bitDepth)

        if let avcCBox = firstChild(ofType: MP4AvcCBox.self) {
            let sampleDescriptionExtensionAtoms: NSDictionary = [
                "avcC": avcCBox.data as NSData
            ]
            extensions[.sampleDescriptionExtensionAtoms] = .init(sampleDescriptionExtensionAtoms)
        }
        
        if let colrBox = firstChild(ofType: MP4ColorParameterBox.self) {
            if let primaries = colrBox.colorPrimaries {
                extensions[.colorPrimaries] = .string(primaries)
            }
            if let transferFunction = colrBox.transferFunction {
                extensions[.transferFunction] = .string(transferFunction)
            }
            if let yCbCrMatrix = colrBox.yCbCrMatrix {
                extensions[.yCbCrMatrix] = .string(yCbCrMatrix)
            }
        }
        
        return try .init(videoCodecType: .h264, width: Int(width), height: Int(height), extensions: extensions)
    }
}