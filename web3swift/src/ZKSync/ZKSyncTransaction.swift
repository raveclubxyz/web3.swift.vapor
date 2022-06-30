//
//  web3.swift
//  Copyright © 2022 Argent Labs Limited. All rights reserved.
//

import Foundation
import BigInt
import GenericJSON

// MIQU: Use optionals for chainId + nonce same design as in EthereumTransaction
// to be filled in by client
public struct ZKSyncTransaction: Equatable {
    public static let eip712Type: UInt8 = 0x71
    
    public let txType: UInt8 = Self.eip712Type
    public var to: EthereumAddress
    public var value: BigUInt
    public var data: Data
    public var chainId: Int
    public var nonce: Int
    public var gasPrice: BigUInt
    public var gasLimit: BigUInt
    public var egsPerPubdata: BigUInt
    public var feeToken: EthereumAddress
    
    public struct AAParams: Equatable {
        public var from: EthereumAddress
        public var signature: Data
    }
    
    public var aaParams: AAParams?
    
    public init(
        to: EthereumAddress,
        value: BigUInt,
        data: Data,
        chainId: Int,
        nonce: Int,
        gasPrice: BigUInt,
        gasLimit: BigUInt,
        egsPerPubdata: BigUInt = 0,
        feeToken: EthereumAddress = .zero
    ) {
        self.to = to
        self.value = value
        self.data = data
        self.chainId = chainId
        self.nonce = nonce
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.egsPerPubdata = egsPerPubdata
        self.feeToken = feeToken
    }
    
    public var eip712Representation: TypedData {
        let decoder = JSONDecoder()
        let eip712 = try! decoder.decode(TypedData.self, from: eip712JSON)
        return eip712
    }
    
    private var eip712JSON: Data {
        """
        {
            "types": {
                "EIP712Domain": [
                  {"name": "name", "type": "string"},
                  {"name": "version", "type": "string"},
                  {"name": "chainId", "type": "uint256"}
                ],
                "Transaction": [
                    {"name": "txType","type": "uint8"},
                    {"name": "to","type": "uint256"},
                    {"name": "value","type": "uint256"},
                    {"name": "data","type": "bytes"},
                    {"name": "feeToken","type": "uint256"},
                    {"name": "ergsLimit","type": "uint256"},
                    {"name": "ergsPerPubdataByteLimit","type": "uint256"},
                    {"name": "ergsPrice","type": "uint256"},
                    {"name": "nonce","type": "uint256"}
                ]
            },
            "primaryType": "Transaction",
            "domain": {
                "name": "zkSync",
                "version": "2",
                "chainId": \(chainId)
            },
            "message": {
                "txType" : \(txType),
                "to" : \(to.asBigInt.description),
                "value" : \(value.description),
                "data" : "\(data.web3.hexString)",
                "feeToken" : \(feeToken.asBigInt.description),
                "ergsLimit" : \(gasLimit.description),
                "ergsPrice" : \(gasPrice.description),
                "ergsPerPubdataByteLimit" : \(egsPerPubdata.description),
                "nonce" : \(nonce)
            }
        }
        """.data(using: .utf8)!
    }
}

public struct ZKSyncSignedTransaction {
    public let transaction: ZKSyncTransaction
    public let signature: Signature
    
    public init(
        transaction: ZKSyncTransaction,
        signature raw: Data
    ) {
        self.transaction = transaction
        self.signature = Signature(raw: raw)
    }
    
    public var raw: Data? {
        let txArray: [Any?] = [
            transaction.nonce,
            transaction.gasPrice,
            transaction.gasLimit,
            transaction.to.value.web3.noHexPrefix,
            transaction.value,
            transaction.data,
            signature.recoveryParam,
            signature.r,
            signature.s,
            transaction.chainId,
            transaction.feeToken.value.web3.noHexPrefix,
            transaction.egsPerPubdata,
            // MIQU factorydeps??
            [],
            // MIQU: AA params
            []
//            transaction.from?.value.web3.noHexPrefix,
//            signature
        ]

        return RLP.encode(txArray).flatMap {
            Data([transaction.txType]) + $0.web3.bytes
        }
    }
    
    public var hash: Data? {
        return raw?.web3.keccak256
    }
}

fileprivate extension EthereumAddress {
    var asBigInt: BigUInt {
        .init(hex: self.value)!
    }
}
