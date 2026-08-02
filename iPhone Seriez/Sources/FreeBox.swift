//
//  FreeBox.swift
//  SerieA
//
//  Created by Cyril DELAMARE on 11/11/2025.
//  Copyright © 2025 Home. All rights reserved.
//

import Foundation
import CommonCrypto
import Security

final class FreeboxTrustDelegate: NSObject, URLSessionDelegate {
    private let trustedCACertificates: [SecCertificate]
    
    override init() {
        // Load CA certificate(s) from bundle
        //let certNames = ["freebox_ecc_root_ca", "freebox_root_ca"]
        let certNames = ["freebox_ecc_root_ca"]
        //let certNames = ["freebox_root_ca"]
        print("FreeBox::FreeboxTrustDelegate init start")
        self.trustedCACertificates = certNames.compactMap { name in
            guard let certURL = Bundle.main.url(forResource: name, withExtension: "pem"),
                  let pemString = try? String(contentsOf: certURL, encoding: .utf8),
                  let derData = FreeboxTrustDelegate.pemToDER(pemString: pemString) else { return nil }
            return SecCertificateCreateWithData(nil, derData as CFData)
        }
        print("FreeBox::FreeboxTrustDelegate init end")
        super.init()
    }
    
    // PEM to DER converter
    private static func pemToDER(pemString: String) -> Data? {
        guard let base64 = pemString
            .components(separatedBy: "-----")
            .filter({ !$0.contains("BEGIN") && !$0.contains("END") })
            .joined()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined() as String?,
              let data = Data(base64Encoded: base64) else { return nil }
        return data
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        // Set the trusted CA(s) as anchors
        SecTrustSetAnchorCertificates(serverTrust, trustedCACertificates as CFArray)
        // Only trust these anchors (not built-in)
        SecTrustSetAnchorCertificatesOnly(serverTrust, true)
        var error: CFError?
        let isTrusted = SecTrustEvaluateWithError(serverTrust, &error)
        if isTrusted {
            print("FreeBox::FreeboxTrustDelegate urlSession Trusted")
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("FreeBox::FreeboxTrustDelegate urlSession not Trusted")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

class SSLAcceptingDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            print("FreeBox::SSLAcceptingDelegate serverTrust")
            completionHandler(.useCredential, credential)
        } else {
            print("FreeBox::SSLAcceptingDelegate nil")
            completionHandler(.performDefaultHandling, nil)
        }
    }
}



class FreeBox : NSObject {
    var chrono : TimeInterval = 0
    
    let FreeBoxWiFiURL : String = "https://mafreebox.freebox.fr/api/v15/"
    let FreeBoxWebURL : String = "https://im5fyobr.fbxos.fr:57058/api/v15/"
    var FreeBoxBaseURL : String = ""
    let FreeBoxClientID : String = "44e9b9a92278adc49099f599d6b2a5be19b63e4812dbb7b335b459f8d0eb195c"
    let FreeBoxAppID : String = "Home.SerieA"
    var AppToken : String = "Hxs2ZJY/COFBr2SNj/TtpHj32EI0Y9HBgncROMNlkmlieZYT4eNg+uJEV+gnVpL4"
    var RefreshToken : String = ""
    var TokenExpiration : Date!
    
