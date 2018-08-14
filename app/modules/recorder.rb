module Recorder
  def initiate_recording
    recorder = RPScreenRecorder.sharedRecorder
    if recorder.available? && !recorder.recording?
      recorder.microphoneEnabled = false
      recorder.startRecordingWithHandler(lambda {|_|})
    end
  end
end