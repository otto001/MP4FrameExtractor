//
//  MP4SampleToChunkBox.swift
//
//
//  Created by Matteo Ludwig on 19.11.23.
//

import Foundation


public class MP4SampleToChunkBox: MP4VersionedBox {
    public static let typeName: String = "stsc"
    public static let fullyParsable: Bool = true
    
    public var version: UInt8
    public var flags: MP4BoxFlags
    
    /// All chunks starting at this index up to the next first chunk have the same sample count/description
    public var firstChuck: [MP4Index<UInt32>]
    /// Number of samples in the chunk
    public var samplesPerChunk: [UInt32]
    /// Description (see the sample description box - stsd)
    public var sampleDescriptionID: [UInt32]
    
    public init(version: UInt8, flags: MP4BoxFlags, firstChuck: [MP4Index<UInt32>], samplesPerChunk: [UInt32], sampleDescriptionID: [UInt32]) {
        self.version = version
        self.flags = flags
        self.firstChuck = firstChuck
        self.samplesPerChunk = samplesPerChunk
        self.sampleDescriptionID = sampleDescriptionID
    }
    
    public required init(reader: any MP4Reader) async throws {
        self.version = try await reader.readInteger()
        self.flags = try await .init(readFrom: reader)
        
        self.firstChuck = []
        self.samplesPerChunk = []
        self.sampleDescriptionID = []
        
        let entryCount: UInt32 = try await reader.readInteger(byteOrder: .bigEndian)
        for _ in 0..<entryCount {
            self.firstChuck.append(.init(index1: try await reader.readInteger(byteOrder: .bigEndian)))
            self.samplesPerChunk.append(try await reader.readInteger(byteOrder: .bigEndian))
            self.sampleDescriptionID.append(try await reader.readInteger(byteOrder: .bigEndian))
        }
    }
    
    public struct SamplePosition: Equatable, Hashable {
        public var chunk: MP4Index<UInt32>
        public var sampleOfChunkIndex: MP4Index<UInt32>
    }
    

    public func samplePosition(for sample: MP4Index<UInt32>) -> SamplePosition {
        
        var currentChunkGroup: MP4Index<UInt32> = .zero
        var currentChunkIndex: MP4Index<UInt32> = .zero
        
        //var currentChunkStartSample: MP4Index<UInt32> = .init(index0: 0)
        var currentChunkEndSample: MP4Index<UInt32> = .init(index0: samplesPerChunk[currentChunkGroup])
        
        while sample >= currentChunkEndSample {
            
            currentChunkIndex += 1
            if currentChunkGroup.index0 < firstChuck.count && currentChunkIndex >= firstChuck[currentChunkGroup + 1] {
                currentChunkGroup += 1
            }
            
            //currentChunkStartSample = currentChunkEndSample
            currentChunkEndSample += samplesPerChunk[currentChunkGroup]
        }
        
        return SamplePosition(chunk: currentChunkIndex, 
                              sampleOfChunkIndex: sample - (currentChunkEndSample - samplesPerChunk[currentChunkGroup]))
    }
}
