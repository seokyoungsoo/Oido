
enum State //유한 상태 기계 FSM구조를 위한 변수
{
  BirthState, 
    Moving, 
    Dead, 
    None
}

class Creature extends MotionInfo //생물체 클래스 
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
  
  boolean notTentacle; //작은 물고기 중간 물고기 물뱀 문어 해파리는 tentacle구조, 심해어 불가사리는 notTentacle
  PVector destination; //setdestination함수로 destination 정보를 갱신해주면 그쯕으로 움직인다
  State state = State.BirthState; //제일 처음 상태는 BirthState

  float delta = 0;
  int alphaValue = 255;

  protected point spawnInfo;
  PVector startPosition = new PVector();
  boolean isAlive;
  ArrayList<Tentacle> tentacles;
  int nTentacles;
  int partCount;

 ///심해어 움직임을 위한 변수
  PVector loc;
  PVector vel;
  PVector acc;
  float aAcc;
  float aVel;
  float angle;
  float mass;
  float diameter;
  float radius;
  PVector dir;
  float speed;
  float oAmp;
  float oTimer;
  float oTimerRate;
  float deepseafishAlpha = 150; 
  ///심해어 움직임을 위한 변수
  
  float headSize;
  
  float specularSizeX; //문어 머리 위의 specular를 위한 변수
  float specularSizeY;
  
  float tempo =random(5, 8); //심해어 꼬리 흔드는 주기
  float f, k; 
  PVector preposition = new PVector();
  
  float birthScaleDelta = 0; //birthstate 상태를 위한 변수
  float deadScaleDelta = 0;
  float speedValue;

  Aquarium aquarium; //자신이 속한 aquarium을 담고 있는 변수

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
    this.biteRadius = size * 2.0 * 0.4;
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
    diameter = mass * 5*2;
    radius = diameter / 2;
    oAmp = radius * 1.5;
    oTimer = 0;
    oTimerRate = 0.01;


    loc.x = startPosition.x;
    loc.y = startPosition.y;
    preposition.x = startPosition.x;
    preposition.y = startPosition.y;

    SetDestination();
  }


  void draw() //각 상태에 맞게 생물체들을 그려준다
  {  
    if (state == State.Moving)
    {
      MovingDraw();
    } else if (state == State.BirthState)
    {
      BrithDraw();
    } else if (state == State.Dead)
    {
      DeadDraw();
    }
  }
  
  void MovingDraw()
  {
    if (!notTentacle)
    {
      for (int ti = 0; ti < nTentacles; ti++)
        tentacles.get(ti).draw(); //tentacle구조라면 자신의 tentacle을 그려준다
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
  }

  void DeadDraw()
  {
    if (deadScaleDelta > 0) //birthScaleDelta값에서 값을 빼주면서 0보다 작아지면 생물체를 사라지게 한다
    {
      deadScaleDelta -= (PI/2)/(frameRate*8);
      
      pushMatrix();
      translate(position.x, position.y);      
      scale(sin(deadScaleDelta)); //sin함수로 크기를 조절한다 deadScaleDelta가 점점 작아지니깐 크기 역시 줄어든다
      translate(-position.x, -position.y);  

      if (255*sin(deadScaleDelta) < 150) //물 안으로 들어가는 효과를 위해 투명도 역시 빼준다
        alphaValue = 100;
      else
        alphaValue = int(255*sin(deadScaleDelta));


      if (!notTentacle)
      {
        for (int ti = 0; ti < nTentacles; ti++)
        { 
          tentacles.get(ti).draw();
          tentacles.get(ti).alphaValue = alphaValue;
        }
        fill (headColor, alphaValue);

        if (typeId == octopusId)
        {
          octopusDraw();
        } else if (typeId == jellyfishId)
        {
          if (alphaValue > 150)
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

          if (150*sin(deadScaleDelta) < 100)
            deepseafishAlpha = 50; //20 + 130*sin(birthScaleDelta);
          else
            deepseafishAlpha = 150*sin(deadScaleDelta);
          deepseafishDraw();
          break;
        default:
          break;
        }
      }
      popMatrix();
    } else
    {
      disturb(int(position.x), int(position.y)); //사라지면서 물이 한 번 일렁이게 만든다 -> 물결을 호출하는 함수다
      state = State.None; //state를 None으로 바꿔준다 -> NullCheck는 이런 생물체를 찾아서 지워준다
      aquarium.monsterNumber--; 
      //aquarium.creatures.remove(this);
      if (aquarium.monsterNumber == 0) //자신이 만약에 마지막 생물체 였다면 아쿠아리움 자체를 없애버린다
        //  if (aquarium.creatures.size() == 0)
      {      
        println("removewithdeep");
        aquariums.remove(aquarium);
      }
    }
  }

  void BrithDraw()
  {
    if (birthScaleDelta <= PI/2) //BirthScaleDelta가 PI/2 즉 sin값이 1이 되면 MovinState로 넘어간다
    {
      birthScaleDelta += (PI/2)/(frameRate*8);
      deadScaleDelta = birthScaleDelta; //BirthState에서 바로 Dead가 되는 경우도 있으므로 항상 deadScaleDelta값을 갱신해준다.
      pushMatrix();
      translate(position.x, position.y);      
      scale(sin(birthScaleDelta));
      translate(-position.x, -position.y);  

      if (255*sin(birthScaleDelta) < 150)
        alphaValue = 100;
      else
        alphaValue = int(255*sin(birthScaleDelta));

      // alphaValue = int(255*sin(birthScaleDelta));

      if (!notTentacle)
      {
        for (int ti = 0; ti < nTentacles; ti++)
        { 
          tentacles.get(ti).draw();
          tentacles.get(ti).alphaValue = alphaValue;
        }
        fill (headColor, alphaValue);

        if (typeId == octopusId)
        {
          octopusDraw();
        } else if (typeId == jellyfishId)
        {
          if (alphaValue > 150)
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
          if (150*sin(birthScaleDelta) < 100)
            deepseafishAlpha = 50; //20 + 130*sin(birthScaleDelta);
          else
            deepseafishAlpha = 150*sin(birthScaleDelta);
          deepseafishDraw();
          break;
        default:
          break;
        }
      }
      popMatrix();
    } else
    {
      state = State.Moving; //상태를 바꿔준다
      alphaValue = 255;
      deadScaleDelta = birthScaleDelta;
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
          if (alphaValue > 150)
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
          deepseafishAlpha = 150;
          deepseafishDraw();
          break;
        default:
          break;
        }
      }
    }
  }

  void octopusDraw() //머리 위에 광을 만들어 주기 위한 함수다
  {
    float t = timer.time;
    float specularSizeValue =  0.1 + abs(sin(t/2));
    float sizeValue = (2 + 0.5*abs(sin(t)));

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

  void creatureDraw() //생물체들의 머리를 그려주기 위한 함수
  {
    ellipse (position.x, position.y, headRadius*2, headRadius*2);
  }

  void jellyfishDraw() //해파리의 머리(반원 모양)을 만들어주기 위한 함수
  {
    fill (headColor, alphaValue);       
    pushMatrix();
    translate(position.x, position.y);
    rotate(direction + PI + QUARTER_PI*2);  
    arc(0, 0, headRadius*10*0.8, headRadius*10*0.8, 0-0.5, PI+0.5, CHORD);   
    fill (headColor, alphaValue + 50); 
    ellipse(0, 0, headRadius*5*0.8, headRadius*5*0.8);        
    popMatrix();
  }


  void deepseafishDraw() //심해어를 그리기 위한 함수
  {
    pushMatrix();
    translate(position.x, position.y);           
    rotate(direction);
    noStroke();

    // tail
    stroke(255, 100, 100, deepseafishAlpha);
    strokeWeight(int(radius/2));
    fill(250, 100, 100, deepseafishAlpha);



    k += 1;
    if (k>100000)
      k = 0;
    for (int i = 0; i < 360; i=i+180) {
      for (int n=1; n<20; n=n+2) {     
        fill(250, 150, 100, deepseafishAlpha);
        ellipse(-radius*1.5+(n*1.1)*cos(radians(i-(1.5*n)*sin(k/5)/tempo)), (n*1.1)*tempo/5*sin(radians(i-(1.5*n)*cos(k/5)/tempo)), 12-(5.5+n/2), 12-(5.5+n/2));
      }
    }


    stroke(255, 100, 100, deepseafishAlpha);
    strokeWeight(int(radius/2));

    // wings
    //ellipse(radius*0.5, 0, diameter*1.6,diameter*2.2);
    //fill(120,220,180,90);
    float tempSize = abs(sin(timer.time/2));
    if (tempSize <0.7)
      tempSize = 0.7;



    fill(180, 150, 100, deepseafishAlpha+50);
    ellipse(radius*0.6, 0, diameter, diameter*2*tempSize);

    ellipse(radius*0.3, 0, diameter*1.4, diameter*2.5*tempSize);
    ellipse(radius*0.3, 0, diameter*1.2*tempSize, diameter*1.6*tempSize);
    ellipse(radius*0.1, 0, diameter*0.6*tempSize, diameter*1.2*tempSize);
    ellipse(radius*0.1, 0, diameter*0.6*tempSize, diameter*1.2*tempSize);
    ellipse(radius*0.3*-1, 0, diameter*1, diameter*3*tempSize);
    ellipse(radius*-1, 0, diameter*1, diameter*2*tempSize);
    ellipse(radius*-2, -5, diameter*0.3, diameter*0.3);
    ellipse(radius*-2, 5, diameter*0.3, diameter*0.3);

    stroke(255, 100, 100, deepseafishAlpha);
    strokeWeight(int(radius/2));


    // bodies
    fill(250, 150, 100, deepseafishAlpha);
    //fill(120,100);
    //fill(120, 220, 95, deepseafishAlpha);
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
    fill(0, deepseafishAlpha);
    ellipse(radius*1.5, radius/2, int(radius/2), int(radius/4));
    ellipse(radius*1.5, -radius/2, int(radius/2), int(radius/4));

    popMatrix();
    strokeWeight(1);
  }

  void starfishDraw() //불가사리를 그려주기 위한 함수
  {   
    f=0.5;
    k=k+1;
    if (k > 100)
      k = 1;
    for (int i = 0; i < 360; i=i+75) {
      for (int n=1; n<10; n=n+2) {
        stroke(140, 160, 160, alphaValue);     
        fill(210-6*f, 25+4*f, 0, alphaValue);  
        ellipse(startPosition.x+(n*1.1)*cos(radians(i-f*(1.5*n)*sin(f*k/5)/3)), startPosition.y+(n*1.1)*sin(radians(i-f*(1.5*n)*cos(f*k/5)/3)), 5-n/2, 5-n/2);
      }
    }
  }


  void update() 
  {
    if (!notTentacle)
    {

      if (dist(destination.x, destination.y, position.x, position.y) < 10) //만약 자신의 위치와 목적지가 충분히 가까워 지면 목적지를 다시 갱신해준다
      {
        SetDestination();
      }
      age++;
      
      ///아래는 방향과 회전각을 계산하기 위한 부분이다
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
    } else if (typeId == deepseafishId) //심해어의 경우 구조가 다르므로 다른 방식으로 회전 방향을 계산해준다
    {    
      calc();
    }
  }

  void calc() {
    ///심해어의 회전과 이동을 계산하기 위한 함수
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



  void SetDestination() //목적지를 계산해주기 위한 함수
  { 
    
    specularSizeX = random(-3, 3); //문어 머리 광을 위한 변수
    specularSizeY = random(-3, 3);

    int tempX = int(spawnInfo.x + random(-spawnInfo.radiusX, spawnInfo.radiusX)); //우선 contour를 감싸는 사각형 내부의 임의의 점을 뽑아낸다
    int tempY = int(spawnInfo.y + random(-spawnInfo.radiusY, spawnInfo.radiusY));
    disturb(int(position.x), int(position.y)); //목적지가 바뀐다 -> 몸이 크게 움직인다 -> 이때 물결을 만들어내면 자연스러우므로 넣었다

    if (spawnInfo.contour.containsPoint(tempX, tempY)) //뽑아낸 tempX, tempY가 contour 내부에 속하는 점인지 검사한다
    {

      preposition.x = position.x;
      preposition.y = position.y; 

      destination.x = tempX; //내부에 속하는 점이면 새롭게 목적지로 갱신해준다
      destination.y = tempY;
    } else //내부에 속하지 않는 점이라면
    {
      destination.x = preposition.x; //그 전에 목적지였던 곳으로 되돌아간다
      destination.y = preposition.y;
      //destination.x = spawnInfo.x;
      //destination.y = spawnInfo.y;
    }
  }

  //맵 정보가 갱신될 때 자신의 이전 위치가 남아있으면 그쪽으로 가버리므로 갱신된 spawnInfo의 중심점을 자신의 이전 위치로 넣어준다
  void SetPrePosition() 
  {
    preposition.x = int(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    preposition.y = int(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));
  }

  //맵 정보가 갱신될 때 위의 SetDestination을 쓰게 되면 preposition값에 더 이상 맵에 속하지 않는 자신의 이전 위치를 넣어버릴 수 있으므로 함수를 오버로딩해서 맵 정보 갱신할 때만 이 함수를 쓴다
  void SetDestination(int i)
  { 

    specularSizeX = random(-3, 3);
    specularSizeY = random(-3, 3);

    int tempX = int(spawnInfo.x + random(-spawnInfo.radiusX, spawnInfo.radiusX));
    int tempY = int(spawnInfo.y + random(-spawnInfo.radiusY, spawnInfo.radiusY));

    //disturb(int(position.x), int(position.y));    

    if (spawnInfo.contour.containsPoint(tempX, tempY))
    {

      destination.x = tempX;
      destination.y = tempY;
    } else
    {
      destination.x = preposition.x;
      destination.y = preposition.y;
      //destination.x = spawnInfo.x;
      //destination.y = spawnInfo.y;
    }
  }
}  

PVector getVector2d (float radius, float direction)
{
  return new PVector (cos(direction) * radius
    , sin(direction) * radius);
}