    override init() {
        super.init()
        FreeBoxBaseURL = FreeBoxWiFiURL
        print("FreeBox::init ok")
    }
    
    
    func initializeToken() {
        
        var request = URLRequest(url: URL(string: FreeBoxBaseURL+"login/authorize/")!)
        let body : String = "{\"app_id\":\"\(FreeBoxAppID)\",\"app_name\":\"Une Serie ?\",\"app_version\":\"1.0\",\"device_name\":\"IOS\"}"
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        let session = URLSession(configuration: .default, delegate: FreeboxTrustDelegate(), delegateQueue: nil)
        //let session = URLSession(configuration: .default, delegate: SSLAcceptingDelegate(), delegateQueue: nil)
        
        print("FreeBox::initializeToken variables ok")
        
        let task = session.dataTask(with: request) { data, response, error in
            print("FreeBox::initializeToken session ok")
            if let data = data, let response = response as? HTTPURLResponse {
                //                if let data = data, let response = response as? HTTPURLResponse {
                do {
                    
                    print("FreeBox::initializeToken data ok")
                    
                    if (response.statusCode != 200) { print("FreeBox::initializeToken error \(response.statusCode) received"); return; }
                    
                    print("FreeBox::initializeToken statusCode ok")
                    
                    let result : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary ?? NSDictionary()
                    
                    if ((result.object(forKey: "success") as? Bool ?? false) == true) {
                        self.AppToken = ((result as AnyObject).object(forKey: "result")! as AnyObject).object(forKey: "app_token") as? String ?? ""
                        let id : Int = ((result as AnyObject).object(forKey: "result")! as AnyObject).object(forKey: "track_id") as? Int ?? 0
                        
                        print("FreeBox::initializeToken : Token = \(self.AppToken) for id = \(id)")
                    }
                    else {
                        let error_code : String = result.object(forKey: "error_code") as? String ?? ""
                        let msg : String = result.object(forKey: "msg") as? String ?? ""
                        
                        print("FreeBox::initializeToken : Error = \(error_code) = \(msg)")
                    }
                } catch let error as NSError { print("FreeBox::initializeToken \(error.localizedDescription)") }
            } else { print(error as Any);  }
        }
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { usleep(1000) }
    }
}


//
//
//struct FreeboxConfig {
//    static let localBaseURL = URL(string: "https://mafreebox.freebox.fr/api/v15/")!
//    static let remoteBaseURL = URL(string: "https://im5fyobr.fbxos.fr:57058/api/v10/")! // <- ton domaine distant
//    //static let localBaseURL = URL(string: "https://mafreebox.freebox.fr/api/v10/")!
//    //static let remoteBaseURL = URL(string: "https://xxxxx.freeboxos.fr/api/v10/")! // <- ton domaine distant
//    // https://im5fyobr.fbxos.fr:57058/
//    static let baseURL = localBaseURL
//    static let appId = "Home.SerieA"
//    static let appName = "Une Serie ?"
//    static let appVersion = "1.0"
//    //static let deviceName = UIDevice.current.name
//}


//    func openSession(appToken: String) {
//        let urlChallenge = URL(string: FreeBoxBaseURL+"login/")!
//
//        URLSession.shared.dataTask(with: urlChallenge) { data, _, _ in
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                  let result = json["result"] as? [String: Any],
//                  let challenge = result["challenge"] as? String
//            else { return }
//
//            let password = self.hmacSHA1(key: appToken, message: challenge)
//
//            let urlSession = URL(string: self.FreeBoxBaseURL+"login/session/")!
//            let jsonLogin: [String: Any] = [ "app_id": self.FreeBoxAppID, "password": password]
//            var req = URLRequest(url: urlSession)
//            req.httpMethod = "POST"
//            req.httpBody = try? JSONSerialization.data(withJSONObject: jsonLogin)
//            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            URLSession.shared.dataTask(with: req) { data, _, _ in
//                guard let data = data,
//                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                      let result = json["result"] as? [String: Any],
//                      let sessionToken = result["session_token"] as? String
//                else { return }
//
//                print("🔐 Session ouverte sur :", self.FreeBoxBaseURL)
//                print("🔐 Et le Session token est :", sessionToken)
//            }.resume()
//        }.resume()
//    }
//

