class bubble
{ 
  float h;
  float h2;
  float r;
  float v;
  float x;
  float y;
  float tempR;
  float posX;
  float posY;
  float speed;
 
  float timeSpan = TWO_PI;
  float time = 0;

  void CheckTime()
  {
    time += TWO_PI/(frameRate*5);
  }
  
  
  bubble()
  {
    h = random(0.5, 4.1);
    h2 = random(0.5, 4.1);
    r = random(10, 15);
    v = random(6, 45);
    x = random(0, width);
    y = random(0, height);
    speed = random(1, 3);
    
  }
  
  void update()
  {
    CheckTime();
    posX = x + 5 * sin(h2 * (time));
    posY =  height - (y + v);
    if(posY < -10)
    {
     time = 0;
    
     posY = height + 10; 
     y = 0;
     v = 0;
    }
    tempR =  4*sin(h * time);
    v += speed;
  }
  
  void draw()
  {
    noFill();   
    stroke(255);
    strokeWeight(1);
    ellipse(
     posX, 
     posY, 
     r+tempR, r+tempR
      );
  }
}