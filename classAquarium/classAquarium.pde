/*
  제작자: 석영수, 김경태
  버전: Processing 3.2.3
  
  사용한 라이브러리 
  - kinect4winsdk
  - opencv for processing
  - java.awt.rectangle
*/


import gab.opencv.*;
import java.awt.Rectangle;
import kinect4WinSDK.Kinect;

Kinect kinect; 

PImage bgImage;

int frameNum = 0; 
int mapFrameNum = 0; 

boolean initMap = true; 

int maxFrameRate = 30; //frameRate할당

int mapFrameRate;


int planktonDelay; //생물체가 생성되는 주기를 설정
int pollywogDelay;
int midDelay;
int jellyfishDelay;
int octopusDelay;
int starfishDelay;
int deepseafishDelay;
int standardArea;

int bubbleNum = 100; //맵에 나오는 물방울 개수 설정



Timer timer;

void setup()
{
 // kinect = new Kinect(this);  //키넥트를 사용할 때에는 이 주석을 해제해서 키넥트를 장치를 할당해주면 됩니다.

  //bgImage = loadImage("bottom_6.gif"); //배경이미지를 로드한다 -> MapManager의 CleanMap 함수 내부의 주석을 풀어야함 background를 이미지를 넣어서 호출하는 형태임
 
  imgName[0] = "test19202.png";  //테스트하는 동안 키넥트 이미지가 아닌 직접 만든 이미지 파일로 테스트 했습니다.
  imgName[1] = "test19202.png";
  imgName[2] = "test1920.png";
  imgName[3] = "test1920.png";
  imgName[4] = "test1920.png";

  mapFrameRate = 180; //맵이 갱신되는 주기

  planktonDelay = 3; //각 생물체들이 생성되는 주기 딜레이
  pollywogDelay = 6;
  midDelay = 10;
  jellyfishDelay = 15;
  octopusDelay = 23;
  starfishDelay = 8;
  deepseafishDelay = 26;
  standardArea = 40000;


  size(1176, 664); //window size 
  //size(1500, 1000);
  frameRate(maxFrameRate); // set frameRate
  smooth();
  MakeMap(); 
  initMap = false;

  /////물결 효과를 위한 부분
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
  ////물결 효과를 위한 부분
  
  for (int i = 0; i < bubbleNum; i++) //물방울을 만들어내기 위함 -> 팩토리 구조 사용
  {
    bubble b = new bubble();
    bubbles.add(b);
  }  

  timer = new Timer();
}



void draw() 
{

  CleanMap(); //프레임 마다 지워주기 위한 함수 호출

  //image(bgImage, 0, 0);
  mapFrameNum++;
  
  for (int i = 0; i < aquariums.size(); i++)
  {
    Aquarium a  = aquariums.get(i);
    a.draw();
  }

  if (mapFrameNum == mapFrameRate)
  {
    MakeMap(); //설정해놓은 맵 프레임 주기와 일치하면 다시 맵을 그려준다 -> 키넥트가 맵 정보를 갱신하는 주기 
    mapFrameNum = 0;
  }
   
   
  ///물결 효과를 위함
  loadPixels();
  texture = pixels;

  newframe();

  for (int i = 0; i < pixels.length; i++) {
    pixels[i] = ripple[i];
  }

  updatePixels();
  ///물결 효과를 위함 
  
  timer.CheckTime();
 
}


final int planktonId = 0; //생물체 id
final int pollywogId = 1;
final int midFishId    = 2;
final int jellyfishId = 3;
final int octopusId  = 4;
final int starfishId  = 5;
final int deepseafishId  = 6;
final int monstersNum = 7;


PVector zeroVector = new PVector();


final int ac_move = 0;   // 별 의미는 없다   