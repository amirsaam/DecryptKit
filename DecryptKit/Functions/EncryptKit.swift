//
//  EncryptKit.swift
//  deCripple
//
//  Created by Amachi on 13/01/2023
//

import Foundation
import CommonCrypto
import UIKit

class EncryptKit {

  private let concatenatedString = "00000000" + (UIDevice.current.identifierForVendor?.uuidString ?? "UID not Found")
  private let concatenatedData = (
    "00000000" +
    (UIDevice.current.identifierForVendor?.uuidString ?? "UID not Found")
  ).data(using: .utf8)

  func doReturnEncrypted() async -> String? {
    guard let encryptedData = await encryptAES256() else { return nil }
    print("EncryptKit, EncryptedData: ", encryptedData)
    let encryptedString = encryptedData.hexEncodedString()
    print("EncryptKit, EncryptedString: ", encryptedString)
    return String(encryptedString.dropFirst(14)) + String(encryptedString.prefix(14))
  }

  func doReturnDecrypted(encryptedString: String) async -> String? {
    let revertedString = encryptedString.suffix(14) + encryptedString.dropLast(14)
    print("EncryptKit, ReversedString: ", revertedString)
    guard let decryptedData = await decryptAES256(encryptedData: Data(revertedString.utf8)) else { return nil }
    print("EncryptKit, DecryptedData: ", decryptedData)
    return String(data: decryptedData, encoding: .utf8)
  }

  // key and iv creation func
  private func createKeyAndIV() -> (key: Data, iv: Data)? {
    var key = Data(count: kCCKeySizeAES256)
    var iv = Data(count: kCCBlockSizeAES128)
    
    let keyQueue = DispatchQueue(label: "keyQueue")
    keyQueue.sync {
        _ = key.withUnsafeMutableBytes { keyBytes in
            SecRandomCopyBytes(kSecRandomDefault, keyBytes.count, keyBytes.baseAddress!)
        }
        _ = iv.withUnsafeMutableBytes { ivBytes in
            SecRandomCopyBytes(kSecRandomDefault, ivBytes.count, ivBytes.baseAddress!)
        }
    }
    
    print("EncryptKit, Key: ", key)
    print("EncryptKit, IV: ", iv)
    return (key, iv)
  }

  // encryption  func
  private func encryptAES256() async -> Data? {
    
    guard let (key, iv) = createKeyAndIV(),
          let data = concatenatedData else {
      return nil
    }
    
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
    
    if status != kCCSuccess {
      return nil
    }
    
    cryptData.count = bytesLength
    return cryptData
  }

  // decryption func
  private func decryptAES256(encryptedData: Data) async -> Data? {
    
    guard let (key, iv) = createKeyAndIV() else { return nil }
    
    let cryptLength = encryptedData.count + kCCBlockSizeAES128
    var cryptData = Data(count: cryptLength)
    
    let keyLength = kCCKeySizeAES256
    let options = CCOptions(kCCOptionPKCS7Padding)
    
    var bytesLength = 0
    
    let status = cryptData.withUnsafeMutableBytes { cryptBytes in
      encryptedData.withUnsafeBytes { dataBytes in
        key.withUnsafeBytes { keyBytes in
          iv.withUnsafeBytes { ivBytes in
            CCCrypt(CCOperation(kCCDecrypt),
                    CCAlgorithm(kCCAlgorithmAES),
                    options,
                    keyBytes.baseAddress, keyLength,
                    ivBytes.baseAddress,
                    dataBytes.baseAddress, encryptedData.count,
                    cryptBytes.baseAddress, cryptLength,
                    &bytesLength)
          }
        }
      }
    }
    
    if status != kCCSuccess {
      return nil
    }

    cryptData.count = bytesLength
    return cryptData
  }
}

extension Data {
  func hexEncodedString() -> String {
    return map { String(format: "%02hhx", $0) }.joined()
  }
}