//
//func detectFreeboxBaseURL(completion: @escaping (URL?) -> Void) {
//    let session = URLSession(configuration: .default, delegate: SSLAcceptingDelegate(), delegateQueue: nil)
//
//    let urlsToTry = [FreeboxConfig.localBaseURL, FreeboxConfig.remoteBaseURL]
//    var currentIndex = 0
//
//    func tryNext() {
//        guard currentIndex < urlsToTry.count else {
//            completion(nil)
//            return
//        }
//        let testURL = urlsToTry[currentIndex].appendingPathComponent("api_version")
//        currentIndex += 1
//
//        let task = session.dataTask(with: testURL) { data, response, error in
//            if let _ = data, error == nil {
//                print("✅ Freebox détectée :", testURL)
//                completion(urlsToTry[currentIndex - 1])
//            } else {
//                print("❌ Échec sur :", testURL)
//                tryNext()
//            }
//        }
//        task.resume()
//    }
//
//    tryNext()
//}
//
//
//
//
//
//
//func uploadFile(baseURL: URL, sessionToken: String, localURL: URL, remotePath: String) {
//    var components = URLComponents(url: baseURL.appendingPathComponent("fs/put/"), resolvingAgainstBaseURL: false)!
//    components.queryItems = [URLQueryItem(name: "path", value: remotePath)]
//
//    var request = URLRequest(url: components.url!)
//    request.httpMethod = "POST"
//    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
//    request.setValue(sessionToken, forHTTPHeaderField: "X-Fbx-App-Auth")
//
//    URLSession.shared.uploadTask(with: request, fromFile: localURL) { data, response, error in
//        if let error = error {
//            print("Erreur upload :", error)
//        } else {
//            print("✅ Upload terminé :", remotePath)
//        }
//    }.resume()
//}
//
//
//func downloadFile(baseURL: URL, sessionToken: String, remotePath: String, localDestinationURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
//    var components = URLComponents(url: baseURL.appendingPathComponent("fs/get/"), resolvingAgainstBaseURL: false)!
//    components.queryItems = [URLQueryItem(name: "path", value: remotePath)]
//
//    var request = URLRequest(url: components.url!)
//    request.httpMethod = "GET"
//    request.setValue(sessionToken, forHTTPHeaderField: "X-Fbx-App-Auth")
//
//    let task = URLSession.shared.downloadTask(with: request) { tempURL, _, error in
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//        guard let tempURL = tempURL else {
//            completion(.failure(NSError(domain: "Freebox", code: -2, userInfo: [NSLocalizedDescriptionKey: "Pas de fichier téléchargé"])))
//            return
//        }
//        do {
//            if FileManager.default.fileExists(atPath: localDestinationURL.path) {
//                try FileManager.default.removeItem(at: localDestinationURL)
//            }
//            try FileManager.default.moveItem(at: tempURL, to: localDestinationURL)
//            completion(.success(localDestinationURL))
//        } catch {
//            completion(.failure(error))
//        }
//    }
//    task.resume()
//}



//
//func hmacSHA1(key: String, message: String) -> String {
//    let keyData = key.data(using: .utf8)!
//    let msgData = message.data(using: .utf8)!
//    var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
//    keyData.withUnsafeBytes { keyBytes in
//        msgData.withUnsafeBytes { msgBytes in
//            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
//                   keyBytes.baseAddress,
//                   keyData.count,
//                   msgBytes.baseAddress,
//                   msgData.count,
//                   &digest)
//        }
//    }
//    return Data(digest).map { String(format: "%02hhx", $0) }.joined()
//}
//

/*
 
 
 You're encountering a TLS trust evaluation failure when trying to connect to your Freebox device. This happens because the Freebox uses its own self-signed or locally issued certificates (Freebox ECC Root CA), which aren't trusted by default in iOS/macOS, resulting in errors like:
 
 You mention you possess the Freebox ECC Root CA and Freebox Root CA certificates. Here’s how you can address this issue:
 
 ⸻
 
 Why This Happens
 
 • System Trust Store: Apple platforms trust only a set of built-in root CAs (Certificate Authorities).
 • Custom CA: Your Freebox signs its certificate with its own CA, not included in Apple's trusted list.
 • Result: Connections fail unless you manually trust that CA.
 
 ⸻
 
 Options to Trust the Freebox CA
 
 1. Adding CA to System Keychain (Manual, For Development)
 • On macOS or iOS simulator, you can add the Freebox CA certificate to the system or user keychain and mark it as "Always Trust."
 • Not recommended for production or App Store apps—users cannot be expected to do this.
 
 2. Custom Trust Handling in Your App (Recommended Approach for This Use Case)
 You can override the default trust evaluation in your app for these connections by implementing a custom URLSessionDelegate. This lets you programmatically trust the Freebox CA for your requests.
 
 Example: Accepting the Freebox Certificate
 
 If you look at the end of your file, you have an SSLAcceptingDelegate:
 
 Currently, this code just accepts any certificate, which works for testing but is insecure. A better approach is to validate the server certificate chain includes your Freebox CA.
 
 Steps:
 • Load your Freebox CA certificate (in DER or PEM form) as a SecCertificate.
 • In your delegate, compare the server's certificate chain to your CA.
 • Only trust the connection if the chain is signed by your CA.
 
 Example (pseudocode):
 
 • This will accept only certificates signed by your CA.
 
 ⸻
 
 3. For Simplicity: Accept All Certificates (Not Secure)
 If this is for local development/testing and you don't care about security, use your current delegate as shown (SSLAcceptingDelegate). But never ship this to production, as it makes your app vulnerable to man-in-the-middle attacks.
 
 ⸻
 
 How to Use a Custom Delegate
 
 When creating the URLSession, use:
 
 (This pattern is already present in the commented-out code in your file.)
 
 ⸻
 
 Summary
 
 • For production or distribution, validate server certificates against your Freebox CA programmatically.
 • For development, you can add the CA to your system keychain or accept all certificates (insecure).
 • Never leave "accept any certificate" code in production apps.
 
 ⸻
 
 Would you like an exact code sample for securely trusting your Freebox CA certificate in Swift? If so, let me know how your CA certificate is available (file name, format, etc.), and I can draft that for you!
 
 
 
 */





