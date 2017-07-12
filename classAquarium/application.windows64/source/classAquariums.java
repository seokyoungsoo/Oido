import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import gab.opencv.*; 
import java.awt.Rectangle; 
import kinect4WinSDK.Kinect; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class classAquariums extends PApplet {





Kinect kinect;

PImage bgImage;
int frameNum = 0; 
int mapFrameNum = 0;

boolean initMap = true;

int maxFrameRate = 30;

int textHeight = 18;
int selectionHeight = 30;
int startx, starty;
int mapFrameRate;




int planktonDelay; //respawn delay time
int pollywogDelay;
int midDelay;
int jellyfishDelay;
int octopusDelay;
int starfishDelay;
int deepseafishDelay;
int standardArea;
int bubbleNum = 100;



Timer timer;

public void setup()
{
  
  ////////////////
  bgImage = loadImage("bottom_6.gif"); //\ubc30\uacbd\uc774\ubbf8\uc9c0\ub97c \ub85c\ub4dc\ud55c\ub2e4
 
  imgName[0] = "testS.png"; //located in same folder, change randomly 
  imgName[1] = "testS.png";
  imgName[2] = "test3.png";
  imgName[3] = "test3.png";
  imgName[4] = "testS.png";

  mapFrameRate = 400; //\ub9f5\uc774 \uac31\uc2e0\ub418\ub294 \uc8fc\uae30

  planktonDelay = 1; //\uac01 \uc0dd\ubb3c\uccb4\ub4e4\uc774 \uc0dd\uc131\ub418\ub294 \uc8fc\uae30 \ub51c\ub808\uc774
  pollywogDelay = 2;
  midDelay = 2;
  jellyfishDelay = 2;
  octopusDelay = 2;
  starfishDelay = 2;
  deepseafishDelay = 3;
  standardArea = 90000;


   //window size
  frameRate(maxFrameRate); // set frameRate
  
  MakeMap(); 
  initMap = false;

  hwidth = width>>1;
  hheight = height>>1;
  riprad=3; //test with 3

  size = width * (height+2) * 2;

  ripplemap = new int[size];
  ripple = new int[width*height];
  texture = new int[width*height];

  oldind = width;
  newind = width * (height+3);

  loadPixels();

  for (int i = 0; i < bubbleNum; i++)
  {
    bubble b = new bubble();
    bubbles.add(b);
  }  

  timer = new Timer();
}



public void draw() 
{

  CleanMap(); //call background function and draw selected map info

  //image(bgImage, 0, 0);
  mapFrameNum++;
  for (int i = 0; i < aquariums.size(); i++)
  {
    Aquarium a  = aquariums.get(i);

    a.draw();
  }

  if (mapFrameNum == mapFrameRate)
  {
    MakeMap();
    mapFrameNum = 0;
  }

  loadPixels();
  texture = pixels;

  newframe();

  for (int i = 0; i < pixels.length; i++) {
    pixels[i] = ripple[i];
  }

  updatePixels();
  timer.CheckTime();
}


final int planktonId = 0; //monster index 
final int pollywogId = 1;
final int midFishId    = 2;
final int jellyfishId = 3;
final int octopusId  = 4;
final int starfishId  = 5;
final int deepseafishId  = 6;
final int monstersNum = 7;


PVector zeroVector = new PVector();


final int ac_move = 0;   // creature action   
class Aquarium
{

  int[] monsterLimit = new int[monstersNum];
  int[] monsterLimitForRemove = new int[monstersNum];
  int[] monsterNum = new int[monstersNum];


  IntList removeMonsterId = new IntList();

  int monsterNumber = 0;
  float areaSize;
  boolean isActive;

  ArrayList<Creature> creatures;
  point spawnInfo;

  Aquarium(point spawnInfo) 
  {
    this.spawnInfo = spawnInfo;  
    creatures = new ArrayList<Creature>();
    SetMonsterNumLimit();
    isActive = true;
  }

  public void SetSmallerNumLimit() //\ub9f5\uc774 \uc791\uc544\uc9c8 \ub54c \uc0dd\ubb3c\uccb4 \uc218\ub97c \uc904\uc774\ub294 \ud568\uc218
  {
    areaSize = spawnInfo.contour.area();
    int standardForNum =  PApplet.parseInt(areaSize / standardArea);

    monsterLimitForRemove[planktonId] =  monsterNum[planktonId] - standardForNum * 5;
    monsterLimitForRemove[pollywogId] =  monsterNum[pollywogId] - standardForNum * 3;
    monsterLimitForRemove[midFishId] =  monsterNum[midFishId] - standardForNum * 3;
    monsterLimitForRemove[jellyfishId] =  monsterNum[jellyfishId] - standardForNum * 2;
    monsterLimitForRemove[octopusId] =  monsterNum[octopusId] - standardForNum * 2;
    monsterLimitForRemove[starfishId] =  monsterNum[starfishId];
    monsterLimitForRemove[deepseafishId] =  monsterNum[deepseafishId] - standardForNum;


    for (int i = 0; i <  monsterLimitForRemove[planktonId]; i++)
    {
      SetDead(planktonId);
      monsterNum[planktonId]--;
    }

    for (int i = 0; i <  monsterLimitForRemove[pollywogId]; i++)
    {
      SetDead(pollywogId);
      monsterNum[pollywogId]--;
    }

    for (int i = 0; i <  monsterLimitForRemove[midFishId]; i++)
    {
      SetDead(midFishId);
      monsterNum[midFishId]--;
    }

    for (int i = 0; i <  monsterLimitForRemove[jellyfishId]; i++)
    {
      SetDead(jellyfishId);
      monsterNum[jellyfishId]--;
    }

    for (int i = 0; i <  monsterLimitForRemove[octopusId]; i++)
    {      
      SetDead(octopusId);
      monsterNum[octopusId]--;
    }

    for (int i = 0; i <  monsterLimitForRemove[starfishId]; i++)
    {      
      SetDead(starfishId);
      monsterNum[starfishId]--;
    }

    for (int i = 0; i <  monsterLimitForRemove[deepseafishId]; i++)
    {      
      SetDead(deepseafishId);
      monsterNum[deepseafishId]--;
    }

    monsterLimit[planktonId] = standardForNum * 10;
    monsterLimit[pollywogId] = standardForNum * 5;
    monsterLimit[midFishId] = standardForNum * 3;
    monsterLimit[jellyfishId] = standardForNum * 2;
    monsterLimit[octopusId] = standardForNum * 2;
    monsterLimit[starfishId] = standardForNum * 2;
    monsterLimit[deepseafishId] = standardForNum;
  }


  public void NullCheck()
  {
    int creatureSize = creatures.size();
    for (int i = 0; i < creatureSize; i++)
    {
      Creature a = creatures.get(i);
      if (a.state == State.None)
      {
        creatures.remove(a);
        creatureSize--;
        i-=1;
      }
    }
  }





  public void SetDead(int id)
  {
    for (int i = 0; i < creatures.size(); i++)
    {
      Creature a = creatures.get(i);
      if (a.typeId == id && a.state == State.Moving)
      {
        a.state = State.Dead;
        break;
      }
    }
  }

  public void SetMonsterNumLimit()
  {
    areaSize = spawnInfo.contour.area();
    int standardForNum =  PApplet.parseInt(areaSize / standardArea);

    monsterLimit[planktonId] = standardForNum * 10;
    monsterLimit[pollywogId] = standardForNum * 5;
    monsterLimit[midFishId] = standardForNum * 3;
    monsterLimit[jellyfishId] = standardForNum * 2;
    monsterLimit[octopusId] = standardForNum * 2;
    monsterLimit[starfishId] = standardForNum * 2;
    monsterLimit[deepseafishId] = standardForNum;
  }

  public void ResetSpawnInfo()
  {

    for (int i = 0; i < creatures.size(); i++)
    {
      Creature acreature =  creatures.get(i);
      acreature.spawnInfo = this.spawnInfo;
      acreature.SetDestination();
    }
  }

  public void draw()
  {
    for (int mi = 0; mi < creatures.size (); mi++)
    {
      Creature aCreature = creatures.get(mi); 
      aCreature.draw(); 
      aCreature.update();
    }

    addNewCreatures();
  }


  public void redraw()
  {
    for (int mi = 0; mi < creatures.size (); mi++)
    {
      Creature aCreature = creatures.get(mi); 
      aCreature.draw();
    }
  }


  public void addPlankton(PVector moveDir, point spawnInfo)
  {
    monsterNum[planktonId]++;
    monsterNumber++;
    int px = PApplet.parseInt(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = PApplet.parseInt(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    PVector startPosition;
    if (px > 0.0f)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    int headColor = SelectColor(planktonId, PApplet.parseInt(random(0, 5)));
    float speed = random (2, 4);
    creatures.add (new Creature (planktonId, headColor, startPosition, moveDir, speed
      , 6   // Size
      , 1   // tentacle count
      , 10   // tentacle parts
      , 3   // compactness
      , 88, 33   // moving, waiting
      , 0.1f, 0.3f   // swing
      , spawnInfo
      , false
      , this

      ));
  }
  //----------------------------------------------------------
  public void addPollywog(PVector moveDir, point spawnInfo)
  {
    monsterNum[pollywogId]++;
    monsterNumber++;
    int px = PApplet.parseInt(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = PApplet.parseInt(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    PVector startPosition;
    if (px > 0.0f)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    int headColor = SelectColor(pollywogId, PApplet.parseInt(random(0, 5)));
    float speed = random (2, 4);
    creatures.add (new Creature (pollywogId, headColor, startPosition, moveDir, speed
      , 10   // Size
      , 1   // tentacle count
      , 20   // tentacle parts
      , 3   // compactness
      , 88, 33   // moving, waiting
      , 0.1f, 0.3f   // swing
      , spawnInfo
      , false
      , this
      ));
  }

  public void addMidfish(PVector moveDir, point spawnInfo)
  {

    monsterNum[midFishId]++;
    monsterNumber++;
    int px = PApplet.parseInt(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = PApplet.parseInt(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    PVector startPosition;
    if (px > 0.0f)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    int headColor = SelectColor(midFishId, PApplet.parseInt(random(0, 5)));
    float speed = random (3.0f, 4.5f);
    Creature snake = new Creature (midFishId, headColor, startPosition, moveDir, speed
      , 8   // Size
      , 1   // tentacle count
      , 30   // tentacle parts
      , 4   // compactness
      , 111, 33   // moving, waiting 
      , 0.5f, 0.5f   // swing
      , spawnInfo
      , false
      , this
      ); 
    creatures.add(snake);
    //println (" snake added");
  }
  //----------------------------------------------------------
  public void addJellyfish(PVector moveDir, point spawnInfo)
  {
    monsterNum[jellyfishId]++;
    monsterNumber++;
    int px = PApplet.parseInt(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = PApplet.parseInt(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    PVector startPosition;
    if (px > 0.0f)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    int headColor = SelectColor(jellyfishId, PApplet.parseInt(random(0, 5)));
    float speed = 1;//random (2,3);

    Creature jellyfish = new Creature (jellyfishId, headColor, startPosition, moveDir, speed
      , 10  // Size
      , 5   // tentacle count
      , 20   // tentacle parts
      , 3  // compactness
      , 10, 80   // moving, waiting
      // , 0.1, 0.05   // swing
      , 0.5f, 0.01f   // swing
      , spawnInfo
      , false
      , this
      );

    creatures.add(jellyfish);
    //println (" starfish added");
  }
  //----------------------------------------------------------

  public void addOctopus(PVector moveDir, point spawnInfo)
  {
    monsterNum[octopusId]++;
    monsterNumber++;
    PVector startPosition;
    int px = PApplet.parseInt(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = PApplet.parseInt(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    if (px > 0.0f)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    int headColor = SelectColor(octopusId, PApplet.parseInt(random(0, 5)));
    float speed = random (3.0f, 4.0f);

    Creature octopus = new Creature (octopusId, headColor, startPosition, moveDir, speed
      , 15   // Size
      , 5   // tentacle count
      , 13   // tentacle parts
      , 5   // compactness
      , 44, 66   // moving, waiting
      , 0.1f, 0.2f   // swing
      , spawnInfo
      , false
      , this

      ); 
    creatures.add(octopus);
    //println (" octopus added");
  }

  public void addStarfish(PVector moveDir, point spawnInfo)
  {
    monsterNum[starfishId]++;
    monsterNumber++;
    PVector startPosition;
    int px = PApplet.parseInt(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = PApplet.parseInt(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    if (px > 0.0f)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    int headColor = SelectColor(starfishId, PApplet.parseInt(random(0, 5)));
    float speed = random (3.0f, 4.0f);

    Creature starfish = new Creature (starfishId, headColor, startPosition, moveDir, speed
      , 15   // Size
      , 10   // tentacle count
      , 10   // tentacle parts
      , 3   // compactness
      , 44, 66   // moving, waiting
      , 0.1f, 0.5f   // swing
      , spawnInfo
      , true
      , this
      ); 
    creatures.add(starfish);
  }

  public void addDeepSeaFish(PVector moveDir, point spawnInfo)
  {
    monsterNum[deepseafishId]++;
    monsterNumber++;
    PVector startPosition;
    int px = PApplet.parseInt(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = PApplet.parseInt(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    if (px > 0.0f)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    int headColor = SelectColor(deepseafishId, PApplet.parseInt(random(0, 5)));
    float speed = 10;

    Creature deepseafish = new Creature (deepseafishId, headColor, startPosition, moveDir, speed
      , 15   // Size
      , 6   // tentacle count
      , 18   // tentacle parts
      , 5   // compactness
      , 44, 66   // moving, waiting
      , 0.1f, 0.5f   // swing
      , spawnInfo
      , true
      , this
      ); 
    creatures.add(deepseafish);
  }






  //----------------------------------------------------------
  public void addNewCreatures ()
  {
    if (frameCount %   (planktonDelay*maxFrameRate)  == 0 &&  monsterNum[planktonId] < monsterLimit[planktonId] && isActive) addPlankton (zeroVector, spawnInfo);
    if (frameCount % ( pollywogDelay*maxFrameRate) == 0 && monsterNum[pollywogId] < monsterLimit[pollywogId] && isActive) addPollywog (zeroVector, spawnInfo);   
    if (frameCount % (midDelay*maxFrameRate) == 0 &&  monsterNum[midFishId] < monsterLimit[midFishId] && isActive) addMidfish    (zeroVector, spawnInfo);
    if (frameCount % (jellyfishDelay*maxFrameRate) == 0 &&  monsterNum[jellyfishId] < monsterLimit[jellyfishId] && isActive) addJellyfish (zeroVector, spawnInfo);
    if (frameCount % (octopusDelay*maxFrameRate) == 0 &&  monsterNum[octopusId] < monsterLimit[octopusId] && isActive) addOctopus (zeroVector, spawnInfo);
    if (frameCount % (starfishDelay*maxFrameRate) == 0 &&  monsterNum[starfishId] < monsterLimit[starfishId] && isActive) addStarfish (zeroVector, spawnInfo);
    if (frameCount % (deepseafishDelay*maxFrameRate) == 0 &&  monsterNum[deepseafishId] < monsterLimit[deepseafishId] && isActive) addDeepSeaFish (zeroVector, spawnInfo);
  }
}

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
  int headColor;             // creatures head color
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
    , int headColor          // color of creatures head
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
      , 0.3f                    // maxMotionAcceleration
      , radians(4.0f)           // maxAngleSpeed   
      , radians(1.0f)           // maxAngleAcceleration
      , startPosition);        // current start position
    this.speed = maxMotionSpeed;
    this.startPosition = startPosition;
    this.isAlive = true;
    this.typeId = typeId;  
    this.headColor = headColor;
    this.headRadius = size/2;
    this.biteRadius = size * 2.0f;
    this.notTentacle = notTentacle;
    this.visibilityRadius = size * 10.0f;
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
    maxSize = random(0.2f, PI/2); 
    SetDestination();

    tentacles = new ArrayList<Tentacle>();
    for (int i = 0; i < nTentacles; i++) 
    {
      float direction = moveDirection; // + (0.5 * i * angle) - angle + halfAngle;
      PVector tPos = startPosition.get();
      tPos.sub (getVector2d (headRadius, direction));

      // create a tentacle
      Tentacle tentacle = new Tentacle(typeId, tPos, direction, partCount, size*0.9f, compactness, headColor);
      // add tentacle to tentacle list
      tentacles.add(tentacle);
    }

    loc = new PVector();
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    aAcc = 0;
    aVel = 0;
    angle = 0;
    mass = 1.5f;
    diameter = mass * 10*2;
    radius = diameter / 2;
    oAmp = radius * 1.5f;
    oTimer = 0;
    oTimerRate = 0.01f;

    loc.x = startPosition.x;
    loc.y = startPosition.y;
  }


  public void draw() 
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

  public void octopusDraw()
  {
    float t = timer.time;
    float specularSizeValue =  0.1f + abs(sin(t/2));
    float sizeValue = 2 + 0.5f*abs(sin(t));

    ellipse (position.x, position.y, headRadius*sizeValue, headRadius*sizeValue); 
    fill(200, 30);
    ellipse (position.x +3, position.y, headRadius*sizeValue, headRadius*sizeValue);   
    noStroke();
    fill(180, 80);
    ellipse (position.x + specularSizeX, position.y + specularSizeY, headRadius * 1 * specularSizeValue, headRadius * 0.8f * specularSizeValue);
    fill(200, 80);
    ellipse (position.x + specularSizeX, position.y + specularSizeY, headRadius * 0.8f * specularSizeValue, headRadius * 0.5f * specularSizeValue);
    fill(255, 80);
    ellipse (position.x + specularSizeX, position.y + specularSizeY, headRadius*0.3f * specularSizeValue, headRadius*0.5f * specularSizeValue);
  }

  public void creatureDraw()
  {
    ellipse (position.x, position.y, headRadius*2, headRadius*2);
  }

  public void jellyfishDraw()
  {
    
    fill (headColor, alphaValue);       
    pushMatrix();
    translate(position.x, position.y);
    rotate(direction + PI + QUARTER_PI*2);  
    arc(0, 0, headRadius*10, headRadius*10, 0-0.5f, PI+0.5f, CHORD);   
    fill (headColor, alphaValue + 50); 
    ellipse(0, 0, headRadius*5, headRadius*5);        
    popMatrix();
  }


  public void deepseafishDraw()
  {
    pushMatrix();
    translate(position.x, position.y);           
    rotate(direction);
    noStroke();

    // tail
    stroke(255, 100, 100, deepseafishAlpha);
    strokeWeight(PApplet.parseInt(radius/2));
    fill(255, 100, 100, deepseafishAlpha);
    float x = oAmp * sin(timer.time)/2;

    line(radius, 0, x-diameter, 0);
    ellipse(-radius, 0, PApplet.parseInt(radius/2)*1.5f, PApplet.parseInt(radius/2)*1.5f);
    ellipse(x-diameter, 0, PApplet.parseInt(radius/6), PApplet.parseInt(radius/6));


    stroke(255, 100, 100, deepseafishAlpha);
    strokeWeight(PApplet.parseInt(radius/2));

    // wings
    //ellipse(radius*0.5, 0, diameter*1.6,diameter*2.2);
    //fill(120,220,180,90);
    float tempSize = sin(timer.time /2 );
    fill(120, deepseafishAlpha);
    ellipse(radius*0.6f, 0, diameter, diameter*2.5f*tempSize);

    ellipse(radius*0.3f, 0, diameter, diameter*1.6f);
    ellipse(radius*0.1f, 0, diameter, diameter*1.2f);


    // bodies
    //fill(220,150,100,120);
    //fill(120,100);
    fill(120, 220, 95, deepseafishAlpha);
    ellipseMode(CENTER);
    ellipse(radius, 0, diameter*1.5f, diameter*1.2f);
    //fill(120,220,180,90);
    ellipse(radius*0.6f, 0, diameter*1.8f, diameter*0.8f);
    ellipse(radius*0.1f, 0, diameter*2.2f, diameter*0.5f);


    // eyes
    //fill(100,100,255,150);
    fill(20, deepseafishAlpha);
    ellipse(radius*1.6f, radius/2, PApplet.parseInt(radius/2)*2, PApplet.parseInt(radius/4)*2);
    ellipse(radius*1.6f, -radius/2, PApplet.parseInt(radius/2)*2, PApplet.parseInt(radius/4)*2);
    fill(255, 50, 0, deepseafishAlpha);
    ellipse(radius*1.5f, radius/2, PApplet.parseInt(radius/2), PApplet.parseInt(radius/4));
    ellipse(radius*1.5f, -radius/2, PApplet.parseInt(radius/2), PApplet.parseInt(radius/4));

    popMatrix();
    strokeWeight(1);
  }

  public void starfishDraw()
  {   
    f=0.5f;
    k=k+1;
    for (int i = 0; i < 360; i=i+75) {
      for (int n=1; n<16; n=n+2) {
        stroke(140, 160, 160, alphaValue);     
        fill(210-6*f, 25+4*f, 0, alphaValue);  
        ellipse(startPosition.x+(n*1.1f)*cos(radians(i-f*(1.5f*n)*sin(f*k/5)/3)), startPosition.y+(n*1.1f)*sin(radians(i-f*(1.5f*n)*cos(f*k/5)/3)), 8-n/2, 8-n/2);
      }
    }
  }

  public void deepseafishDead()
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

  public void fixedDead()
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


  public void DeadState()
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





  public void DeadScaleDown(float delta)
  {
    headRadius *= cos(delta);
    for (int ti = 0; ti < nTentacles; ti++)
    {
      tentacles.get(ti).alphaValue = 255 - PApplet.parseInt(delta * 150);
      for (int j = 0; j < tentacles.get(ti).parts.size(); j++ )
      {
        tentacles.get(ti).parts.get(j).size *= cos(delta);
      }
    }
  }



  public void update() 
  {
    if (!notTentacle)
    {

      if (dist(destination.x, destination.y, position.x, position.y) < 10)
      {
        SetDestination();
      }
      age++;

      moveDirection = atan2(destination.y-position.y, destination.x-position.x); 

      // moveDirection += random(-1, 1) * radians(100);  // -50\u00b0 .. 50\u00b0
      float add = swingSize * sin(frameCount * swingFrequency);

      if (!notTentacle)
        moveDirection +=  add;  // -50\u00b0 .. 50\u00b0


      //    steering.linear.div(currentTime/50 > 0 ? currentTime/50 : 1);
      direction = moveDirection;
      //    steering = wander(this, 100.0, 80.0, radians(5));  // 5\u00b0 .. +5\u00b0
      //    super.update(steering);
      PVector dir = getOrientationAsVector();
      super.update(dir, rotation);

      currentTime++;

      // set main tentacle directions  
      float partAngle = TWO_PI / nTentacles; 
      float halfAngle = (nTentacles % 2 == 0 ? partAngle*0.5f : 0.0f);
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

  public void calc() {

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


    if (abs(dt) > 0.1f) {

      direction = (direction + 0.1f * dt + 2 * TWO_PI) % TWO_PI;
    }


    float v = speed * 0.1f + 0.2f * cos(5 * timer.time); 
    float dir = theta+ 0.7f * cos(5 * timer.time);

    position.x += v* cos(dir);
    position.y += v* sin(dir);
  }



  public void SetDestination()
  { 

    specularSizeX = random(-3, 3);
    specularSizeY = random(-3, 3);
    //float angle = random(TWO_PI);
    int tempX = PApplet.parseInt(spawnInfo.x + random(-spawnInfo.radiusX, spawnInfo.radiusX));
    int tempY = PApplet.parseInt(spawnInfo.y + random(-spawnInfo.radiusY, spawnInfo.radiusY));


    if (spawnInfo.contour.containsPoint(tempX, tempY))
    {
      disturb(PApplet.parseInt(position.x), PApplet.parseInt(position.y));
      destination.x = tempX;
      destination.y = tempY;
    } else
    {
      destination.x = spawnInfo.x;
      destination.y = spawnInfo.y;
    }
  }
}  

public PVector getVector2d (float radius, float direction)
{
  return new PVector (cos(direction) * radius
    , sin(direction) * radius);
}

String[] imgName = new String[5];

point tempPoint;
PImage originImage, dst;
OpenCV opencv;
ArrayList<Contour> contours;
ArrayList<Contour> polygons;
ArrayList<point> areaInfo = new ArrayList<point>();
ArrayList<Aquarium> aquariums = new ArrayList<Aquarium>();
ArrayList<bubble> bubbles = new ArrayList<bubble>();

int preMonSize = 0;


public void MakeMap()
{

  if (initMap)
  {
    PImage tempImage = loadImage(imgName[PApplet.parseInt(random(0, imgName.length))]);   
    opencv = new OpenCV(this, tempImage);
    opencv.gray();
    opencv.threshold(190);
    contours = opencv.findContours();  

    for (Contour contour : contours)
    {
      if (contour.area() > 100000)
      {
        fill(255); 
        Rectangle rects = contour.getBoundingBox(); 
        tempPoint = new point(contour, rects.x + rects.width/2, rects.y + rects.height/2, rects.width/2, rects.height/2);

        areaInfo.add(tempPoint);
      }
    }

    for (int i = 0; i < areaInfo.size(); i++)
    {
      aquariums.add(new Aquarium(areaInfo.get(i)));
    }
  } else
  {
    ChangeMap();
  }

  for (int i = 0; i < aquariums.size(); i++)
  {
    Aquarium a  = aquariums.get(i);
    println("monster number : " + a.creatures.size());
  }
}

public void ChangeMap()
{

  CleanMap();
  PImage tempImage = loadImage(imgName[PApplet.parseInt(random(0, imgName.length))]);   
  opencv = new OpenCV(this, tempImage); 
  opencv.gray();
  opencv.threshold(185); 
  contours = opencv.findContours();  

  for (int i = 0; i < aquariums.size(); i++)
  {
    Aquarium a  = aquariums.get(i);
    a.redraw();
  }

  areaInfo.clear();  

  for (Contour contour : contours)
  {
    if (contour.area() > 100000)
    {
      fill(255); 
      Rectangle rects = contour.getBoundingBox();
      tempPoint = new point(contour, rects.x + rects.width/2, rects.y + rects.height/2, rects.width/2, rects.height/2);

      areaInfo.add(tempPoint);
    }
  }  

  ChangeMonsterSpawnInfo();
  for (int i = 0; i < areaInfo.size(); i++)
  {
    if (!areaInfo.get(i).isSet)
    {
      aquariums.add(new Aquarium(areaInfo.get(i)));
    }
  }
}

public void ChangeMonsterSpawnInfo()
{

  int loopIdx = 0;
  int loopSize = aquariums.size();

  for (; loopIdx < loopSize; loopIdx++)
  {
    Aquarium b = (Aquarium)aquariums.get(loopIdx); 
    if (!CircleIncludeCheck(b)) //\uc0c8\ub86d\uac8c \uac31\uc2e0\ub41c areaInfo\ub4e4\uacfc \uc790\uc2e0\uc758 spawnInfo\uac00 \uacb9\uce58\uc9c0 \uc54a\ub294\ub2e4\uba74 \uc0dd\ubb3c\uccb4\ub4e4\uc758 \uc0c1\ud0dc\ub97c Dead\ub85c \ubc14\uafd4\uc900\ub2e4.
    {
      b.isActive = false;
      for (int j = 0; j < b.creatures.size(); j++)
      {
        b.creatures.get(j).state = State.Dead;
      }
    }
  }
}

public boolean CircleIncludeCheck(Aquarium b) 
{

  for (int i = 0; i < areaInfo.size(); i++)
  {
    if (overlap(b.spawnInfo, areaInfo.get(i))) //\ub9cc\uc57d \ub9f5\uc774 \uacb9\uce58\uba74 spawnInfo\ub97c \uad50\uccb4\ud558\ub294 \uc2dd\uc73c\ub85c \ub9f5 \uc815\ubcf4\ub97c \uac31\uc2e0\ud55c\ub2e4.
    {
      float areaSize = b.spawnInfo.contour.area();
      b.spawnInfo.x = areaInfo.get(i).x;
      b.spawnInfo.y = areaInfo.get(i).y;
      b.spawnInfo.radiusX = areaInfo.get(i).radiusX;
      b.spawnInfo.radiusY = areaInfo.get(i).radiusY;
      b.spawnInfo.contour = areaInfo.get(i).contour;
      areaInfo.get(i).isSet = true; 
      b.ResetSpawnInfo(); //\uc544\ucfe0\uc544\ub9ac\uc6c0\uc758 \uc0dd\ubb3c\uccb4\ub4e4\uc758 spawnInfo\ub97c \uad50\uccb4\ud574\uc900\ub2e4.

      if (areaSize > b.spawnInfo.contour.area())
      {
        b.SetSmallerNumLimit();
      } else
      {
        b.SetMonsterNumLimit();
      }
      b.NullCheck();

      return true;
    }
  }
  return false;
}


public boolean overlap(point mySpawnInfo, point targetSpawnInfo) //AABB \ucda9\ub3cc \uac80\ucd9c\uc744 \ud1b5\ud55c \uc678\ubd80 \uc9c1\uc0ac\uac01\ud615\uc758 \uacb9\uce68\uc744 \uac80\uc0ac\ud55c\ub2e4
{
  float offset = 50;
  boolean noOverlap = mySpawnInfo.x - (mySpawnInfo.radiusX - offset) > targetSpawnInfo.x + (targetSpawnInfo.radiusX - offset) ||
    targetSpawnInfo.x - (targetSpawnInfo.radiusX - offset) > mySpawnInfo.x + (mySpawnInfo.radiusX - offset)||
    mySpawnInfo.y - (mySpawnInfo.radiusY - offset)> targetSpawnInfo.y + (targetSpawnInfo.radiusY - offset) ||
    targetSpawnInfo.y - (targetSpawnInfo.radiusY - offset) > mySpawnInfo.y +( mySpawnInfo.radiusY - offset);

  return !noOverlap;
}



public void CleanMap() { 
  //fill(0, 200, 200); 
  //rect(0, 0, width, height);

  bgImage.resize(1500, 1000);
  background(bgImage);

  for (int i = 0; i < bubbleNum; i++)
  {
    bubble b = bubbles.get(i);
    b.update();
    b.draw();
  }


  for (int i = 0; i < aquariums.size(); i++)
  {
    Aquarium a  = aquariums.get(i);
    //image(bgImage, a.spawnInfo.x - a.spawnInfo.radiusX, a.spawnInfo.y - a.spawnInfo.radiusY, a.spawnInfo.radiusX * 2, a.spawnInfo.radiusY * 2);
    a.redraw();
  }

  /*for (int i = 0; i < areaInfo.size(); i++)
   {
   fill(180);
   Contour tempContour = areaInfo.get(i).contour;
   tempContour.draw();
   }*/
}
class MotionInfo 
{
  PVector position;        // current positon
  PVector moveDirection;   // moving direction
  protected PVector velocity;        // speed
  protected float direction;
  protected float rotation;          // rotation angle [radiant]
  protected float maxSpeed;          // speed limit
  protected float maxAccel;          // acceleration limit
  protected float maxAngSpeed;       // max. rotation speed
  protected float maxAngAccel;       // max. rotation acceleration
 
  //----------------------------------------------------------
  MotionInfo() 
  {
    maxSpeed = 0.1f;
    maxAccel = 1.0f;
    maxAngSpeed = 0.0f;
    maxAngAccel = 0.0f;
    position = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    direction = random (0, TWO_PI);
    rotation = 0.0f;
   
  }
  //----------------------------------------------------------
  MotionInfo(float startDirection           // [radiant]
            ,float maxMotionSpeed
            ,float maxMotionAcceleration
            ,float maxAngleSpeed
            ,float maxAngleAcceleration
            ,PVector startPosition) 
  {
    position = startPosition;
    direction = startDirection;

//println ("MotionInfo: dir=" + degrees(rotation));

    maxSpeed = maxMotionSpeed;
    maxAccel = maxMotionAcceleration;
    maxAngSpeed = maxAngleSpeed;
    maxAngAccel = maxAngleAcceleration;
    velocity = new PVector(0, 0, 0);
    rotation = 0.0f;
  }
  //----------------------------------------------------------
  // get current move direction
  //----------------------------------------------------------
  public PVector getOrientationAsVector() 
  {
    return new PVector(cos(direction), sin(direction), 0.0f);
  }
  //----------------------------------------------------------
  // set move direction
  //----------------------------------------------------------
  public void setDirection2d (float directionAngle) 
  {
    moveDirection = PVector.fromAngle (directionAngle % TWO_PI); 
//    println (" motion.setDirection2d: " + nf(degrees(directionAngle),0,2) + "\u00b0   " );
  }
  //----------------------------------------------------------
  // change move direction
  //----------------------------------------------------------
  public void turn2d (float angle) 
  {
//    println (" motion.turn2d: " + nf(degrees(angle),0,2) + "\u00b0");
    setDirection2d (moveDirection.heading() + angle);
  }
  //----------------------------------------------------------
  // execute motion
  //----------------------------------------------------------
  public void update(PVector move, float angular) 
  {
//    println (" motion.update: " + move + "   "+nf(degrees(angular),0,2) + "\u00b0");
    velocity.add(move);
    velocity.limit(maxSpeed);  // limit max speed
    position.add(velocity);
   
    if (rotation < maxAngSpeed)
      rotation += angular;  
    else
      rotation = maxAngSpeed;

    direction += rotation;
    direction %= TWO_PI;
  }

}
class SteeringInfo 
{
  PVector linear;
  float angular;
  SteeringInfo()
  {
    linear = new PVector(0, 0, 0);
    angular = 0;
  }
};

//----------------------------------------------------------
// the following should be in a static public class "SteeringBehavior"
// but I would then have to setup a whole new Eclipse project and I'm laaaazyy
//----------------------------------------------------------
public SteeringInfo align (MotionInfo agent
                   ,MotionInfo target
                   ,float slowRadius
                   ,float targetRadius) 
{
  SteeringInfo steering = new SteeringInfo();

  float angularDirection = target.direction - agent.direction;

  angularDirection %= TWO_PI;

  if (angularDirection > PI)
    angularDirection -= TWO_PI;
  else if (angularDirection < -PI)
    angularDirection += TWO_PI;

  float angularDistance = abs(angularDirection);

  if(angularDistance < targetRadius)
  {
    agent.rotation = 0;
    steering.angular = 0;
    return steering;
  }

  float targetRotationSpeed;

  if( angularDistance < slowRadius ) 
 
    targetRotationSpeed = agent.maxAngAccel * (angularDistance / slowRadius);
  else 
    targetRotationSpeed = agent.maxAngAccel;
 


  if(angularDirection > 0) angularDirection /= angularDistance;
  float targetRotation = targetRotationSpeed * angularDirection;
  steering.angular = targetRotation - agent.rotation;

  if(steering.angular > agent.maxAngAccel) 
  {
    steering.angular /= abs(steering.angular);
    steering.angular *= agent.maxAngAccel;
  }
  return steering;
}

//----------------------------------------------------------
public SteeringInfo face (MotionInfo agent
                  ,MotionInfo target
                  ,float slowRadius
                  ,float targetRadius) 
{
  PVector direction = PVector.sub(target.position, agent.position);

  MotionInfo alignTarget = new MotionInfo(random(2*PI), 1.0f, 1.0f, 0.2f, 0.2f, direction);
  alignTarget.direction = atan2(direction.y, direction.x);

  return align(agent, alignTarget, slowRadius, targetRadius);
}

float wanderOrientation = 0.0f;

//----------------------------------------------------------
// wanderOffset = distance to the projected circle
// wanderRadius = circle radius
// wanderRate   = rate of direction change
//----------------------------------------------------------
public SteeringInfo wander (MotionInfo agent
                    ,float wanderOffset
                    ,float wanderRadius
                    ,float wanderRate) 
{
  MotionInfo target = new MotionInfo();

  wanderOrientation += random(-1, 1) * wanderRate;
  wanderOrientation %= TWO_PI;

  if (wanderOrientation > PI)
    wanderOrientation -= TWO_PI;
  else if (wanderOrientation < -PI)
    wanderOrientation += TWO_PI;

  target.direction = agent.direction + wanderOrientation;

  PVector positionOffset = agent.getOrientationAsVector();
  positionOffset.mult(wanderOffset);

  PVector orientationOffset = target.getOrientationAsVector();
  orientationOffset.mult(wanderRadius/2);

  target.position = agent.position.get();
  target.position.add(positionOffset);
  /*
  pushMatrix();
  pushStyle();
  noFill();
  stroke(255, 0, 0);
  ellipse(target.position.x, target.position.y, wanderRadius, wanderRadius);
  */
  target.position.add(orientationOffset);
  /*
  rect(target.position.x, target.position.y, 2, 2);
  popMatrix();
  popStyle();
  */

  SteeringInfo steering = face(agent, target, PI, 0);
  steering.linear = agent.getOrientationAsVector();
  steering.linear.mult(agent.maxAccel);
  return steering;
}
class Tentacle 
{
  PVector position;
  float direction;
  float compactness;
  ArrayList<TentaclePart> parts;   // tentacle parts
  int nParts;
  int alphaValue = 255;
  //----------------------------------------------------------
  // create tentacle
  //----------------------------------------------------------
  Tentacle (int typeId
    , PVector startPosition     
    , float startDirection      // 0 .. 2*pi (360\u00b0)
    , int partCount             // tentacle parts: 1..100
    , float partSize            // start size of 1st part 
    , float compactnessFactor   // 0.0 .. 1.0
    , int aColor
    )
  {
    switch(typeId)
    {
    case 0:
    case 1:
      position = startPosition;
      direction = startDirection;
      nParts = constrain (partCount, 2, 100);
      float headSize = partSize;
      compactness = compactnessFactor;

      // create tentacle parts
      parts = new ArrayList<TentaclePart>();
      int mixColor = color(random(150, 222));
      for (int ni = 0; ni < nParts; ni++) 
      {
        TentaclePart part = new TentaclePart();
        part.position = position.get();
        part.position.sub (getVector2d(PApplet.parseFloat(ni+1), direction));
        part.size = headSize * PApplet.parseFloat(nParts-ni) / nParts;
        float mix = 0.5f + 0.5f * sin(PApplet.parseFloat(ni)*0.4f);
        part.tColor = aColor;
        parts.add(part);
      }
      break;
    case 3:
      position = startPosition;
      direction = startDirection;
      nParts = constrain (partCount, 2, 100);
      float headSize_j = partSize;
      compactness = compactnessFactor;

      // create tentacle parts
      parts = new ArrayList<TentaclePart>();
      int mixColor_j = color(random(150, 222));
      for (int ni = 0; ni < nParts; ni++) 
      {
        TentaclePart part = new TentaclePart();
        part.position = position.get();
        part.position.sub (getVector2d(PApplet.parseFloat(ni+1), direction));
        part.size = headSize_j * PApplet.parseFloat(nParts-ni) / nParts;
        float mix = 0.5f + 0.5f * sin(PApplet.parseFloat(ni)*0.4f);
        int tempColor = lerpColor (aColor, mixColor_j, mix);
        part.tColor =  color(tempColor, 150);
        parts.add(part);
      }
      break;
    default:
      position = startPosition;
      direction = startDirection;
      nParts = constrain (partCount, 2, 100);
      float headSize_d = partSize;
      compactness = compactnessFactor;

      // create tentacle parts
      parts = new ArrayList<TentaclePart>();
      int mixColor_d = color(random(150, 222));
      for (int ni = 0; ni < nParts; ni++) 
      {
        TentaclePart part = new TentaclePart();
        part.position = position.get();
        part.position.sub (getVector2d(PApplet.parseFloat(ni+1), direction));
        part.size = headSize_d * PApplet.parseFloat(nParts-ni) / nParts;
        float mix = 0.5f + 0.5f * sin(PApplet.parseFloat(ni)*0.4f);
        part.tColor =  lerpColor (aColor, mixColor_d, mix);
        parts.add(part);
      }
      break;
    }
  }

  //----------------------------------------------------------
  // animate tentacle
  //----------------------------------------------------------
  public void update()
  {
    PVector pos0 = parts.get(0).position;  // reference to pos 0
    PVector pos1 = parts.get(1).position;  // reference to pos 1
    pos1.set(position.get());      // set tentacle root position
    pos0.set(position.get());      // set tentacle root position
    pos1.sub(getVector2d(compactness, direction));
    //    println ("update=");
    for (int ni = 2; ni < nParts; ni++) 
    {
      PVector partPos = parts.get(ni).position;  // reference 
      PVector currentPos = partPos.get();
      PVector pos2 = parts.get(ni-2).position.get();
      PVector dist = PVector.sub(currentPos, pos2);
      float distance = dist.mag();
      PVector pos = parts.get(ni-1).position.get();
      PVector move = PVector.mult(dist, compactness);
      move.div(distance);
      //    println ("d=" + nf (distance,0,2));
      pos.add(move);
      partPos.set(pos);
    }
  }
  //----------------------------------------------------------
  // animate tentacle
  //----------------------------------------------------------
  public void update2() 
  {
    PVector pos0 = parts.get(0).position;
    PVector pos1 = parts.get(1).position;
    pos1.set(position.get());      // set tentacle root position
    pos0.set(position.get());
    pos1.x = pos0.x + ( compactness * cos( direction ) );
    pos1.y = pos0.y + ( compactness * sin( direction ) );
    for (int i = 2; i < nParts; i++) 
    {
      PVector currentPos = parts.get(i).position.get();
      PVector dist = PVector.sub( currentPos, parts.get(i-2).position.get() );
      float distmag = dist.mag();
      PVector pos = parts.get(i - 1).position.get();
      PVector move = PVector.mult(dist, compactness);
      move.div(distmag);
      pos.add(move);
      parts.get(i).position.set(pos);
    }
  }
  //----------------------------------------------------------
  // draw tentacle
  //----------------------------------------------------------
  public void draw(int a, int b)
  {
    for (int ni = nParts - 1; ni >= 0; ni--) 
    {
      TentaclePart part = parts.get(ni);
      pushMatrix();
      translate(part.position.x, part.position.y);
      noStroke();
      fill(part.tColor);
      ellipse(0, 0, part.size, part.size);
      popMatrix();
    }
  }


  public void draw() 
  {
    for (int ni = nParts - 1; ni >= 0; ni--) 
    {
      TentaclePart part = parts.get(ni);
      noStroke();
      fill(part.tColor, alphaValue);
      ellipse(part.position.x, part.position.y, part.size, part.size);
    }
  }
};

class TentaclePart 
{
  PVector position;
  float size;
  int tColor;
};
class Timer
{
  float timeSpan = TWO_PI;
  float time = 0;

  public void CheckTime()
  {
    time += TWO_PI/(frameRate*5);
    if(time > timeSpan)
      time = 0;
  }
}
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

  public void CheckTime()
  {
    time += TWO_PI/(frameRate*5);
  }
  
  
  bubble()
  {
    h = random(0.5f, 4.1f);
    h2 = random(0.5f, 4.1f);
    r = random(10, 15);
    v = random(6, 45);
    x = random(0, width);
    y = random(0, height);
    speed = random(1, 3);
    
  }
  
  public void update()
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
  
  public void draw()
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

public int SelectColor(int j, int idx)
{
  if (j==0) {
    switch(idx)
    {
    case 0:
      return color(140, 140, 140); 
    case 1:
      return color(150, 150, 150); 
    case 2:
      return color(140, 140, 140); 
    case 3:
      return color(150, 150, 150); 
    case 4:
      return color(140, 140, 140);
    }
  } else if (j==1) {
    switch(idx)
    {
    case 0:
      return color(235,238,103); 
    case 1:
      return color(235,228,93); 
    case 2:
      return color(235,218,83); 
    case 3:
      return color(235,208,73); 
    case 4:
      return color(245,208,63);
    }
  } else if (j==2) { 
    switch(idx)
    {
    case 0:
      return color(0,210,30); 
    case 1:
      return color(0,200,30); 
    case 2:
      return color(0,190,30); 
    case 3:
      return color(0,180,30); 
    case 4:
      return color(0,170,30);
    }
  } else if (j==3) {
    switch(idx)
    {
    case 0:
      return color(96,170,250); 
    case 1:
      return color(96,173,240); 
    case 2:
      return color(96,175,230); 
    case 3:
      return color(106,175,230); 
    case 4:
      return color(116,180,230);
    }
  } else if (j==4) {        
    switch(idx)
    {
    case 0:
      return color(137,110,180); 
    case 1:
      return color(147,110,170); 
    case 2:
      return color(157,110,160); 
    case 3:
      return color(167,120,160); 
    case 4:
      return color(177,130,160);
    }
  } else
  {
    return color(255, 255, 255);
  }
  return 0;
}
class point
{
 float x;
 float y;
 float radiusX;
 float radiusY;
 Contour contour;
 boolean isSet;
 
 
 point(Contour contour, float tempX, float tempY, float tempRadiusX, float tempRadiusY)
 {
   this.contour = contour;
   x = tempX;
   y = tempY;
   radiusX = tempRadiusX;
   radiusY = tempRadiusY;
   isSet = false;
 }
 
}
/* Processing Water Simulation 
* adapted by: Rodrigo Amaya
* 
* Based on "Java Water Simulation", by: Neil Wallis
* For more information visit the original article here: 
* http://neilwallis.com/projects/java/water/index.php
*
* How does it work? "2D Water"
* http://freespace.virgin.net/hugo.elias/graphics/x_water.htm
*
*/

//import processing.opengl.*;

PImage img;

int size;
int hwidth,hheight;
int riprad;

int ripplemap[];
int ripple[];
int texture[];

int oldind,newind, mapind;

int i,a,b; 


public void disturb(int dx, int dy) {
  for (int j=dy-riprad;j<dy+riprad;j++) {
    for (int k=dx-riprad;k<dx+riprad;k++) {
      if (j>=0 && j<height && k>=0 && k<width) {
      ripplemap[oldind+(j*width)+k] += 36;   //test with 512         
      } 
    }
  }
}

public void newframe() {
  //Toggle maps each frame
  i=oldind;
  oldind=newind;
  newind=i;

  i=0;
  mapind=oldind;
  for (int y=0;y<height;y++) {
    for (int x=0;x<width;x++) {
    short data = (short)((ripplemap[mapind-width]+ripplemap[mapind+width]+ripplemap[mapind-1]+ripplemap[mapind+1])>>1);
      data -= ripplemap[newind+i];
      data -= data >> 5;
      ripplemap[newind+i]=data;

    //where data=0 then still, where data>0 then wave
    data = (short)(1024-data);

      //offsets
    a=((x-hwidth)*data/1024)+hwidth;
      b=((y-hheight)*data/1024)+hheight;

     //bounds check
      if (a>=width) a=width-1;
      if (a<0) a=0;
      if (b>=height) b=height-1;
      if (b<0) b=0;

      ripple[i]=texture[a+(b*width)];
      mapind++;
    i++;
    }
  }
}

public void mouseMoved()
{
  //disturb(mouseX, mouseY);
}
  public void settings() {  size(1500, 1000);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "classAquariums" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
