Accelerate of IOS Spectral Flux detection function
================

I'm working on a IOS process for audio spectral flux signal for a peak finder.
I tried a lot of stuffs on the internet, but I didn't find something very efficient, except professional SDK, but that costs a lot of money and as it's just for a study, I've been forced to work on it from scratch by myself.

So now that works great and at the end, we'll be able to obtain an array of flux for a the peak detector.

But now i'm facing a issue, it is slow. 

iPad mini : Finished in : 30.943131 for 6.226721 min(s)

iPad air : Finished in : 7.547086 for 6.226721 min(s)

iPhone 5 : Finished in : 18.188398 for 6.226721 min(s)


EDIT New stats:

iPad mini : Finished in : 22.382947 for 6.226721 min(s) 29% gain

iPad air : Finished in : 3.890087 for 6.226721 min(s) 48% gain

iPhone 5 : Finished in : 12.774067 for 6.226721 min(s) 33% gain


So, I tried during a lot of times to accelerate the process, but I didn't find a true solution.
I'm still convincing that something can be done.  

So now I'm looking for advises, or someone wiser than me because I pretty sure, I missed something . 

Very important!

The HopeTime (Spacing of audio frames) has to stay at 0,010 Ms for the best scan result, and I can't drop my framecount (Total number of audio frames) as well to keep the flux quite good.  

So for example :

I tried to raise the fftSize buffer and the buffSize and adapt the last loop for the flux to keep it intact, but with 2048 it's perfect when I use 4096 each time I got a crash from the FFT accelerate function?

I tried also to get directly the stream in mono from the reader to reduce the amount of data but the reader seems to mix the channel left with the rigth and at the end the result is deteriorated.

Pat
