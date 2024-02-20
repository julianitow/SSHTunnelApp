//
//  NIOSSHClient.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 20/02/2024.
//

import Dispatch
import NIOCore
import NIOPosix
import NIOSSH

final class ErrorHandler: ChannelInboundHandler {
    typealias InboundIn = Any

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error in pipeline: \(error)")
        context.close(promise: nil)
    }
}

/**
* TEMPORARY MADE FOR IMPLMENTATION TESTING PURPOSES ONLY !!!
 */
final class AcceptAllHostKeysDelegate: NIOSSHClientServerAuthenticationDelegate {
    func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        // Do not replicate this in your own code: validate host keys! This is a
        // choice made for expedience, not for any other reason.
        validationCompletePromise.succeed(())
    }
}

class NIOSSHClient {
    let delegate = NIOSSHDelegate()
    
    var group: MultiThreadedEventLoopGroup?
    var bootstrap: ClientBootstrap?
    var channel: Channel?
    var server: PortForwardingServer?
    
    var host: Substring?
    var port: Int?
    var targetHost: String?
    var targetPort: Int?
    var targetSSHPort: Int?
    
    init() {
        
    }
    
    func setConfig(host: String, port: Int, targetHost: String, targetPort: Int, targetSSHPort: Int? = 22) -> Void {
        self.host = host.suffix(0)
        self.port = port
        self.targetHost = targetHost
        self.targetPort = targetPort
    }
    
    func listen() -> Void {
        guard let _ = self.host,
              let _ = self.port,
              let _ = self.targetHost,
              let _ = self.targetPort else {
            print("Missing configuration")
            return
        }
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let clientConfiguration = SSHClientConfiguration(userAuthDelegate: self.delegate, serverAuthDelegate: self.delegate)
        self.bootstrap = ClientBootstrap(group: self.group!)
            .channelInitializer { channel in
                channel.pipeline.addHandlers([
                    NIOSSHHandler(role: .client(clientConfiguration), allocator: channel.allocator, inboundChildChannelInitializer: nil),
                    ErrorHandler()
                ])
            }
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
        let channel = try? self.bootstrap!.connect(host: self.targetHost!, port: self.targetSSHPort ?? 22).wait()
        if (channel == nil) {
            print("Channel nil")
            return
        }
        self.server = PortForwardingServer(group: self.group!,
                                           bindHost: self.host ?? "127.0.0.1",
                                           bindPort: self.port!) { inboundChannel in
            channel!.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
                let promise = inboundChannel.eventLoop.makePromise(of: Channel.self)
                let directTCPIP = SSHChannelType.DirectTCPIP(
                    targetHost: self.targetHost!,
                    targetPort: self.targetPort!,
                    originatorAddress: inboundChannel.remoteAddress!)
                print(directTCPIP)
                
                sshHandler.createChannel(promise,
                                         channelType: .directTCPIP(directTCPIP)) { childChannel, channelType in
                    guard case .directTCPIP = channelType else {
                        return channel!.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                    }
                    
                    let (ours, theirs) = GlueHandler.matchedPair()
                    return childChannel.pipeline.addHandlers([SSHWrapperHandler(), ours, ErrorHandler()]).flatMap {
                        inboundChannel.pipeline.addHandlers([theirs, ErrorHandler()])
                    }
                }
                return promise.futureResult.map { _ in }
            }
        }
        try! self.server!.run().wait()
    }
    
    func disconnect() -> Void {
        try? group?.syncShutdownGracefully()
    }
}

/**
 * NIOSSH related
 */
class NIOSSHDelegate: NIOSSHClientUserAuthenticationDelegate, NIOSSHClientServerAuthenticationDelegate {
    
    func nextAuthenticationType(availableMethods: NIOSSH.NIOSSHAvailableUserAuthenticationMethods, nextChallengePromise: NIOCore.EventLoopPromise<NIOSSH.NIOSSHUserAuthenticationOffer?>) {
        print("nextAuthenticationType")
        print(availableMethods)
        
        guard availableMethods.contains(.password) else {
            print("Error: password auth not supported")
            nextChallengePromise.fail(SSHClientError.passwordAuthenticationNotSupported)
            return
        }
        
        nextChallengePromise.succeed(NIOSSHUserAuthenticationOffer(username: "***REMOVED***", serviceName: "", offer: .password(.init(password: "***REMOVED***"))))
    }
    
    func validateHostKey(hostKey: NIOSSH.NIOSSHPublicKey, validationCompletePromise: NIOCore.EventLoopPromise<Void>) {
        print("validateHostKey")
        validationCompletePromise.succeed(())
    }
}
