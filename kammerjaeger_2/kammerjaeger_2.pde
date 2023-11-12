import processing.video.*;

int width_buffer = 640/10;
int height_buffer = 480/10;
LucasKanade optFlow = new LucasKanade(width_buffer, height_buffer, 5);


PImage current;
PImage buffer1;
PImage buffer2;
PImage buffer3;

float[][] pheromone;
float[][] buffer;
float decay = 0.8;
float drag = 1.0;
Particle[] particles = new Particle[100000];

float angle = 0.3;
float sensor_dist = 5;
float angle_sensitivity = 0.9;
float rand_angle = 0.2;

Capture video;

void captureEvent(Capture video) {
  buffer1 = buffer2.copy();
  buffer2 = buffer3.copy();
  buffer3 = current.copy();
  
  video.read();
  
  current = video.copy();
  optFlow.shift_buffer(video);
}


void keyPressed() {
  resample_slime_mold_paramters();
}

void setup(){
  size(640, 480);
  //fullScreen();
  video = new Capture(this, 640, 480, "pipeline: ksvideosrc device-index=0 ! video/x-raw,width=640,height=480,framerate=30/1");
  video.start();
  current = createImage(width, height, RGB);
  buffer1 = createImage(width, height, RGB);
  buffer2 = createImage(width, height, RGB);
  buffer3 = createImage(width, height, RGB);

  pheromone = new float[width][height];
  buffer = new float[width][height];
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      pheromone[i][j] = 0;
      buffer[i][j] = 0;
    }
  }
  for (int k=0; k<particles.length; k++) {
    particles[k] = new Particle();
  }
}

void draw() {
  //video.loadPixels();
  //image(current,0 ,0);
  /*for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      set(i, j, color(abs(green(current.get(i, j)) - green(buffer1.get(i, j)))));
    }
  }*/
  float[][][] uv = optFlow.optical_flow();
  
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      float motion_level = abs(green(current.get(i, j)) - green(buffer1.get(i, j)));
      //if (i==50 && j==50) println(motion_level);
      set(i, j, color((pheromone[i][j]>100) ? 0.2*pheromone[i][j]-100 : 0, motion_level, 0.5*pheromone[i][j]));
      
      float dynamic_decay = max(0, 1-motion_level/1.);
      pheromone[i][j] *= decay*dynamic_decay;
    }
  }
  
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      float neighbor_sum = 0;
      for (int k=-1; k<=1; k++) {
        for (int q=-1; q<=1; q++) {
          int ii = i+k;
          int jj = j+q;
          if (ii < 0) ii += width;
          if (jj < 0) jj += height;
          if (ii >= width) ii -= width;
          if (jj >= height) jj -=height;
          
          neighbor_sum += pheromone[ii][jj];
        }
      }
      buffer[i][j] = neighbor_sum/9;
    }
  }
  pheromone = buffer;
  
  for (int k=0; k<particles.length; k++) {
    particles[k].update(uv);
  }
  //println(frameRate);
}
