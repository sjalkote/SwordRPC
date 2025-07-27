//
//  Register.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

#if !os(Linux)
import CoreServices
#else
import Glibc
#endif

/// Platform-specific registration utilities for SwordRPC.
///
/// This extension enables the Discord Rich Presence client to register custom URL schemes
/// and Steam game handlers on macOS, Linux, and other supported platforms.
/// The registration allows Discord to launch the game or application via
/// protocol links (e.g., `discord-<appid>://`) and, if applicable, Steam URLs.
///
/// On macOS, it uses CoreServices to register the URL scheme and, if a Steam ID
/// is provided, creates a JSON file for Discord to launch the game via Steam.
/// On Linux, it creates a .desktop file and registers the custom URL scheme
/// using xdg utilities, supporting both native and Steam games.
extension SwordRPC {
  
  /// Creates a file with the specified name, path, and contents.
  /// - Parameters:
  ///   - name: The name of the file to create.
  ///   - path: The directory path where the file will be created (relative to the user's home directory).
  ///   - data: The string contents to write to the file.
    func createFile(_ name: String, at path: String, with data: String) {
        let fm = FileManager.default
    
        try? fm.createDirectory(
            atPath: NSHomeDirectory() + path,
            withIntermediateDirectories: true,
            attributes: nil
        )
    
        fm.createFile(
            atPath: path + "/" + name,
            contents: data.data(using: .utf8),
            attributes: nil
        )
    }
  
  /// Registers the application's custom URL scheme with the OS so Discord can launch it via protocol links.
  ///
  /// On macOS, registers the URL scheme using CoreServices. If a Steam ID is provided, registers a Steam handler instead.
  /// On Linux, creates a .desktop file and registers the scheme using xdg utilities.
    func registerUrl() {
#if !os(Linux)
        guard self.steamId == nil else {
            self.registerSteamGame()
            return
        }
      
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return
        }
    
        let scheme = "discord-\(self.appId)" as CFString
        var response = LSSetDefaultHandlerForURLScheme(
            scheme,
            bundleId as CFString
        )
    
        guard response == 0 else {
            print("[SwordRPC] Error creating URL scheme: \(response)")
            return
        }
    
        let bundleUrl = Bundle.main.bundleURL as CFURL
        response = LSRegisterURL(bundleUrl, true)
      
        if response != 0 {
            print("[SwordRPC] Error registering application: \(response)")
        }
#else
        var execPath = ""
      
        if let steamId = self.steamId {
            execPath = "xdg-open steam://rungameid/\(steamId)"
        } else {
            let exec = UnsafeMutablePointer<Int8>.allocate(
                capacity: Int(PATH_MAX) + 1
            )
      
            defer {
                free(exec)
            }
      
            let n = readlink("/proc/self/exe", exec, Int(PATH_MAX))
            guard n >= 0 else {
                print("[SwordRPC] Error getting game's execution path")
                return
            }
            exec[n] = 0
      
            execPath = String(cString: exec)
        }
      
      self.createFile(
        "discord-\(self.appId).desktop",
        at: "/.local/share/applications",
        with: """
        [Desktop Entry]
        Name=Game \(self.appId)
        Exec=\(execPath) %u
        Type=Application
        NoDisplay=true
        Categories=Discord;Games;
        MimeType=x-scheme-handler/discord-\(self.appId)
        """
      )
    
      let command = "xdg-mime default discord-\(self.appId).desktop x-scheme-handler/discord-\(self.appId)"
      
      if system(command) < 0 {
          print("[SwordRPC] Error registering URL scheme")
      }
#endif
  }
  
#if !os(Linux)
  /// Registers a Steam game handler for Discord by creating a JSON file with the Steam launch command.
  /// Only used on macOS if a Steam ID is provided.
  func registerSteamGame() {
      if self.steamId == nil {
          print("[SwordRPC] No Steam ID provided, cannot register Steam game.")
      }
      self.createFile(
        "\(self.appId).json",
        at: "/Library/Application Support/discord/games",
        with: """
        {
        "command": "steam://rungameid/\(self.steamId!)"
        }
        """
      )
  }
#endif
  
}
