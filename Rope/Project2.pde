void setup() {
  size(1000, 1000);
  surface.setTitle("Project 2");
  scene_scale = height / 10.0f;
  frameRate(15);
  for(int i = 0; i < numRopes; i++)
  {
     bases[i] = new Node(new Vec2(1+2*i, 2));
  }
  
  
  for(int i = 0; i < numRopes; i++)
  {
    for(int j = 0; j < numNodes; j ++)
    {
     nodes[i][j] = new Node(new Vec2(1+2*i+(j+1)*link_length * .8, 2.0 + ((j + 1) * link_length * 0.6)));
    }
  }
}

// Node struct
class Node {
  Vec2 pos;
  Vec2 vel;
  Vec2 last_pos;
  boolean hit;
  boolean severed;

  Node(Vec2 pos) {
    this.pos = pos;
    this.vel = new Vec2(0, 0);
    this.last_pos = pos;
    this.hit = false;
    this.severed = false;
  }
}

// Link length
float link_length = .5;

// Nodes
Vec2 base_pos = new Vec2(5, 5);
int numRopes = 5;
Node [] bases = new Node[numRopes];
int numNodes = 10;
Node [][] nodes = new Node[numRopes][numNodes];

Vec2 theObstacle = new Vec2(4,6);
float theRadius = .5;
float nodeRadius = .2;


// Gravity
Vec2 gravity = new Vec2(0, 10);


// Scaling factor for the scene
float scene_scale = width / 10.0f;

// Physics Parameters
int relaxation_steps = 100;
int sub_steps = 10;


class Line {
   float startX;
   float startY;
   float endX;
   float endY;
   
   Line(Node A, Node B)
   {
      float dX = B.pos.x - A.pos.x;
      float dY = B.pos.y - A.pos.y;
      float collisionX;
      float collisionY;
      
      dX = dX / 2.0;
      dY = dY / 2.0;
      
      collisionX = A.pos.x + dX;
      collisionY = A.pos.y + dY;
      
      startX = collisionX - (dY * 1000);
      startY = collisionY + (dX * 1000);
      
      endX = collisionX + (dY * 1000);
      endY = collisionY - (dX * 1000);
   }
   
   Vec2 reflection(float dX, float dY)
   {
     Vec2 incident = new Vec2(dX, dY);
     Vec2 normalizing = new Vec2(startY - endY, endX - startX);
     float theDot = dot(incident, normalizing);
     Vec2 theRef = incident.minus( normalizing.times(2.0 * theDot));
     theRef.setToLength(incident.length());
     
     return theRef;
     
   }
}


void update_physics(float dt) {
  // Semi-implicit Integration
 for(int i = 0; i < numRopes; i++)
  {
    for(int j = 0; j < numNodes; j ++)
    {
      nodes[i][j].hit = false;
    }
  }
 
  for(int i = 0; i < numRopes; i++)
  {
    for(int j = 0; j < numNodes; j ++)
    {
      nodes[i][j].last_pos = nodes[i][j].pos;
      nodes[i][j].vel = nodes[i][j].vel.plus(gravity.times(dt));
      nodes[i][j].pos = nodes[i][j].pos.plus(nodes[i][j].vel.times(dt));
      
      if(nodes[i][j].pos.distanceTo(theObstacle) < theRadius + nodeRadius)
      {
        Vec2 normal = nodes[i][j].pos.minus(theObstacle);
        normal.normalize();
        nodes[i][j].pos = theObstacle.plus(normal.times((theRadius + nodeRadius) * 1.01));
        nodes[i][j].vel = new Vec2(0,0);
        nodes[i][j].last_pos = nodes[i][j].pos;
        //nodes[i][j].hit = true;
      }
      if(nodes[i][j].hit == false)
      {
        for(int k = 0; k < numRopes; k++)
        {
          for(int l = 0; l < numNodes; l++)
          {
              if(k == i ) //&& l == j
              {
                 continue; 
              }
              if(nodes[i][j].pos.distanceTo(nodes[k][l].pos) < nodeRadius * 2.0)
              {
                Vec2 normal = nodes[i][j].pos.minus(nodes[k][l].pos);
                Vec2 normal2 = nodes[k][l].pos.minus(nodes[i][j].pos);
                normal.normalize();
                normal2.normalize();
                Line perpLine = new Line(nodes[i][j], nodes[k][l]); 
                Line perpLine2 = new Line(nodes[k][l], nodes[i][j]);
                Vec2 reflect = perpLine.reflection(nodes[i][j].vel.x, nodes[i][j].vel.y);
                Vec2 reflect2 = perpLine2.reflection(nodes[k][l].vel.x, nodes[k][l].vel.y);
                
                Vec2 tempPos = new Vec2(nodes[i][j].pos.x, nodes[i][j].pos.y);
                nodes[i][j].pos = nodes[k][l].pos.plus(normal.times((2.0 * nodeRadius) * 1.01));
                nodes[i][j].vel = reflect.times(0.9);
                nodes[i][j].last_pos = nodes[i][j].pos;
                nodes[i][j].hit = true;
                
                nodes[k][l].pos = tempPos.plus(normal2.times((2.0 * nodeRadius) * 1.01));
                nodes[k][l].vel = reflect2.times(0.9);
                nodes[k][l].last_pos = nodes[k][l].pos;
                nodes[k][l].hit = true;
              }
              
              
          }
        }
      }
      
    }
  }



  // Constrain the distance between nodes to the link length
  for (int i = 0; i < relaxation_steps; i++) {
    

    for(int j = 0; j < numRopes; j++)
    {
      Vec2 delta;
      
      for(int k = 0; k < numNodes; k++)
      {
        if(k == 0)
        {
          delta = nodes[j][0].pos.minus(bases[j].pos);
        }
        else
        {
          delta = nodes[j][k].pos.minus(nodes[j][k-1].pos);
        }
        float delta_len = delta.length();
        float correction = delta_len - link_length;
        if(correction > .01)
        {
            nodes[j][k].severed = true; 
        }
        if(nodes[j][k].severed == false)
        {
          Vec2 delta_normalized = delta.normalized();
          nodes[j][k].pos = nodes[j][k].pos.minus(delta_normalized.times(correction / 2));
          
          if(k == 0)
          {
            bases[j].pos = bases[j].pos.plus(delta_normalized.times(correction / 2));
          }
          else
          { 
            nodes[j][k-1].pos = nodes[j][k-1].pos.plus(delta_normalized.times(correction / 2));
          }
        }
      }
       bases[j].pos = new Vec2(1+2*j, 2); // Fix the base node in place
    }
      
  }

  // Update the velocities (PBD)
 
 for(int i = 0; i < numRopes; i++)
 {
 
  bases[i].vel = bases[i].pos.minus(bases[i].last_pos).times(1 / dt);
  
  for(int j = 0; j < numNodes; j++)
  {
    nodes[i][j].vel = nodes[i][j].pos.minus(nodes[i][j].last_pos).times(1 / dt);
  }
 }
  
}

