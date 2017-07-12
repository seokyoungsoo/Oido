
color SelectColor(int j, int idx) //각각의 생물체 id에 맞게 색을 반환해준다.
{
  //j가 생물체의 id이고 idx는 랜덤으로 넣어주는 건데 같은 색계열 속에서 어느정도 다양성을 위해 랜덤으로 색을 할당해주기 위함
  if (j==0) { 
    switch(idx)  
    {
    case 0:
      return color(37, 36, 255); 
    case 1:
      return color(37, 36, 255); 
    case 2:
      return color(37, 36, 255); 
    case 3:
      return color(37, 36, 255); 
    case 4:
      return color(37, 36, 255);
    }
  } else if (j==1) {
    switch(idx)
    {
    case 0:
      return color(255, 148, 54); 
    case 1:
      return color(255, 148, 54); 
    case 2:
      return color(255, 148, 54); 
    case 3:
      return color(255, 148, 54); 
    case 4:
      return color(255, 148, 54);
    }
  } else if (j==2) { 
    switch(idx)
    {
    case 0:
      return color(0, 210, 30); 
    case 1:
      return color(0, 200, 30); 
    case 2:
      return color(0, 190, 30); 
    case 3:
      return color(0, 180, 30); 
    case 4:
      return color(0, 170, 30);
    }
  } else if (j==3) {
    switch(idx)
    {
    case 0:
      return color(0, 150, 141); 
    case 1:
      return color(0, 160, 141);
    case 2:
      return color(0, 140, 141);
    case 3:
      return color(0, 155, 141);
    case 4:
      return color(0, 150, 141);
    }
  } else if (j==4) {        
    switch(idx)
    {
    case 0:
      return color(137, 110, 180); 
    case 1:
      return color(147, 110, 170); 
    case 2:
      return color(157, 110, 160); 
    case 3:
      return color(167, 120, 160); 
    case 4:
      return color(177, 130, 160);
    }
  } else
  {
    return color(255, 255, 255);
  }
  return 0;
}