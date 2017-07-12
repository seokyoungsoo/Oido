
color SelectColor(int j, int idx)
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