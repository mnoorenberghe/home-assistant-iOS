//
//  MediaPlayerComponent.swift
//  HomeAssistant
//
//  Created by Robbie Trencheny on 4/5/16.
//  Copyright © 2016 Robbie Trencheny. All rights reserved.
//

import Foundation
import ObjectMapper

class MediaPlayer: SwitchableEntity {

    var IsPlaying: Bool = false
    var IsIdle: Bool = false
    var IsVolumeMuted: Bool = false
    var MediaContentID: String? = nil
    var MediaContentType: String? = nil
    var MediaDuration: Int?
    var MediaTitle: String? = nil
    var VolumeLevel: Float?
    var Source: String? = nil
    var SourceList: [String] = [String]()
    var SupportsPause: Bool = false
    var SupportsSeek: Bool = false
    var SupportsVolumeSet: Bool = false
    var SupportsVolumeMute: Bool = false
    var SupportsPreviousTrack: Bool = false
    var SupportsNextTrack: Bool = false
    var SupportsTurnOn: Bool = false
    var SupportsTurnOff: Bool = false
    var SupportsPlayMedia: Bool = false
    var SupportsVolumeStep: Bool = false
    var SupportsSelectSource: Bool = false
    var SupportsStop: Bool = false
    var SupportsClearPlaylist: Bool = false
    var SupportedMediaCommands: Int?

    override func mapping(map: Map) {
        super.mapping(map: map)

        IsPlaying        <- (map["state"], ComponentBoolTransform(trueValue: "playing", falseValue: "paused"))
        IsIdle           <- (map["state"], ComponentBoolTransform(trueValue: "idle", falseValue: ""))
        IsVolumeMuted    <- map["attributes.is_volume_muted"]
        MediaContentID   <- map["attributes.media_content_id"]
        MediaContentType <- map["attributes.media_content_type"]
        MediaDuration    <- map["attributes.media_duration"]
        MediaTitle       <- map["attributes.media_title"]
        Source           <- map["attributes.source"]
        VolumeLevel      <- map["attributes.volume_level"]
        SourceList       <- map["attributes.source_list"]

        SupportedMediaCommands  <- map["attributes.supported_media_commands"]

        if let supported = self.SupportedMediaCommands {
            let features = MediaPlayerSupportedCommands(rawValue: supported)
            self.SupportsPause = features.contains(.Pause)
            self.SupportsSeek = features.contains(.Seek)
            self.SupportsVolumeSet = features.contains(.VolumeSet)
            self.SupportsVolumeMute = features.contains(.VolumeMute)
            self.SupportsPreviousTrack = features.contains(.PreviousTrack)
            self.SupportsNextTrack = features.contains(.NextTrack)
            self.SupportsTurnOn = features.contains(.TurnOn)
            self.SupportsTurnOff = features.contains(.TurnOff)
            self.SupportsPlayMedia = features.contains(.PlayMedia)
            self.SupportsVolumeStep = features.contains(.VolumeStep)
            self.SupportsSelectSource = features.contains(.SelectSource)
            self.SupportsStop = features.contains(.Stop)
            self.SupportsClearPlaylist = features.contains(.ClearPlaylist)
        }
    }

    func humanReadableMediaDuration() -> String {
        if let durationSeconds = self.MediaDuration {
            let hours = durationSeconds / 3600
            let minutes = (durationSeconds % 3600) / 60
            let seconds = (durationSeconds % 3600) % 60
            return "\(hours):\(minutes):\(seconds)"
        } else {
            return "00:00:00"
        }
    }

    func muteOn() {
        let _ = HomeAssistantAPI.sharedInstance.CallService(domain: "media_player",
                                                            service: "volume_mute",
                                                            serviceData: [
                                                                "entity_id": self.ID as AnyObject,
                                                                "is_volume_muted": "on" as AnyObject
            ])
    }
    func muteOff() {
        let _ = HomeAssistantAPI.sharedInstance.CallService(domain: "media_player",
                                                            service: "volume_mute",
                                                            serviceData: [
                                                                "entity_id": self.ID as AnyObject,
                                                                "is_volume_muted": "off" as AnyObject
            ])
    }
    func setVolume(_ newVolume: Float) {
        let fixedVolume = newVolume/100
        let _ = HomeAssistantAPI.sharedInstance.CallService(domain: "media_player",
                                                            service: "volume_set",
                                                            serviceData: [
                                                                "entity_id": self.ID as AnyObject,
                                                                "volume_level": fixedVolume as AnyObject
            ])
    }

    override var ComponentIcon: String {
        return "mdi:cast"
    }

    override func StateIcon() -> String {
        return (self.State != "off" && self.State != "idle") ? "mdi:cast-connected" : "mdi:cast"
    }
}

struct MediaPlayerSupportedCommands: OptionSet {
    let rawValue: Int

    static let Pause = MediaPlayerSupportedCommands(rawValue: 1)
    static let Seek = MediaPlayerSupportedCommands(rawValue: 2)
    static let VolumeSet = MediaPlayerSupportedCommands(rawValue: 4)
    static let VolumeMute = MediaPlayerSupportedCommands(rawValue: 8)
    static let PreviousTrack = MediaPlayerSupportedCommands(rawValue: 16)
    static let NextTrack = MediaPlayerSupportedCommands(rawValue: 32)
    static let TurnOn = MediaPlayerSupportedCommands(rawValue: 128)
    static let TurnOff = MediaPlayerSupportedCommands(rawValue: 256)
    static let PlayMedia = MediaPlayerSupportedCommands(rawValue: 512)
    static let VolumeStep = MediaPlayerSupportedCommands(rawValue: 1024)
    static let SelectSource = MediaPlayerSupportedCommands(rawValue: 2048)
    static let Stop = MediaPlayerSupportedCommands(rawValue: 4096)
    static let ClearPlaylist = MediaPlayerSupportedCommands(rawValue: 8192)
}
