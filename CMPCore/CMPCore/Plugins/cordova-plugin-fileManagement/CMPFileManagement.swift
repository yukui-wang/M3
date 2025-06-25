//
//  CMPFileManagement.swift
//  M3
//
//  Created by MacBook on 2019/10/8.
//

import UIKit

class CMPFileManagement: CDVPlugin,UIDocumentPickerDelegate {
    lazy var fileMgr : SyFileProvider = SyFileProvider.instance()
    func showDocumentPickerView(command : CDVInvokedUrlCommand?) {
        
        let documentTypes = ["public.content", "public.text", "public.source-code ", "public.image", "public.audiovisual-content", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt"]
        let documentPickerVC = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        documentPickerVC.delegate = self
        if #available(iOS 11.0, *) {
            documentPickerVC.allowsMultipleSelection = false
        } else {
            // Fallback on earlier versions
        }
        viewController.navigationController?.present(documentPickerVC, animated: true, completion: nil)
    }
    
    func getAllFiles(command : CDVInvokedUrlCommand) {
        let result = CDVPluginResult(status: CDVCommandStatus.init(1), messageAs: ["ok"])
        commandDelegate.send(result, callbackId: command.callbackId)
    }
    
    func getAllTypes(command : CDVInvokedUrlCommand) {
        let filePages = fileMgr.findOfflineFiles(withStart: 0, rowCount: 20)
        
        
    }
    
    
    
    func deleteFile(command : CDVInvokedUrlCommand?) {
        
    }
    
    func deleteFiles(command : CDVInvokedUrlCommand?) {
        
    }
    
    
    // MARK: - UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
    }
    
}
