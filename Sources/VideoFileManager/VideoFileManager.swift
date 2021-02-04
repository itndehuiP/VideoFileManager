
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
                let description = "Couldn't create directory \(error.localizedDescription)"
                print("Video File Manager [Info]: \(description)")
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
                let description = "Couldn't create Album directory \(error.localizedDescription)"
                print("Video File Manager [Info]: \(description)")
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
    /**
     Saves data to file, obtaining the data from the url passed.
     - Parameters:
     - Precondition: there must be valid data in the URL passed, valid id,
     - URL: The url where the data to saved is located. This should be a local URL.
     - album: the name of the folder where the data should be saved, if nil is passed, the data will be saved wihout a folder.
     - id: The name under wich the data will be saved.
     - removeFromOrigin: default value to true, if true removes data from the URL passed.
     - returns: Returns the URL where the data was saved.
     - Note: The URL returned just works per session, use the method LoadVideoInfo for recover the data saved.
     */
    public func saveVideo(url: URL?, album: String? = nil, id: String?, removeFromOrigin: Bool = true) -> URL? {
        guard let url = url, let data = try? Data(contentsOf: url), let id = id, let dataPath = dataDirectoryPath(album: album, with: id, createIfNeeded: true) else { return nil }
        do {
            try data.write(to: dataPath)
            if removeFromOrigin {
                deleteData(originalURL: url)
            }
        } catch {
            let description = "Couldn't save data from url with id: \(id) \(error.localizedDescription)"
            print("Video File Manager [Info]: \(description)")
        }
        return dataPath
    }
    /**
     Saves data to file
     - Parameters:
     - Precondition: the data passed must be valid, as well as the id.
     - data: the data to save.
     - album: the name of the folder where the data should be saved, if nil is passed, the data will be saved wihout a folder.
     - id: The name under wich the data will be saved.
     - returns: Returns the URL where the data was saved.
     - Note: The URL returned just works per session, use the method LoadVideoInfo for recover the data saved.
     */
    public func saveVideo(data: Data?, album: String? = nil, id: String?) -> URL? {
        guard let data = data, let id = id, let dataPath = dataDirectoryPath(album: album, with: id, createIfNeeded: true) else { return nil }
        do {
            try data.write(to: dataPath)
        } catch {
            let description = "Couldn't save data with id: \(id) \(error.localizedDescription)"
            print("Video File Manager [Info]: \(description)")
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
            let description = "Failed to delete main folder \(error.localizedDescription)"
            print("Video File Manager [Info]: \(description)")
        }
    }
    
    public func delete(album: String) {
        guard let albumPath = albumDirectoryPath(album: album, createIfNeeded: false) else { return }
        do {
            try FileManager.default.removeItem(at: albumPath)
        } catch {
            let description = "Failed to delete album folder: \(album). \(error.localizedDescription)"
            print("Video File Manager [Info]: \(description)")
        }
    }
    
    public func deleteVideo(album: String? = nil, id: String?) {
        guard let id = id, let dataPath = dataDirectoryPath(album: album, with: id, createIfNeeded: false) else { return }
        do {
            try FileManager.default.removeItem(at: dataPath)
        } catch {
            let description = "Failed to delete data with id \(id). \(error.localizedDescription)"
            print("Video File Manager [Info]: \(description)")
        }
    }
    
    private func deleteData(originalURL: URL) {
        do {
            try FileManager.default.removeItem(at: originalURL)
        } catch {
            let description = "Failed to delete data in url passed. \(error.localizedDescription)"
            print("Video File Manager [Info]: \(description)")
        }
    }

}
