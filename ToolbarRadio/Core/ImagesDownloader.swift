//
//  ImagesDownloader.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 12/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import AppKit
import Combine
import SwifterSwift

class ImagesDownloader {
    
    static let shared = ImagesDownloader()

    private let session = URLSession.shared
    
    private let cacheFolder: URL = {
        let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let imagesCache = cache.appendingPathComponent("images")
        if !FileManager.default.fileExists(atPath: imagesCache.path) {
            do {
                try FileManager.default.createDirectory(at: imagesCache, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("error trying to create images cache directory: \(error)")
            }
        }
        return imagesCache
    }()
    
//    private var cache: [URL: URL] = [:]
//    private var tasks: [URL: Any] = [:]

    func download(_ url: URL, resize size: CGSize = .zero) -> AnyPublisher<URL?, URLSession.DataTaskPublisher.Failure> {
        
        let path = cacheFolder.appendingPathComponent(url.lastPathComponent)
        let type: NSBitmapImageRep.FileType
        if url.pathExtension.ends(with: "png") {
            type = .png
        } else if url.pathExtension.ends(with: "gif") {
            type = .gif
        } else {
            type = .jpeg
        }
        
        let imageTask = session.dataTaskPublisher(for: url)
            .map({ [weak self] response -> URL? in
                let data = self?.resize(response.data, to: size, fileType: type) ?? response.data
                guard !data.isEmpty else { return nil }
                do {
                    try data.write(to: path)
                } catch {
                    print("error trying to save image \(url) to \(path)")
                    return nil
                }
                return path
            }).eraseToAnyPublisher()
        
        return imageTask
    }
    
    private func resize(_ data: Data, to size: CGSize, fileType type: NSBitmapImageRep.FileType) -> Data {
        guard size.width > 0 && size.height > 0 else { return data }
        guard let image = NSImage(data: data) else { return data }
        
        let smaller = image.scaled(toMaxSize: size)
        guard let smallerData = smaller.tiffRepresentation else { return data }
        guard let smallerImageRep = NSBitmapImageRep(data: smallerData) else { return data }

        return smallerImageRep.representation(using: type, properties: [.compressionFactor: 0.7]) ?? data
    }
    
}
