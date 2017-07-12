
enum State
{
  BirthState, 
    Moving, 
    Dead, 
    None
}

class Creature extends MotionInfo
{
  int typeId;                  // unique creature type
  color headColor;             // creatures head color
  float headRadius;            // creature size
  float biteRadius;            // bite radius
  float visibilityRadius;      // start hunting radius 
  float moveDirection;         // move direction [radiant]
  float swingSize;             // swing amplitude
  float swingFrequency;        // swing frequency
  int moveTime, waitTime;      // move time [frames]      
  int currentTime;             // current time [frames] 
  boolean stopped;             // current time state
  int age;                     // current age     
  int action;                  // move, flee, hunt, bite 
  SteeringInfo steering;       
  boolean notTentacle;
  PVector destination;
  State state = State.Moving;
  float delta = 0;
  float maxSize;
  int alphaValue = 255;
  protected point spawnInfo;
  PVector startPosition = new PVector();
  float f, k;
  boolean isAlive;
  ArrayList<Tentacle> tentacles;
  int nTentacles;
  int partCount;

  PVector loc;
  PVector vel;
  PVector acc;

  float aAcc;
  float aVel;
  float angle;
  // float movdirection;
  float mass;
  float diameter;
  float radius;
  PVector dir;
  float speed;
  float oAmp;
  float oTimer;
  float oTimerRate;
  float deepseafishAlpha = 100; 

  float headSize;
  float specularSizeX;
  float specularSizeY;




  Aquarium aquarium;

  //----------------------------------------------------------
  // build a new creature
  //----------------------------------------------------------
  Creature (int typeId         // unique creature type id 
    , color headColor          // color of creatures head
    , PVector startPosition    // current start position 
    , PVector startDirection   // current move direction 
    , float maxMotionSpeed     // 1.0 .. 6.0
    , float size               // head diameter
    , int tentacleCount        // number of tentacles
    , int tentacleParts        // number of tentacle parts 
    , float compactness        // 0.0 .. 1.0 
    , int movingTime           // time of moving
    , int waitingTime          // time of waiting
    , float swingSize          // swing amplitude 
    , float swingFrequency     // swing frequency 
    , point spawnInfo          // spawn area info 
    , boolean notTentacle          // fixed object like starFish -> true
    , Aquarium aquarium  
    )         
  { 

    // create MotionInfo
    super ( random(2*PI)       // startDirection 
      , maxMotionSpeed         // maxMotionSpeed
      , 0.3                    // maxMotionAcceleration
      , radians(4.0)           // maxAngleSpeed   
      , radians(1.0)           // maxAngleAcceleration
      , startPosition);        // current start position
    this.speed = maxMotionSpeed;
    this.startPosition = startPosition;
    this.isAlive = true;
    this.typeId = typeId;  
    this.headColor = headColor;
    this.headRadius = size/2;
    this.biteRadius = size * 2.0;
    this.notTentacle = notTentacle;
    this.visibilityRadius = size * 10.0;
    this.moveDirection = random(TWO_PI);
    this.steering = new SteeringInfo();
    this.moveTime = constrain (movingTime, 10, 200);
    this.waitTime = constrain (waitingTime, 0, 200);
    this.currentTime = 0;
    this.stopped = false;
    this.swingSize = swingSize;
    this.swingFrequency = swingFrequency;
    this.nTentacles = constrain (tentacleCount, 1, 20);
    this.partCount = constrain (tentacleParts, 2, 100);
    this.action = ac_move;
    this.age = 0;
    this.aquarium = aquarium;
    specularSizeX = random(-3, 3);
    specularSizeY = random(-3, 3);

    delta = 0;
    destination = new PVector();
    this.spawnInfo = spawnInfo;
    maxSize = random(0.2, PI/2); 
    SetDestination();

    tentacles = new ArrayList<Tentacle>();
    for (int i = 0; i < nTentacles; i++) 
    {
      float direction = moveDirection; // + (0.5 * i * angle) - angle + halfAngle;
      PVector tPos = startPosition.get();
      tPos.sub (getVector2d (headRadius, direction));

      // create a tentacle
      Tentacle tentacle = new Tentacle(typeId, tPos, direction, partCount, size*0.9, compactness, headColor);
      // add tentacle to tentacle list
      tentacles.add(tentacle);
    }

    loc = new PVector();
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    aAcc = 0;
    aVel = 0;
    angle = 0;
    mass = 1.5;
    diameter = mass * 10*2;
    radius = diameter / 2;
    oAmp = radius * 1.5;
    oTimer = 0;
    oTimerRate = 0.01;

    loc.x = startPosition.x;
    loc.y = startPosition.y;
  }


