//
//  EncryptKit.swift
//  deCripple
//
//  Created by Amachi on 13/01/2023
//

import Foundation
import CommonCrypto

func encryptKit(_ vendorID: String) -> String {
  
  //encryption  func
  func encryptAES256(data: Data, key: Data, iv: Data) -> Data? {
    let cryptLength = data.count + kCCBlockSizeAES128
    var cryptData = Data(count: cryptLength)
    
    let keyLength = kCCKeySizeAES256
    let options = CCOptions(kCCOptionPKCS7Padding)
    
    var bytesLength = 0
    
    let status = cryptData.withUnsafeMutableBytes { cryptBytes in
      data.withUnsafeBytes { dataBytes in
        key.withUnsafeBytes { keyBytes in
          iv.withUnsafeBytes { ivBytes in
            CCCrypt(CCOperation(kCCEncrypt),
                    CCAlgorithm(kCCAlgorithmAES),
                    options,
                    keyBytes.baseAddress, keyLength,
                    ivBytes.baseAddress,
                    dataBytes.baseAddress, data.count,
                    cryptBytes.baseAddress, cryptLength,
                    &bytesLength)
          }
        }
      }
    }
    
    if status == kCCSuccess {
      cryptData.count = bytesLength
      return cryptData
    }
    return nil
  }
  //decryption func
  func decryptAES256(data: Data, key: Data, iv: Data) -> Data? {
    let cryptLength = data.count + kCCBlockSizeAES128
    var cryptData = Data(count: cryptLength)
    
    let keyLength = kCCKeySizeAES256
    let options = CCOptions(kCCOptionPKCS7Padding)
    
    var bytesLength = 0
    
    let status = cryptData.withUnsafeMutableBytes { cryptBytes in
      data.withUnsafeBytes { dataBytes in
        key.withUnsafeBytes { keyBytes in
          iv.withUnsafeBytes { ivBytes in
            CCCrypt(CCOperation(kCCDecrypt),
                    CCAlgorithm(kCCAlgorithmAES),
                    options,
                    keyBytes.baseAddress, keyLength,
                    ivBytes.baseAddress,
                    dataBytes.baseAddress, data.count,
                    cryptBytes.baseAddress, cryptLength,
                    &bytesLength)
          }
        }
      }
    }
    
    if status == kCCSuccess {
      cryptData.count = bytesLength
      return cryptData
    }
    return nil
  }
  let platformID = "00000000"
  let concatenatedData = platformID
  
  let keyQueue = DispatchQueue(label: "keyQueue")
  let dataToEncrypt = concatenatedData.data(using: .utf8)!
  var key = Data(count: kCCKeySizeAES256)
  var iv = Data(count: kCCBlockSizeAES128)
  
  keyQueue.sync {
    _ = key.withUnsafeMutableBytes { keyBytes in
      SecRandomCopyBytes(kSecRandomDefault, keyBytes.count, keyBytes.baseAddress!)
    }
    _ = iv.withUnsafeMutableBytes { ivBytes in
      SecRandomCopyBytes(kSecRandomDefault, ivBytes.count, ivBytes.baseAddress!)
    }
  }
  
  
  
  let dataQueue = DispatchQueue(label: "dataQueue")
  
  return dataQueue.sync {
    let dataToEncrypt = concatenatedData.data(using: .utf8)!
    let encryptedData = encryptAES256(data: dataToEncrypt, key: key, iv: iv)!
    let decryptedData = decryptAES256(data: encryptedData, key: key, iv: iv)!
    let decryptedString = String(data: decryptedData, encoding: .utf8)
    
    let keyHex = key.map { String(format: "%02x", $0) }.joined()
    let ivHex = iv.map { String(format: "%02x", $0) }.joined()
    
    print("Original String: \(concatenatedData)")
    print("Encrypted Data: \(encryptedData.hexEncodedString())")
    print("Decrypted String: \(decryptedString!)")
    
    print("Key: \(keyHex)")
    print("Iv: \(iv.hexEncodedString())")
    print("IvPrint:\(ivHex)")
    
    
    
    
    
    let result = encryptKit("test")
    
    let key_swapped = result
    let first14 = key_swapped.prefix(14)
    let newKey = String(key_swapped.dropFirst(14)) + String(first14)
    //newkey is the thing u want to save to db
    print(newKey)
    
    print("result is", newKey)
    
    return encryptedData.hexEncodedString()
  }
}

extension Data {
  func hexEncodedString() -> String {
    return map { String(format: "%02hhx", $0) }.joined()
  }
}
