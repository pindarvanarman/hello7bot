
////////////////////////////////////////////////////////////////////////////////////////////
/* SENT DATA TO 7BOT */

// set motor force status: 0-forceless, 1-normal servo, 2-protection
void setForceStatus(int status) {
  myPort.write(0xFE);
  myPort.write(0xF5);
  myPort.write(status & 0x7F);
}

// set motion fluency & speeds (0~250 ---> 0~25)
void setSpeed(boolean fluentEnables[], int speeds[]) {
  // 1- Process Data
  int[] sendData = new int[SERVO_NUM];
  for (int i=0; i<SERVO_NUM; i++) {
    sendData[i] = constrain(speeds[i], 0, 250)/10;
    if (fluentEnables[i]) sendData[i] += 64;
  }
  // 2- Send Data
  myPort.write(0xFE);
  myPort.write(0xF7);
  for (int i=0; i<SERVO_NUM; i++) {
    myPort.write(sendData[i] & 0x7F);
  }
}


// set Servo angles
void setServoAngles(float servoAngles[]) {
  isAllConverge = false;
  // 1- Process Data
  int[] sendData = new int[SERVO_NUM];
  for (int i=0; i<SERVO_NUM; i++) {
    sendData[i] = (int)(servoAngles[i]*50/9);
  }
  // 2- Send Data
  myPort.write(0xFE);
  myPort.write(0xF9);
  for (int i=0; i<SERVO_NUM; i++) {
    myPort.write((sendData[i]/128) & 0x7F);
    myPort.write(sendData[i] & 0x7F);
  }
}


// IK6(6 angles)
// j6:mm(-500~500), vec:(-1.0~1.0)--->(-500~500), theta:Degrees
void setIK(PVector j6, PVector vec56, PVector vec67, float theta6) {
  isAllConverge = false;
  // 1- Process Data
  PVector j6_c = new PVector(constrain(j6.x, -500, 500), constrain(j6.y, -500, 500), constrain(j6.z, -500, 500));
  PVector vec56_c = vec56; 
  vec56_c.normalize(); 
  vec56_c.mult(500);
  PVector vec67_c = vec67; 
  vec67_c.normalize(); 
  vec67_c.mult(500);
  //
  int[] sendData = new int[10];
  sendData[0] = (int)abs(j6_c.x); 
  if (j6_c.x<0) sendData[0] += 1024; 
  sendData[1] = (int)abs(j6_c.y); 
  if (j6_c.y<0) sendData[1] += 1024; 
  sendData[2] = (int)abs(j6_c.z); 
  if (j6_c.z<0) sendData[2] += 1024; 
  //
  sendData[3] = (int)abs(vec56_c.x); 
  if (vec56_c.x<0) sendData[3] += 1024; 
  sendData[4] = (int)abs(vec56_c.y); 
  if (vec56_c.y<0) sendData[4] += 1024;  
  sendData[5] = (int)abs(vec56_c.z); 
  if (vec56_c.z<0) sendData[5] += 1024; 
  //
  sendData[6] = (int)abs(vec67_c.x); 
  if (vec67_c.x<0) sendData[6] += 1024; 
  sendData[7] = (int)abs(vec67_c.y); 
  if (vec67_c.y<0) sendData[7] += 1024; 
  sendData[8] = (int)abs(vec67_c.z); 
  if (vec67_c.z<0) sendData[8] += 1024; 
  //
  sendData[9] = (int)(theta6*50/9);
  // 2- Send Data
  myPort.write(0xFE);
  myPort.write(0xFA);
  for (int i=0; i<10; i++) {
    myPort.write((sendData[i]/128) & 0x7F);
    myPort.write(sendData[i] & 0x7F);
  }
}

