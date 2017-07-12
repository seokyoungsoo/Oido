class SteeringInfo //주석 생략
{
  PVector linear;
  float angular;
  SteeringInfo()
  {
    linear = new PVector(0, 0, 0);
    angular = 0;
  }
};

//----------------------------------------------------------
// the following should be in a static public class "SteeringBehavior"
// but I would then have to setup a whole new Eclipse project and I'm laaaazyy
//----------------------------------------------------------
SteeringInfo align (MotionInfo agent
                   ,MotionInfo target
                   ,float slowRadius
                   ,float targetRadius) 
{
  SteeringInfo steering = new SteeringInfo();

  float angularDirection = target.direction - agent.direction;

  angularDirection %= TWO_PI;

  if (angularDirection > PI)
    angularDirection -= TWO_PI;
  else if (angularDirection < -PI)
    angularDirection += TWO_PI;

  float angularDistance = abs(angularDirection);

  if(angularDistance < targetRadius)
  {
    agent.rotation = 0;
    steering.angular = 0;
    return steering;
  }

  float targetRotationSpeed;

  if( angularDistance < slowRadius ) 
 
    targetRotationSpeed = agent.maxAngAccel * (angularDistance / slowRadius);
  else 
    targetRotationSpeed = agent.maxAngAccel;
 


  if(angularDirection > 0) angularDirection /= angularDistance;
  float targetRotation = targetRotationSpeed * angularDirection;
  steering.angular = targetRotation - agent.rotation;

  if(steering.angular > agent.maxAngAccel) 
  {
    steering.angular /= abs(steering.angular);
    steering.angular *= agent.maxAngAccel;
  }
  return steering;
}

//----------------------------------------------------------
SteeringInfo face (MotionInfo agent
                  ,MotionInfo target
                  ,float slowRadius
                  ,float targetRadius) 
{
  PVector direction = PVector.sub(target.position, agent.position);

  MotionInfo alignTarget = new MotionInfo(random(2*PI), 1.0, 1.0, 0.2, 0.2, direction);
  alignTarget.direction = atan2(direction.y, direction.x);

  return align(agent, alignTarget, slowRadius, targetRadius);
}

float wanderOrientation = 0.0;

//----------------------------------------------------------
// wanderOffset = distance to the projected circle
// wanderRadius = circle radius
// wanderRate   = rate of direction change
//----------------------------------------------------------
SteeringInfo wander (MotionInfo agent
                    ,float wanderOffset
                    ,float wanderRadius
                    ,float wanderRate) 
{
  MotionInfo target = new MotionInfo();

  wanderOrientation += random(-1, 1) * wanderRate;
  wanderOrientation %= TWO_PI;

  if (wanderOrientation > PI)
    wanderOrientation -= TWO_PI;
  else if (wanderOrientation < -PI)
    wanderOrientation += TWO_PI;

  target.direction = agent.direction + wanderOrientation;

  PVector positionOffset = agent.getOrientationAsVector();
  positionOffset.mult(wanderOffset);

  PVector orientationOffset = target.getOrientationAsVector();
  orientationOffset.mult(wanderRadius/2);

  target.position = agent.position.get();
  target.position.add(positionOffset);
  /*
  pushMatrix();
  pushStyle();
  noFill();
  stroke(255, 0, 0);
  ellipse(target.position.x, target.position.y, wanderRadius, wanderRadius);
  */
  target.position.add(orientationOffset);
  /*
  rect(target.position.x, target.position.y, 2, 2);
  popMatrix();
  popStyle();
  */

  SteeringInfo steering = face(agent, target, PI, 0);
  steering.linear = agent.getOrientationAsVector();
  steering.linear.mult(agent.maxAccel);
  return steering;
}