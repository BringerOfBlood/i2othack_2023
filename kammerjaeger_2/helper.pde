void resample_slime_mold_paramters() {
  angle = random(PI/2);
  sensor_dist = random(30);
  angle_sensitivity = random(0.5, 1.0);
  rand_angle = random(PI/4);
  println("angle: "+angle+", sensor_dist: "+sensor_dist+", angle_sensitivity: "+angle_sensitivity+", rand_angle: "+rand_angle);
}