/*
 
 
 
 Thank you for providing your Freebox Root CA certificates in PEM format. I'll show you how to securely trust only your Freebox Root CA in Swift, so only connections signed by this CA are allowed—without disabling trust checks globally.
 
 Here's exactly what you need to do:
 
 ⸻
 
 1. Add the CA Certificate(s) to Your App Bundle
 
 • Save each certificate as a file in your Xcode project (e.g., freebox_ecc_root_ca.pem and/or freebox_root_ca.pem).
 • Ensure each file is included in your app's target.
 
 ⸻
 
 2. Write a Custom URLSessionDelegate
 
 This delegate loads your CA at runtime and uses it as the trusted anchor for only these requests.
 
 import Foundation
 import Security
 
 final class FreeboxTrustDelegate: NSObject, URLSessionDelegate {
 private let trustedCACertificates: [SecCertificate]
 
 override init() {
 // Load CA certificate(s) from bundle
 let certNames = ["freebox_ecc_root_ca", "freebox_root_ca"]
 self.trustedCACertificates = certNames.compactMap { name in
 guard let certURL = Bundle.main.url(forResource: name, withExtension: "pem"),
 let pemString = try? String(contentsOf: certURL),
 let derData = FreeboxTrustDelegate.pemToDER(pemString: pemString) else { return nil }
 return SecCertificateCreateWithData(nil, derData as CFData)
 }
 super.init()
 }
 
 // PEM to DER converter
 private static func pemToDER(pemString: String) -> Data? {
 guard let base64 = pemString
 .components(separatedBy: "-----")
 .filter({ !$0.contains("BEGIN") && !$0.contains("END") })
 .joined()
 .components(separatedBy: .whitespacesAndNewlines)
 .joined() as String?,
 let data = Data(base64Encoded: base64) else { return nil }
 return data
 }
 
 func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
 guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
 let serverTrust = challenge.protectionSpace.serverTrust else {
 completionHandler(.performDefaultHandling, nil)
 return
 }
 // Set the trusted CA(s) as anchors
 SecTrustSetAnchorCertificates(serverTrust, trustedCACertificates as CFArray)
 // Only trust these anchors (not built-in)
 SecTrustSetAnchorCertificatesOnly(serverTrust, true)
 var error: CFError?
 let isTrusted = SecTrustEvaluateWithError(serverTrust, &error)
 if isTrusted {
 completionHandler(.useCredential, URLCredential(trust: serverTrust))
 } else {
 completionHandler(.cancelAuthenticationChallenge, nil)
 }
 }
 }
 
 ⸻
 
 3. Use the Custom Delegate with URLSession
 
 let session = URLSession(configuration: .default, delegate: FreeboxTrustDelegate(), delegateQueue: nil)
 // Use this session for all your Freebox requests
 
 ⸻
 
 4. Summary
 
 • Place your PEM Root CA files in the bundle.
 • Use this delegate when creating your URLSession for Freebox access.
 • This approach only trusts your Freebox certificates, never disables TLS verification, and is secure for production.
 
 ⸻
 
 If you only want to use one CA file, adjust the certNames array accordingly. If you have questions about converting PEM to DER or how to get certificates into your bundle, let me know!
 
 Would you like a ready-to-copy helper to convert your provided PEM string to a file, or instructions for integrating this with your existing FreeBox class?
 
 */
