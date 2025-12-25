import Foundation
import Flutter
import UIKit

class DuixNativeHandler: NSObject, FlutterStreamHandler, URLSessionDownloadDelegate {
  static let shared = DuixNativeHandler()

  private var eventSink: FlutterEventSink?
  private var downloads: [Int: DownloadInfo] = [:]
  private var session: URLSession!
  private var viewController: FlutterViewController?

  private override init() {
    super.init()
    let cfg = URLSessionConfiguration.default
    session = URLSession(configuration: cfg, delegate: self, delegateQueue: nil)
  }

  func registerChannels(with controller: FlutterViewController) {
    self.viewController = controller
    let methodChannel = FlutterMethodChannel(name: "com.example.duix_sdk", binaryMessenger: controller.binaryMessenger)
    let eventChannel = FlutterEventChannel(name: "com.example.duix_sdk/events", binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(self)

    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      switch call.method {
      case "checkBaseConfig":
        result(self.checkBaseConfig())
      case "checkModel":
        if let args = call.arguments as? [String:Any], let modelName = args["modelName"] as? String {
          result(self.checkModel(modelName: modelName))
        } else { result(false) }
      case "downloadBaseConfig":
        if let args = call.arguments as? [String:Any], let url = args["url"] as? String {
          self.download(urlString: url)
          result(true)
        } else { result(false) }
      case "downloadModel":
        if let args = call.arguments as? [String:Any], let url = args["modelUrl"] as? String {
          self.download(urlString: url)
          result(true)
        } else { result(false) }
      case "initModel":
        if let args = call.arguments as? [String:Any], let modelName = args["modelName"] as? String {
          let ok = self.initModel(modelName: modelName)
          result(ok)
        } else { result(false) }
      case "playAudioBytes":
        if let args = call.arguments as? [String:Any], let data = args["audioBytes"] as? FlutterStandardTypedData {
          self.playAudioBytes(data.data)
          result(nil)
        } else { result(FlutterError(code: "BAD_ARGS", message: "audioBytes missing", details: nil)) }
      case "playWavFile":
        if let args = call.arguments as? [String:Any], let path = args["wavFilePath"] as? String {
          self.playWavFile(path)
          result(nil)
        } else { result(FlutterError(code: "BAD_ARGS", message: "wavFilePath missing", details: nil)) }
      case "stopAudio":
        GJLDigitalManager.manager().stopPlaying({ _ in })
        result(nil)
      case "isModelReady":
        result(GJLDigitalManager.manager().isGetAuth() == 1)
      case "setVolume":
        if let args = call.arguments as? [String:Any], let v = args["volume"] as? Double {
          GJLDigitalManager.manager().toSetVolume(Float(v))
          result(nil)
        } else { result(nil) }
      case "startPush":
        GJLDigitalManager.manager().newSession()
        result(nil)
      case "pushPcm":
        if let args = call.arguments as? [String:Any], let data = args["pcmData"] as? FlutterStandardTypedData {
          let ns = data.data
          GJLDigitalManager.manager().toWavPcmData(ns)
          result(nil)
        } else { result(FlutterError(code: "BAD_ARGS", message: "pcmData missing", details: nil)) }
      case "stopPush":
        GJLDigitalManager.manager().finishSession()
        result(nil)
      case "release":
        GJLDigitalManager.manager().toStop()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // hook SDK callbacks to emit events
    GJLDigitalManager.manager().playFailed = { [weak self] (code, msg) in
      self?.emitEvent(["type":"play_error","code":code,"message":msg ?? ""]) }
    GJLDigitalManager.manager().audioPlayEnd = { [weak self] in
      self?.emitEvent(["type":"play_end"]) }
    GJLDigitalManager.manager().audioPlayProgress = { [weak self] (current,total) in
      self?.emitEvent(["type":"audio_progress","current":current,"total":total]) }
  }

  // MARK: - Stream Handler
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  private func emitEvent(_ payload: [String:Any]) {
    DispatchQueue.main.async {
      self.eventSink?(payload)
    }
  }

  // MARK: - Checks
  private func cacheBaseDir() -> URL {
    let lib = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    let cache = lib.appendingPathComponent("GJCache/model")
    try? FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true, attributes: nil)
    return cache
  }

  func checkBaseConfig() -> Bool {
    let base = cacheBaseDir().appendingPathComponent("gj_dh_res")
    let baseTag = cacheBaseDir().appendingPathComponent("tmp/gj_dh_res")
    return FileManager.default.fileExists(atPath: base.path) && FileManager.default.fileExists(atPath: baseTag.path)
  }

  func checkModel(modelName: String) -> Bool {
    let modelDir = cacheBaseDir().appendingPathComponent(modelName)
    let tag = cacheBaseDir().appendingPathComponent("tmp/") .appendingPathComponent(modelName)
    return FileManager.default.fileExists(atPath: modelDir.path) && FileManager.default.fileExists(atPath: tag.path)
  }

  // MARK: - Init
  func initModel(modelName: String) -> Bool {
    let base = cacheBaseDir().appendingPathComponent("gj_dh_res")
    let digital = cacheBaseDir().appendingPathComponent(modelName)
    guard FileManager.default.fileExists(atPath: base.path), FileManager.default.fileExists(atPath: digital.path) else {
      return false
    }
    DispatchQueue.main.sync {
      if let vc = self.viewController {
        let showView = UIView(frame: vc.view.bounds)
        showView.backgroundColor = UIColor.clear
        vc.view.addSubview(showView)
        let result = GJLDigitalManager.manager().initBaseModel(base.path, digitalModel: digital.path, showView: showView)
        if result == 1 {
          GJLDigitalManager.manager().toStart({ isSuccess, err in
            if isSuccess {
              GJLDigitalManager.manager().toStartRuning()
            } else {
              self.emitEvent(["type":"init_error","message":err ?? ""]) }
          })
        } else {
          self.emitEvent(["type":"init_failed","code":result])
        }
      }
    }
    return true
  }

  // MARK: - Play
  func playAudioBytes(_ data: Data) {
    // Expect PCM bytes (16k mono). Directly push.
    GJLDigitalManager.manager().toWavPcmData(data)
  }

  func playWavFile(_ path: String) {
    // For simplicity, if file path points to wav, try using GJLPCMManager if available.
    if let cls = NSClassFromString("GJLPCMManager") as? NSObjectProtocol,
       cls.responds(to: Selector(("toSpeakWithPath:"))) {
      let sel = Selector("toSpeakWithPath:")
      _ = cls.perform(sel, with: path)
    } else {
      // fallback: read file and attempt to send raw data
      if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
        GJLDigitalManager.manager().toWavPcmData(data)
      }
    }
  }

