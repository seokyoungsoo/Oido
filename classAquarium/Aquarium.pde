class Aquarium //검출된 영역마다 Aquarium을 하나씩 만들어준다
{

  int[] monsterLimit = new int[monstersNum]; //맵 크기 마다 생물체가 생성되는 수를 달리하기 위함
  int[] monsterLimitForRemove = new int[monstersNum]; //만약 맵 크기가 줄어들 때 거기에 맞춰서 생물체 수를 맞춰주기 위함
  int[] monsterNum = new int[monstersNum]; //생물체 수


  IntList removeMonsterId = new IntList(); 

  int monsterNumber = 0;
  float areaSize;
  boolean isActive; //아쿠아리움이 활성화 상태면 생물체를 만들어내고 아니면 안 만들어낸다
  boolean isSame = false; 

  ArrayList<Creature> creatures; //아쿠라이움의 생물체들을 전체적으로 관리하기 위한 변수
  point spawnInfo;

  Aquarium(point spawnInfo) //Constructor
  {
    this.spawnInfo = spawnInfo; //각각의 아쿠아리움은 자신의 spawnInfo(중심, 크기 등)의 정보를 가지고 있다  
    creatures = new ArrayList<Creature>(); 
    SetMonsterNumLimit();
    isActive = true;
  }

  void SetSmallerNumLimit() //맵이 작아질 때 생물체 수를 줄이는 함수
  {

    areaSize = spawnInfo.contour.area();
    int standardForNum =  int(areaSize / standardArea); //기준 면적과 자신의 면적을 비교해서 그 배율만큼 생물체 수를 설정해주는 구조이다.

    int planktonLmtNum = constrain(standardForNum * 5, 3, 15); //배율의 5배 즉 기준 면적과 자신의 면적이 2배 차이라며 10마리를 생성한다
    int pollywogLmtNum = constrain(standardForNum * 3, 2, 9);
    int midFishLmtNum = constrain(standardForNum * 1, 1, 4);
    int jellyfishLmtNum = constrain(standardForNum * 1, 1, 2);
    int octopusLmtNum = constrain(standardForNum * 1, 1, 2);
    int starfishLmtNum = constrain(standardForNum * 2, 0, 6);
    int deepseafishLmtNum = constrain(standardForNum, 0, 2);

    monsterLimitForRemove[planktonId] =  monsterNum[planktonId] - planktonLmtNum; //줄어든 맵 크기 만큼 생물체 수가 줄어야 하므로 없애야하는 생물체 수를 할당해준다
    monsterLimitForRemove[pollywogId] =  monsterNum[pollywogId] - pollywogLmtNum;
    monsterLimitForRemove[midFishId] =  monsterNum[midFishId] - midFishLmtNum;
    monsterLimitForRemove[jellyfishId] =  monsterNum[jellyfishId] - jellyfishLmtNum;
    monsterLimitForRemove[octopusId] =  monsterNum[octopusId] - octopusLmtNum;
    monsterLimitForRemove[starfishId] =  monsterNum[starfishId]; //불가사리의 경우 고착형 생물이라 맵이 줄어들 경우 전부 없애버리고 다시 그린다
    monsterLimitForRemove[deepseafishId] =  monsterNum[deepseafishId] - deepseafishLmtNum;

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

    monsterLimit[planktonId] = planktonLmtNum;
    monsterLimit[pollywogId] = pollywogLmtNum;
    monsterLimit[midFishId] = midFishLmtNum;
    monsterLimit[jellyfishId] = jellyfishLmtNum;
    monsterLimit[octopusId] = octopusLmtNum;
    monsterLimit[starfishId] = starfishLmtNum;
    monsterLimit[deepseafishId] = deepseafishLmtNum;

    for (int i = 0; i < creatures.size(); i++)  //맵 정보가 갱신될 때 생물체들의 목적지와 위치정보를 갱신해준다
    {
      Creature c = creatures.get(i);
      c.SetPrePosition();
      c.SetDestination(1);
    }
  }

  void SetMonsterNumLimit() //맵 크기가 자신과 동일하거나 크게 갱신될 때 호출되어서 생물체 제한수를 그대로 두거나 늘려준다
  {
    areaSize = spawnInfo.contour.area();
    int standardForNum =  int(areaSize / standardArea); 

    int planktonLmtNum = constrain(standardForNum * 10, 1, 30);
    int pollywogLmtNum = constrain(standardForNum * 5, 1, 15);
    int midFishLmtNum = constrain(standardForNum * 2, 1, 8);
    int jellyfishLmtNum = constrain(standardForNum * 1, 1, 3);
    int octopusLmtNum = constrain(standardForNum * 1, 1, 3);
    int starfishLmtNum = constrain(standardForNum * 2, 1, 6);
    int deepseafishLmtNum = constrain(standardForNum, 0, 2);

    print("same: "+isSame);
    if (isSame == false) //불가사리의 경우 고착형 생물이므로 맵이 커지거나 줄어들 때 전부 없애고 다시 그려주지만 맵 크기가 동일한 경우 그대로 두기 위해 isSame이라는 변수를 사용해 조절한다
    {
      float starfishLim = monsterNum[starfishId];
      for (int i = 0; i <  starfishLim; i++)
      {      
        SetDead(starfishId);
        monsterNum[starfishId]--;
      }
    } else if (isSame == true)
      isSame = false;

    monsterLimit[planktonId] = planktonLmtNum;
    monsterLimit[pollywogId] = pollywogLmtNum;
    monsterLimit[midFishId] = midFishLmtNum;
    monsterLimit[jellyfishId] = jellyfishLmtNum;
    monsterLimit[octopusId] = octopusLmtNum;
    monsterLimit[starfishId] = starfishLmtNum;
    monsterLimit[deepseafishId] = deepseafishLmtNum;
  }


  void NullCheck() //맵 정보가 갱신될 때 NullCheck로 상태가 None인 생물체들을 없애준다.
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





  void SetDead(int id) //바로 없애는 것이 아니라 Dead상태로 만들어주고 그에 따른 처리(크기와 알파값이 줄어드는 것)를 해주기 위함이다
  {
    for (int i = 0; i < creatures.size(); i++)
    {
      Creature a = creatures.get(i);
      if (a.typeId == id)
      {
        if (a.state == State.Moving||a.state == State.BirthState) 
        {
          a.state = State.Dead;
          break;
        }
      }
    }
  }



  void ResetSpawnInfo() //맵 정보가 바뀌면 생물체들의 SpawnInfo도 갱신해줘야한다. 
  {

    for (int i = 0; i < creatures.size(); i++)
    {
      Creature acreature =  creatures.get(i);
      acreature.spawnInfo = this.spawnInfo;
      // acreature.SetDestination();
    }
  }

  void draw() //draw는 단순히 생물체를 그리고 update는 방향과 회전각을 계산해준다..
  {
    for (int mi = 0; mi < creatures.size (); mi++)
    {
      Creature aCreature = creatures.get(mi); 
      aCreature.draw(); 
      aCreature.update();
    }

    addNewCreatures(); //각 생물체들의 delay시간에 따른 재생성 시간에 생물체들을 만들어준다
  }


  void redraw()
  {
    for (int mi = 0; mi < creatures.size (); mi++)
    {
      Creature aCreature = creatures.get(mi); 
      aCreature.draw();
    }
  }


  void addPlankton(PVector moveDir, point spawnInfo) //제일 작은 물고기를 생성하는 함수
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
    float size = random(4, 6);
    float speed = random (1, 1.5); 
    creatures.add (new Creature (planktonId, headColor, startPosition, moveDir, speed //생물체들의 모양을 바꾸고싶다면 tentacle count과 tentacle parts 그리고 compactness를 변경하면 된다
      , size*0.5   // Size
      , 1   // tentacle count
      , 10   // tentacle parts
      , 3*0.5   // compactness
      , 88, 33   // moving, waiting
      , 0.1, 0.3   // swing
      , spawnInfo
      , false
      , this

      ));
  }
  void addPollywog(PVector moveDir, point spawnInfo) //중간 크기의 물고기를 생성하기 위한 함수
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
    float speed = random (0.8, 1.2);
    float size = random(8, 10);
    creatures.add (new Creature (pollywogId, headColor, startPosition, moveDir, speed
      , size*0.5   // Size
      , 1   // tentacle count
      , 20   // tentacle parts
      , 3*0.5   // compactness
      , 88, 33   // moving, waiting
      , 0.1, 0.3   // swing
      , spawnInfo
      , false
      , this
      ));
  }

  void addMidfish(PVector moveDir, point spawnInfo) // 물뱀을 만들기 위한 함수
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
    float speed = random (1.5, 2.5);
    Creature snake = new Creature (midFishId, headColor, startPosition, moveDir, speed
      , 8*0.5   // Size
      , 1   // tentacle count
      , 30   // tentacle parts
      , 4*0.5   // compactness
      , 111, 33   // moving, waiting 
      , 0.5, 0.5   // swing
      , spawnInfo
      , false
      , this
      ); 
    creatures.add(snake);
    //println (" snake added");
  }

  void addJellyfish(PVector moveDir, point spawnInfo) //해파리를 만들기 위한 함수
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
    float speed = 0.3;//random (2,3);

    Creature jellyfish = new Creature (jellyfishId, headColor, startPosition, moveDir, speed
      , 10*0.5  // Size
      , 6   // tentacle count
      , 20   // tentacle parts
      , 3*0.4  // compactness
      , 10, 80   // moving, waiting
      // , 0.1, 0.05   // swing
      , 0.5, 0.03   // swing
      , spawnInfo
      , false
      , this
      );

    creatures.add(jellyfish);
    //println (" starfish added");
  }
  //----------------------------------------------------------

  void addOctopus(PVector moveDir, point spawnInfo) //문어를 만들기 위한 함수
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
    float speed = random (1.5, 2);

    Creature octopus = new Creature (octopusId, headColor, startPosition, moveDir, speed
      , 15*0.5   // Size
      , 5   // tentacle count
      , 13   // tentacle parts
      , 5*0.5   // compactness
      , 44, 66   // moving, waiting
      , 0.1, 0.2   // swing
      , spawnInfo
      , false
      , this

      ); 
    creatures.add(octopus);
    //println (" octopus added");
  }
  
  ///불가사리와 심해어는 구조를 맞추기 위해 이렇게 적어놓은것이고 실제적인 모형 구현 함수는 creature내부에 있다 밑에 코드는 의미가 없다
  void addStarfish(PVector moveDir, point spawnInfo) //불가사리를 만들기 위한 함수
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

  void addDeepSeaFish(PVector moveDir, point spawnInfo) //심해어를 만들기 위한 함수
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