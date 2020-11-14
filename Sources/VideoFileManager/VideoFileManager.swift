
import Foundation

public struct VideoFileManager {
    public init() {}
    private let mainFolder = "VideoFileManager"
    
    private var directoryPath: URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      let folderDirectoryURL = paths.first!.appendingPathComponent(mainFolder)
        return folderDirectoryURL
    }
    
    private func directoryPath(createIfNeeded: Bool) -> URL {
        if createIfNeeded {
            do {
              try FileManager.default.createDirectory(at: directoryPath,
                                                      withIntermediateDirectories: true,
                                                      attributes: nil)
            } catch {
                  print("Couldn't create directory \(error.localizedDescription)")
            }
        }
        return directoryPath
    }
    
    private func albumDirectoryPath(album: String, createIfNeeded: Bool) -> URL? {
        let albumDirectoryURL = directoryPath(createIfNeeded: createIfNeeded).appendingPathComponent(album, isDirectory: true)
        if createIfNeeded {
            do {
                try FileManager.default.createDirectory(at: albumDirectoryURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print("Couldn't create directory \(error.localizedDescription)")
            }
        }
        return albumDirectoryURL
    }
    
    private func dataDirectoryPath(album: String? = nil, with id: String, createIfNeeded: Bool) -> URL? {
        guard !id.isEmpty else { return nil }
        if let album = album {
            return albumDirectoryPath(album: album, createIfNeeded: createIfNeeded)?.appendingPathComponent(id).appendingPathExtension("MP4")

        } else {
            return directoryPath(createIfNeeded: createIfNeeded).appendingPathComponent(id).appendingPathExtension("MP4")
        }
    }
    
    public func saveVideo(url: URL?, album: String? = nil, id: String?) -> URL? {
        guard let url = url, let data = try? Data(contentsOf: url), let id = id, let dataPath = dataDirectoryPath(album: album, with: id, createIfNeeded: true) else { return nil }
        do {
            try data.write(to: dataPath)
            deleteData(originalURL: url)
        } catch {
            print("Couldn't write to save file: " + error.localizedDescription)
        }
        return dataPath
    }
    
    public func loadVideoInfo(album: String? = nil, id: String?, recoverData: Bool = false) -> (URL?, Data?) {
        guard let id = id, let dataPath = dataDirectoryPath(album: album, with: id, createIfNeeded: false) else { return (nil, nil) }
        return (dataPath, recoverData ? try? Data(contentsOf: dataPath) : nil)
    }
    
    //MARK: Delete
    public func deleteAll() {
        do {
            try FileManager.default.removeItem(at: directoryPath(createIfNeeded: false))
        } catch {
            print("Error Deleting Folder. " + error.localizedDescription)
        }
    }
    
    public func delete(album: String) {
        guard let albumPath = albumDirectoryPath(album: album, createIfNeeded: false) else { return }
        do {
            try FileManager.default.removeItem(at: albumPath)
        } catch {
            print("Error Deleting Folder. " + error.localizedDescription)
        }
    }
    
    public func deleteVideo(album: String? = nil, id: String?) {
        guard let id = id, let dataPath = dataDirectoryPath(album: album, with: id, createIfNeeded: false) else { return }
        do {
            try FileManager.default.removeItem(at: dataPath)
        } catch {
            print("Error Deleting Folder. " + error.localizedDescription)
        }
    }
    
    private func deleteData(originalURL: URL) {
        do {
            try FileManager.default.removeItem(at: originalURL)
        } catch {
            print("Error deleting from temporary. " + error.localizedDescription)
        }
    }

}
