int nextWell = 7;

int currentStroke = 0;
int strokeSteps = 2;

boolean firstStroke = true;
int strokesSinceLastRefill = 0;
int strokesBeforeRefill = 2;

String[] colorWellMapping = {  "#ffffff", "#dddddd", "#bbbbbb", "#999999", "#777777","#555555", "#333333", "#111111", "#xxxxxx", "#xxxxxx", "#xxxxxx", "#xxxxxx" };
int[]        brushMapping = {          3,         1,         3,         5,         3,         3,         5,        5,        3,         3,         3,         3 };





int getColorWell(String colorString) {
  for (int i=0;i<colorWellMapping.length;i++) {
    if (colorString.equals(colorWellMapping[i])) {
      return i;
    }
  }
  return 9;
}


int getBrushMapping(int colorWellMapping) {
  return brushMapping[colorWellMapping];
}

float getBrushAngle(int brush) {
 float brushAngle = 90;
  if (brush == 1) {
    brushAngle = 0;
  } else if (brush == 2) {
    brushAngle = 45;
  } else if (brush == 3) {
    brushAngle = 90;
  } else if (brush == 4) {
    brushAngle = 135;
  } else if (brush == 5) {
    brushAngle = 180;
  }
  return brushAngle;
}

float scale = 1.0;

float lasttimestamp = 0;
JSONArray colorArray = new JSONArray();
String lastColor = "#xxxxxx";
String currentColor = "";

float lastX = 0;
float lastY = 0;



PVector getBrushVector() {
  return easelVec56; //centerVec56;
}

void paintPercentage(String index, int strokesPerColor, int startStroke, int endStroke) {

  strokesBeforeRefill = strokesPerColor;
  currentStroke = startStroke;

  //arm starts at home
  if (firstStroke) {
    goToStartPose();
  }

  while (true && currentStroke <= endStroke) {
    //8:04 

    println("currentStroke " +currentStroke);
    println("currentStroke " +currentStroke);
    println("currentStroke " +currentStroke);

    //check db constantl for strokes ordered by time, after lasttimestamp
    JSONObject brushstroke = getNextBrushstroke(index, currentStroke);

    if (hasHits(brushstroke)) {
      //establish scale
      float xWidth = getPaintingWidth(brushstroke); 
      float yHeight = getPaintingHeight(brushstroke);
      //println("scales: "+xScale+" : "+yScale+" ");
      //if (xScale > yScale) {
      //  scale = xScale;  
      //  scaleRobotXCanvas(yScale/xScale);
      //} else {
      //  scale = yScale;
      //  scaleRobotXCanvas(xScale/yScale);
      //}

      println(" "+scale+" ");
      //if new stroke appears, grab it.
      //record time of strokes in global variable - save to search db or file


      lasttimestamp = getTimestamp(brushstroke);
      //check if color is current color
      currentColor = getColor(brushstroke);
      int colorWellNumber = getColorWell(currentColor);
      int brushNumber = getBrushMapping(colorWellNumber);
      //TRUE
      //CONTINUE
      //FALSE
      //check if color exists is JSONArray
      //TRUE, set current color 
      //FALSE, add to JSONArray and set currentcolor
      //Only get paint once in a while
      if (firstStroke || strokesSinceLastRefill>=strokesBeforeRefill || !currentColor.equals(lastColor)) {
        //Execute Stroke by     
        getPaint(colorWellNumber, brushNumber);
        //goOverPaints();
        //goToPaintWell(nextWell); 
       // comeFromAboveRightPaintWells();
       strokesSinceLastRefill = 0;
       goToStrokePost(getBrushAngle(brushNumber));
      }
      lastColor = currentColor;

      //Go to color well staging area
      //go above color 
      //go into color 
      //move around
      //go above color  //<>//
      //Go to color well staging area

      //Go to brush practice staging area
      //draw couple of lines
      //Go to brush practice staging area

      //go to painting staging area - 0.5 0.5 above canvas
/*
    smoothStroke(fromX, fromY, fromX, fromY, threeBrushVec56, 90, false, true, false);
    smoothStroke(fromX, fromY, toX, toY, threeBrushVec56, 90, true, false, false);
    smoothStroke(toX, toY, toX, toY, threeBrushVec56, 90, false, false, true); 
*/
      //go to startX and startY above canvas
      JSONArray path = getStrokes(brushstroke);
      JSONArray startpoint = path.getJSONArray(0);
      Float nextX = startpoint.getFloat(0)/xWidth;
      Float nextY = startpoint.getFloat(1)/yHeight;
      //println("nx "+nextX+" : "+nextY+" ");
      goToStrokePost(getBrushAngle(brushNumber));
      //moveBrush(0.5, 0.5, nextX, nextY,getBrushVector(), defaultBrushAngle);     
      smoothStroke(nextX, nextY, nextX, nextY,getBrushVector(), getBrushAngle(brushNumber), false, true, false);
      lastX = nextX;
      lastY = nextY;
      int numberOfPoints = path.size();
      println("numberPoints "+numberOfPoints+" : "+nextY+" ");
      for (int i=0; i<numberOfPoints; i++) {
        // Get a JSON Object with a list of details about the first item
        JSONArray point = path.getJSONArray(i);
        nextX = point.getFloat(0)/xWidth;
        nextY = point.getFloat(1)/yHeight;
        smoothStroke(lastX, lastY, nextX, nextY,getBrushVector(), getBrushAngle(brushNumber), true, false, false);
        lastX = nextX;
        lastY = nextY;
      }
      smoothStroke(lastX, lastY, nextX, nextY,getBrushVector(), getBrushAngle(brushNumber), false, false, true);
      goToStrokePost(getBrushAngle(brushNumber));

      //moveBrush(lastX, lastY, lastX, lastY,getBrushVector(), defaultBrushAngle);  

      //go to startX and startY
      //iterate through path until endX endY
      //go to endX and endY above canvas
      //go to painting staging area - 0.5 0.5 above canvas
      //smoothStroke(0.5,  0.5, 0.0, 1.0);
      //smoothStroke(0.0, 1.0,  1.0,  1.0);
      //smoothStroke(1.0, 1.0, 1.0,  0.0);
      //smoothStroke(1.0, 0.0, 0.0,  0.0);
      //get next strokes from DB
      firstStroke = false;
      strokesSinceLastRefill = strokesSinceLastRefill+1;
      currentStroke = currentStroke+strokeSteps;
    } else {
      delay(2000);
      goToStartPose();
    }
  }
}

