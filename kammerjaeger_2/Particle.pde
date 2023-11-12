class Particle{
  PVector position;
  PVector velocity;
  
  Particle() {
    position = new PVector(random(width), random(height));//width/2, height/2);//
    velocity = PVector.random2D();
    
  }
  
  void update(float[][][] uv) {
    
    
    int x = max(0, min(width-1, int(position.x)));
    int y = max(0, min(height-1, int(position.y)));
    
    int ii = x/(width/width_buffer);
    int jj = y/(height/(height_buffer));
    ii = max(0, min(width-1, ii));
    jj = max(0, min(height-1, jj));
    
    float u = -drag*uv[ii][jj][0];
    float v = -drag*uv[ii][jj][1];
    
    velocity.x += u;
    velocity.y += v;
    PVector target_vel = velocity.copy().normalize();
    velocity.x = velocity.x + 0.1*(target_vel.x - velocity.x);
    velocity.y = velocity.y + 0.1*(target_vel.y - velocity.y);
    
    
    position.add(velocity);
    /*int x = int(position.x);
    int y = int(position.y);*/
    pheromone[x][y] += 255;
    
    //float motion_level = abs(green(current.get(x, y)) - green(buffer1.get(x, y)));
    //if (motion_level>10) position = new PVector(random(width), random(height));
    
    PVector position_left_sensor = PVector.add(position, velocity.copy().rotate(-angle).normalize().mult(sensor_dist));
    int x_pls = int(position_left_sensor.x);
    int y_pls = int(position_left_sensor.y);
    
    if (x_pls < 0) x_pls += width;
    if (y_pls < 0) y_pls += height;
    if (x_pls >= width) x_pls -= width;
    if (y_pls >= height) y_pls -=height;
    
    PVector position_right_sensor = PVector.add(position, velocity.copy().rotate(angle).normalize().mult(sensor_dist));
    int x_prs = int(position_right_sensor.x);
    int y_prs = int(position_right_sensor.y);
    
    if (x_prs < 0) x_prs += width;
    if (y_prs < 0) y_prs += height;
    if (x_prs >= width) x_prs -= width;
    if (y_prs >= height) y_prs -=height;
    
    
    if (pheromone[x_pls][y_pls] < pheromone[x_prs][y_prs]) {
      velocity.rotate(angle_sensitivity*angle);
    } else {
      velocity.rotate(-angle_sensitivity*angle);
    }
    velocity.rotate(random(-rand_angle, rand_angle));
    
    
    if (position.x <= 0) position.x += width;
    if (position.y <= 0) position.y += height;
    if (position.x >= (width-1)) position.x -= width;
    if (position.y >= (height-1)) position.y -= height;
  }
}