  void draw() 
  {
    if (state == State.Moving)
    {
      if (!notTentacle)
      {
        for (int ti = 0; ti < nTentacles; ti++)
          tentacles.get(ti).draw();
        fill (headColor, alphaValue);

        if (typeId == octopusId)
        {
          octopusDraw();
        } else if (typeId == jellyfishId)
        {
          alphaValue = 150;
          jellyfishDraw();
        } else 
        {
          creatureDraw();
        }
      } else if (notTentacle)
      {
        switch(typeId)
        {
        case starfishId:
          starfishDraw();
          break;
        case deepseafishId:
          deepseafishDraw();
          break;
        default:
          break;
        }
      }
    } else if (state == State.BirthState)
    {
    } else if (state == State.Dead)
    {
      if (!notTentacle)
      {
        for (int ti = 0; ti < nTentacles; ti++)
          tentacles.get(ti).draw();

        fill (headColor, alphaValue);
        if (typeId == octopusId)
        {
        } else if (typeId == jellyfishId)
        {
          alphaValue = 150;
          jellyfishDraw();
        } else
        {
          creatureDraw();
        }
        DeadState();
      } else if (notTentacle)
      {
        switch(typeId)
        {
        case starfishId:
          fixedDead();
          break;
        case deepseafishId:
          deepseafishDead();     
          break;
        default:      
          break;
        }
      }
    }
  }

  void octopusDraw()
  {
    float t = timer.time;
    float specularSizeValue =  0.1 + abs(sin(t/2));
    float sizeValue = 2 + 0.5*abs(sin(t));

    ellipse (position.x, position.y, headRadius*sizeValue, headRadius*sizeValue); 
    fill(200, 30);
    ellipse (position.x +3, position.y, headRadius*sizeValue, headRadius*sizeValue);   
    noStroke();
    fill(180, 80);
    ellipse (position.x + specularSizeX, position.y + specularSizeY, headRadius * 1 * specularSizeValue, headRadius * 0.8 * specularSizeValue);
    fill(200, 80);
    ellipse (position.x + specularSizeX, position.y + specularSizeY, headRadius * 0.8 * specularSizeValue, headRadius * 0.5 * specularSizeValue);
    fill(255, 80);
    ellipse (position.x + specularSizeX, position.y + specularSizeY, headRadius*0.3 * specularSizeValue, headRadius*0.5 * specularSizeValue);
  }

  void creatureDraw()
  {
    ellipse (position.x, position.y, headRadius*2, headRadius*2);
  }

  void jellyfishDraw()
  {
    
    fill (headColor, alphaValue);       
    pushMatrix();
    translate(position.x, position.y);
    rotate(direction + PI + QUARTER_PI*2);  
    arc(0, 0, headRadius*10, headRadius*10, 0-0.5, PI+0.5, CHORD);   
    fill (headColor, alphaValue + 50); 
    ellipse(0, 0, headRadius*5, headRadius*5);        
    popMatrix();
  }