  // MARK: - Download
  private struct DownloadInfo {
    let urlString: String
    let zipPath: URL
    let destPath: URL
  }

  func download(urlString: String) {
    guard let url = URL(string: urlString) else { return }
    let cache = cacheBaseDir()
    let zipName = url.lastPathComponent
    let zipPath = cache.appendingPathComponent(zipName)
    let dest = cache.appendingPathComponent((zipName as NSString).deletingPathExtension)

    let task = session.downloadTask(with: url)
    downloads[task.taskIdentifier] = DownloadInfo(urlString: urlString, zipPath: zipPath, destPath: dest)
    task.resume()
    emitEvent(["type":"download_start","url":urlString])
  }

  // URLSessionDownloadDelegate
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    guard let info = downloads[downloadTask.taskIdentifier] else { return }
    emitEvent(["type":"download_progress","url":info.urlString,"current":totalBytesWritten,"total":totalBytesExpectedToWrite])
  }

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    guard let info = downloads[downloadTask.taskIdentifier] else { return }
    do {
      try FileManager.default.removeItem(at: info.zipPath)
    } catch {}
    do {
      try FileManager.default.moveItem(at: location, to: info.zipPath)
    } catch {
      emitEvent(["type":"download_fail","url":info.urlString,"code":-1000,"message":error.localizedDescription])
      downloads.removeValue(forKey: downloadTask.taskIdentifier)
      return
    }

    // unzip with SSZipArchive progress
    SSZipArchive.unzipFile(atPath: info.zipPath.path, toDestination: info.destPath.path, progressHandler: { entry, zipInfo, entryIndex, total in
      self.emitEvent(["type":"unzip_progress","url":info.urlString,"current":entryIndex,"total":total])
    }, completionHandler: { path, succeeded, error in
      if succeeded {
        self.emitEvent(["type":"download_complete","url":info.urlString,"path":info.destPath.path])
      } else {
        self.emitEvent(["type":"download_fail","url":info.urlString,"code":-1001,"message":error?.localizedDescription ?? "unzip failed"]) }
      self.downloads.removeValue(forKey: downloadTask.taskIdentifier)
    })
  }
}
