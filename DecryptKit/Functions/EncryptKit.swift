//
//  EncryptKit.swift
//  deCripple
//
//  Created by Amachi on 13/01/2023
//

import Foundation
import CommonCrypto
import UIKit

// MARK: - Created by Amachi my Arse :))
class EncryptKit {
  public static let shared = EncryptKit()

  let concatenatedString = UIDevice.current.identifierForVendor?.uuidString ?? "UIDPlaceholder"

  public func doReturnEncrypted() -> (encryptedId: String, keyHex: String, ivHex: String)? {
    var encreyptedData = Data()
    var key = Data(count: kCCKeySizeAES256)
    var iv = Data(count: kCCBlockSizeAES128)
    DispatchQueue(label: "keyQueue").sync {
      _ = key.withUnsafeMutableBytes { keyBytes in
        SecRandomCopyBytes(kSecRandomDefault, keyBytes.count, keyBytes.baseAddress!)
      }
      _ = iv.withUnsafeMutableBytes { ivBytes in
        SecRandomCopyBytes(kSecRandomDefault, ivBytes.count, ivBytes.baseAddress!)
      }
    }
    guard let concatenatedData = concatenatedString.data(using: .utf8) else { return nil }
    DispatchQueue(label: "dataQueue").sync {
      encreyptedData = encryptAES256(data: concatenatedData, key: key, iv: iv)!
    }
    return (encreyptedData.hexEncodedString(), key.hexEncodedString(), iv.hexEncodedString())
  }

  public func doReturnDecrypted(encryptedId: String, keyHex: String, ivHex: String) -> String? {
      guard let encryptedData = encryptedId.hexDecodedData(),
            let key = keyHex.hexDecodedData(),
            let iv = ivHex.hexDecodedData() else { return nil }
    let decryptedData = decryptAES256(data: encryptedData, key: key, iv: iv)!
    guard let decryptedString = String(data: decryptedData, encoding: .utf8) else { return nil }
    return decryptedString
  }

  private func encryptAES256(data: Data, key: Data, iv: Data) -> Data? {
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

  private func decryptAES256(data: Data, key: Data, iv: Data) -> Data? {
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

extension String {
  func hexDecodedData() -> Data? {
    var data = Data(capacity: count / 2)
    let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
    regex.enumerateMatches(in: self, options: [], range: NSRange(self.startIndex..., in: self)) { match, _, _ in
      if let match = match {
        let byteStringRange = Range(match.range, in: self)!
        let byteString = self[byteStringRange]
        if let num = UInt8(byteString, radix: 16) {
          data.append(num)
        }
      }
    }
    guard data.count > 0 else { return nil }
    return data
  }
}
