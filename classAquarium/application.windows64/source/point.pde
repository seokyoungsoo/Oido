class point
{
 float x;
 float y;
 float radiusX;
 float radiusY;
 Contour contour;
 boolean isSet;
 
 
 point(Contour contour, float tempX, float tempY, float tempRadiusX, float tempRadiusY)
 {
   this.contour = contour;
   x = tempX;
   y = tempY;
   radiusX = tempRadiusX;
   radiusY = tempRadiusY;
   isSet = false;
 }
 
}