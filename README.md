# Boids
This game built in the Godot engine uses hand tracking controls powered by MediaPipe (via OpenCV and Python) to model a flock of Boids.

I was inspired by three YouTube videos:

https://youtu.be/QbUPfMXXQIY
https://www.youtube.com/shorts/t-1QQQxZ9JE?feature=share
https://youtu.be/e2FtkufeErY

Everything is original with the exception of the hand_detection.py script which was used under the MIT Open Source License. The original can be found on Florian Trautweiler's GitHub page:

https://github.com/trflorian/virtual-hand-clone/blob/main/python/hand_detection.py

Demo.mp4 demonstrates each of the controls:

Cohesion and attraction strength: left pinch
Noise: right pinch
Time scale: index finger distance
Red color component: left hand rotation
Blue color component: right hand rotation