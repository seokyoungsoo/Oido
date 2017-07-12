class Tentacle //주석 생략
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
    , float startDirection      // 0 .. 2*pi (360°)
    , int partCount             // tentacle parts: 1..100
    , float partSize            // start size of 1st part 
    , float compactnessFactor   // 0.0 .. 1.0
    , color aColor
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
      color mixColor = color(random(150, 222));
      for (int ni = 0; ni < nParts; ni++) 
      {
        TentaclePart part = new TentaclePart();
        part.position = position.get();
        part.position.sub (getVector2d(float(ni+1), direction));
        part.size = headSize * float(nParts-ni) / nParts;
        float mix = 0.5 + 0.5 * sin(float(ni)*0.4);
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
      color mixColor_j = color(random(150, 222));
      for (int ni = 0; ni < nParts; ni++) 
      {
        TentaclePart part = new TentaclePart();
        part.position = position.get();
        part.position.sub (getVector2d(float(ni+1), direction));
        part.size = headSize_j * float(nParts-ni) / nParts;
        float mix = 0.5 + 0.5 * sin(float(ni)*0.4);
        color tempColor = lerpColor (aColor, mixColor_j, mix);
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
      color mixColor_d = color(random(150, 222));
      for (int ni = 0; ni < nParts; ni++) 
      {
        TentaclePart part = new TentaclePart();
        part.position = position.get();
        part.position.sub (getVector2d(float(ni+1), direction));
        part.size = headSize_d * float(nParts-ni) / nParts;
        float mix = 0.5 + 0.5 * sin(float(ni)*0.4);
        part.tColor =  lerpColor (aColor, mixColor_d, mix);
        parts.add(part);
      }
      break;
    }
  }

  //----------------------------------------------------------
  // animate tentacle
  //----------------------------------------------------------
  void update()
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
  void update2() 
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
  void draw(int a, int b)
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


  void draw() 
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
  color tColor;
};