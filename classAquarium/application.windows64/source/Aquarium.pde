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

  void SetSmallerNumLimit() //맵이 작아질 때 생물체 수를 줄이는 함수
  {
    areaSize = spawnInfo.contour.area();
    int standardForNum =  int(areaSize / standardArea);

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


  void NullCheck()
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





  void SetDead(int id)
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

  void SetMonsterNumLimit()
  {
    areaSize = spawnInfo.contour.area();
    int standardForNum =  int(areaSize / standardArea);

    monsterLimit[planktonId] = standardForNum * 10;
    monsterLimit[pollywogId] = standardForNum * 5;
    monsterLimit[midFishId] = standardForNum * 3;
    monsterLimit[jellyfishId] = standardForNum * 2;
    monsterLimit[octopusId] = standardForNum * 2;
    monsterLimit[starfishId] = standardForNum * 2;
    monsterLimit[deepseafishId] = standardForNum;
  }

  void ResetSpawnInfo()
  {

    for (int i = 0; i < creatures.size(); i++)
    {
      Creature acreature =  creatures.get(i);
      acreature.spawnInfo = this.spawnInfo;
      acreature.SetDestination();
    }
  }

  void draw()
  {
    for (int mi = 0; mi < creatures.size (); mi++)
    {
      Creature aCreature = creatures.get(mi); 
      aCreature.draw(); 
      aCreature.update();
    }

    addNewCreatures();
  }


  void redraw()
  {
    for (int mi = 0; mi < creatures.size (); mi++)
    {
      Creature aCreature = creatures.get(mi); 
      aCreature.draw();
    }
  }


  void addPlankton(PVector moveDir, point spawnInfo)
  {
    monsterNum[planktonId]++;
    monsterNumber++;
    int px = int(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = int(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    PVector startPosition;
    if (px > 0.0)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    color headColor = SelectColor(planktonId, int(random(0, 5)));
    float speed = random (2, 4);
    creatures.add (new Creature (planktonId, headColor, startPosition, moveDir, speed
      , 6   // Size
      , 1   // tentacle count
      , 10   // tentacle parts
      , 3   // compactness
      , 88, 33   // moving, waiting
      , 0.1, 0.3   // swing
      , spawnInfo
      , false
      , this

      ));
  }
  //----------------------------------------------------------
  void addPollywog(PVector moveDir, point spawnInfo)
  {
    monsterNum[pollywogId]++;
    monsterNumber++;
    int px = int(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = int(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    PVector startPosition;
    if (px > 0.0)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    color headColor = SelectColor(pollywogId, int(random(0, 5)));
    float speed = random (2, 4);
    creatures.add (new Creature (pollywogId, headColor, startPosition, moveDir, speed
      , 10   // Size
      , 1   // tentacle count
      , 20   // tentacle parts
      , 3   // compactness
      , 88, 33   // moving, waiting
      , 0.1, 0.3   // swing
      , spawnInfo
      , false
      , this
      ));
  }

  void addMidfish(PVector moveDir, point spawnInfo)
  {

    monsterNum[midFishId]++;
    monsterNumber++;
    int px = int(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = int(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    PVector startPosition;
    if (px > 0.0)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    color headColor = SelectColor(midFishId, int(random(0, 5)));
    float speed = random (3.0, 4.5);
    Creature snake = new Creature (midFishId, headColor, startPosition, moveDir, speed
      , 8   // Size
      , 1   // tentacle count
      , 30   // tentacle parts
      , 4   // compactness
      , 111, 33   // moving, waiting 
      , 0.5, 0.5   // swing
      , spawnInfo
      , false
      , this
      ); 
    creatures.add(snake);
    //println (" snake added");
  }
  //----------------------------------------------------------
  void addJellyfish(PVector moveDir, point spawnInfo)
  {
    monsterNum[jellyfishId]++;
    monsterNumber++;
    int px = int(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = int(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    PVector startPosition;
    if (px > 0.0)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    color headColor = SelectColor(jellyfishId, int(random(0, 5)));
    float speed = 1;//random (2,3);

    Creature jellyfish = new Creature (jellyfishId, headColor, startPosition, moveDir, speed
      , 10  // Size
      , 5   // tentacle count
      , 20   // tentacle parts
      , 3  // compactness
      , 10, 80   // moving, waiting
      // , 0.1, 0.05   // swing
      , 0.5, 0.01   // swing
      , spawnInfo
      , false
      , this
      );

    creatures.add(jellyfish);
    //println (" starfish added");
  }
  //----------------------------------------------------------

  void addOctopus(PVector moveDir, point spawnInfo)
  {
    monsterNum[octopusId]++;
    monsterNumber++;
    PVector startPosition;
    int px = int(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = int(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    if (px > 0.0)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    color headColor = SelectColor(octopusId, int(random(0, 5)));
    float speed = random (3.0, 4.0);

    Creature octopus = new Creature (octopusId, headColor, startPosition, moveDir, speed
      , 15   // Size
      , 5   // tentacle count
      , 13   // tentacle parts
      , 5   // compactness
      , 44, 66   // moving, waiting
      , 0.1, 0.2   // swing
      , spawnInfo
      , false
      , this

      ); 
    creatures.add(octopus);
    //println (" octopus added");
  }

  void addStarfish(PVector moveDir, point spawnInfo)
  {
    monsterNum[starfishId]++;
    monsterNumber++;
    PVector startPosition;
    int px = int(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = int(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    if (px > 0.0)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    color headColor = SelectColor(starfishId, int(random(0, 5)));
    float speed = random (3.0, 4.0);

    Creature starfish = new Creature (starfishId, headColor, startPosition, moveDir, speed
      , 15   // Size
      , 10   // tentacle count
      , 10   // tentacle parts
      , 3   // compactness
      , 44, 66   // moving, waiting
      , 0.1, 0.5   // swing
      , spawnInfo
      , true
      , this
      ); 
    creatures.add(starfish);
  }

  void addDeepSeaFish(PVector moveDir, point spawnInfo)
  {
    monsterNum[deepseafishId]++;
    monsterNumber++;
    PVector startPosition;
    int px = int(spawnInfo.x + random(-spawnInfo.radiusX +50, spawnInfo.radiusX -50));
    int py = int(spawnInfo.y + random(-spawnInfo.radiusY +50, spawnInfo.radiusY -50));

    if (px > 0.0)
      startPosition = new PVector(px, py);  
    else startPosition = new PVector(random(40, width-40), random(40, height-40));

    color headColor = SelectColor(deepseafishId, int(random(0, 5)));
    float speed = 10;

    Creature deepseafish = new Creature (deepseafishId, headColor, startPosition, moveDir, speed
      , 15   // Size
      , 6   // tentacle count
      , 18   // tentacle parts
      , 5   // compactness
      , 44, 66   // moving, waiting
      , 0.1, 0.5   // swing
      , spawnInfo
      , true
      , this
      ); 
    creatures.add(deepseafish);
  }






  //----------------------------------------------------------
  void addNewCreatures ()
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