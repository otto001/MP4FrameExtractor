//
//  MP4ChunkOffsetBox.swift
//
//
//  Created by Matteo Ludwig on 19.11.23.
//

import Foundation

public protocol MP4ChunkOffsetBox: MP4FullBox {
    func chunkOffset(of chunk: MP4Index<UInt32>) -> Int
    func setChunkOffset(of chunk: MP4Index<UInt32>, to offset: Int)
    func moveChunks(by offset: Int)
}

public class MP4ChunkOffset32Box: MP4ChunkOffsetBox {
    public static let typeName: MP4FourCC = "stco"

    public var readByteRange: Range<Int>?
    
    public var version:  MP4BoxVersion
    public var flags: MP4BoxFlags
    
    public var chunkOffsets: [UInt32]
    
    public init(version:  MP4BoxVersion, flags: MP4BoxFlags, chunkOffsets: [UInt32]) {
        self.version = version
        self.flags = flags
        self.chunkOffsets = chunkOffsets
    }
    
    public required init(contentReader reader: MP4SequentialReader) async throws {
        self.version = try await reader.read()
        self.flags = try await reader.read()
        
        self.chunkOffsets = []
        let entryCount: UInt32 = try await reader.readInteger(byteOrder: .bigEndian)
        for _ in 0..<entryCount {
            self.chunkOffsets.append(try await reader.readInteger(byteOrder: .bigEndian))
        }
    }
    
    public func writeContent(to writer: MP4Writer) async throws {
        try await writer.write(version)
        try await writer.write(flags)
        
        try await writer.write(UInt32(chunkOffsets.count), byteOrder: .bigEndian)
        
        for chunkOffset in chunkOffsets {
            try await writer.write(chunkOffset, byteOrder: .bigEndian)
        }
    }
    
    public var overestimatedContentByteSize: Int {
        8 + chunkOffsets.count * 4
    }
    
    public func chunkOffset(of chunk: MP4Index<UInt32>) -> Int {
        return Int(chunkOffsets[chunk])
    }
    
    public func setChunkOffset(of chunk: MP4Index<UInt32>, to offset: Int) {
        chunkOffsets[chunk] = UInt32(offset)
    }
    
    public func moveChunks(by offset: Int) {
        let offset = UInt32(offset)
        chunkOffsets = chunkOffsets.map { $0 + offset }
    }
}


public class MP4ChunkOffset64Box: MP4ChunkOffsetBox {
    public static let typeName: MP4FourCC = "co64"

    public var readByteRange: Range<Int>?
    
    public var version:  MP4BoxVersion
    public var flags: MP4BoxFlags
    
    public var chunkOffsets: [UInt64]
    
    public init(version:  MP4BoxVersion, flags: MP4BoxFlags, chunkOffsets: [UInt64]) {
        self.version = version
        self.flags = flags
        self.chunkOffsets = chunkOffsets
    }
    
    public required init(contentReader reader: MP4SequentialReader) async throws {
        self.version = try await reader.read()
        self.flags = try await reader.read()
        
        self.chunkOffsets = []
        let entryCount: UInt32 = try await reader.readInteger(byteOrder: .bigEndian)
        for _ in 0..<entryCount {
            self.chunkOffsets.append(try await reader.readInteger(byteOrder: .bigEndian))
        }
    }
    
    public func writeContent(to writer: MP4Writer) async throws {
        try await writer.write(version)
        try await writer.write(flags)
        
        try await writer.write(UInt32(chunkOffsets.count), byteOrder: .bigEndian)
        
        for chunkOffset in chunkOffsets {
            try await writer.write(chunkOffset, byteOrder: .bigEndian)
        }
    }
    
    public var overestimatedContentByteSize: Int {
        8 + chunkOffsets.count * 8
    }
    
    public func chunkOffset(of chunk: MP4Index<UInt32>) -> Int {
        return Int(chunkOffsets[chunk])
    }
    
    public func setChunkOffset(of chunk: MP4Index<UInt32>, to offset: Int) {
        chunkOffsets[chunk] = UInt64(offset)
    }
    
    public func moveChunks(by offset: Int) {
        let offset = UInt64(offset)
        chunkOffsets = chunkOffsets.map { $0 + offset }
    }
}
