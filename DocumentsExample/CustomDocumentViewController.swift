//
//  CustomDocumentViewController.swift
//
//  Created by Chris Van Buskirk on 2/9/25.
//

import UIKit

/// A custom document view controller that lets you choose the type of document to manage.
class CustomDocumentViewController: UIDocumentViewController, UITextViewDelegate {

    // A text view that will display either the rich or plain text content.
    private let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launchOptions.browserViewController.delegate = self

        launchOptions.background.image = BackgroundImageView().asUIImage(size: view.frame.size)
        launchOptions.foregroundAccessoryView = AccessoryUIView()
        let templateAction = LaunchOptions.createDocumentAction(withIntent: .template)
        templateAction.title = "Choose a Template"
        launchOptions.secondaryAction = templateAction
        self.configureDocument()
    }
    
    // Do your navigation item stuff in here. Use the new toolbar content.
    override func navigationItemDidUpdate() {
        super.navigationItemDidUpdate()
        navigationItem.centerItemGroups = [undoRedoItemGroup]
    }
    
    // Overriding documentDidOpen to add custom behavior after the document is opened.
    override func documentDidOpen() {
        super.documentDidOpen()
        self.configureDocument()
    }
    
    private func configureDocument() {
        guard let document = document, !document.documentState.contains(.closed) && isViewLoaded else { return }
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            // Update constraints to account for navigation bar
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        textView.delegate = self // Set the delegate
        // Determine which document was opened and update the UI accordingly.
        if let richDocument = self.document as? RichDocument {
            print("Opened a RichDocument.")
            setupRichDocumentUI(with: richDocument)
            
        } else if let textDocument = self.document as? TextDocument {
            print("Opened a TextDocument.")
            setupTextDocumentUI(with: textDocument)
            
        } else {
            print("Opened an unknown document type.")
        }
        
        // Add observers for undo/redo notifications to update the UI when an undo/redo happens.
        if let undoManager = self.document?.undoManager {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(undoRedoNotification(_:)),
                name: .NSUndoManagerDidUndoChange,
                object: undoManager
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(undoRedoNotification(_:)),
                name: .NSUndoManagerDidRedoChange,
                object: undoManager
            )
        }
    }
    
    @objc private func undoRedoNotification(_ notification: Notification) {
        // Update the UI based on the current document's content.
        if let richDocument = self.document as? RichDocument {
            textView.attributedText = richDocument.attributedText
            // Ensure the text color is set correctly for dark mode
            textView.textColor = UIColor.label
        } else if let textDocument = self.document as? TextDocument {
            textView.text = textDocument.text
        }
    }
    
    deinit {
        if let undoManager = self.document?.undoManager {
            NotificationCenter.default.removeObserver(
                self,
                name: .NSUndoManagerDidUndoChange,
                object: undoManager
            )
            NotificationCenter.default.removeObserver(
                self,
                name: .NSUndoManagerDidRedoChange,
                object: undoManager
            )
        }
    }
    
    // Configure UI for a rich document using the document's attributedText
    private func setupRichDocumentUI(with document: RichDocument) {
        textView.attributedText = document.attributedText
        textView.backgroundColor = UIColor.systemGroupedBackground
        textView.textColor = UIColor.label
    }
    
    // Configure UI for a text document using the document's text
    private func setupTextDocumentUI(with document: TextDocument) {
        textView.text = document.text
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.backgroundColor = UIColor.white
        textView.textColor = UIColor.black
    }
    
    // UITextViewDelegate method to update document when text changes
    func textViewDidChange(_ textView: UITextView) {
        if let richDocument = self.document as? RichDocument {
            richDocument.attributedText = textView.attributedText
        } else if let textDocument = self.document as? TextDocument {
            textDocument.text = textView.text
        }
    }
} 

