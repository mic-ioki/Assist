//
//  Mint.swift
//  
//
//  Created by Stefan Herold on 24.09.20.
//

import Foundation
import SwiftShell

public struct Mint {

}

public extension Mint {

    static func screenshots(resultsBundleURL: URL, screensURL: URL, multipleRuntimeUIStyles: Bool) throws {
        var args = ["run", "dbdrive/xcparse", "xcparse", "screenshots",
                    "--test-plan-config",
                    "--model",
                    "--verbose",
                    resultsBundleURL.path,
                    screensURL.path]

        if multipleRuntimeUIStyles {
            args.append("--in-activity-identifier")
        }

        let out = run("mint", args)

        if let error = out.error {
            Logger.shared.error(out.stderror)
            throw error
        }
    }
}
