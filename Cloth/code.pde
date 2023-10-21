
// Link length
float link_length = 0.5;

// All the nodes for the cloth
Node[][] everynode = new Node[10][10]; 



// Gravity
Vec3 gravity = new Vec3(0, 10, 0);

// Scaling factor for the scene
float scene_scale = width / 10.0f;

// Physics Parameters
int relaxation_steps = 1;
int sub_steps = 10;

// For pausing the simulation
boolean paused = false;

// Variables for adding on the nodes
float x_pos = 5.0;
float y_pos = 5.0;
float z_pos = 5.0;

// The code for the sphere obstacle and image for the sphere texture
PImage img;
PShape globe;

// Code for the camera movement
float eyeX, eyeY, eyeZ;

// The angle of the camera pointing
float ang = 0;

// Starting z value for camera
float d = -52.094467;

void keyPressed() {

  if (key == ' ') {
      paused = !paused;
    }
   if (key == 'd') {
       // To add a angle and adjust the z value when d is pressed on the keyboard
       ang += 5;
       eyeZ = d*cos(radians(ang));

    }
    
  if (key == CODED) {
    if (keyCode == UP) {
      // When the up arrow key is pressed it moves the camera up and tilts the camera with scalars
      ang += 5;
      eyeY += 20;
    }
    
    if (keyCode == DOWN) {
      // When the down arrow key is pressed it moves the camera down
      eyeY -= 20;
    }
    if (keyCode == RIGHT) {
      // When the right arrow key is pressed it moves the camera to the right
      eyeX += 10;
    }
    if (keyCode == LEFT) {
      // When the left arrow key is pressed it moves the camera to the left
      eyeX -= 10;
    }
  }
}

void setup() {
  size(600, 600, P3D);
  surface.setTitle("Project 2 :)");

  // Setting up globe obstacle:
  img = loadImage("glob.png");
  globe = createShape(SPHERE, 50);
  globe.setTexture(img);

  scene_scale = width / 10.0f;

  // Adding the position for the nodes for the cloth
  for(int i = 0; i < everynode.length; i++) {
    for(int j = 0; j < everynode.length; j++) {
      everynode[i][j] = new Node(new Vec3(x_pos + link_length * i, y_pos, z_pos + link_length * j));
    }
  }

  // Setting up camera coordinates
  eyeX = 280;

  eyeY = 280;
  
  eyeZ = d;

}

// Adding the sphere positions
float SpherePos_x = 7;
float SpherePos_y = 8;
float SpherePos_z = 4;
Vec3 SpherePos = new Vec3(SpherePos_x, SpherePos_y, SpherePos_z);

// Node struct
class Node {
  Vec3 pos;
  Vec3 vel;
  Vec3 last_pos;

  Node(Vec3 pos) {
    this.pos = pos;
    this.vel = new Vec3(0, 0, 0);
    this.last_pos = pos;
  }
}


void array_update_physics(float dt) {
  // Simulate nodes position & velocity
  for(int n = 0; n < everynode.length; n++) {
      for(int m = 0; m < everynode.length; m++) {
        everynode[n][m].last_pos = everynode[n][m].pos;
        everynode[n][m].vel = everynode[n][m].vel.plus(gravity.times(dt));
        everynode[n][m].pos = everynode[n][m].pos.plus(everynode[n][m].vel.times(dt));
        
      }
    }
  
  // Constrain the distance between nodes to the link length
  for (int i = 0; i < relaxation_steps; i++) {
    for(int j = 1; j < everynode.length; j++) {
      for(int k = 0; k < everynode.length; k++) {
        Vec3 delta = everynode[j][k].pos.minus(everynode[j-1][k].pos);
        float delta_len = delta.length();
        float correction = delta_len - link_length;
        Vec3 delta_normalized = delta.normalized();
        everynode[j][k].pos = everynode[j][k].pos.minus(delta_normalized.times(correction / 2));
        everynode[j-1][k].pos = everynode[j-1][k].pos.plus(delta_normalized.times(correction / 2));
        
      }
    }
    
    for(int j = 0; j < everynode.length; j++) {
      for(int k = 1; k < everynode.length; k++) {
        Vec3 delta = everynode[j][k].pos.minus(everynode[j][k-1].pos);
        float delta_len = delta.length();
        float correction = delta_len - link_length;
        Vec3 delta_normalized = delta.normalized();
        everynode[j][k].pos = everynode[j][k].pos.minus(delta_normalized.times(correction / 2));
        everynode[j][k-1].pos = everynode[j][k-1].pos.plus(delta_normalized.times(correction / 2));
        
      }
    }
    
    // Code to pin two nodes
    everynode[0][0].pos = new Vec3(5, 5, 5);
    everynode[9][0].pos = everynode[9][0].last_pos;
    
  }
  
  for(int j = 0; j < everynode.length; j++) {
      for(int k = 0; k < everynode.length; k++) {
        // Code for Sphere collision:
        Vec3 curr_scaled = new Vec3(everynode[j][k].pos.x * scene_scale, everynode[j][k].pos.y * scene_scale,  everynode[j][k].pos.z * scene_scale);
        Vec3 sph_scaled = new Vec3(SpherePos.x * scene_scale, SpherePos.y * scene_scale,  SpherePos.z * scene_scale);
        float d = sph_scaled.distanceTo(curr_scaled);
        
        if(d < 50+.09){
          
          Vec3 n = (curr_scaled.minus(sph_scaled)).normalized();
          Vec3 bn = sph_scaled.plus(n.times(52).times(1));
          
          // Scale down calculations to set position of node
          Vec3 sbn = new Vec3(bn.x/scene_scale, bn.y/scene_scale,bn.z/scene_scale);
          everynode[j][k].pos = sbn;
          
          // Reset last_pos
          everynode[j][k].last_pos = everynode[j][k].pos;

        }
        everynode[j][k].vel = everynode[j][k].pos.minus(everynode[j][k].last_pos).times(1 / dt);
        
      }
    }
  
}