  void deepseafishDraw()
  {
    pushMatrix();
    translate(position.x, position.y);           
    rotate(direction);
    noStroke();

    // tail
    stroke(255, 100, 100, deepseafishAlpha);
    strokeWeight(int(radius/2));
    fill(255, 100, 100, deepseafishAlpha);
    float x = oAmp * sin(timer.time)/2;

    line(radius, 0, x-diameter, 0);
    ellipse(-radius, 0, int(radius/2)*1.5, int(radius/2)*1.5);
    ellipse(x-diameter, 0, int(radius/6), int(radius/6));


    stroke(255, 100, 100, deepseafishAlpha);
    strokeWeight(int(radius/2));

    // wings
    //ellipse(radius*0.5, 0, diameter*1.6,diameter*2.2);
    //fill(120,220,180,90);
    float tempSize = sin(timer.time /2 );
    fill(120, deepseafishAlpha);
    ellipse(radius*0.6, 0, diameter, diameter*2.5*tempSize);

    ellipse(radius*0.3, 0, diameter, diameter*1.6);
    ellipse(radius*0.1, 0, diameter, diameter*1.2);


    // bodies
    //fill(220,150,100,120);
    //fill(120,100);
    fill(120, 220, 95, deepseafishAlpha);
    ellipseMode(CENTER);
    ellipse(radius, 0, diameter*1.5, diameter*1.2);
    //fill(120,220,180,90);
    ellipse(radius*0.6, 0, diameter*1.8, diameter*0.8);
    ellipse(radius*0.1, 0, diameter*2.2, diameter*0.5);


    // eyes
    //fill(100,100,255,150);
    fill(20, deepseafishAlpha);
    ellipse(radius*1.6, radius/2, int(radius/2)*2, int(radius/4)*2);
    ellipse(radius*1.6, -radius/2, int(radius/2)*2, int(radius/4)*2);
    fill(255, 50, 0, deepseafishAlpha);
    ellipse(radius*1.5, radius/2, int(radius/2), int(radius/4));
    ellipse(radius*1.5, -radius/2, int(radius/2), int(radius/4));

    popMatrix();
    strokeWeight(1);
  }

  void starfishDraw()
  {   
    f=0.5;
    k=k+1;
    for (int i = 0; i < 360; i=i+75) {
      for (int n=1; n<16; n=n+2) {
        stroke(140, 160, 160, alphaValue);     
        fill(210-6*f, 25+4*f, 0, alphaValue);  
        ellipse(startPosition.x+(n*1.1)*cos(radians(i-f*(1.5*n)*sin(f*k/5)/3)), startPosition.y+(n*1.1)*sin(radians(i-f*(1.5*n)*cos(f*k/5)/3)), 8-n/2, 8-n/2);
      }
    }
  }

  void deepseafishDead()
  {

    if (deepseafishAlpha>20)
    {     
      deepseafishDraw();
      deepseafishAlpha -= 20/frameRate;
    } else
    {
     
      deepseafishAlpha = 0;
      state = State.None;
      aquarium.monsterNumber--;
      aquarium.creatures.remove(this);
      //  if (aquarium.monsterNumber == 0)
      if (aquarium.creatures.size() == 0)
      {      
        println("removewithdeep");
        aquariums.remove(aquarium);
      }
    }
  }

  void fixedDead()
  {
    if (alphaValue>10)
    {
      starfishDraw();
      alphaValue -= 40/frameRate;
    } else
    {
      
      alphaValue = 0;
      state = State.None;
      aquarium.monsterNumber--;


      aquarium.creatures.remove(this);
      //if (aquarium.monsterNumber == 0)
      if (aquarium.creatures.size() == 0)
      {
        println("removewithfixed");
        aquariums.remove(aquarium);
      }
    }
  }


  void DeadState()
  {
    if (delta < HALF_PI)
    {
      DeadScaleDown(delta);
      delta += (PI/20)/frameRate;
      alphaValue -= 20/frameRate;
    } else
    {      
     
      state = State.None;
      headRadius = 0;
      aquarium.monsterNumber--;

      aquarium.creatures.remove(this);
      //   if (aquarium.monsterNumber == 0)
      if (aquarium.creatures.size() == 0)
      {
        println("removeAquawithdeadState");
        aquariums.remove(aquarium);
      }
    }
  }





