module Sounds
  def play_wave_sound
    path = NSBundle.mainBundle.pathForResource('battleground', ofType:'wav')
    pathURL = NSURL.fileURLWithPath(path)
    sound_id = Pointer.new('I')
    AudioServicesCreateSystemSoundID(pathURL, sound_id)
    AudioServicesPlaySystemSound(sound_id[0])
  end

  def play_freeze_sound
    path = NSBundle.mainBundle.pathForResource('freeze', ofType:'mp3')
    pathURL = NSURL.fileURLWithPath(path)
    sound_id = Pointer.new('I')
    AudioServicesCreateSystemSoundID(pathURL, sound_id)
    AudioServicesPlaySystemSound(sound_id[0])
  end

  def play_shoot_sound
    path = NSBundle.mainBundle.pathForResource('shoot', ofType:'mp3')
    pathURL = NSURL.fileURLWithPath(path)
    sound_id = Pointer.new('I')
    AudioServicesCreateSystemSoundID(pathURL, sound_id)
    AudioServicesPlaySystemSound(sound_id[0])
  end
end