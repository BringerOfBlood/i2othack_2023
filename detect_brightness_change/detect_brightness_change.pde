import processing.video.*;

PImage current;
PImage buffer;
PImage buffer2;
PImage buffer3;

Capture video;
void setup() {
  size(640, 480);
  video = new Capture(this, 640, 480, "pipeline: ksvideosrc device-index=0 ! video/x-raw,width=640,height=480,framerate=30/1");
  video.start();
  current = createImage(width, height, RGB);
  buffer = createImage(width, height, RGB);
  buffer2 = createImage(width, height, RGB);
  buffer3 = createImage(width, height, RGB);
}

void captureEvent(Capture video) {
  buffer = buffer2.copy();
  buffer2 = buffer3.copy();
  buffer3 = current.copy();

  video.read();

  current = video.copy();
}

PImage blur(PImage img, int window) {
  PImage img_out = img.copy();
  for (int i=0; i<=img.width; i++) {
    for (int j=0; j<=img.height; j++) {
      float sum_r = 0, sum_g = 0, sum_b=0;
      float count = 0;
      for (int k=-window; k<=window; k++) {
        for (int p=-window; p<=window; p++) {
          int ii = ((i + k) + width)%width;
          int jj = ((j + p) + height)%height;
          color pix_color = img.get(ii, jj);
            float r = red(pix_color);
          float g = green(img.get(ii, jj));
          float b = blue(img.get(ii, jj));
          sum_r += r;
          sum_g += g;
          sum_b += b;
          count += 1;
        }
      }
      img_out.set(i, j, color(int(sum_r/count), int(sum_g/count), int(sum_b/count)));
    }
  }
  return img_out;
}

void draw() {
  //video.loadPixels();
  //image(current,0 ,0);
  PImage cur = current.copy();//blur(current, 1);
  PImage buf = buffer.copy(); //blur(buffer, 1);
  /*cur.filter(BLUR, 3);
  buf.filter(BLUR, 3);*/
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      float motion_level = abs(green(cur.get(i, j)) - green(buf.get(i, j)));
      float motion_threshold = 20;
      float motion_amplification = 2;
      set(i, j, color(max(0, motion_level - motion_threshold)*motion_amplification));
      //set(i, j, color(motion_level));
    }
  }
}
