//
//  SSHTunnelingApp.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 21/09/2023.
//

import SwiftUI

@main
struct SSHTunnelingApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) var openURL
    @StateObject var viewModel = SSHTunnelsViewModel()
    @State var updateAvailable: Bool = false
    
    var contentView: ContentView
    var appMenu: AppMenu
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init() {
        VersionService.fetchLatestTag()
        self.contentView = ContentView()
        self.appMenu = AppMenu()
    }
    

    var body: some Scene {
        Window("SSHTunneling", id: "main-window") {
            self.contentView
                .environmentObject(viewModel)
                .onAppear {
                    self.appDelegate.SSHTunnels = self.contentView.SSHTunnels
                }
                .alert("New update", isPresented: $updateAvailable) {
                    Button("Later", role: .cancel) {
                        updateAvailable = false
                    }
                    Button("Download") {
                        openURL(URL(string: REPO_URL)!)
                    }
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New tunnel") {
                    viewModel.newTunnel()
                }
                Divider()
                Button("Reset configs") {
                    NotificationCenter.default.post(name: Notification.Name.resetNotification, object: "resetConfig")
                }
            }
            CommandGroup(replacing: .saveItem) {
                EmptyView()
            }
            CommandGroup(replacing: .printItem) {
                EmptyView()
            }
            CommandGroup(replacing: .undoRedo) {
                EmptyView()
            }
            CommandGroup(replacing: .pasteboard) {
                EmptyView()
            }
            CommandGroup(replacing: .help) {
                Button("Check for update") {
                    if !VersionService.isLatest() {
                        self.updateAvailable = true
                    }
                }
            }
            CommandGroup(replacing: .appInfo) {
                Button("About SSHTunnelApp") {
                NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationVersion: "Version: \(VersionService.latestTag!.ref.split(separator: "/").last!)",
                            NSApplication.AboutPanelOptionKey.version: VersionService.latestTag!.ref.split(separator: "/").last!,
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "Julianitow Development Corporation",
                                attributes: [
                                    NSAttributedString.Key.font: NSFont.boldSystemFont(
                                        ofSize: NSFont.smallSystemFontSize)
                                ]
                            ),
                            NSApplication.AboutPanelOptionKey(
                                rawValue: "Copyright"
                            ): "© 2023 Julien GUILLAN"
                        ]
                    )
                }
            }
        }
        MenuBarExtra("SSH Tunneling", systemImage: "rectangle.connected.to.line.below") {
            self.appMenu
                .environmentObject(viewModel)
        }
        .menuBarExtraStyle(.menu)
    }
}
