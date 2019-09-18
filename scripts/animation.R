#20190917 animation
# making it into a separate script

require(magick)
setwd("/Users/grapp/Desktop/working/B_v2/animations")
## creating and saving animations
system("convert *.png -delay 2 -loop 0 bw5_animation.gif")