float zoom = 1;
final static float inc = .05;
float time = 0;
void draw() {

  background(0);

  // Lighting:
  int sc = 10;
  directionalLight(51*sc, 102*sc, 126*sc, eyeX, eyeY, eyeZ);
  ambientLight(51*sc, 102*sc, 126*sc, eyeX, eyeY, eyeZ);

  // CAMERA:  
  camera(eyeX, eyeY, eyeZ, height/2, width/2, 0, 0, 1, 0);

  float dt = 0.05; //Dynamic dt: 1/frameRate;
  
  if (!paused) {
    for (int i = 0; i < sub_steps; i++) {
      time += dt / sub_steps;
      array_update_physics(dt / sub_steps);
    }
  }


  background(255);
  stroke(0);
  strokeWeight(2);

  fill(0, 255, 0);
  stroke(0);
  strokeWeight(0.02 * scene_scale);
  

  // Drawing individual nodes
  for(int i = 0; i < everynode.length; i++) {
    for(int j = 0; j < everynode.length; j++) {
      pushMatrix();
      translate(everynode[i][j].pos.x * scene_scale, everynode[i][j].pos.y * scene_scale,  everynode[i][j].pos.z * scene_scale);
      
      fill(0, 255, 0);
      sphere(0.5); 
      popMatrix();
      
  }
}
  
  // Draw Links
  stroke(0);
  strokeWeight(0.02 * scene_scale);
  for(int i = 0; i < everynode.length; i++) {
    for(int j = 0; j < everynode.length; j++) {
      if(i+1 < everynode.length){
       line(everynode[i][j].pos.x * scene_scale, everynode[i][j].pos.y * scene_scale,everynode[i][j].pos.z * scene_scale, everynode[i+1][j].pos.x * scene_scale, everynode[i+1][j].pos.y * scene_scale, everynode[i+1][j].pos.z * scene_scale);
       
      }
      if(j+1 < everynode.length){
       line(everynode[i][j].pos.x * scene_scale, everynode[i][j].pos.y * scene_scale,everynode[i][j].pos.z * scene_scale, everynode[i][j+1].pos.x * scene_scale, everynode[i][j+1].pos.y * scene_scale,  everynode[i][j+1].pos.z * scene_scale);
      }
    }
  }

  // Sphere
  noStroke(); 
  beginShape();
  pushMatrix();
    translate(SpherePos_x* scene_scale, SpherePos_y* scene_scale, SpherePos_z* scene_scale);
    shape(globe);
  popMatrix();
  
  endShape();

  

}


//---------------
//Vec 2 Library
//---------------

//Vector Library
//CSCI 5611 Vector 2 Library
// Stephen J. Guy <sjguy@umn.edu>

public class Vec3 {
  public float x, y, z;

  public Vec3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public String toString() {
    return "(" + x + "," + y +"," + z + ")";
  }

  public float length() {
    return sqrt(x * x + y * y + z * z);
  }

  public float lengthSqr() {
    return x * x + y * y + z * z;
  }

  public Vec3 plus(Vec3 rhs) {
    return new Vec3(x + rhs.x, y + rhs.y, z + rhs.z);
  }

  public void add(Vec3 rhs) {
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }

  public Vec3 minus(Vec3 rhs) {
    return new Vec3(x - rhs.x, y - rhs.y, z - rhs.z);
  }

  public void subtract(Vec3 rhs) {
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }

  public Vec3 times(float rhs) {
    return new Vec3(x * rhs, y * rhs, z * rhs);
  }

  public void mul(float rhs) {
    x *= rhs;
    y *= rhs;
    z *= rhs;
  }

  public void clampToLength(float maxL) {
    float magnitude = sqrt(x * x + y * y + z*z);
    if (magnitude > maxL) {
      x *= maxL / magnitude;
      y *= maxL / magnitude;
      z *= maxL / magnitude;
    }
  }

  public void setToLength(float newL) {
    float magnitude = sqrt(x * x + y * y + z*z);
    x *= newL / magnitude;
    y *= newL / magnitude;
    z *= newL / magnitude;
  }

  public void normalize() {
    float magnitude = sqrt(x * x + y * y + z * z);
    x /= magnitude;
    y /= magnitude;
    z /= magnitude;
  }

  public Vec3 normalized() {
    float magnitude = sqrt(x * x + y * y + z * z);
    return new Vec3(x / magnitude, y / magnitude, z / magnitude);
  }

  public float distanceTo(Vec3 rhs) {
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    float dz = rhs.z - z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
}


float dot(Vec3 a, Vec3 b) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}
