module Sounds
  def play_wave_sound
    play('battleground', ext: 'wav')
  end

  def play_freeze_sound
    play('freeze', ext: 'mp3')
  end

  def play_shoot_sound
    play('shoot', ext: 'mp3')
  end

  def play_recharge_sound
    play('recharge-freeze-ability', ext: 'mp3')
  end

  def play(filename, ext: extension)
    path = NSBundle.mainBundle.pathForResource(filename, ofType: extension)
    pathURL = NSURL.fileURLWithPath(path)
    @player = AVAudioPlayer.alloc.initWithContentsOfURL(pathURL, error: nil)
    @player.play
  end
end