/*
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import LoggerAPI

/// String Utils
extension String {

    /// Parses percent encoded string into query parameters with comma-separated
    /// values.
    var urlDecodedFieldValuePairs: [String: String] {
        var result: [String: String] = [:]
        for item in self.split(separator: "&") {
            let (keySub, valueSub) = item.keyAndDecodedValue
            if let valueSub = valueSub {
                let value = String(valueSub)
                let key = String(keySub)
                // If value already exists for this key, append it
                if let existingValue = result[key] {
                    result[key] = "\(existingValue),\(value)"
                }
                else {
                    result[key] = value
                }
            }
        }
        return result
    }

    /// Parses percent encoded string int query parameters with values as an
    /// array rather than a concatcenated string.
    var urlDecodedFieldMultiValuePairs: [String: [String]] {
        var result: [String: [String]] = [:]

        for item in self.split(separator: "&") {
            let (keySub, valueSub) = item.keyAndDecodedValue
            if let valueSub = valueSub {
                let value = String(valueSub)
                let key = String(keySub)
                result[key, default: []].append(value)
            }
        }

        return result
    }
}

extension Substring {
    /// Splits a URL-encoded key and value pair (e.g. "foo=bar") into a tuple
    /// with corresponding "key" and "value" values, with the value being URL
    /// unencoded.
    var keyAndDecodedValue: (key: Substring, value: Substring?) {
        guard let index = self.firstIndex(of: "=") else {
            return (key: self, value: nil)
        }
        // substring up to index
        let key = self[..<index]
        // substring from index
        var value = self[self.index(after: index)...]

        //let valueReplacingPlus = value.replacingOccurrences(of: "+", with: " ")
        // Faster way to replace '+' with ' ' that does not involve conversion to NSString
        value.replaceCharacters("+", with: " ")

// TEMPORARY - evaluate benefit of removing this NSString method
        value.removePercentEncoding()
        return (key: key, value: value)
//        let decodedValue = value.removingPercentEncoding
//        if decodedValue == nil {
//            Log.warning("Unable to decode query parameter \(key) (coded value: \(value)")
//        }
//        return (key: key, value: decodedValue != nil ? Substring(decodedValue!) : value)
    }

    /// Finds and replaces all occurrences of a character with the provided substring
    /// (eg. another character).
    @inline(__always)
    private mutating func replaceCharacters(_ src: Character, with dst: Substring) {
        repeat {
            guard let startIndex = self.firstIndex(of: src) else {
                break
            }
            self.replaceSubrange(startIndex...startIndex, with: dst)
        } while true
    }

//    /// Lookup table of valid hex characters
    private static let validHexChars: [UInt8?] = [
        /* 00 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 08 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 10 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 18 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 20 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 28 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 30 */  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        /* 38 */  0x08, 0x09,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 40 */   nil, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,  nil,
        /* 48 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 50 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 58 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 60 */   nil, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,  nil,
        /* 68 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 70 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 78 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 80 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 88 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 90 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* 98 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* A0 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* A8 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* B0 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* B8 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* C0 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* C8 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* D0 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* D8 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* E0 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* E8 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* F0 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
        /* F8 */   nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
    ]

    /// Process this substring, replacing each valid percent-escaped sequence with
    /// the corresponding character.
    /// This implementation differs subtly from the CoreFoundation approach, in that
    /// we will replace all valid percent-escaped sequences whilst ignoring any
    /// invalid ones.
    private mutating func removePercentEncoding() {
        guard self.count > 2 else {
            // Failure - string is too short to contain a valid escape sequence
            return
        }
        var currentIndex = self.startIndex
        repeat {
            let char = self[currentIndex]
            switch char {
            case "%":
                let hexChar1 = self.index(after: currentIndex)
                guard hexChar1 < self.endIndex else {
                    // Failure - invalid escape sequence (EOF)
                    return
                }
                let hexChar2 = self.index(after: hexChar1)
                guard hexChar2 < self.endIndex else {
                    // Failure - invalid escape sequence (EOF)
                    return
                }
                // get the hex digits
                let hex1check = Substring.validHexChars[Int(self[hexChar1].unicodeScalars.first!.value)];
                let hex2check = Substring.validHexChars[Int(self[hexChar2].unicodeScalars.first!.value)];
                guard let hex1 = hex1check, let hex2 = hex2check else {
                    // Failure - invalid hex sequence - but we can try to continue
                    break
                }
                // convert hex digits
                let resultingByte = (hex1 << 4) + hex2
                let resultingChar = UnicodeScalar(resultingByte)
                let resultingCharSequence = [Character(resultingChar)]
                // assign result
                self.replaceSubrange(currentIndex...hexChar2, with: resultingCharSequence)
            default:
                // Not the start of an escape sequence, carry on
                break
            }
            currentIndex = self.index(after: currentIndex)
        } while currentIndex < self.endIndex
    }
}
