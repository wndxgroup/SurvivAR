module Survival
  def play_wave_sound
    path = NSBundle.mainBundle.pathForResource('wave-sound', ofType:'wav')
    pathURL = NSURL.fileURLWithPath(path)
    sound_id = Pointer.new('I')
    AudioServicesCreateSystemSoundID(pathURL, sound_id)
    AudioServicesPlaySystemSound(sound_id[0])
  end
end