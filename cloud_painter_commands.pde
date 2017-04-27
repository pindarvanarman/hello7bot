  // 4- IK Geometry
  PVector j6 = new PVector(0, 100, 200);
  //PVector vec56 = new PVector(0, 0, -1);
  //PVector vec67 = new PVector(1, 0, 0);
  //PVector threeBrushVec56 = new PVector(0, 0.15, -0.5);
  //PVector threeBrushVec56 = new PVector(0, 1.2, -1);//Working Straight On
  PVector leftVec56 = new PVector(-2, 1.2, -1);
  PVector centerVec56 = new PVector(0, 1.2, -1);
  PVector rightVec56 = new PVector(1, 1.2, -1);
  PVector workingVec56 = new PVector(0, 1.2, -1);
  PVector vec67 = new PVector(0, 0, 0);
  float theta3 = 90;
  float theta4 = 90;
  float theta5 = 90;
  float theta6 = 60;
  
  float defaultBrushAngle = 90.0;

  
  
void goToStartPose() {
  //float[] angles= {90, 135, 45, 90, 90, 90, 80}; 
  float[] angles= {90, 135, 45, 90, 180, 90, 80}; 
  setServoAngles(angles);
  while(!isAllConverge){delay(1000);}
}
void goToStrokePost(float brushAngle) {
  //float[] angles= {90, 135, 45, 90, 90, 90, 80}; 
  float[] angles= {90, 120, 60, 90, 180, brushAngle, 80}; 
  setServoAngles(angles);
  while(!isAllConverge){delay(200);}
}

void goToStartSmoothStroke(PVector vec56, float brushAngle) {
  moveBrush(0.5, 0.5, 0.5, 0.5, vec56, brushAngle);
}

void paintStrokeFromXYtoXY(float fromX, float fromY, float toX, float toY, PVector vec56, float servo7) {
  smoothStroke(fromX, fromY, toX, toY, vec56, servo7, true, false, false);
}

void paintStrokeFromXYPtoXYP(float fromX, float fromY, float toX, float toY) {
    goToStartPose();
    smoothStroke(fromX, fromY, fromX, fromY, new PVector(0, 1, -1), 90, false, true, false);
    smoothStroke(fromX, fromY, toX, toY, new PVector(0, 1, -1), 90, true, false, false);
    smoothStroke(toX, toY, toX, toY, new PVector(0, 1, -1), 90, false, false, true); 
}   

void smoothStroke(float startX, float startY, float endX, float endY, PVector vec56, float brushAngle, boolean strokeOnly, boolean putBrushDown, boolean pickBrushUp) {
   int increments = (int)((Math.abs(startX-endX)/2 + Math.abs(startY-endY)/2)*40);
   if (increments < 1) {
     increments = 1;
   }
   float yAdjustment=0;
   float zAdjustment=0;
   if (putBrushDown || pickBrushUp) {
     yAdjustment = -14;
     zAdjustment = 14;
     increments  = 3;
   }
   if (strokeOnly) {
     smoothStrokeFloat(increments, getRobotX(startX,startY), getRobotY(startY), getRobotZforRobotY(startY), getRobotX(endX,startY), getRobotY(endY), getRobotZforRobotY(endY), vec56, brushAngle, theta6);
   } else if (putBrushDown) {
     smoothStrokeFloat(increments, getRobotX(startX,startY), getRobotY(startY)+yAdjustment, getRobotZforRobotY(startY)+zAdjustment, getRobotX(endX,startY), getRobotY(endY), getRobotZforRobotY(endY), vec56, brushAngle, theta6);
   } else if (pickBrushUp) {
     smoothStrokeFloat(increments, getRobotX(startX,startY), getRobotY(startY), getRobotZforRobotY(startY), getRobotX(endX,startY), getRobotY(endY)+yAdjustment, getRobotZforRobotY(endY)+zAdjustment, vec56, brushAngle, theta6);
   }
}


void moveBrush(float startX, float startY, float endX, float endY, PVector vec56, float brushAngle) {
   int zAdjustment = 40; 
   int increments = (int)((Math.abs(startX-endX)/2 + Math.abs(startY-endY)/2)*20);
   smoothStrokeFloat(increments, getRobotX(startX, startY), getRobotY(startY)-zAdjustment, getRobotZforRobotY(startY)+zAdjustment, getRobotX(endX, endY), getRobotY(endY)-zAdjustment, getRobotZforRobotY(endY)+zAdjustment, vec56, brushAngle, theta6);
}