boolean paused = false;

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
}


float time = 0;
void draw() {
  float dt = 1.0 / 20; //Dynamic dt: 1/frameRate;
  
  if (!paused) {
    for (int i = 0; i < sub_steps; i++) {
      time += dt / sub_steps;
      update_physics(dt / sub_steps);
    }
  }

  background(255);
  stroke(0);
  strokeWeight(2);

  // Draw Nodes (green with black outline)
  fill(0, 255, 0);
  stroke(0);
  strokeWeight(0.01 * scene_scale);
  ellipse(theObstacle.x * scene_scale, theObstacle.y * scene_scale, theRadius * scene_scale * 2, theRadius * scene_scale * 2);
  for(int i = 0; i < numRopes; i++)
  {
    // Draw Links (black)
    stroke(0);
    strokeWeight(0.02 * scene_scale);
    line(bases[i].pos.x * scene_scale, bases[i].pos.y * scene_scale, nodes[i][0].pos.x * scene_scale, nodes[i][0].pos.y * scene_scale);
    
    for(int j = 1; j < numNodes; j++)
    {
      if(nodes[i][j].severed == false)
      {
        line(nodes[i][j-1].pos.x * scene_scale, nodes[i][j-1].pos.y * scene_scale, nodes[i][j].pos.x * scene_scale, nodes[i][j].pos.y * scene_scale);
      }
    }
    
    fill(0, 255, 0);
    ellipse(bases[i].pos.x * scene_scale, bases[i].pos.y * scene_scale, nodeRadius * 2.0 * scene_scale, nodeRadius * 2.0 * scene_scale);
    for(int j = 0; j < numNodes; j++)
    {
      if(nodes[i][j].hit)
      {
         fill(255, 0, 0); 
      }
      else
      {
         fill(0, 255, 0); 
      }
      ellipse(nodes[i][j].pos.x * scene_scale, nodes[i][j].pos.y * scene_scale, nodeRadius * 2.0 * scene_scale, nodeRadius * 2.0 * scene_scale);
    }
  
  }
  

}



//---------------
//Vec 2 Library
//---------------

public class Vec2 {
  public float x, y;

  public Vec2(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public String toString() {
    return "(" + x + "," + y + ")";
  }

  public float length() {
    return sqrt(x * x + y * y);
  }

  public float lengthSqr() {
    return x * x + y * y;
  }

  public Vec2 plus(Vec2 rhs) {
    return new Vec2(x + rhs.x, y + rhs.y);
  }

  public void add(Vec2 rhs) {
    x += rhs.x;
    y += rhs.y;
  }

  public Vec2 minus(Vec2 rhs) {
    return new Vec2(x - rhs.x, y - rhs.y);
  }

  public void subtract(Vec2 rhs) {
    x -= rhs.x;
    y -= rhs.y;
  }

  public Vec2 times(float rhs) {
    return new Vec2(x * rhs, y * rhs);
  }

  public void mul(float rhs) {
    x *= rhs;
    y *= rhs;
  }

  public void clampToLength(float maxL) {
    float magnitude = sqrt(x * x + y * y);
    if (magnitude > maxL) {
      x *= maxL / magnitude;
      y *= maxL / magnitude;
    }
  }

  public void setToLength(float newL) {
    float magnitude = sqrt(x * x + y * y);
    x *= newL / magnitude;
    y *= newL / magnitude;
  }

  public void normalize() {
    float magnitude = sqrt(x * x + y * y);
    x /= magnitude;
    y /= magnitude;
  }

  public Vec2 normalized() {
    float magnitude = sqrt(x * x + y * y);
    return new Vec2(x / magnitude, y / magnitude);
  }

  public float distanceTo(Vec2 rhs) {
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    return sqrt(dx * dx + dy * dy);
  }
}

Vec2 interpolate(Vec2 a, Vec2 b, float t) {
  return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t) {
  return a + ((b - a) * t);
}

float dot(Vec2 a, Vec2 b) {
  return a.x * b.x + a.y * b.y;
}

// 2D cross product is a funny concept
// ...its the 3D cross product but with z = 0
// ... (only the resulting z component is not zero so we just store it as a scalar)
float cross(Vec2 a, Vec2 b) {
  return a.x * b.y - a.y * b.x;
}

Vec2 projAB(Vec2 a, Vec2 b) {
  return b.times(a.x * b.x + a.y * b.y);
}

Vec2 perpendicular(Vec2 a) {
  return new Vec2(-a.y, a.x);
}
