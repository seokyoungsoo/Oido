class point //spawnInfo를 위한 클래스
{
 float x; //중심점
 float y;
 float radiusX; //크기
 float radiusY;
 Contour contour; //이 폐곡선을 감싸는 형태로 만든 사각형의 x, y, radiusX, radiusY이다 
 boolean isSet; //spawnInfo 한 개에 aquarium 한 개로 제한하기 위함 예를들어 3개에서 1개로 맵이 줄어드는데 3개 아쿠아리움이 이 1개의 아쿠아리움과 겹치는 상황이면 생물체들이 한쪽으로 몰려버린다
 
 
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