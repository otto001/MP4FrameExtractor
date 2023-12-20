//
//  MP4MetadataKeyDeclarationBox.swift
//  
//
//  Created by Matteo Ludwig on 01.12.23.
//

import Foundation


public class MP4MetadataKeyDeclarationBox: MP4ParsableBox {
    public static let typeName: MP4FourCC = "keyd"
    public static let supportedChildBoxTypes: MP4BoxTypeMap = []
    
    public var namespace: String
    public var value: Data
    
    var stringValue: String? {
        return String(data: value, encoding: .ascii)
    }
    
    public required init(reader: MP4SequentialReader) async throws {
        self.namespace = try await reader.readAscii(byteCount: 4)
        self.value = try await reader.readAllData()
    }
    
    public func writeContent(to writer: any MP4Writer) async throws {
        try await writer.write(namespace, encoding: .ascii)
        try await writer.write(value)
    }
}
