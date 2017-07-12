import gab.opencv.*;
import java.awt.Rectangle;
import kinect4WinSDK.Kinect;

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

void setup()
{
  
  ////////////////
  bgImage = loadImage("bottom_6.gif"); //배경이미지를 로드한다
 
  imgName[0] = "testS.png"; //located in same folder, change randomly 
  imgName[1] = "testS.png";
  imgName[2] = "test3.png";
  imgName[3] = "test3.png";
  imgName[4] = "testS.png";

  mapFrameRate = 400; //맵이 갱신되는 주기

  planktonDelay = 1; //각 생물체들이 생성되는 주기 딜레이
  pollywogDelay = 2;
  midDelay = 2;
  jellyfishDelay = 2;
  octopusDelay = 2;
  starfishDelay = 2;
  deepseafishDelay = 3;
  standardArea = 90000;


  size(1500, 1000); //window size
  frameRate(maxFrameRate); // set frameRate
  smooth();
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



void draw() 
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