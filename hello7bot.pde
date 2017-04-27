import processing.serial.*; //<>// //<>// //<>//

Serial myPort;  
int BAUD_RATE = 115200;
int SERVO_NUM = 7;
double[] posD = new double[SERVO_NUM];
int[] force = new int[SERVO_NUM];
boolean isAllConverge = true;

//Define Geometry of Canvas for Inverse Kinematics
float MinX = -60;
float MaxX = 60;
float MinY = 160.0;
float MaxY = 300.0;
float MinZ = 70.0;
float MaxZ = 200.0;
PVector easelVec56 = new PVector(0, 1, -1);
float servo7Angle = 90;

String index = "search_index";
int startOnStrokeNumber = 0;

boolean wakeRobot = true;
boolean testRobot = true;
boolean moveRobot = false;
boolean record    = false;
boolean playback  = false;

void setup() 
{


  if (wakeRobot) {
    // Open Serial Port: Your should change PORT_ID according to your own situation. 
    // Please refer to: https://www.processing.org/reference/libraries/serial/Serial.html
    ////////////////////////////////////////////////////////////////////////
    int PORT_ID =  0;
    myPort = new Serial(this, Serial.list()[PORT_ID], BAUD_RATE); 
    System.out.println("wakingup");
    // Delay 2 seconds to wait 7Bot waking up
    delay(2000);
    ////////////////////////////////////////////////////////////////////////
    //1- change force status
    System.out.println("forcestatus:2");
    setForceStatus(2);  // change forece status to forceless 
    delay(1000);
    ////////////////////////////////////////////////////////////////////////
    // 2- speed & pose setting 
    System.out.println("forcestatus:1");
    setForceStatus(1);
    delay(1000);   // reboot 7Bot if previous status is not normal servo
    // To make motion much more stable, highly recommend you use fluency all the time.
    boolean[] fluentEnables = {true, true, true, true, true, true, true};
    int[] speeds_1 = {50, 50, 50, 200, 200, 200, 200};  
    setSpeed(fluentEnables, speeds_1); // set speed
    ////////////////////////////////////////////////////////////////////////delay(1000);
    System.out.println("awake");
  }

  if (testRobot) {
    System.out.println("go to start pose");
    goToStartPose();   
    //Paint perimeter of a canvas as defined in geometry file.
    //Values for this test are
    //     paintStrokeFromXYtoXY(startX, startY, endX, endY, vec45, servo7);
    //where:
    //     all x and y values are a percentage of cavas width and height (Min and Max X and Y as defined above)
    //     easelVec56 is canvas orientation
    //     servo7Angle is the angle of seventh servo - brush head
    System.out.println("painting perimeter of canvas");
    paintStrokeFromXYtoXY(0.0, 0.0, 0.0, 1.0, easelVec56, servo7Angle);
    paintStrokeFromXYtoXY(0.0, 1.0, 1.0, 1.0, easelVec56, servo7Angle);
    paintStrokeFromXYtoXY(1.0, 1.0, 1.0, 0.0, easelVec56, servo7Angle);
    paintStrokeFromXYtoXY(1.0, 0.0, 0.0, 0.0, easelVec56, servo7Angle);
    paintStrokeFromXYtoXY(0.0, 0.0, 0.5, 0.5, easelVec56, servo7Angle);
    goToStartPose(); //<>//
  }

  if (moveRobot) {
    System.out.println("go to start pose");
    goToStartPose();
    paint(index, startOnStrokeNumber);
    delay(1000);
    println("The End");
  }

  if (record) {
    System.out.println("go to start pose");
    goToStartPose();
    delay(1000);
    System.out.println("forcestatus:2");
    setForceStatus(2);
    delay(1000);
    recordStrokes();
  }

  if (playback) {
    System.out.println("go to start pose");
    goToStartPose();
    delay(1000);
    System.out.println("forcestatus:2");
    setForceStatus(2);
    delay(1000);
    playStrokes();
  }
}



void draw()
{
}