int paintMapWidth = 100;
int paintMapHeight = 100;

boolean[][] paintMap = new boolean[paintMapWidth][paintMapHeight];

double nextXPercentage = 0.50;
double nextYPercentage = 0.50;

boolean getNextRandomPoint() {
  int randomX = (int)(random(0, paintMapWidth-1));
  int randomY = (int)(random(0, paintMapHeight-1));
  System.out.println("trying a: "+randomX+","+randomY);
  if (paintMap[randomX][randomY]==false) {
      paintMap[randomX][randomY] = true;
      nextXPercentage = (1.0/paintMapWidth)*(randomX);
      nextYPercentage = (1.0/paintMapHeight)*(randomY);
      return true;
  } else {
    for (int i=randomX;i<paintMapWidth;i++) {
      for (int j=0;j<paintMapHeight;j++) {
        System.out.println("trying b: "+i+","+j);
        if (paintMap[i][j]==false) {
          paintMap[i][j] = true;
          nextXPercentage = (1.0/paintMapWidth)*(i);
          nextYPercentage = (1.0/paintMapWidth)*(j);
          return true;
        }
      }
    }
    for (int i=0;i<paintMapWidth;i++) {
      for (int j=0;j<paintMapHeight;j++) {
         System.out.println("trying c: "+i+","+j);
         if (paintMap[i][j]==false) {
          paintMap[i][j] = true;
          nextXPercentage = (1.0/paintMapWidth)*(i);
          nextYPercentage = (1.0/paintMapWidth)*(j);
          return true;
        }        
      }
    }
  }
  return false;
}