// IK5(5 angles)
// j6:mm(-500~500), vec:(-1.0~1.0)--->(-500~500),  theta:Degrees
void setIK(PVector j6, PVector vec56, float theta5, float theta6) {
  isAllConverge = false;
  // 1- Process Data
  PVector j6_c = new PVector(constrain(j6.x, -500, 500), constrain(j6.y, -500, 500), constrain(j6.z, -500, 500));
  PVector vec56_c = vec56; 
  vec56_c.normalize(); 
  vec56_c.mult(500);
  //
  int[] sendData = new int[8];
  sendData[0] = (int)abs(j6_c.x); 
  if (j6_c.x<0) sendData[0] += 1024;   
  sendData[1] = (int)abs(j6_c.y); 
  if (j6_c.y<0) sendData[1] += 1024;   
  sendData[2] = (int)abs(j6_c.z); 
  if (j6_c.z<0) sendData[2] += 1024;  
  //
  sendData[3] = (int)abs(vec56_c.x); 
  if (vec56_c.x<0) sendData[3] += 1024;   
  sendData[4] = (int)abs(vec56_c.y); 
  if (vec56_c.y<0) sendData[4] += 1024;   
  sendData[5] = (int)abs(vec56_c.z); 
  if (vec56_c.z<0) sendData[5] += 1024; 
  //
  sendData[6] = (int)(theta5*50/9);
  sendData[7] = (int)(theta6*50/9);
  // 2- Send Data
  myPort.write(0xFE);
  myPort.write(0xFB);
  for (int i=0; i<8; i++) {
    myPort.write((sendData[i]/128) & 0x7F);
    myPort.write(sendData[i] & 0x7F);
  }
}


// IK3(3 angles)
// j5:mm(-500~500),   theta:Degrees
void setIK(PVector j5, float theta3, float theta4, float theta5, float theta6) {
  isAllConverge = false;
  // 1- Process Data
  PVector j5_c = new PVector(constrain(j5.x, -500, 500), constrain(j5.y, -500, 500), constrain(j5.z, -500, 500));
  //
  int[] sendData = new int[7];
  sendData[0] = (int)abs(j5_c.x); 
  if (j5_c.x<0) sendData[0] += 1024; 
  sendData[1] = (int)abs(j5_c.y); 
  if (j5_c.y<0) sendData[1] += 1024; 
  sendData[2] = (int)abs(j5_c.z); 
  if (j5_c.z<0) sendData[2] += 1024; 
  //
  sendData[3] = (int)(theta3*50/9);
  sendData[4] = (int)(theta4*50/9);
  sendData[5] = (int)(theta5*50/9);
  sendData[6] = (int)(theta6*50/9);
  // 2- Send Data
  myPort.write(0xFE);
  myPort.write(0xFC);
  for (int i=0; i<7; i++) {
    myPort.write((sendData[i]/128) & 0x7F);
    myPort.write(sendData[i] & 0x7F);
  }
}


////////////////////////////////////////////////////////////////////////////////////////////
/* RECEIVE DATA FROM 7BOT */

int[] dataBuf = new int[60];
boolean beginFlag = false;
int instruction = 0;
int cnt = 0;

void serialEvent(Serial myPort) {

  while (myPort.available () > 0) {

    // read data
    int rxBuf = myPort.read();
    if (!beginFlag)
    {
      beginFlag = rxBuf == 0xFE ? true : false; // Beginning Flag 0xFE
    } else
    {
      if (instruction == 0) instruction = rxBuf - 240;
      else {
        switch (instruction) {

        case 9:
          dataBuf[cnt++] = rxBuf;
          if (cnt >= SERVO_NUM * 2 + 1)
          {
            beginFlag = false;
            instruction = 0;
            cnt = 0;
            for (int i = 0; i < SERVO_NUM; i++) {
              int posCode = dataBuf[i * 2] * 128 + dataBuf[i * 2 + 1];
              force[i] = posCode%16384/1024; 
              if (posCode/16384>0) force[i] = - force[i];

              posD[i] = (posCode%1024)*9/50; // convert 0~1000 code to 0~180 degree(accuracy 0.18 degree)
            }

            if (dataBuf[(SERVO_NUM-1) * 2 + 2] == 1) isAllConverge = true;
            else isAllConverge = false;
          }
          break;

        default:
          beginFlag = false;
          instruction = 0;
          cnt = 0;
          break;
        }
      }
    }
  }
}