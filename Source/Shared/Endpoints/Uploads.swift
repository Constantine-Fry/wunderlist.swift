//
//  Uploads.swift
//  Wunderlist
//
//  Created by Constantine Fry on 05/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation
import MobileCoreServices

/** 
    Represents Upload endpoint on Wunderilst.
    https://developer.wunderlist.com/documentation/endpoints/upload
*/
public class Uploads: Endpoint {
    override var endpoint: String {
        return "uploads"
    }
    
    /** 
        Perform three steps for fil uploading:
            1. Requests upload URL.
            2. Uploads file as on chunk.
            3. Marks upload as finished.
    */
    public func uploadFileAtURL(fileURL:NSURL, completionHandler: (uploadInfo: UploadInfo?, error: NSError?) -> Void) {
        let getURLTask = self.getUploadURLForFileAtURL(fileURL) {
            (uploadInfo, error) -> Void in
            if uploadInfo != nil {
                
                let uploadTask = self.uploadFile(fileURL, uploadInfo: uploadInfo!) {
                    (uploaded, error) -> Void in
                    if uploaded {
                        
                        let markTask = self.markUploadAsFinished(uploadInfo!.identifier) {
                            (marked, error) -> Void in
                            if marked {
                                completionHandler(uploadInfo: uploadInfo, error: nil)
                            } else {
                                completionHandler(uploadInfo: nil, error: error)
                            }
                        } // self.markUploadAsFinishe
                        markTask.start()
                        
                    } else {
                        completionHandler(uploadInfo: nil, error: error)
                    }
                } // self.uploadFile
                uploadTask.start()
                
            } else {
                completionHandler(uploadInfo: nil, error: error)
            }
        } // self.getUploadURLForFileAtURL
        getURLTask.start()
    }
    
    /* This is the first step: receive upload URL. */
    public func getUploadURLForFileAtURL(fileURL:NSURL, completionHandler: (uploadInfo: UploadInfo?, error: NSError?) -> Void) -> SessionTask {
        var UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileURL.pathExtension as NSString?, nil)
        var tag = UTTypeCopyPreferredTagWithClass(UTI.takeUnretainedValue(), kUTTagClassMIMEType)
        
        var error: NSError?
        let properties = fileURL.resourceValuesForKeys([NSURLFileSizeKey], error: &error) as [String: UInt]?
        if properties == nil {
            fatalError("Can't read file size \(error)")
        }
        let contentType = tag.takeUnretainedValue() as String
        let fileName = fileURL.lastPathComponent as String!
        var parameters = [
            "content_type"  : contentType as String,
            "file_name"     : fileName as String
            ] as [String: AnyObject]
        if let fileSize = properties?[NSURLFileSizeKey] {
            parameters["file_size"] = fileSize
        }
        return taskWithPath(nil, parameters: parameters, HTTPMethod: "POST", transformClosure: { UploadInfo(JSON: $0) })  {
            (result, error) -> Void in
            completionHandler(uploadInfo: result as UploadInfo?, error: error)
        }
    }
    
    /* This is the second step: actual upload. */
    public func uploadFile(fileURL: NSURL, uploadInfo: UploadInfo, completionHandler: (uploaded: Bool, error: NSError?) -> Void) -> SessionUploadTask {
        return uploadTaskWithFileURL(fileURL, uploadInfo: uploadInfo) {
            (finished, error) -> Void in
            completionHandler(uploaded: finished, error: error)
        }
    }
    
    /** The last step: finilize uploading. */
    public func markUploadAsFinished(uploadId: Int, completionHandler: (marked: Bool, error: NSError?) -> Void)  -> SessionTask {
        let path = String(uploadId)
        let parameters = [
            "state" : "finished"
        ]
        return taskWithPath(path, parameters: parameters, HTTPMethod: "PATCH", transformClosure: nil) {
            (result, error) -> Void in
            completionHandler(marked: error == nil, error: error)
        }
    }
    
    
    private func uploadTaskWithFileURL(fileURL: NSURL, uploadInfo: UploadInfo, completionHandler: ((fineshed: Bool, error: NSError?) -> Void)?) -> SessionUploadTask {
        if uploadInfo.uploadURL == nil {
            fatalError("Incorrect upload info")
        }
        
        let request = NSMutableURLRequest(URL: uploadInfo.uploadURL!)
        request.HTTPMethod = "PUT"
        request.setValue(uploadInfo.authorization,  forHTTPHeaderField: "Authorization")
        request.setValue(uploadInfo.date,           forHTTPHeaderField: "x-amz-date")
        request.setValue(uploadInfo.contentType,    forHTTPHeaderField: "Content-Type")
        
        return
            SessionUploadTask(
            session: session,
            fileURL: fileURL,
            request: request,
            completionHandler: completionHandler)
    }
}