void paintPercentageImitator(String index, int widthSteps, int heightSteps) {
  
  JSONObject anyDoc = getNextBrushstroke(index, 1);
   
  indexPaintingWidth  =  getPaintingWidth( anyDoc );
  indexPaintingHeight = getPaintingHeight( anyDoc );
   
  paintMapWidth = widthSteps;
  paintMapHeight = heightSteps;

  paintMap = new boolean[paintMapWidth][paintMapHeight];

  for (int i=0;i<paintMapWidth;i++) {
    for (int j=0;j<paintMapHeight;j++) {
      paintMap[i][j] = false;
    }
  }
  goToStartPose();

  while (getNextRandomPoint()) {
    println("currentStroke " +currentStroke);
    println("currentStroke " +currentStroke);
    println("currentStroke " +currentStroke);
    

    //check db constantl for strokes ordered by time, after lasttimestamp
    JSONObject brushstroke = getStrokeAtPercent(index, nextXPercentage, nextYPercentage);

    if (hasHits(brushstroke)) {
      //establish scale
      float xWidth = getPaintingWidth(brushstroke); 
      float yHeight = getPaintingHeight(brushstroke);
      lasttimestamp = getTimestamp(brushstroke);
      //check if color is current color
      currentColor = getColor(brushstroke);
      int colorWellNumber = getColorWell(currentColor);
      int brushNumber = getBrushMapping(colorWellNumber);
      if (firstStroke || strokesSinceLastRefill>strokesBeforeRefill || !currentColor.equals(lastColor)) {
        //Execute Stroke by     
        //getPaint(9, brushNumber);
        //getPaint(10, brushNumber);
        //getPaint(11, brushNumber);
        
        getPaint(colorWellNumber, brushNumber);
        //goOverPaints();
        //goToPaintWell(nextWell); 
       // comeFromAboveRightPaintWells();
       strokesSinceLastRefill = 0;
       goToStrokePost(getBrushAngle(brushNumber));
      }
      lastColor = currentColor;

      //Go to color well staging area
      //go above color 
      //go into color 
      //move around
      //go above color 
      //Go to color well staging area

      //Go to brush practice staging area
      //draw couple of lines
      //Go to brush practice staging area

      //go to painting staging area - 0.5 0.5 above canvas
/*
    smoothStroke(fromX, fromY, fromX, fromY, threeBrushVec56, 90, false, true, false);
    smoothStroke(fromX, fromY, toX, toY, threeBrushVec56, 90, true, false, false);
    smoothStroke(toX, toY, toX, toY, threeBrushVec56, 90, false, false, true); 
*/
      //go to startX and startY above canvas
      JSONArray path = getStrokes(brushstroke);
      JSONArray startpoint = path.getJSONArray(0);
      Float nextX = startpoint.getFloat(0)/xWidth;
      Float nextY = startpoint.getFloat(1)/yHeight;
      //println("nx "+nextX+" : "+nextY+" ");
      goToStrokePost(getBrushAngle(brushNumber));
      //moveBrush(0.5, 0.5, nextX, nextY,getBrushVector(), defaultBrushAngle);     
      smoothStroke(nextX, nextY, nextX, nextY,getBrushVector(), getBrushAngle(brushNumber), false, true, false);
      lastX = nextX;
      lastY = nextY;
      int numberOfPoints = path.size();
      println("numberPoints "+numberOfPoints+" : "+nextY+" ");
      for (int i=0; i<numberOfPoints; i++) {
        // Get a JSON Object with a list of details about the first item
        JSONArray point = path.getJSONArray(i);
        nextX = point.getFloat(0)/xWidth;
        nextY = point.getFloat(1)/yHeight;
        smoothStroke(lastX, lastY, nextX, nextY,getBrushVector(), getBrushAngle(brushNumber), true, false, false);
        lastX = nextX;
        lastY = nextY;
      }
      smoothStroke(lastX, lastY, nextX, nextY,getBrushVector(), getBrushAngle(brushNumber), false, false, true);
      goToStrokePost(getBrushAngle(brushNumber));

      //moveBrush(lastX, lastY, lastX, lastY,getBrushVector(), defaultBrushAngle);  

      //go to startX and startY
      //iterate through path until endX endY
      //go to endX and endY above canvas
      //go to painting staging area - 0.5 0.5 above canvas
      //smoothStroke(0.5,  0.5, 0.0, 1.0);
      //smoothStroke(0.0, 1.0,  1.0,  1.0);
      //smoothStroke(1.0, 1.0, 1.0,  0.0);
      //smoothStroke(1.0, 0.0, 0.0,  0.0);
      //get next strokes from DB
      firstStroke = false;
      strokesSinceLastRefill = strokesSinceLastRefill+1;
      currentStroke = currentStroke+strokeSteps;
    } else {
      delay(500);
      goToStartPose();
    }
  }
}



