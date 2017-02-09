//
//  BugfenderSwift.swift
//  BleDemo
//
//  Created by Alex on 1/15/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import Foundation

func BFLog(_ message: String, filename: String = #file, line: Int = #line, funcname: String = #function) {
    let file = ("\(filename)" as NSString).lastPathComponent as String
    
    Bugfender.logLineNumber(line, method: funcname, file: file, level: BFLogLevel.default, tag: nil, message: message)
    #if DEBUG
        NSLog("[\(file):\(line)] \(funcname) - %@", message)
    #endif
}

func BFLogErr(_ message: String, filename: String = #file, line: Int = #line, funcname: String = #function) {
    let file = ("\(filename)" as NSString).lastPathComponent as String
    
    Bugfender.logLineNumber(line, method: funcname, file: file, level: BFLogLevel.error, tag: nil, message: message)
    #if DEBUG
        NSLog("[\(file):\(line)] \(funcname) - %@", message)
    #endif
}

func BFLogWarn(_ message: String, filename: String = #file, line: Int = #line, funcname: String = #function) {
    let file = ("\(filename)" as NSString).lastPathComponent as String
    
    Bugfender.logLineNumber(line, method: funcname, file: file, level: BFLogLevel.warning, tag: nil, message: message)
    #if DEBUG
        NSLog("[\(file):\(line)] \(funcname) - %@", message)
    #endif
}
