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
    maxSpeed = 0.1;
    maxAccel = 1.0;
    maxAngSpeed = 0.0;
    maxAngAccel = 0.0;
    position = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    direction = random (0, TWO_PI);
    rotation = 0.0;
   
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
    rotation = 0.0;
  }
  //----------------------------------------------------------
  // get current move direction
  //----------------------------------------------------------
  PVector getOrientationAsVector() 
  {
    return new PVector(cos(direction), sin(direction), 0.0);
  }
  //----------------------------------------------------------
  // set move direction
  //----------------------------------------------------------
  void setDirection2d (float directionAngle) 
  {
    moveDirection = PVector.fromAngle (directionAngle % TWO_PI); 
//    println (" motion.setDirection2d: " + nf(degrees(directionAngle),0,2) + "°   " );
  }
  //----------------------------------------------------------
  // change move direction
  //----------------------------------------------------------
  void turn2d (float angle) 
  {
//    println (" motion.turn2d: " + nf(degrees(angle),0,2) + "°");
    setDirection2d (moveDirection.heading() + angle);
  }
  //----------------------------------------------------------
  // execute motion
  //----------------------------------------------------------
  void update(PVector move, float angular) 
  {
//    println (" motion.update: " + move + "   "+nf(degrees(angular),0,2) + "°");
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