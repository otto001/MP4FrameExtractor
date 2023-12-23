//
//  MP4VideoMediaHeaderBox.swift
//
//
//  Created by Matteo Ludwig on 23.12.23.
//

import Foundation


public class MP4VideoMediaHeaderBox: MP4VersionedBox {
    public static let typeName: MP4FourCC = "vmhd"

    public var version: UInt8
    public var flags: MP4BoxFlags
    
    public var graphicsMode: MP4VideoGraphicsMode
    public var opColor: (UInt16, UInt16, UInt16)
    
    required public init(reader: MP4SequentialReader) async throws {
        self.version = try await reader.read()
        self.flags = try await reader.read()

        self.graphicsMode = try await reader.read()
        self.opColor = (try await reader.readInteger(byteOrder: .bigEndian),
                        try await reader.readInteger(byteOrder: .bigEndian),
                        try await reader.readInteger(byteOrder: .bigEndian))
    }
    
    public func writeContent(to writer: MP4Writer) async throws {
        try await writer.write(version)
        try await writer.write(flags)
        
        try await writer.write(self.graphicsMode)
        try await writer.write(self.opColor.0, byteOrder: .bigEndian)
        try await writer.write(self.opColor.1, byteOrder: .bigEndian)
        try await writer.write(self.opColor.2, byteOrder: .bigEndian)
    }
}
