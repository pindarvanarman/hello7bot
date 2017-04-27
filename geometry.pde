




float convertCmToMm(float cm) {
  float mm = cm*10;
  return mm;
}

//input is number between 0 and 1
float getRobotX(float xPercentage, float yPercentage) {
  float xRange = MaxX-MinX;
  float distFromCenter = Math.abs((0.5-xPercentage));
  float adjustment = yPercentage*30*distFromCenter;
  if(xPercentage>=0.5) {
    adjustment = -adjustment;
  }
  
  return MaxX-(xRange*xPercentage)+adjustment;
}

//input is number between 0 and 1
float getRobotY(float yPercentage) {
  float yRange = MaxY-MinY;
  return MinY+(yRange*yPercentage);
}

//input is y - returns z needed for that y to touch canvas
float getRobotZforRobotY(float yPercentage) {
  float zRange = MaxZ-MinZ;
  return MinZ+(zRange*yPercentage);
}


//Higher Y IS FROM Bottom / MORE X NEEDs TO BOW OUTWARDS
float getArcXAdjustment(float xAdjustment, float x, float y) {
  //-100   100
  float sign = 1;
  if (x<0) {
    sign = -1;
  }
  
  float maxY = MaxY-MinY;
  float normalizedY = y-MinY;
  float distFromBottomYPercentage = normalizedY/maxY;
  //you want z a little lower
  return sign*(xAdjustment*distFromBottomYPercentage); //18 for z and 10 for y
}
 //<>// //<>//
//FURTHER OUT X IS FROM CENTER / MORE Y AND Z NEED TO BE CLOSER TO CANVAS
float getArcYZAdjustment(float yAdjustment, float x, float adjustment) {
  //-100   100
  float range = abs(MinX)+abs(MaxX);
  float midPoint = range/2; //100
  float distFromCenterXPercentage = abs(x/midPoint);
  //you want z a little lower
  return ((0*yAdjustment)*distFromCenterXPercentage)+(distFromCenterXPercentage*(0*adjustment)); //18 for z and 10 for y
}