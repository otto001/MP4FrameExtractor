//
//  MP4SampleDescriptionBox.swift
//
//
//  Created by Matteo Ludwig on 19.11.23.
//

import Foundation


public class MP4SampleDescriptionBox: MP4ParsableBox {
    public static let typeName: String = "stsd"
    public static let fullyParsable: Bool = true
    
    public var version: UInt8
    public var flags: MP4BoxFlags
    
    public var children: [MP4Box]
    
    public required init(reader: any MP4Reader) async throws {
        self.version = try await reader.readInteger()
        self.flags = try await .init(readFrom: reader)
        
        
        //let entryCount: UInt32 = try await reader.readInteger(byteOrder: .bigEndian)
        reader.offset += MemoryLayout<UInt32>.size
        
        self.children = try await MP4BoxParser(reader: reader).readBoxes()
    }
}
