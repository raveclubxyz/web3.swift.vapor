//
//  web3.swift
//  Copyright © 2022 Argent Labs Limited. All rights reserved.
//

import XCTest
@testable import web3
import BigInt

final class ZKSyncTransactionTests: XCTestCase {
    
    let eoaAccount = try! EthereumAccount(keyStorage: TestEthereumKeyStorage(privateKey: "0xf707ce8805f09a68294b4efdfad686629b31a5128670ef0e502c8c396181f1cb"))
    let aaAccount = try! EthereumAccount(keyStorage: TestEthereumKeyStorage(privateKey: "0xf707ce8805f09a68294b4efdfad686629b31a5128670ef0e502c8c396181f1cb"))
    
    let eoaTransfer = ZKSyncTransaction(
        to: .init("0x64d0eA4FC60f27E74f1a70Aa6f39D403bBe56793"),
        value: BigUInt(hex: "0xe8d4a51000")!,
        data: Data(),
        chainId: TestConfig.ZKSync.chainId,
        nonce: 0,
        gasPrice: BigUInt(hex: "0x6f9c")!,
        gasLimit: BigUInt(hex: "0x55af")!,
        egsPerPubdata: 0,
        feeToken: .zero
    )
    
    func test_GivenEOATransfer_EncodesCorrectly() {
        let signature = "0xab458591c89f04e201676cdd70b009b7edf38d892cd0727bac6f72f80907bce54c7e79049aa2f690bc56827d7433a3eb3c00a382b38e01c1b3b297a2c39a9d4a1c".web3.hexData!
        let signed = ZKSyncSignedTransaction(
            transaction: eoaTransfer, signature: signature
        )
        XCTAssertEqual(signed.raw?.web3.hexString, "0x71f88180826f9c8255af9464d0ea4fc60f27e74f1a70aa6f39d403bbe5679385e8d4a510008001a0ab458591c89f04e201676cdd70b009b7edf38d892cd0727bac6f72f80907bce5a04c7e79049aa2f690bc56827d7433a3eb3c00a382b38e01c1b3b297a2c39a9d4a82011894000000000000000000000000000000000000000080c0c0")
    }
    
    func test_GivenEOATransfer_WhenFeeTokenIsNotZeroEncodesCorrectly() {
        let signature = "0x07e1fd4eee291f740c413575223ba34f4e332538060207c61bab8f108276c6e31a07bc459cc7f31a7b26aba83f25fba158655df6f4ea2425f17d14c53b0634991c".web3.hexData!
        let signed = ZKSyncSignedTransaction(
            transaction: with( eoaTransfer) { $0.feeToken = EthereumAddress("0x54a14D7559BAF2C8e8Fa504E019d32479739018c") }, signature: signature
        )
        
        XCTAssertEqual(signed.raw?.web3.hexString, "0x71f88180826f9c8255af9464d0ea4fc60f27e74f1a70aa6f39d403bbe5679385e8d4a510008001a007e1fd4eee291f740c413575223ba34f4e332538060207c61bab8f108276c6e3a01a07bc459cc7f31a7b26aba83f25fba158655df6f4ea2425f17d14c53b0634998201189454a14d7559baf2c8e8fa504e019d32479739018c80c0c0")
    }
    
    func test_GivenEOATransfer_WhenSigningWithEOAAccount_ThenEncodesAndSignsCorrectly()  {
        let signed = try? eoaAccount.sign(zkTransaction: eoaTransfer)
        XCTAssertEqual(signed?.raw?.web3.hexString,
                       "0x71f88180826f9c8255af9464d0ea4fc60f27e74f1a70aa6f39d403bbe5679385e8d4a510008001a0ab458591c89f04e201676cdd70b009b7edf38d892cd0727bac6f72f80907bce5a04c7e79049aa2f690bc56827d7433a3eb3c00a382b38e01c1b3b297a2c39a9d4a82011894000000000000000000000000000000000000000080c0c0")
    }
//
//    let ethTransfer = ZKSyncTransaction(
//        to: .init("0xf5c7511000523ebcc90c7555a339b21f3a19647b"),
//        value: BigUInt(hex: "0xe8d4a51000")!,
//        data: Data(),
//        chainId: TestConfig.ZKSync.chainId,
//        nonce: 15,
//        gasPrice: BigUInt(hex: "0x6f9c")!,
//        gasLimit: BigUInt(hex: "0x55af")!,
//        egsPerPubdata: 0,
//        feeToken: .zero
//    )
//
//    func test_GivenEthTransferTransaction_WhenSigningWithAAAccount_ThenEncodesAndSignsCorrectly()  {
//        let signed = try? aaAccount.sign(zkTransaction: ethTransfer)
//        XCTAssertEqual(signed?.raw?.web3.hexString,
//                       "0x71f89c0f826f9c8255af94f5c7511000523ebcc90c7555a339b21f3a19647b85e8d4a5100080820118808082011894000000000000000000000000000000000000000080c0f85894143b06e4963e5a1dc056a8a41c11746a504d46ccb841ccfb484e154aa74d9239bb3a61a6e3fd30afb692e65aa1950f2aec444c086ae96b93524ec6484793df78e01988f1e3f37eedd30a786f3078a88971fad39994cb1c")
//    }
}