//input - painting index name / optional lasttimestamp
void paint(String index, int startStroke) {
  currentStroke = startStroke;

  //arm starts at home
  if (firstStroke) {
    goToStartPose();
    firstStroke = false;
  }

  while (true) {
    //8:04 

    println("currentStroke " +currentStroke);
    println("currentStroke " +currentStroke);
    println("currentStroke " +currentStroke);

    //check db constantl for strokes ordered by time, after lasttimestamp
    JSONObject brushstroke = getNextBrushstroke(index, currentStroke);

    if (hasHits(brushstroke)) {
      //establish scale
      float xWidth = getPaintingWidth(brushstroke); 
      float yHeight = getPaintingHeight(brushstroke);

      lasttimestamp = getTimestamp(brushstroke);
      //check if color is current color
      //TRUE
      //CONTINUE
      //FALSE
      //check if color exists is JSONArray
      //TRUE, set current color 
      //FALSE, add to JSONArray and set currentcolor
      //Only get paint once in a while
      if (firstStroke || currentStroke%strokesBeforeRefill == 0) {
        //Execute Stroke by     

        getPaint(1,3);
        //goToPaintWell(nextWell); 
       // comeFromAboveRightPaintWells();
        goToStartSmoothStroke(getBrushVector(), 90);
        nextWell++;
        if (nextWell>9) {
          nextWell = 1;
        }
      }


      //Go to color well staging area
      //go above color 
      //go into color 
      //move around
      //go above color  //<>// //<>//
      //Go to color well staging area

      //Go to brush practice staging area
      //draw couple of lines
      //Go to brush practice staging area

      //go to painting staging area - 0.5 0.5 above canvas

      //go to startX and startY above canvas
      JSONArray path = getStrokes(brushstroke);
      JSONArray startpoint = path.getJSONArray(0);
      Float nextX = startpoint.getFloat(0)/xWidth;
      Float nextY = startpoint.getFloat(1)/yHeight;
      //println("nx "+nextX+" : "+nextY+" ");
      moveBrush(0.5, 0.5, nextX, nextY,getBrushVector(), defaultBrushAngle);     
      smoothStroke(nextX, nextY, nextX, nextY,getBrushVector(), defaultBrushAngle, true, false, false);
      lastX = nextX;
      lastY = nextY;
      int numberOfPoints = path.size();
      println("numberPoints "+numberOfPoints+" : "+nextY+" ");
      for (int i=0; i<numberOfPoints; i++) {
        // Get a JSON Object with a list of details about the first item
        JSONArray point = path.getJSONArray(i);
        nextX = point.getFloat(0)/xWidth;
        nextY = point.getFloat(1)/yHeight;
        smoothStroke(lastX, lastY, nextX, nextY,getBrushVector(), defaultBrushAngle, true, false, false);
        lastX = nextX;
        lastY = nextY;
      }
      moveBrush(lastX, lastY, lastX, lastY,getBrushVector(), defaultBrushAngle);  

      //go to startX and startY
      //iterate through path until endX endY
      //go to endX and endY above canvas
      //go to painting staging area - 0.5 0.5 above canvas
      //smoothStroke(0.5,  0.5, 0.0, 1.0);
      //smoothStroke(0.0, 1.0,  1.0,  1.0);
      //smoothStroke(1.0, 1.0, 1.0,  0.0);
      //smoothStroke(1.0, 0.0, 0.0,  0.0);
      //get next strokes from DB
      currentStroke = currentStroke+1;
    } else {
      delay(2000);
      goToStartPose();
    }
  }
}


void getPaint(int colorWell, int brush) {
  goToStartPose();
  delay(1000);
  goOverPaints(colorWell);
  delay(500);
  dipTheBrush(colorWell, brush);
  delay(500);
  goOverPaints(colorWell);
  delay(500);
  goToStartPose();
  delay(1000);
}

void goOverPaints(int colorWellNumber) {

  if (colorWellNumber<=5) {
    float[] angles= {154, 140, 63, 92, 180, 90, 56}; 
    setServoAngles(angles);
    while (!isAllConverge) {
      delay(500);
    }
  } else {
      float[] angles= {26, 140, 63, 92, 180, 90, 56}; 
    setServoAngles(angles);
    while (!isAllConverge) {
      delay(500);
    }
  }
}

