//
//  web3.swift
//  Copyright © 2022 Argent Labs Limited. All rights reserved.
//

import Foundation


extension EthereumClient {
    // MIQU should extend protocol too
    public func eth_sendRawZKSyncTransaction(_ transaction: ZKSyncTransaction, withAccount account: EthereumAccountProtocol, completionHandler: @escaping (Result<String, EthereumClientError>) -> Void) {
        concurrentQueue.addOperation {
            let group = DispatchGroup()
            group.enter()

            // Inject pending nonce
            self.eth_getTransactionCount(address: account.address, block: .Pending) { (error, count) in
                guard let nonce = count else {
                    group.leave()
                    return completionHandler(.failure(.unexpectedReturnValue))
                }

                var transaction = transaction
                transaction.nonce = nonce

                guard let signedTx = try? account.sign(zkTransaction: transaction),
                      let transactionHex = signedTx.raw?.web3.hexString else {
                    return completionHandler(.failure(.encodeIssue))
                }

                EthereumRPC.execute(session: self.session, url: self.url, method: "eth_sendRawTransaction", params: [transactionHex], receive: String.self) { (error, response) in
                    group.leave()
                    if let resDataString = response as? String {
                        completionHandler(.success(resDataString))
                    } else {
                        
                        if case let .executionError(result) = error as? JSONRPCError {
                            completionHandler(.failure(.executionError(result.error)))
                        } else {
                            completionHandler(.failure(.unexpectedReturnValue))
                        }
                    }
                }

            }
            group.wait()
        }
    }
    public func eth_sendRawZKSyncTransaction(_ transaction: ZKSyncTransaction, withAccount account: EthereumAccountProtocol) async throws -> String {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            eth_sendRawZKSyncTransaction(transaction, withAccount: account, completionHandler: continuation.resume)
        }
    }
}