void smoothStrokeFloat(int increments, float startX, float startY, float startZ, float endX, float endY, float endZ, PVector vec56, float brushAngle , float theta6 ) {
  int steps = increments;
  float diffX = endX-startX;
  float diffY = endY-startY;
  float diffZ = endZ-startZ;
  float stepX = diffX/steps;
  float stepY = diffY/steps;
  float stepZ = diffZ/steps; //<>//
  PVector j6 = new PVector(startX,//+getArcXAdjustment(10, startX,startY),
                           startY,//+getArcYZAdjustment(5, startX, 5),
                           startZ//+getArcYZAdjustment(9, startX, -9)
                          );
  //System.out.println(":"+steps+" : "+increments+" : "+startX+" : "+startY+" : "+startZ);  
  setIK(j6, vec56, brushAngle, theta6);
  while(!isAllConverge){delay(10);}
  for (int i=1; i<=steps; i++) {
    float nextX = startX+(stepX*i);
    float nextY = startY+(stepY*i);//+getArcYZAdjustment(5, nextX, 5);
          nextX = startX+(stepX*i);//+getArcXAdjustment(10, nextX, nextY);
    float nextZ = startZ+(stepZ*i);//+getArcYZAdjustment(9, nextX, -9);
    System.out.println(nextX+" : "+nextY+" : "+nextZ);
    j6 = new PVector(nextX, nextY , nextZ);
    setIK(j6, vec56, brushAngle, theta6);
    while(!isAllConverge){delay(1);}
  }
  j6 = new PVector(endX,//+getArcXAdjustment(10, endX, endY),
                   endY,//+getArcYZAdjustment(5, endX, 5),
                   endZ//+getArcYZAdjustment(9, endX, -9)
                          );
  setIK(j6, vec56, brushAngle, theta6);
  while(!isAllConverge){delay(10);}
}







//above middle
//157  108 67 84 180 84  60

//well 1
//172  99  114  94  132  90  57
//172  80  123 94 127 90 
void smoothStroke(int increments, int startX, int startY, int startZ, int endX, int endY, int endZ, PVector vec56, float theta5, float theta6 ) {
  int steps = increments;
  int diffX = endX-startX;
  int diffY = endY-startY;
  int diffZ = endZ-startZ;
  int stepX = diffX/steps;
  int stepY = diffY/steps;
  int stepZ = diffZ/steps;
  PVector j6 = new PVector(startX, startY, startZ);
  setIK(j6, vec56, theta5, theta6);
  while(!isAllConverge){delay(10);}
  for (int i=1; i<=steps; i++) {
    int nextX = startX+(stepX*i);
    int nextY = startY+(stepY*i);
    int nextZ = startZ+(stepZ*i);
    System.out.println(nextX+" : "+nextY+" : "+nextZ);
    j6 = new PVector(nextX, nextY , nextZ);
    setIK(j6, vec56, theta5, theta6);
    while(!isAllConverge){delay(1);}
  }
  j6 = new PVector(endX, endY, endZ);
  setIK(j6, vec56, theta5, theta6);
  while(!isAllConverge){delay(10);}
}

void smoothStroke(int increments, int startX, int startY, int startZ, int endX, int endY, int endZ, float theta3,float theta4, float theta5, float theta6 ) {
  int steps = increments;
  int diffX = endX-startX;
  int diffY = endY-startY;
  int diffZ = endZ-startZ;
  int stepX = diffX/steps;
  int stepY = diffY/steps;
  int stepZ = diffZ/steps;
  PVector j6 = new PVector(startX, startY, startZ);
  setIK(j6, theta3, theta4, theta5, theta6);
  delay(500);
  for (int i=1; i<steps; i++) {
    int nextX = startX+(stepX*i);
    int nextY = startY+(stepY*i);
    int nextZ = startZ+(stepZ*i);
    System.out.println(nextX+" : "+nextY+" : "+nextZ);
    j6 = new PVector(nextX, nextY , nextZ);
    setIK(j6, theta3, theta4, theta5, theta6);
    while(!isAllConverge){delay(10);}
  }
  j6 = new PVector(endX, endY, endZ);
  setIK(j6, theta3, theta4, theta5, theta6);
  delay(500);
}

//well 2
//162  94 111 104 140  91  55
//161  77 120  104  136  90 56

//well 3
//144 88 109  93  144 109 40
//145 71 121 108 125 139 19

//well 4
//174  73  110  94  143  131  25
//173  60  117  96  136  130  25

//well5
//162  75  109  96  137  129  27
//162  63  118  102  125  132  25

//well6
//151  72  111 103  128  180  168  
//150  60  117  104  128  169  181

//well7
//174  55 102  103  95  142  160  5
//173  47  114  91  128  166 1

//well8
//162  54  102  90  144  171  181
//163  39  110  96  153  178  175

//well 9
//154  45  100 100 148 180  162
//154  35  105  100 151  180  162