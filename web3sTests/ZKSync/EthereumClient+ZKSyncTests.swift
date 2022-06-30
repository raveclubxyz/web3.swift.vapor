//
//  web3.swift
//  Copyright © 2022 Argent Labs Limited. All rights reserved.
//

import Foundation
@testable import web3
import XCTest
import BigInt

final class EthereumClientZKSyncTests: XCTestCase {
    let eoaAccount = try! EthereumAccount(keyStorage: TestEthereumKeyStorage(privateKey: TestConfig.privateKey))
    let client = EthereumClient(url: TestConfig.ZKSync.clientURL)
    let eoaEthTransfer = ZKSyncTransaction(
        to: .init("0x64d0eA4FC60f27E74f1a70Aa6f39D403bBe56793"),
        value: BigUInt(hex: "0xe8d4a51000")!,
        data: Data(),
        chainId: TestConfig.ZKSync.chainId,
        nonce: 0,
        gasPrice: BigUInt(hex: "0x6f9c")!,
        gasLimit: BigUInt(hex: "0x55af")!
    )
    
    func test_GivenEOAAccount_WhenSendETH_ThenSendsCorrectly() async {
        do {
            let txHash = try await client.eth_sendRawZKSyncTransaction(eoaEthTransfer, withAccount: eoaAccount)
            XCTAssertNotNil(txHash, "No tx hash, ensure key is valid in TestConfig.swift")
        } catch {
            XCTFail("Expected tx but failed \(error).")
        }
    }
}
