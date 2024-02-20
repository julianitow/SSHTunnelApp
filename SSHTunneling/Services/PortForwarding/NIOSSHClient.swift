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
import Foundation

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
    var group: MultiThreadedEventLoopGroup?
    var bootstrap: ClientBootstrap?
    //var channel: Channel?
    var server: PortForwardingServer?
    var isConnected: Bool = false
    
    var host: Substring?
    var port: Int?
    var targetHost: String?
    var targetPort: Int?
    var targetSSHPort: Int?
    var username: String?
    var password: String?
    
    
    init() {

    }
    
    func debugConfig() -> Void {
        print(" host: \(self.host)\n port: \(self.port)\n targetHost: \(self.targetHost)\n targetPort: \(self.targetPort)\n username: \(self.username)\n password: \(self.password) ")
    }
    
    func setConfig(config: SSHTunnelConfig) -> Void {
        self.host = "127.0.0.1"; //config.host.suffix(0)
        self.port = config.localPort
        self.targetHost = config.serverIP
        self.targetPort = config.distantPort
        self.username = config.username
        self.password = config.password
    }
    
    func listen() -> Bool {
        guard let _ = self.host,
              let _ = self.port,
              let _ = self.targetHost,
              let _ = self.targetPort,
              let _ = self.username,
              let _ = self.password else {
            print("Missing configuration")
            return false
        }
        //debugConfig()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let clientConfiguration = SSHClientConfiguration(userAuthDelegate: self, serverAuthDelegate: self)
        self.bootstrap = ClientBootstrap(group: self.group!)
            .channelInitializer { channel in
                channel.pipeline.addHandlers([
                    NIOSSHHandler(role: .client(clientConfiguration), allocator: channel.allocator, inboundChildChannelInitializer: nil),
                    ErrorHandler()
                ])
            }
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
        let channel: Channel
        do {
            channel = try self.bootstrap!.connect(host: self.targetHost!, port: self.targetSSHPort ?? 22).wait()
            self.isConnected = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.connectionNotification, object: self)
            }
        } catch {
            print(error)
            return false
        }
        self.server = PortForwardingServer(group: self.group!,
                                           bindHost: self.host ?? "127.0.0.1",
                                           bindPort: self.port!) { inboundChannel in
            channel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
                let promise = inboundChannel.eventLoop.makePromise(of: Channel.self)
                let directTCPIP = SSHChannelType.DirectTCPIP(
                    targetHost: self.targetHost!,
                    targetPort: self.targetPort!,
                    originatorAddress: inboundChannel.remoteAddress!)
                print(directTCPIP)
                
                sshHandler.createChannel(promise,
                                         channelType: .directTCPIP(directTCPIP)) { childChannel, channelType in
                    guard case .directTCPIP = channelType else {
                        return channel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                    }
                    
                    let (ours, theirs) = GlueHandler.matchedPair()
                    return childChannel.pipeline.addHandlers([SSHWrapperHandler(), ours, ErrorHandler()]).flatMap {
                        inboundChannel.pipeline.addHandlers([theirs, ErrorHandler()])
                    }
                }
                return promise.futureResult.map { _ in }
            }
        }
        do {
            try self.server!.run().wait()
            return true
        } catch {
            return false
        }
    }
    
    func shutdown() -> Void {
        try? group?.syncShutdownGracefully()
    }
    
    func disconnect() -> Void {
        _ = self.server?.close()
        self.shutdown()
        self.isConnected = false
    }
}

/**
 * NIOSSH related
 */
extension NIOSSHClient: NIOSSHClientUserAuthenticationDelegate, NIOSSHClientServerAuthenticationDelegate {
    
    func nextAuthenticationType(availableMethods: NIOSSH.NIOSSHAvailableUserAuthenticationMethods, nextChallengePromise: NIOCore.EventLoopPromise<NIOSSH.NIOSSHUserAuthenticationOffer?>) {
        print("nextAuthenticationType")
        print(availableMethods)
        
        guard availableMethods.contains(.password) else {
            print("Error: password auth not supported")
            nextChallengePromise.fail(SSHClientError.passwordAuthenticationNotSupported)
            return
        }
        
        guard let _ = self.username,
              let _ = self.password else {
            print("Missing credentials")
            return nextChallengePromise.fail(SSHClientError.badCredentials)
        }
        
        //self.debugConfig()
        
        nextChallengePromise.succeed(NIOSSHUserAuthenticationOffer(username: self.username!, serviceName: "", offer: .password(.init(password: self.password!))))
    }
    
    func validateHostKey(hostKey: NIOSSH.NIOSSHPublicKey, validationCompletePromise: NIOCore.EventLoopPromise<Void>) {
        print("validateHostKey")
        validationCompletePromise.succeed(())
    }
}
