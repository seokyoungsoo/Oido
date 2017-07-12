
String[] imgName = new String[5]; //테스트를 위한 이미지 이름을 담고 있다

point tempPoint;
PImage originImage, dst;
OpenCV opencv;
ArrayList<Contour> contours;
ArrayList<Contour> polygons;
ArrayList<point> areaInfo = new ArrayList<point>();
ArrayList<Aquarium> aquariums = new ArrayList<Aquarium>();
ArrayList<bubble> bubbles = new ArrayList<bubble>();

int preMonSize = 0;

public PImage getReversePImage( PImage image ) {
  PImage reverse = new PImage( image.width, image.height );
  for ( int i=0; i < image.width; i++ ) {
    for (int j=0; j < image.height; j++) {
      reverse.set( image.width - 1 - i, j, image.get(i, j) );
    }
  }
  return reverse;
}

void MakeMap()
{

  if (initMap) //처음 맵을 만들 때에는 기존에 있던 맵들과 비교할 필요가 없다 따라서 분기시켰다.
  {
    PImage tempImage = loadImage(imgName[int(random(0, imgName.length))]);  //테스르를 할 때에는 imgName배열에 담아놓은 5개의 이미지 중 랜덤으로 불러오게 했다
    //PImage tempImage =  kinect.GetImage();  //키넥트를 쓸 때에는 키넥트에서 이미지를 가져온다

    tempImage = getReversePImage(tempImage); //키넥트의 이미지는 좌우가 반전되어 있으므로 다시 반전시켜준다
    // tempImage = tempImage.get(0, 0, 320, 240); //현장에서 설치할 경우 키넥트에 이미지가 딱 들어오게 설치할 수가 없다 따라서 들어온 이미지에서 필요없는 부분은 없애버려야한다. 현장 설치의 경우 이 변수를 손봐야한다
    // 키넥트의 이미지는 640, 480으로 들어오는데 그 중에 모래가 설치된 부분만 화면에 잡혀야한다. 따라서 0, 0을 모래가 시작되는 좌상단 픽셀 좌표로 잡아주고 320, 240을 width와 height를 넣어주면 된다
    tempImage.resize(1176, 664); //잘라낸 이미지를 우리가 출력할 화면 해상도인 1176, 664로 늘려준다. 준비한 모니터에 좌우 1cm가량 여백이 생기지만 부하가 걸려서 해상도를 낮췄다.
    opencv = new OpenCV(this, tempImage); //키넥트로 불러온 이미지를 opencv작업을 위해 할당해준다
    opencv.gray(); //grayscale로 바꾼다 
    opencv.threshold(200); //임계점을 설정해준다. 이 변수를 낮추면 밝기가 적더라도 남겨놓는다 적절한 값을 넣어줘야 모래가 있는 부분과 아닌 부분을 구분할 수 있다. 특히나 손의 경우 모래로 인식하게 만드는게 적합하므로 threshold를 200정도로 높게 잡았다
    contours = opencv.findContours(); //contour 즉 모래가 아닌 부분들을 폐곡선 형태로 잡아낸다.

    for (Contour contour : contours) 
    {
      if (contour.area() > 30000) //모래 영역이 적어도 30000은 넘어야 아쿠아리움이 만들어지도록 했다. 너무 작으면 이곳저곳 중구난방하게 생길 수 있으니 조절을 잘해야한다.->너무 많으면 부하가 걸린다
      {
        fill(255); 
        Rectangle rects = contour.getBoundingBox(); //만들어진 contour의 형태를 감싸는 사각형을 하나 만든다. -> 중심점을 찾기 위함
        tempPoint = new point(contour, rects.x + rects.width/2, rects.y + rects.height/2, rects.width/2, rects.height/2); //tempPoint에 중심점과 가로 세로 길이를 할당해준다 후에 이것들이 spawnInfo가 된다

        areaInfo.add(tempPoint); //areaInfo배열에 각각 담아준다
      }
    }

    for (int i = 0; i < areaInfo.size(); i++)
    {
      aquariums.add(new Aquarium(areaInfo.get(i))); //areaInfo에 담긴 spawnInfo들을 아쿠아리움 생성자에 넣어서 각각의 위치에 아쿠아리움을 만들어준다.
    }
  } else //초기 맵이 아니라면 그 전의 맵들과 비교를 해야하므로 분기함
  {
    ChangeMap();
  }

  print("aquaNum: "+aquariums.size());
}