  void DeadScaleDown(float delta)
  {
    headRadius *= cos(delta);
    for (int ti = 0; ti < nTentacles; ti++)
    {
      tentacles.get(ti).alphaValue = 255 - int(delta * 150);
      for (int j = 0; j < tentacles.get(ti).parts.size(); j++ )
      {
        tentacles.get(ti).parts.get(j).size *= cos(delta);
      }
    }
  }



  void update() 
  {
    if (!notTentacle)
    {

      if (dist(destination.x, destination.y, position.x, position.y) < 10)
      {
        SetDestination();
      }
      age++;

      moveDirection = atan2(destination.y-position.y, destination.x-position.x); 

      // moveDirection += random(-1, 1) * radians(100);  // -50° .. 50°
      float add = swingSize * sin(frameCount * swingFrequency);

      if (!notTentacle)
        moveDirection +=  add;  // -50° .. 50°


      //    steering.linear.div(currentTime/50 > 0 ? currentTime/50 : 1);
      direction = moveDirection;
      //    steering = wander(this, 100.0, 80.0, radians(5));  // 5° .. +5°
      //    super.update(steering);
      PVector dir = getOrientationAsVector();
      super.update(dir, rotation);

      currentTime++;

      // set main tentacle directions  
      float partAngle = TWO_PI / nTentacles; 
      float halfAngle = (nTentacles % 2 == 0 ? partAngle*0.5 : 0.0);
      for (int ni = 0; ni < nTentacles; ni++) 
      {
        Tentacle t = tentacles.get(ni);
        float angle = moveDirection + ni * partAngle + halfAngle;   
        this.angle = angle;
        t.position.x = position.x + (cos(angle) * headRadius);
        t.position.y = position.y + (sin(angle) * headRadius);
        t.direction = atan2((t.position.y - position.y), (t.position.x - position.x));
        t.update();
      }
      action = ac_move;
    } else if (typeId == deepseafishId)    
    {    
      calc();
    }
  }

  void calc() {

    float theta = (atan2(destination.y - position.y, destination.x - position.x)+ TWO_PI) % TWO_PI;
    float distance = dist(destination.x, destination.y, position.x, position.y);

    if (distance < 3)
    { 
      position.x = destination.x;
      position.y = destination.y;
      SetDestination();
    }


    float z = (theta - direction + 2 * TWO_PI) % TWO_PI;
    float dt = 0;


    if (z > PI) {
      dt = z - TWO_PI;
    } else {
      dt = z;
    }


    if (abs(dt) > 0.1) {

      direction = (direction + 0.1 * dt + 2 * TWO_PI) % TWO_PI;
    }


    float v = speed * 0.1 + 0.2 * cos(5 * timer.time); 
    float dir = theta+ 0.7 * cos(5 * timer.time);

    position.x += v* cos(dir);
    position.y += v* sin(dir);
  }



  void SetDestination()
  { 

    specularSizeX = random(-3, 3);
    specularSizeY = random(-3, 3);
    //float angle = random(TWO_PI);
    int tempX = int(spawnInfo.x + random(-spawnInfo.radiusX, spawnInfo.radiusX));
    int tempY = int(spawnInfo.y + random(-spawnInfo.radiusY, spawnInfo.radiusY));


    if (spawnInfo.contour.containsPoint(tempX, tempY))
    {
      disturb(int(position.x), int(position.y));
      destination.x = tempX;
      destination.y = tempY;
    } else
    {
      destination.x = spawnInfo.x;
      destination.y = spawnInfo.y;
    }
  }
}  

PVector getVector2d (float radius, float direction)
{
  return new PVector (cos(direction) * radius
    , sin(direction) * radius);
}