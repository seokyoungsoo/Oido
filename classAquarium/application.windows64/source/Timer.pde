class Timer
{
  float timeSpan = TWO_PI;
  float time = 0;

  void CheckTime()
  {
    time += TWO_PI/(frameRate*5);
    if(time > timeSpan)
      time = 0;
  }
}