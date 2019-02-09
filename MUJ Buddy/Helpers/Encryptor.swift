//
//  Encryptor.swift
//  MUJ Buddy
//
//  Created by Nick on 1/20/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import SwiftyRSA

//
//  RSA encryption related functions
//
func encryptDataWithRSA(withDataToEncrypt: String) -> String {
    // Get hold of the public key
    if let pub_path = Bundle.main.path(forResource: "app_pub", ofType: "") {
        // Try to read that file
        do {
            let raw_pub = try String(contentsOfFile: pub_path)
            // Create that into a public key object
            let pub_key = try PublicKey(base64Encoded: raw_pub)
            let clearData = try ClearMessage(string: withDataToEncrypt, using: .utf8)
            let encodedData = try clearData.encrypted(with: pub_key, padding: .PKCS1)
            return encodedData.base64String
        }
        catch let err {
            print("Error in reading the PKEY", err)
            return ""
        }
    }
    return ""
}
