//Ruth Mesfin - cloth sim

//table csv output stuff
Table table;

// Link length
float link_length = 0.5;

// Nodes
//float x_pos = 5.0;
//float y_pos = 5.0;

Node[][] everynode = new Node[10][10]; 



//Vec2 nth_pin;
// Gravity
Vec3 gravity = new Vec3(0, 10, 0);

// Scaling factor for the scene
float scene_scale = width / 10.0f;

// Physics Parameters !!
int relaxation_steps = 1;
int sub_steps = 10;

boolean paused = false;
float x_pos = 5.0;
float y_pos = 5.0;
float z_pos = 5.0;

PImage img;
PShape globe;



//float SpherePos_x = 9.5;
//float SpherePos_y = 5;
//float SpherePos_z = 5;
//Vec3 SpherePos = new Vec3(SpherePos_x, SpherePos_y, SpherePos_z);
//Vec3 SpherePos_wscale = new Vec3(SpherePos_x* scene_scale, SpherePos_y* scene_scale, SpherePos_z* scene_scale);
//// -----------------------------------------------------------------

float eyeX, eyeY, eyeZ;

float ang = 0;

float d = -52.094467;

void keyPressed() {

  if (key == ' ') {
      paused = !paused;
    }
   if (key == 'd') {
       ang += 5;
       eyeZ = d*cos(radians(ang));

    }
    
  if (key == CODED) {
    if (keyCode == UP) {
      
      ang += 5;
      
      //eyeY = (height/2)-d*(sin(radians(ang)));
      eyeY += 20;
      //eyeZ = d*cos(radians(ang));
    
    }
    
    if (keyCode == DOWN) {
    
      //ang -= 5;
      eyeY -= 20;
      //eyeY = (height/2)-d*(sin(radians(ang)));
      
      //eyeZ = d*cos(radians(ang));
    
    }
    if (keyCode == RIGHT) {
    
      //ang -= 5;
      //eyeY -= 20;
      eyeX += 10;
      
      //eyeZ = d*cos(radians(ang));
    
    }
    if (keyCode == LEFT) {
    
      //ang -= 5;
      //eyeY -= 20;
      eyeX -= 10;
      
      //eyeZ = d*cos(radians(ang));
    
    }
    //println(eyeX, eyeY, eyeZ);
    
    
    
  }
    
  
  
  //println(eyeX+" / "+eyeY+" / "+eyeZ);
}

//translate(250, 400);

void setup() {
  size(600, 600, P3D);
  surface.setTitle("RUTHHW1 :)");
  img = loadImage("glob.png");
  globe = createShape(SPHERE, 50);
  globe.setTexture(img);
  scene_scale = width / 10.0f;
  //table = new Table();
  //table.addColumn("time");
  //table.addColumn("energy");
  
  //all node addition
  for(int i = 0; i < everynode.length; i++) {
    for(int j = 0; j < everynode.length; j++) {
      everynode[i][j] = new Node(new Vec3(x_pos + link_length * i, y_pos, z_pos + link_length * j));
      //println(z_pos + link_length * j);
    }
  }
  
  eyeX = 280;

  eyeY = 280;
  
  eyeZ = d;

}

float SpherePos_x = 7;
float SpherePos_y = 8;
float SpherePos_z = 4;
Vec3 SpherePos = new Vec3(SpherePos_x, SpherePos_y, SpherePos_z);
//Vec3 SpherePos_wscale = new Vec3(SpherePos_x* scene_scale, SpherePos_y* scene_scale, SpherePos_z* scene_scale);
// -----------------------------------------------------------------

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
  //Simulate nodes position & velocity
  for(int n = 0; n < everynode.length; n++) {
    //println(i);
      for(int m = 0; m < everynode.length; m++) {
        everynode[n][m].last_pos = everynode[n][m].pos;
        everynode[n][m].vel = everynode[n][m].vel.plus(gravity.times(dt));
        everynode[n][m].pos = everynode[n][m].pos.plus(everynode[n][m].vel.times(dt));
        
      }
    }
  
  // Constrain the distance between nodes to the link length
  for (int i = 0; i < relaxation_steps; i++) {
    //new double array addition
    for(int j = 1; j < everynode.length; j++) { //rows
    //println(i);
      for(int k = 0; k < everynode.length; k++) {
        Vec3 delta = everynode[j][k].pos.minus(everynode[j-1][k].pos);
        float delta_len = delta.length();
        float correction = delta_len - link_length;
        Vec3 delta_normalized = delta.normalized();
        everynode[j][k].pos = everynode[j][k].pos.minus(delta_normalized.times(correction / 2));
        everynode[j-1][k].pos = everynode[j-1][k].pos.plus(delta_normalized.times(correction / 2));
        
      }
    }
    
    for(int j = 0; j < everynode.length; j++) { //cols
    //println(i);
      for(int k = 1; k < everynode.length; k++) {
        Vec3 delta = everynode[j][k].pos.minus(everynode[j][k-1].pos);
        float delta_len = delta.length();
        float correction = delta_len - link_length;
        Vec3 delta_normalized = delta.normalized();
        everynode[j][k].pos = everynode[j][k].pos.minus(delta_normalized.times(correction / 2));
        everynode[j][k-1].pos = everynode[j][k-1].pos.plus(delta_normalized.times(correction / 2));
        
      }
    }
    
   
    everynode[0][0].pos = new Vec3(5, 5, 5);
    everynode[9][0].pos = everynode[9][0].last_pos;
    //println(everynode[0][0].pos);
    //base.pos = base_pos;
    
  }
  
  for(int j = 0; j < everynode.length; j++) { //rows
    //println(i);
      for(int k = 0; k < everynode.length; k++) {
        //.times(0.9)
        //!!! Sphere collision here!!!
        
        Vec3 curr_scaled = new Vec3(everynode[j][k].pos.x * scene_scale, everynode[j][k].pos.y * scene_scale,  everynode[j][k].pos.z * scene_scale);
        Vec3 sph_scaled = new Vec3(SpherePos.x * scene_scale, SpherePos.y * scene_scale,  SpherePos.z * scene_scale);
        float d = sph_scaled.distanceTo(curr_scaled);
        
        if(d < 50+.09){
          
          Vec3 n = (curr_scaled.minus(sph_scaled)).normalized();
          //n.normalize();
          //Vec3 bounce = n.times(dot(everynode[j][k].vel, n));
          
          
          Vec3 bn = sph_scaled.plus(n.times(52).times(1));
          //scale down and add to pos?
          Vec3 sbn = new Vec3(bn.x/scene_scale, bn.y/scene_scale,bn.z/scene_scale);
          everynode[j][k].pos = sbn;
          
          //everynode[j][k].vel.minus(bounce.times(1.5)); 
          everynode[j][k].last_pos = everynode[j][k].pos;

        }
        everynode[j][k].vel = everynode[j][k].pos.minus(everynode[j][k].last_pos).times(1 / dt);
        
      }
    }
  
}
//SpherePos
//translate(250, 400);
//sphere(50);

  //from lecture slides:
  //for i in range(nx):
  //  for j in range(ny):
  //    d = SpherePos.distTo(p[i,j])
  //    if d < sphereR+.09:
  //      n = -1*(SpherePos - p[i,j]) #sphere normal
  //      n.normalize(); n = [n[0],n[1],n[2]]
  //      bounce = np.multiply(np.dot(v[i,j],n),n)
  //      v[i,j] -= 1.5*bounce
  //      p[i,j] += np.multiply(.1 + sphereR - d, n)