void ChangeMap()
{

  CleanMap();
  
  ///MakeMap과 동일
  PImage tempImage = loadImage(imgName[int(random(0, imgName.length))]);  
  //PImage tempImage =  kinect.GetImage(); 
  //tempImage = tempImage.get(160, 120, 320, 240);
  tempImage.resize(1176, 664);
  tempImage = getReversePImage(tempImage);


  opencv = new OpenCV(this, tempImage); 
  opencv.gray();
  opencv.threshold(200); 
  contours = opencv.findContours();  

  for (int i = 0; i < aquariums.size(); i++) 
  {
    Aquarium a  = aquariums.get(i);
    a.redraw();
  }

  areaInfo.clear();  

  for (Contour contour : contours)
  {
    if (contour.area() > 30000)
    {
      fill(255); 
      Rectangle rects = contour.getBoundingBox();
      tempPoint = new point(contour, rects.x + rects.width/2, rects.y + rects.height/2, rects.width/2, rects.height/2);

      areaInfo.add(tempPoint);
    }
  }  


  ChangeMonsterSpawnInfo(); //기존에 있던 맵들과 비교를 하기 위함 -> 자신과 겹쳐지면 그쪽으로 생물체들이 이동하고 겹쳐지는 맵이 없다면 아쿠아리움을 없애버린다. 

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
      b.isActive = false; //더 이상 생물체들을 생성하지 못하게 한다
      for (int j = 0; j < b.creatures.size(); j++)
      {
        b.creatures.get(j).state = State.Dead;
      }
    }
  }
}

boolean CircleIncludeCheck(Aquarium b) // 겹쳐지는지 검사하기 위함 
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
      if (areaSize > b.spawnInfo.contour.area()) //자신보다 작은 맵으로 바뀌는 것이라면 생물체 수를 줄여야하므로 
      {
        b.SetSmallerNumLimit();
      } else //자신과 같거나 큰 맵이라면 생물체 수를 줄일 필요없이 제한수만 늘려주면 된다
      {
        if (areaSize-10 <areaInfo.get(i).contour.area() && areaInfo.get(i).contour.area() < areaSize+10) //바뀌는 맵이 자신과 차이가 거의 없다면 isSame을 true로 하여 불가사리가 그대로 남아있도록 만든다.
          b.isSame = true;
        else
          b.isSame = false;

        b.SetMonsterNumLimit();
      }
      b.NullCheck(); //상태가 None인 생물체들을 없애준다

      return true;
    }
  }
  return false; //겹쳐지지 않으면 false를 반환
}


boolean overlap(point mySpawnInfo, point targetSpawnInfo) //AABB 충돌 검출을 통한 외부 직사각형의 겹침을 검사한다
{
  if (targetSpawnInfo.isSet == true)
    return false;

  float offset = 1;
  boolean noOverlap = mySpawnInfo.x - (mySpawnInfo.radiusX *offset) > targetSpawnInfo.x + (targetSpawnInfo.radiusX *offset) ||
    targetSpawnInfo.x - (targetSpawnInfo.radiusX *offset) > mySpawnInfo.x + (mySpawnInfo.radiusX *offset)||
    mySpawnInfo.y - (mySpawnInfo.radiusY *offset)> targetSpawnInfo.y + (targetSpawnInfo.radiusY *offset) ||
    targetSpawnInfo.y - (targetSpawnInfo.radiusY *offset) > mySpawnInfo.y +( mySpawnInfo.radiusY *offset);

  return !noOverlap;
}



void CleanMap() { 
  fill(0, 200, 200); 
  rect(0, 0, width, height);

  //bgImage.resize(1176, 664); //배경이미지를 넣고싶다면 이 두 주석을 풀고 위의 두 구문을 주석처리하면 된다
  //background(bgImage);

  for (int i = 0; i < bubbleNum; i++) //물방울 그리기 위함
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

  for (int i = 0; i < areaInfo.size(); i++) //테스트하는 동안 영역을 보기 위해 그려준 것 후에 전시할 때에는 이 for문을 주석처리해야함
  {
    fill(255);
    Contour tempContour = areaInfo.get(i).contour;
    tempContour.draw();
  }
}