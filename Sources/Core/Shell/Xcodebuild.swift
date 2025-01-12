//
//  Xcodebuild.swift
//  
//
//  Created by Stefan Herold on 23.09.20.
//

import Foundation
import SwiftShell

public struct Xcodebuild {

    public static func execute(subcommand: Subcommand,
                               deviceIds: [String],
                               derivedDataUrl: URL) throws {
        let destinations = deviceIds
            .map { "platform=iOS Simulator,id=\($0)" }
            .flatMap { ["-destination", $0] }
        let commonArgs = [
            "xcodebuild", subcommand.name,
            "-derivedDataPath", derivedDataUrl.path()
        ] + destinations
        let invocations: [Invocation]

        switch subcommand {
        case let .buildForTesting(workspace, schemes, envVariables):
            invocations = schemes.map {
                Invocation(arguments: commonArgs + ["-workspace", workspace, "-scheme", $0] + envVariables)
            }

        case let .testWithoutBuilding(xcTestRunFile, resultsBundleURL, testPlanConfigs):
            var args = ["-xctestrun", xcTestRunFile.path()]
            if let resultsBundleURL {
                args += ["-resultBundlePath", resultsBundleURL.path]
            }
            args += testPlanConfigs.flatMap { ["-only-test-configuration", $0] }
            invocations = [Invocation(arguments: commonArgs + args)]
        }

        for invocation in invocations {
            try invocation.execute()
        }
    }

    // MARK: - Subcommand

    public enum Subcommand {
        case buildForTesting(workspace: String, schemes: [String], envVariables: [String] = [])
        case testWithoutBuilding(xcTestRunFile: URL, resultsBundleURL: URL? = nil, testPlanConfigs: [String] = [])

        var name: String {
            switch self {
            case .buildForTesting: "build-for-testing"
            case .testWithoutBuilding: "test-without-building"
            }
        }
    }

    private struct Invocation {
        let arguments: [String]

        func execute() throws {
            let out = run("xcrun", arguments)

            if let error = out.error {
                Logger.shared.error(out.stderror)
                throw error
            }
        }
    }
}
