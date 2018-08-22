module Recorder
  def initiate_recording
    return unless Player.first.record?
    audio_session = AVAudioSession.sharedInstance
    audio_session.setCategory(AVAudioSessionCategoryPlayAndRecord,
                              withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker,
                              error: nil)
    audio_session.setActive(true, withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker, error: nil)

    recorder = RPScreenRecorder.sharedRecorder
    if recorder.available? && !recorder.recording?
      recorder.microphoneEnabled = true
      recorder.startRecordingWithHandler(lambda {|_|})
    end
  end
end