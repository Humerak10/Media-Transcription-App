//
//  ViewController.swift
//  MediaApp
//
//  Created by Humera Khan on 08/02/25.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController, UIDocumentPickerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // ✅ Button Action for Selecting a Folder
    @IBAction func selectFolderButtonTapped(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }

    // ✅ Handle Folder Selection
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFolder = urls.first else { return }
        
        print("📂 Selected Folder: \(selectedFolder.path)")
        
        // ✅ Scan the selected folder for media files
        let mediaFiles = scanFolder(at: selectedFolder).map { $0.lastPathComponent }
        
        if mediaFiles.isEmpty {
            showAlert(title: "No Media Found", message: "No media files were found in the selected folder.", viewController: self)
        } else {
            saveToJsonFile(mediaFiles, in: selectedFolder)
        }
    }

    // ✅ Scan Folder for Media Files
    func scanFolder(at url: URL) -> [URL] {
        var mediaFiles: [URL] = []
        let fileManager = FileManager.default
        
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                if isMediaFile(fileURL) {
                    mediaFiles.append(fileURL)
                }
            }
        }
        return mediaFiles
    }

    // ✅ Check if a File is a Media File
    func isMediaFile(_ url: URL) -> Bool {
        let allowedExtensions = ["mp3", "wav", "mp4", "mkv", "aac", "flac"]
        return allowedExtensions.contains(url.pathExtension.lowercased())
    }

    // ✅ Save Media File List to JSON
    func saveToJsonFile(_ files: [String], in folderURL: URL) {
        let jsonFileURL = folderURL.appendingPathComponent("media_files.json")

        // ✅ Convert File List to JSON Data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: files, options: .prettyPrinted) else {
            showAlert(title: "Error", message: "Invalid JSON data", viewController: self)
            return
        }

        do {
            try jsonData.write(to: jsonFileURL)
            print("✅ JSON file saved at: \(jsonFileURL.path)") // Debugging
            
            // ✅ Show Success Alert
            showAlert(title: "Success", message: "JSON file saved at:\n\(jsonFileURL.path)", viewController: self)
        } catch {
            print("❌ Error saving JSON file: \(error.localizedDescription)")
            showAlert(title: "Error", message: "Failed to save JSON file: \(error.localizedDescription)", viewController: self)
        }
    }

    // ✅ Function to Show Alerts
    func showAlert(title: String, message: String, viewController: UIViewController?) {
        guard let vc = viewController else {
            print("⚠️ No view controller provided for alert")
            return
        }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }
}
