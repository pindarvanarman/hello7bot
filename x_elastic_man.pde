
JSONObject access_points = null;

float[] connectionsPerAccessPoint;

float minLon =  1000000;
float maxLon = -1000000;
float minLat =  1000000;
float maxLat = -1000000;


void initializeAccessPoints() {
  
  
  String[] access_points_strings = loadStrings("access_points.json");
  String access_point_json = "";

  for (int pb=0; pb < access_points_strings.length; pb++) {
      access_point_json += access_points_strings[pb];
  }
 access_points = parseJSONObject(access_point_json);
 
 JSONArray accesspoints = access_points.getJSONArray("access_points");
 
 //TEST VALUES
 connectionsPerAccessPoint = new float[accesspoints.size()];
 for (int i=0; i<accesspoints.size();i++) {
   JSONObject point = accesspoints.getJSONObject(i);
   connectionsPerAccessPoint[i] = point.getFloat("test_num_clients")+1;
 }
 
 setMinAndMaxLatLons();
}

void setMinAndMaxLatLons() {
  JSONArray accesspoints = access_points.getJSONArray("access_points");
  for (int i=0; i<accesspoints.size();i++) {
    JSONObject point = accesspoints.getJSONObject(i);
    float thisLat = point.getFloat("lat");
    float thisLon = point.getFloat("lon");

    if(thisLat < minLat) {
      minLat = thisLat;
    }
    if(thisLon < minLon) {
      minLon = thisLon;
    }
    if(thisLat > maxLat) {
      maxLat = thisLat;
    }
    if(thisLon > maxLon) {
      maxLon = thisLon;
    }
    System.out.println(" : : "+minLat+", "+minLon+" : : "+maxLat+", "+maxLon);
  }
}

float getLatFromMacAddress(String macAddress) {
  JSONArray accesspoints = access_points.getJSONArray("access_points");
  float foundLat = 10.0;
  for (int i=0; i<accesspoints.size();i++) {
    JSONObject point = accesspoints.getJSONObject(i);
    String point_mac_address = point.getString("mac_address");
    if(point_mac_address.equals(macAddress)) {
         foundLat = point.getFloat("lat");
    } 
  }
  return foundLat;
}

float getLonFromMacAddress(String macAddress) {
  JSONArray accesspoints = access_points.getJSONArray("access_points");
  float foundLon = -10.0;
  for (int i=0; i<accesspoints.size();i++) {
    JSONObject point = accesspoints.getJSONObject(i);
    String point_mac_address = point.getString("mac_address");
    if(point_mac_address.equals(macAddress)) {
         foundLon = point.getFloat("lon");
    } 
  }
  return foundLon;
}

//given a lat, find where it stands between minLat and maxLat - on scale of 0 to 1
float getLatPositionPercentage(float lat) {
  float normalizedMaxLat = maxLat-minLat;  //30
  float normalizedLat = lat-minLat;   //25
  float percentageLat = normalizedLat/normalizedMaxLat;
  return 0.15+(percentageLat*0.7);
}
float getLonPositionPercentage(float lon) {
  float normalizedMaxLon = maxLon-minLon;
  float normalizedLon = lon-minLon;
  float percentageLon = normalizedLon/normalizedMaxLon;
  return 0.1+(percentageLon*0.8);
}


void markElasticonAccessPoints() {
  JSONArray accesspoints = access_points.getJSONArray("access_points");
  //get Color
  for (int i=0; i<accesspoints.size();i++) {
    if (i%6 == 0) {
         getPaint(1,3);
         //dipTheBrush(1, 1);
    }
    JSONObject ap = accesspoints.getJSONObject(i);
    String macAddress  = ap.getString("mac_address");
    float latty = getLatFromMacAddress(macAddress);
    float lonny = getLonFromMacAddress(macAddress);
    float latPercentage = getLatPositionPercentage(latty);
    float lonPercentage = getLonPositionPercentage(lonny);

    goToStartPose();
    smoothStroke(lonPercentage, latPercentage, lonPercentage, latPercentage, easelVec56, 0, false, true, false);
    smoothStroke(lonPercentage, latPercentage, lonPercentage, latPercentage, easelVec56, 0, true, false, false);
    smoothStroke(lonPercentage, latPercentage, lonPercentage, latPercentage, easelVec56, 0, false, false, true);  
  } 
}

int getRandomAccessPointBasedOnProbability() {
    float totalAccesses = 0;
    for (int i=0; i< connectionsPerAccessPoint.length; i++) {
      totalAccesses += connectionsPerAccessPoint[i];
    }
    float randomNumber = random(totalAccesses);
    for (int i=0; i< connectionsPerAccessPoint.length; i++) {
      randomNumber = randomNumber - connectionsPerAccessPoint[i];
      if (randomNumber<0) {
        return i;
      }
    }
    return 0;
  }
  
 int dotsPainted = 0;
 void paintRandomAccessPoint(int numberOfDots){
   for (int i=0; i<numberOfDots;i++) {
     dotsPainted = dotsPainted+1;
    if (i%8 == 0) {
         goToStartPose();
         getPaint(2,3);
         //dipTheBrush(2,3);
         goToStartPose();
    }
    int accessPointNumber = getRandomAccessPointBasedOnProbability();
    JSONArray accesspoints = access_points.getJSONArray("access_points");
    JSONObject ap = accesspoints.getJSONObject(accessPointNumber);
    String macAddress  = ap.getString("mac_address");
    float latty = getLatFromMacAddress(macAddress);
    float lonny = getLonFromMacAddress(macAddress);

    float verticalOffset = random(-6,6);
    float horizontalOffset = random (-4,4);

    float latPercentage = getLatPositionPercentage(latty)+(verticalOffset/100);
    float lonPercentage = getLonPositionPercentage(lonny)+(horizontalOffset/100);

    System.out.println(":::"+dotsPainted+":::");
    goToStartPose();
    System.out.println(":::"+dotsPainted+":::");
    goToStartPose();
    smoothStroke(lonPercentage, latPercentage, lonPercentage, latPercentage, easelVec56, 90, false, true, false);
    smoothStroke(lonPercentage, latPercentage, lonPercentage, latPercentage, easelVec56, 90, true, false, false);
    smoothStroke(lonPercentage, latPercentage, lonPercentage, latPercentage, easelVec56, 90, false, false, true);  
    
   }
   
   
 }