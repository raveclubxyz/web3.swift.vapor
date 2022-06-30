//
//  web3.swift
//  Copyright © 2022 Argent Labs Limited. All rights reserved.
//

import Foundation

public enum ZKSyncAccuntSignature {
    case eoa
    case aa
}

extension EthereumAccountProtocol {
    func sign(
        zkTransaction: ZKSyncTransaction,
        type: ZKSyncAccuntSignature = .aa
    ) throws -> ZKSyncSignedTransaction {
        let typed = zkTransaction.eip712Representation
        let signature = try signMessage(message: typed).web3.hexData!
        
        return .init(
            transaction: zkTransaction,
            signature: signature
        )
    }
}