void colorCommand(int action, int colorWell, int brush) {

  float brushAngle = getBrushAngle(brush);
  
    float[] overW = new float[7];
    float[] rightAboveW  = new float[7]; 
    float[] rightAboveLiftedW  = new float[7]; 
    float[] rightAboveShakeW  = new float[7]; 
    float[] inW = new float[7];
    
  if (colorWell == 0) {
    float[] over       = {170, 140, 63, 92, 180, brushAngle, 56}; 
    float[] rightAbove = {173, 135, 92, 92, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {173, 138, 87, 92, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {173, 138, 87, 92, 170, brushAngle, 56 }; 
    float[] in         = {173, 115, 103, 92, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 1) {
    float[] over       = {155, 140, 63, 92, 180, brushAngle, 56}; 
    float[] rightAbove = {156, 130, 93, 92, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {156, 130, 93, 92, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {156, 130, 93, 92, 170, brushAngle, 56 }; 
    float[] in         = {156, 115, 104, 95, 180, brushAngle, 56 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 2) {
    float[] over       = {141, 114, 64, 92, 180, brushAngle, 56}; 
    float[] rightAbove = {141, 106, 99, 91, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {141, 106, 99, 91, 90, brushAngle, 56 }; 
    float[] rightAboveShake =  {141, 106, 99, 91, 170, brushAngle, 56 }; 
    float[] in         = {141, 99, 107, 93, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 3) {
    float[] over       = {173, 135, 65, 92, 180, brushAngle, 56};
    //float[] rightAbove = {173, 138, 87, 92, 180, brushAngle, 56 }; 
    float[] rightAbove =   {173, 99,  97, 90, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {173, 99,  97, 90, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {173, 112,  97, 90, 170, brushAngle, 56 }; 
    float[] in         =   {173, 90, 107, 90, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 4) {  
    float[] over       = {155, 140, 63, 92, 180, brushAngle, 56};
    //float[] rightAbove = {173, 138, 87, 92, 180, brushAngle, 56 }; 
    float[] rightAbove =   {158, 100, 97, 90, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = { 158, 100, 97, 90, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {158, 112, 97, 90, 170, brushAngle, 56 }; 
    float[] in         = {158, 88, 106, 90, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 5) {
    float[] over       = {147, 140, 63, 92, 180, brushAngle, 56};
    //float[] rightAbove = {173, 138, 87, 92, 180, brushAngle, 56 }; 
    float[] rightAbove =   {146, 92, 96, 90, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {146, 92, 96, 90, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {146, 104, 96, 90, 170, brushAngle, 56 }; 
    float[] in         = {146, 77, 105, 90, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 6) {
    float[] over       = {3, 140, 63, 92, 180, brushAngle, 56}; 
    float[] rightAbove = {3, 135, 92, 92, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {3, 138, 87, 92, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {3, 138, 87, 92, 170, brushAngle, 56 }; 
    float[] in         = {3, 115, 103, 92, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 7) {
    float[] over       = {21, 140, 63, 92, 180, brushAngle, 56}; 
    float[] rightAbove = {20, 125, 93, 92, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {20, 125, 93, 92, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {20, 125, 93, 92, 170, brushAngle, 56 }; 
    float[] in         = {20, 115, 104, 95, 180, brushAngle, 56 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 8) {
    float[] over       = {33, 125, 64, 92, 180, brushAngle, 56}; 
    float[] rightAbove = {33, 116, 94, 91, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {33, 116, 94, 91, 90, brushAngle, 56 }; 
    float[] rightAboveShake =  {33, 116, 94, 91, 170, brushAngle, 56 }; 
    float[] in         = {32, 99, 107, 93, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 9) {
    float[] over       = {3, 135, 65, 92, 180, brushAngle, 56};
    //float[] rightAbove = {173, 138, 87, 92, 180, brushAngle, 56 }; 
    float[] rightAbove =   {3, 99,  97, 90, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {3, 99,  97, 90, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {3, 112,  97, 90, 170, brushAngle, 56 }; 
    float[] in         =   {3, 90, 107, 90, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 10) {  
    float[] over       = {17, 140, 63, 92, 180, brushAngle, 56};
    //float[] rightAbove = {173, 138, 87, 92, 180, brushAngle, 56 }; 
    float[] rightAbove =   {14, 100, 97, 90, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = { 14, 100, 97, 90, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {14, 112, 97, 90, 170, brushAngle, 56 }; 
    float[] in         = {14, 88, 106, 90, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  } else if (colorWell == 11) {
    float[] over       = {25, 140, 63, 92, 180, brushAngle, 56};
    //float[] rightAbove = {173, 138, 87, 92, 180, brushAngle, 56 }; 
    float[] rightAbove =   {25, 92, 96, 90, 180, brushAngle, 56 }; 
    float[] rightAboveLifted = {25, 92, 96, 90, 90, brushAngle, 56 }; 
    float[] rightAboveShake = {25, 104, 96, 90, 170, brushAngle, 56 }; 
    float[] in         = {25, 77, 105, 90, 180, brushAngle, 55 }; 
    overW = over;
    rightAboveW = rightAbove;
    rightAboveLiftedW = rightAboveLifted;
    rightAboveShakeW = rightAboveShake;
    inW = in;
  }
  
  if (action == 1) {
    goCommand(overW, 500);
  } else if (action == 2) {
    goCommand(rightAboveW, 500);
  } else if (action == 3) {
    goCommand(inW, 500);
  } else if (action == 4) {
    goCommand(rightAboveLiftedW, 500);
  } else if (action == 5) {
    goCommand(rightAboveShakeW, 200);
  }
}

void goCommand(float[] go, int delayMS) {
    setServoAngles(go);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    delay(delayMS);
}

void dipTheBrush(int colorWell, int brush) {
  colorCommand( 1, colorWell, brush);
  colorCommand( 2, colorWell, brush);
  colorCommand( 3, colorWell, brush);
  //colorCommand( 2, colorWell, brush);
  //colorCommand( 3, colorWell, brush);
  colorCommand( 1, colorWell, brush);
}

void mixPaint(int colorWell1, int brush1, int colorWell2, int brush2, int destWell) {
  colorCommand( 1, colorWell1, brush1);
  colorCommand( 2, colorWell1, brush1);
  colorCommand( 3, colorWell1, brush1);
  colorCommand( 2, colorWell1, brush1);
  colorCommand( 4, colorWell1, brush1);
  colorCommand( 4, destWell, brush1);
  for (int i=0; i<1; i++) {
    colorCommand( 2, destWell, brush1);
    colorCommand( 3, destWell, brush1);
    colorCommand( 5, destWell, brush1);
  }
  colorCommand( 4, destWell, brush1);
  colorCommand( 4, destWell, brush2);
  colorCommand( 1, colorWell2, brush2);
  colorCommand( 2, colorWell2, brush2);
  colorCommand( 3, colorWell2, brush2);
  colorCommand( 2, colorWell2, brush2);
  colorCommand( 4, colorWell2, brush2);
  colorCommand( 4, destWell, brush2);
  for (int i=0; i<1; i++) {
    colorCommand( 2, destWell, brush2);
    colorCommand( 3, destWell, brush2);
    colorCommand( 5, destWell, brush2);
  }

}



void mixSingleWell() {
    float[] over       = {170, 140, 63, 92, 180, 90, 56}; 
    float[] rightAbove = {173, 135, 92, 92, 180, 90, 56 }; 
    float[] rightAboveLifted = {173, 138, 87, 92, 90, 90, 56 }; 
    float[] rightAboveShake = {173, 138, 87, 92, 170, 90, 56 }; 
    float[] in         = {173, 115, 103, 92, 180, 90, 55 }; 
    float[] inA         = {166, 120, 103, 92, 178, 90, 55 }; 
    float[] inB         = {166, 112, 103, 92, 180, 90, 55 }; 
    float[] inC         = {176, 112, 103, 92, 178, 90, 55 }; 
    float[] inD         = {176, 120, 103, 92, 180, 90, 55 }; 
    int delayMS = 100;
    setServoAngles(over);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    setServoAngles(rightAbove);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    setServoAngles(in);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    for (int i=0;i<200;i++) {
        setServoAngles(inA);
        while (!isAllConverge) {
          println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
          delay(delayMS);
        }
        setServoAngles(inB);
        while (!isAllConverge) {
          println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
          delay(delayMS);
        }
        setServoAngles(inC);
        while (!isAllConverge) {
          println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
          delay(delayMS);
        }
        setServoAngles(inD);
        while (!isAllConverge) {
          println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
          delay(delayMS);
        }
        setServoAngles(rightAbove);
        while (!isAllConverge) {
          println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
          delay(delayMS);
        }   
        setServoAngles(in);
        while (!isAllConverge) {
          println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
          delay(delayMS);
        }
    }
}

void dipTheBrush(float[] over, float[] rightAbove, float[] in, int delayMS) {
    setServoAngles(over);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    delay(delayMS);

    setServoAngles(rightAbove);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    delay(delayMS);

    setServoAngles(in);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    delay(delayMS);

    setServoAngles(rightAbove);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    delay(delayMS);

    setServoAngles(in);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    delay(delayMS);
    setServoAngles(rightAbove);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    delay(delayMS);

    setServoAngles(over);
    while (!isAllConverge) {
      println("Detect Poses: " + posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
      delay(delayMS);
    }
    delay(delayMS);
}