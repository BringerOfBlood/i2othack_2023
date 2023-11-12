import processing.video.*;



int width_buffer = 640/4;
int height_buffer = 480/4;

PImage img;

LucasKanade optFlow = new LucasKanade(width_buffer, height_buffer, 5);

Capture video;
void setup() {
  size(640, 480);
  video = new Capture(this, 640, 480, "pipeline: ksvideosrc device-index=0 ! video/x-raw,width=640,height=480,framerate=30/1");
  video.start();
  
  img = createImage(width, height, RGB);
}

void captureEvent(Capture video) {
  video.read();
  img = video.copy();
  optFlow.shift_buffer(video);
}

void draw() {
  float[][][] uv = optFlow.optical_flow();
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      int ii = i/(width/width_buffer);
      int jj = j/(height/(height_buffer));
      float u = 100*uv[ii][jj][0];
      float v = 100*uv[ii][jj][1];
      float g = 0.1*(red(img.get(i, j)) + green(img.get(i, j)) + blue(img.get(i, j)));
      set(i, j, color(
        g + u - 0.5*v, 
        g - 0.5*u - 0.5*v, 
        g + v - 0.5*u));
    }
  }
}