// Mark: UIDocumentBrowserViewController Delegate
extension CustomDocumentViewController: UIDocumentBrowserViewControllerDelegate {
    
       
   func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
       for url in documentURLs {
           // Create the appropriate document type based on file extension
           let document: UIDocument
           if url.pathExtension == "exampletext" {
               document = TextDocument(fileURL: url)
           } else if url.pathExtension == "sampledoc" {
               document = RichDocument(fileURL: url)
           } else {
               print("Unsupported file type: \(url.pathExtension)")
               continue
           }
           
           // Create the document view controller
           let documentViewController = CustomDocumentViewController()
           documentViewController.document = document
           let navigationController = UINavigationController(rootViewController: documentViewController)
           navigationController.modalPresentationStyle = .fullScreen
           
           // Check if running on macCatalyst
           #if targetEnvironment(macCatalyst)
           // Request a new window scene
           let activity = NSUserActivity(activityType: "com.touchedmedia.documents")
           activity.userInfo = ["documentURL": url]
           
           UIApplication.shared.requestSceneSessionActivation(
               nil,
               userActivity: activity,
               options: nil
           ) { error in
               print("Failed to open window: \(error)")
           }
           #else
           // On iOS, present modally in the same window
           controller.present(navigationController, animated: true)
           #endif
       }
   }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        switch controller.activeDocumentCreationIntent {
        case .template:
            presentTemplatePicker(with: importHandler)
        default:
            presentAlert(with: controller, importHandler: importHandler)
        }
    }
    
    private func presentTemplatePicker(with importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let templatePicker = TemplatePickerViewController()
        templatePicker.modalPresentationStyle = .formSheet
        templatePicker.completion = { [weak self] fileExtension, templateName in
            if fileExtension.isEmpty {
                importHandler(nil, .none)
            } else {
                self?.createNewDocument(
                    withExtension: fileExtension,
                    templateName: templateName,
                    importHandler: importHandler
                )
            }
        }
        
        present(templatePicker, animated: true)
    }
    
    private func presentAlert(with controller: UIDocumentBrowserViewController,
                                   importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let alertController = UIAlertController(
            title: "Create New Document",
            message: "Choose the type of document to create",
            preferredStyle: .actionSheet
        )
        
        // Action for plain text document
        let textAction = UIAlertAction(title: "Text Document", style: .default) { [weak self] _ in
            self?.createNewDocument(
                withExtension: "exampletext",
                templateName: "TextTemplate",
                importHandler: importHandler
            )
        }
        
        // Action for rich text document
        let richAction = UIAlertAction(title: "Rich Document", style: .default) { [weak self] _ in
            self?.createNewDocument(
                withExtension: "sampledoc",
                templateName: "RichTemplate",
                importHandler: importHandler
            )
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            importHandler(nil, .none)
        }
        
        alertController.addAction(textAction)
        alertController.addAction(richAction)
        alertController.addAction(cancelAction)
        
        // For iPad and Mac Catalyst compatibility
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = controller.view
            popoverController.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // Present on the document browser controller instead of self
        controller.present(alertController, animated: true)
    }
    
    private func createNewDocument(
        withExtension ext: String,
        templateName: String,
        importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void
    ) {
        guard let templateURL = Bundle.main.url(forResource: templateName, withExtension: ext) else {
            print("Template file not found: \(templateName).\(ext). Please ensure the template file is added to the project and included in the target's bundle.")
            importHandler(nil, .none)
            return
        }
        
        let documentName: String
        if ext == "exampletext" {
            documentName = "TextDocument"
        } else if ext == "sampledoc" {
            documentName = "RichDocument"
        } else {
            print("Unsupported document type: \(ext)")
            importHandler(nil, .none)
            return
        }
        
        let newDocumentURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(documentName)
            .appendingPathExtension(ext)
        do {
            if FileManager.default.fileExists(atPath: newDocumentURL.path) {
                try FileManager.default.removeItem(at: newDocumentURL)
            }
            try FileManager.default.copyItem(at: templateURL, to: newDocumentURL)
            importHandler(newDocumentURL, .move)
        } catch {
            print("Error creating document from template: \(error.localizedDescription)")
            importHandler(nil, .none)
        }
    }
}

extension UIDocument.CreationIntent {
    static let template = UIDocument.CreationIntent("template")
}
