
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


void MakeMap()
{

  if (initMap)
  {
    PImage tempImage = loadImage(imgName[int(random(0, imgName.length))]);   
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

void ChangeMap()
{

  CleanMap();
  PImage tempImage = loadImage(imgName[int(random(0, imgName.length))]);   
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

void ChangeMonsterSpawnInfo()
{

  int loopIdx = 0;
  int loopSize = aquariums.size();

  for (; loopIdx < loopSize; loopIdx++)
  {
    Aquarium b = (Aquarium)aquariums.get(loopIdx); 
    if (!CircleIncludeCheck(b)) //새롭게 갱신된 areaInfo들과 자신의 spawnInfo가 겹치지 않는다면 생물체들의 상태를 Dead로 바꿔준다.
    {
      b.isActive = false;
      for (int j = 0; j < b.creatures.size(); j++)
      {
        b.creatures.get(j).state = State.Dead;
      }
    }
  }
}

boolean CircleIncludeCheck(Aquarium b) 
{

  for (int i = 0; i < areaInfo.size(); i++)
  {
    if (overlap(b.spawnInfo, areaInfo.get(i))) //만약 맵이 겹치면 spawnInfo를 교체하는 식으로 맵 정보를 갱신한다.
    {
      float areaSize = b.spawnInfo.contour.area();
      b.spawnInfo.x = areaInfo.get(i).x;
      b.spawnInfo.y = areaInfo.get(i).y;
      b.spawnInfo.radiusX = areaInfo.get(i).radiusX;
      b.spawnInfo.radiusY = areaInfo.get(i).radiusY;
      b.spawnInfo.contour = areaInfo.get(i).contour;
      areaInfo.get(i).isSet = true; 
      b.ResetSpawnInfo(); //아쿠아리움의 생물체들의 spawnInfo를 교체해준다.

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


boolean overlap(point mySpawnInfo, point targetSpawnInfo) //AABB 충돌 검출을 통한 외부 직사각형의 겹침을 검사한다
{
  float offset = 50;
  boolean noOverlap = mySpawnInfo.x - (mySpawnInfo.radiusX - offset) > targetSpawnInfo.x + (targetSpawnInfo.radiusX - offset) ||
    targetSpawnInfo.x - (targetSpawnInfo.radiusX - offset) > mySpawnInfo.x + (mySpawnInfo.radiusX - offset)||
    mySpawnInfo.y - (mySpawnInfo.radiusY - offset)> targetSpawnInfo.y + (targetSpawnInfo.radiusY - offset) ||
    targetSpawnInfo.y - (targetSpawnInfo.radiusY - offset) > mySpawnInfo.y +( mySpawnInfo.radiusY - offset);

  return !noOverlap;
}



void CleanMap() { 
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