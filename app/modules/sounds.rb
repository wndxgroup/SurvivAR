module Sounds
  def play_wave_sound
    path = NSBundle.mainBundle.pathForResource('battleground', ofType:'wav')
    play_with_path(path)
  end

  def play_freeze_sound
    path = NSBundle.mainBundle.pathForResource('freeze', ofType:'mp3')
    play_with_path(path)
  end

  def play_shoot_sound
    path = NSBundle.mainBundle.pathForResource('shoot', ofType:'mp3')
    play_with_path(path)
  end

  def play_recharge_sound
    path = NSBundle.mainBundle.pathForResource('recharge-freeze-ability', ofType:'mp3')
    play_with_path(path)
  end

  def play_with_path(path)
    pathURL = NSURL.fileURLWithPath(path)
    # sound_id = Pointer.new('I')
    # AudioServicesCreateSystemSoundID(pathURL, sound_id)
    # AudioServicesPlaySystemSound(sound_id[0])

    @player = AVAudioPlayer.alloc.initWithContentsOfURL(pathURL, error: nil)
    @player.play
  end
end