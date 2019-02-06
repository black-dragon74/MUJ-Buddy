//
//  Encryptor.swift
//  MUJ Buddy
//
//  Created by Nick on 1/20/19.
//  Copyright © 2019 Nick. All rights reserved.
//

// The class that provides utility fuctions to encode and decode the userid and the passwoed

let rjnk = "2aff70f1ecba9"
let ljnk = "7f224854012470b756af4"
let prime: Int = 8743983

func encodeUID(userid: String) -> String {
    // First, let's convert the string back to Int
    var uid = Int(userid)!  // Force unwrap coz we know a int will be passed

    // Add the prime
    uid += prime

    // Convert UID to string
    var localUIDStr = String(uid)

    localUIDStr = ljnk + localUIDStr + rjnk

    return b64Encode(dataToEncode: localUIDStr)
}

func encodePassword(password: String) -> String {
    // Add junk
    let localPass = b64Encode(dataToEncode: password)

    // Add the junk
    let obfuscatedPass = ljnk + localPass + rjnk

    // Encode again and return
    return b64Encode(dataToEncode: obfuscatedPass)
}

private func b64Encode(dataToEncode: String) -> String {
    // Convert string to utf-8 encoding
    guard let utf8String = dataToEncode.data(using: String.Encoding.utf8) else { return "" }

    // Convert to base64
    let b64String = utf8String.base64EncodedString(options: .init(rawValue: 0))

    return String(b64String)
}
