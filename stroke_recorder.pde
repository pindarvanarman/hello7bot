
void recordStrokes() {

  int seconds = 600;
  int recordingsPerSecond = 10;

  ////////////////////////////////////////////////////////////////////////
  // 4- recevie and print pose 
 
  String poseFile = "";
  for(int i=0; i<(seconds*recordingsPerSecond); i++) {
          delay(100);
          println("Detect Poses: " + (i/(recordingsPerSecond)) +" : ", posD[0], posD[1], posD[2], posD[3], posD[4], posD[5], posD[6]);
          String poseLine = ""+i+","+posD[0]+","+posD[1]+","+posD[2]+","+posD[3]+","+posD[4]+","+posD[5]+","+posD[6];
          poseFile = poseFile +" "+poseLine;    
        String[] recording = split(poseFile, ' ');
        // Writes the strings to a file, each on a separate line
        saveStrings("poses.txt", recording);
  }
}