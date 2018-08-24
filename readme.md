# SurvivAR #
This is an AR survival game where you are placed in the center of a battleground with 3 demons chasing you. If a demon gets close enough to touch you, you die. 

The only way to survive is to shoot the demons. However, every shot you take releases another demon into the battleground. So choose your shots wisely.

If you find yourself in a sticky situation, you have one special ability: you can freeze the demons in place for 10 seconds. This gives you a chance to orient yourself into a better position for survival. The ability does take some time to refresh, so only use it when you're in trouble. And heads up, you can't pickup ammo while the demons are frozen.

## Leaderboard Rankings ##
Each battleground is timed and the number of kills are counted. From the menu screen, you can access a leaderboard that lists the bests rounds ever played on the device, sorted by either round length or number of kills.

## Share Your Rounds ##
To go beyond just tracking the number of kills and the length of each battleground you play, each round is also recorded. After you die, you'll have the opportunity to replay the recording, save it, and share it with others. If you decide you don't want it, the app deletes it for you automatically so it doesn't waste any memory or storage.

## Multiple Accounts ##
The app conveniently allows you add multiple accounts to be played with. So if you have a child without a phone, or are with someone who would like to quickly try the application before downloading it to their own device, you can simply create them an account. That way their battlegrounds won't affect your account's history, statistics, or leaderboard rankings.

## Supported Devices ##
SurvivAR is built with the help of ARKit, which, according to the [Apple website](https://www.apple.com/ca/ios/augmented-reality/), "requires an iOS device with iOS 11 and an A9 processor or later". This limits the use of SurvivAR to the iPhone SE or newer, the 5th generation iPad, and all the iPad Pro models. At the time of writing this, however, I have only tested it with the iPhone SE.

## Shooting Accuracy Bug ##
I don't think ARKit was intended to be used in high-movement situations. While playing with the app, if you've moved around a lot, you'll notice that the bullets you shoot don't always fly directly where you are aiming. I'm not exactly sure why this occurs, so by all means, submit a pull request if you figure out a solution.