float zoom = 1;
final static float inc = .05;
float time = 0;
void draw() {
  // background in the draw loop to make it animate rather than draw over itself

  background(0);
  //if (mousePressed)
  //  if      (mouseButton == LEFT)   zoom += inc;
  //  else if (mouseButton == RIGHT)  zoom -= inc;

  //translate(width>>1, height>>1);
  //scale(zoom);
  //lights();
  
  //stroke(255);
  
  // CAMERA:
  
  camera(eyeX, eyeY, eyeZ, height/2, width/2, 0, 0, 1, 0);
  
  //pushMatrix();
  
  //translate(width/2, height/2, 0);
  
  //box(100);
  
  //popMatrix();
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
  

  
  for(int i = 0; i < everynode.length; i++) {
    for(int j = 0; j < everynode.length; j++) {
      //ellipse(everynode[i][j].pos.x * scene_scale, everynode[i][j].pos.y * scene_scale, 0.3 * scene_scale, 0.3 * scene_scale);
      pushMatrix();
      translate(everynode[i][j].pos.x * scene_scale, everynode[i][j].pos.y * scene_scale,  everynode[i][j].pos.z * scene_scale);
      
      fill(0, 255, 0);
      sphere(0.5); 
      popMatrix();
      
      //print(everynode[9][0].pos);
      //if (i==9 && j==0){
      //  println("WACK",everynode[i][j].pos.x * scene_scale, everynode[i][j].pos.x, scene_scale);
      //}
  }
  }
  
  // Draw Links (black)
  stroke(0);
  strokeWeight(0.02 * scene_scale);
  for(int i = 0; i < everynode.length; i++) {
    //println(i);
    for(int j = 0; j < everynode.length; j++) {
      //println(i, j);
      if(i+1 < everynode.length){
       line(everynode[i][j].pos.x * scene_scale, everynode[i][j].pos.y * scene_scale,everynode[i][j].pos.z * scene_scale, everynode[i+1][j].pos.x * scene_scale, everynode[i+1][j].pos.y * scene_scale, everynode[i+1][j].pos.z * scene_scale);
       
      }
      if(j+1 < everynode.length){
       line(everynode[i][j].pos.x * scene_scale, everynode[i][j].pos.y * scene_scale,everynode[i][j].pos.z * scene_scale, everynode[i][j+1].pos.x * scene_scale, everynode[i][j+1].pos.y * scene_scale,  everynode[i][j+1].pos.z * scene_scale);
       //println(everynode[i][j].pos.x, everynode[i][j].pos.y, everynode[i][j].pos.z);
      }
    }
  }

  //sphere
  noStroke();
  //textureMode(NORMAL); 
  beginShape();
  //texture(img);
  pushMatrix();
    //use scene scale
     //* scene_scale,
    translate(SpherePos_x* scene_scale, SpherePos_y* scene_scale, SpherePos_z* scene_scale);
    //fill(255, 0, 0);
    shape(globe);
  popMatrix();
  
  endShape();

  

}


//---------------
//Vec 2 Library
//---------------

//Vector Library
//CSCI 5611 Vector 2 Library [Example]
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

//Vec3 interpolate(Vec3 a, Vec2 b, float t) {
//  return a.plus((b.minus(a)).times(t));
//}

//float interpolate(float a, float b, float t) {
//  return a + ((b - a) * t);
//}

float dot(Vec3 a, Vec3 b) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}

// 2D cross product is a funny concept
// ...its the 3D cross product but with z = 0
// ... (only the resulting z component is not zero so we just store it as a scalar)
//float cross(Vec2 a, Vec2 b) {
//  return a.x * b.y - a.y * b.x;
//}

//Vec2 projAB(Vec2 a, Vec2 b) {
//  return b.times(a.x * b.x + a.y * b.y);
//}

//Vec2 perpendicular(Vec2 a) {
//  return new Vec2(-a.y, a.x);
//}
