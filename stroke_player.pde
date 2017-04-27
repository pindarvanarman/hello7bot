
void playStrokes() {
  ////////////////////////////////////////////////////////////////////////
  // 2- speed & pose setting 
  setForceStatus(1);  delay(2000);   // reboot 7Bot if previous status is not normal servo
  // To make motion much more stable, highly recommend you use fluency all the time.
  boolean[] fluentEnables = {true, true, true, true, true, true, true};
  int[] speeds_1 = {50, 50, 50, 200, 200, 200, 200};  
  setSpeed(fluentEnables, speeds_1); // set speed  
  int seconds = 300;
  int recordingsPerSecond = 30;
  String[] playback = loadStrings("poses.txt");

  getPaint(0,1);

  for (int pb=0; pb < playback.length; pb++) {
     float[] poses = float( split(playback[pb],",") );
    //float[] angles_3 = {45, 135, 65, 90, 90, 90, 80}; 
    if (poses.length == 7) {
      println("Going to : "+pb+" of "+playback.length+" : " + poses[0], poses[1], poses[2], poses[3], poses[4], poses[5], poses[6]);
      setServoAngles(poses);
      while(!isAllConverge){
             delay(10/recordingsPerSecond);
      }  
       println(".");
       if (pb%100==0) {
         getPaint(1,3);
       }

    }
  }
}