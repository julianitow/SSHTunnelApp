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
        self.contentView = ContentView()
        self.appMenu = AppMenu()
        NotificationService.requestAuthorization()
    }
    

    var body: some Scene {
        Window("SSHTunneling", id: "main-window") {
            self.contentView
                .environmentObject(viewModel)
                .onAppear {
                    self.appDelegate.SSHTunnels = self.contentView.SSHTunnels
                    self.appDelegate.viewModel = viewModel
                    VersionService.fetchLatestTag { updateAvailable in
                        self.updateAvailable = updateAvailable
                    }
                }
                .alert("New version available: \(VersionService.latestTag?.version ?? "")", isPresented: $updateAvailable) {
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
                Button("Check for update") {
                    VersionService.fetchLatestTag { updateAvailable in
                        self.updateAvailable = updateAvailable
                    }
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
                EmptyView()
            }
            CommandGroup(replacing: .appInfo) {
                Button("About SSHTunnelApp") {
                NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationVersion: "Version: \(VersionService.latestTag?.version ?? "")" ,
                            NSApplication.AboutPanelOptionKey.version: VersionService.latestTag?.version ?? "",
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
