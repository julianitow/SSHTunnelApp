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
    let tunnelId: UUID
    
    init(tunnelId: UUID) {
        self.tunnelId = tunnelId
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error in pipeline: \(error)")
        context.close(promise: nil)
        NotificationCenter.default.post(name: Notification.Name.connectionErrorNotification, object: self.tunnelId)
    }
}

class NIOSSHClient {
    let id: UUID
    var group: MultiThreadedEventLoopGroup?
    var bootstrap: ClientBootstrap?
    //var channel: Channel?
    var server: PortForwardingServer?
    var isConnected: Bool = false
    var authenticationRequest: NIOSSHUserAuthenticationOffer?
    var authenticationRequestCount = 0
    var authenticationFailed: Bool = false
    
    var host: Substring?
    var port: Int?
    var targetHost: String?
    var targetPort: Int?
    var targetSSHPort: Int?
    var username: String?
    var password: String?
    
    
    init(id: UUID) {
        self.id = id
    }
    
    func debugConfig() -> Void {
        print(" host: \(String(describing: self.host))\n port: \(String(describing: self.port))\n targetHost: \(String(describing: self.targetHost))\n targetPort: \(String(describing: self.targetPort))\n username: \(String(describing: self.username))\n password: \(String(describing: self.password)) ")
    }
    
    func setConfig(config: SSHTunnelConfig) -> Void {
        self.host = "127.0.0.1"; //config.host.suffix(0)
        self.port = config.localPort
        self.targetHost = config.serverIP
        self.targetPort = config.distantPort
        self.username = config.username
        self.password = config.password
        self .authenticationRequest = NIOSSHUserAuthenticationOffer(username: self.username!, serviceName: "", offer: .password(.init(password: self.password!)))
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
                    ErrorHandler(tunnelId: self.id)
                ])
            }
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
            .channelOption(ChannelOptions.connectTimeout, value: .seconds(10))
        let channel: Channel
        do {
            channel = try self.bootstrap!.connect(host: self.targetHost!, port: self.targetSSHPort ?? 22).wait()
            self.isConnected = true
            channel.pipeline.handler(type: NIOSSHHandler.self).whenFailure({ err in print("FAILURE ERR", err)})
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.connectionNotification, object: self)
            }
        } catch {
            print("Channel ERROR:", error)
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
                
                sshHandler.createChannel(promise,
                                         channelType: .directTCPIP(directTCPIP)) { childChannel, channelType in
                    guard case .directTCPIP = channelType else {
                        return channel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                    }
                    
                    let (ours, theirs) = GlueHandler.matchedPair()
                    return childChannel.pipeline.addHandlers([SSHWrapperHandler(), ours, ErrorHandler(tunnelId: self.id)]).flatMap {
                        inboundChannel.pipeline.addHandlers([theirs, ErrorHandler(tunnelId: self.id)])
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
        if (!self.authenticationFailed) { NotificationCenter.default.post(name: Notification.Name.endConnectionNotification, object: self.id) }
    }
}

/**
 * NIOSSH related
 */
extension NIOSSHClient: NIOSSHClientUserAuthenticationDelegate, NIOSSHClientServerAuthenticationDelegate {
    
    func nextAuthenticationType(availableMethods: NIOSSH.NIOSSHAvailableUserAuthenticationMethods, nextChallengePromise: NIOCore.EventLoopPromise<NIOSSH.NIOSSHUserAuthenticationOffer?>) {
        print("nextAuthenticationType")
        self.authenticationRequestCount += 1
        
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
        
        if (self.authenticationRequestCount >= 6) {
            self.authenticationRequestCount = 0
            self.authenticationFailed = true
            return nextChallengePromise.fail(SSHClientError.authenticationFailed)
        }
                
        //self.debugConfig()
        nextChallengePromise.succeed(self.authenticationRequest)
    }
    
    func validateHostKey(hostKey: NIOSSH.NIOSSHPublicKey, validationCompletePromise: NIOCore.EventLoopPromise<Void>) {
        print("validateHostKey")
        validationCompletePromise.succeed(())
    }
}
