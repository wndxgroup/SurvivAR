module Recorder
  def initiate_recording
    recorder = RPScreenRecorder.sharedRecorder
    if recorder.available? && !recorder.recording?
      recorder.microphoneEnabled = true
      recorder.startRecordingWithHandler(lambda {|_|})
    end
  end
end