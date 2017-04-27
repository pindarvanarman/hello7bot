import processing.net.*;  //<>// //<>// //<>// //<>// //<>// //<>//
import http.requests.*;

String username = "elastic_username";
String password = "elastic_password";

String data;

double indexPaintingWidth  = 1.0;
double indexPaintingHeight = 1.0;

void testIndex() {
  
  //hunter_0602_black //98
   String index = "strokes_000000589_corinne_0800"; //207
   String destIndex = "corinne_0800_background";

   
   System.out.println("PUT /"+destIndex+" {\"mappings\":{\"brushstroke\":{\"properties\":{\"name\":{\"type\":\"string\"},\"location\":{\"type\":\"geo_point\"}}}}}");
   
   /*
   PUT /strokes_hunter_005_test_0005
    {
      "mappings": {
        "brushstroke": {
          "properties": {
            "name": {
              "type": "string"
            },
            "location": {
              "type": "geo_point"
            }
          }
        }
      }
    }
   */
   
  /*TO INDEX*/
   for (int i=1; i<=394;i++) { //1486; i++ ) {
     JSONObject singleRecord = getNextBrushstroke(index, i);
     JSONObject singleRecordWithLatLon = addLatLon(singleRecord); 
     //System.out.println(singleRecordWithLatLon.toString());
     indexBrushStroke(destIndex, singleRecordWithLatLon);
    System.out.println(":::::::::" + i);
   }

}

JSONObject addLatLon(JSONObject singleRecord) {

  JSONObject hits = singleRecord.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  JSONObject firstHit = hitArray.getJSONObject(0);
  JSONObject source = firstHit.getJSONObject("_source");
  
  JSONObject singleRecordWithLatLon = source;
  
  double avgX =   getAverageX(singleRecord); 
  double avgY =   getAverageY(singleRecord); 

  singleRecordWithLatLon.setDouble("averageX", avgX);
  singleRecordWithLatLon.setDouble("averageY", avgY);
  
  JSONObject location = new JSONObject();
  location.setDouble("lon", avgX);
  location.setDouble("lat", avgY);

  singleRecordWithLatLon.setJSONObject("location", location);

  return singleRecordWithLatLon;

}

/*
GET strokes_0600_hunter_portrait_000/brushstroke/_search
{"query":{"geo_bounding_box": {"location": {"top_left": {"lat": 5.2,"lon": 6.0},"bottom_right": {"lat": 5.0,"lon": 6.2}}}}}
*/



/*
%7b%22query%22:%7b%22geo_bounding_box%22: %7b%22location%22: %7b%22top_left%22: %7b%22lat%22: 5.2,%22lon%22: 6.0%7d,%22bottom_right%22: %7b%22lat%22: 5.0,%22lon%22: 6.2%7d%7d%7d%7d%7d
*/

JSONObject getStrokeAtPercent(String index, double x, double y) {
  double lat = indexPaintingHeight * y;
  double lon = indexPaintingWidth * x;
 
  /*
  %7b%22query%22:%7b%22geo_bounding_box%22: %7b%22location%22: %7b%22top_left%22: %7b%22lat%22:"+(lat+0.1)+",%22lon%22:"+(lon-0.1)+"%7d,%22bottom_right%22: %7b%22lat%22:"+(lat-0.1)+",%22lon%22:"+(lon+0.1)+"%7d%7d%7d%7d%7d
  */
 
  String theUrl =   new String("https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/"+index+"/brushstroke/_search?pretty=true&size=37&source=");
  //String theSource = new String("%7b%22sort%22:%5b%7b%22@timestamp%22:%7b%22order%22:%22desc%22%7d%7d%5d%7d");

  double geoPadding = 0.2;
  
  String theSource = new String("%7b%22query%22:%7b%22geo_bounding_box%22:%7b%22location%22:%7b%22top_left%22:%7b%22lat%22:"+(lat+geoPadding)+",%22lon%22:"+(lon-geoPadding)+"%7d,%22bottom_right%22:%7b%22lat%22:"+(lat-geoPadding)+",%22lon%22:"+(lon+geoPadding)+"%7d%7d%7d%7d%7d");
  
  String fullGetUrl = theUrl+theSource;
  
  System.out.println(fullGetUrl);
  
  GetRequest get = new GetRequest(fullGetUrl);
  get.addUser(username, password);
  get.send();
  //println("Reponse Content: " + get.getContent());
  String content = get.getContent();  
  JSONObject response = parseJSONObject(content);
  return response;
  
}



boolean hasHits(JSONObject brushstroke) {
  
  JSONObject hits = brushstroke.getJSONObject("hits");
  int total = hits.getInt("total");  
  if (total >=1) {
    return true;
  } else {
    return false;
  }
  
}

void indexBrushStroke(String newIndexName, JSONObject stroke) {
  
  //EXAMPLE
  
  //   POST twitter/tweet/
  // {
  //   "user" : "kimchy",
  //   "post_date" : "2009-11-15T14:12:12",
  //   "message" : "trying out Elasticsearch"
  // }
  
  //PostRequest post = new PostRequest("http://httprocessing.heroku.com");
  //post.addData("name", "Rune");
  //post.send();
  //println("Reponse Content: " + post.getContent());
  //println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
  //post.addUser("username", "password");
  //post.addHeader("Content-Type", "application/json");
  
  String testUrl = "https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/"+newIndexName+"/brushstroke/";
  String testSource = stroke.toString();
  
  PostRequest post = new PostRequest(testUrl);
  post.addHeader("Content-Type", "application/json");
  post.addJson(testSource);
  post.addUser(username, password);
  post.send();
  //System.out.println("Reponse Content:" + post.getContent() + "\n");
  //System.out.println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));

  
  
}

JSONObject getNextBrushstroke(String index, int strokeNumber) {
  
  //ap_info docs
  //https://a988764591d47d22b828dbd6616886fe.eu-west-1.aws.found.io:9243/snmp-*/ap_info/_search?pretty=true&q=*:*
  //https://a988764591d47d22b828dbd6616886fe.eu-west-1.aws.found.io:9243/snmp-*/ap_info/_search?pretty=true&size=16&sort=@timestamp:desc
  //https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/strokes_000000561_robottest_002/brushstroke/_search?q=strokeNumber:6
  //https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/strokes_000000558_robotarm_000/brushstroke/_search?{%22query%22:{%22match%22:{%22_id%22:%22AVoP7GYR3ya2kPajQxB5%22}}}
  
  //GetRequest get = new GetRequest("https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/strokes_000000558_robotarm_000/brushstroke/AVoP7GYR3ya2kPajQxB5");
  //https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/strokes_000000558_robotarm_000/brushstroke/_search?q=_id:AVoP7GYR3ya2kPajQxB5

  String workingElasticUrl = new String("https://a988764591d47d22b828dbd6616886fe.eu-west-1.aws.found.io:9243/snmp-2017-03-09/ap_info/_search?pretty=true&size=37&source=%7b%22sort%22:%5b%7b%22@timestamp%22:%7b%22order%22:%22desc%22%7d%7d%5d%7d");

  String indexUrl = "https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/"+index+"/brushstroke/_search?pretty=true";
  String source = new String("&source=%7b%22sort%22:%5b%7b%22@timestamp%22:%7b%22order%22:%22desc%22%7d%7d%5d%7d");
  String queryString = "&q=strokeNumber:"+strokeNumber;
  
  GetRequest get = new GetRequest(indexUrl+queryString);
  
  System.out.println(indexUrl+queryString);
  
  
  get.addUser(username, password); 

  get.send();
  //println("Reponse Content: " + get.getContent());
  
  // PostRequest post = new PostRequest("https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/"+index+"/brushstroke/_search");
  //   post.addUser("username", "password");
  //   post.send();
  //   post.addData("_id", "AVoP7GYR3ya2kPajQxB5");
  //   post.addHeader("Content-Type", "application/json");
  //https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/strokes_000000558_robotarm_000/brushstroke/_search?q=numberPoints:32
    
  //println("Reponse Content: " + get.getContent());
  //println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
  //source={\'query\': {\'match_all\': {}}}
  //data: params
  //curl -XGET 'localhost:9200/_search?pretty' -H 'Content-Type: application/json' -d'{"query": {"match_all": {}}}'
  //get.
 
  String content = get.getContent();  
  JSONObject response = parseJSONObject(content);
  return response;

}



JSONArray getStrokes(JSONObject brushstrokeObjects) {
 
  // Get the array of items from the JSON object
    // Get the array of items from the JSON object
  JSONObject hits = brushstrokeObjects.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  JSONObject firstHit = hitArray.getJSONObject(0);
  JSONObject source = firstHit.getJSONObject("_source");
  // Get the first item in the JSON array
  JSONArray path = source.getJSONArray("path");

  int numberOfPoints = path.size();

for (int i=0; i<numberOfPoints; i++) {
    // Get a JSON Object with a list of details about the first item
    JSONArray point = path.getJSONArray(i);
    Float x = point.getFloat(0);
    Float y = point.getFloat(1);
    println(" "+x+" : "+y+" ");
  }

  return path;
}

double getAverageX(JSONObject brushstrokeObjects) {
  // Get the array of items from the JSON object
  // Get the array of items from the JSON object
  JSONObject hits = brushstrokeObjects.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  JSONObject firstHit = hitArray.getJSONObject(0);
  JSONObject source = firstHit.getJSONObject("_source");
  // Get the first item in the JSON array
  JSONArray pathAvgPoint = source.getJSONArray("pathAveragePoint");
  double x = pathAvgPoint.getDouble(0);
  return x;
}

double getAverageY(JSONObject brushstrokeObjects) {
  // Get the array of items from the JSON object
  // Get the array of items from the JSON object
  JSONObject hits = brushstrokeObjects.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  JSONObject firstHit = hitArray.getJSONObject(0);
  JSONObject source = firstHit.getJSONObject("_source");
  // Get the first item in the JSON array
  JSONArray pathAvgPoint = source.getJSONArray("pathAveragePoint");
  double y = pathAvgPoint.getDouble(1);
  return y;
}

String getColor(JSONObject brushstrokeObjects) {
  // Get the array of items from the JSON object
  // Get the array of items from the JSON object
  JSONObject hits = brushstrokeObjects.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  JSONObject firstHit = hitArray.getJSONObject(0);
  JSONObject source = firstHit.getJSONObject("_source");
  // Get the first item in the JSON array
  String colorString = source.getString("color");
  return colorString;
}

float getPaintingWidth(JSONObject brushstrokeObjects) {
  // Get the array of items from the JSON object
  JSONObject hits = brushstrokeObjects.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  JSONObject firstHit = hitArray.getJSONObject(0);
  JSONObject source = firstHit.getJSONObject("_source");
  // Get the first item in the JSON array
  float width = source.getFloat("canvasWidth");
  return width;
}

float getPaintingHeight(JSONObject brushstrokeObjects) {
  // Get the array of items from the JSON object
  // Get the array of items from the JSON object
  JSONObject hits = brushstrokeObjects.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  JSONObject firstHit = hitArray.getJSONObject(0);
  JSONObject source = firstHit.getJSONObject("_source");
  float height = source.getFloat("canvasHeight");
  return height;
}

float getTimestamp(JSONObject brushstrokeObjects) {
  // Get the array of items from the JSON object
  JSONObject hits = brushstrokeObjects.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  JSONObject firstHit = hitArray.getJSONObject(0);
  JSONObject source = firstHit.getJSONObject("_source");
  // Get the first item in the JSON array
  float timestamp = source.getInt("timeStamp");
  return timestamp;
}

JSONArray getStrokes() { 
  //https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/strokes_000000533_the_scream_study_001/brushstroke/AVk_7LNZcPMzSlZMM2p7
  
  GetRequest get = new GetRequest("https://87b256626e4ad11cd37ac6d84dcba640.us-east-1.aws.found.io:9243/strokes_000000533_the_scream_study_001/brushstroke/AVk_7LNZcPMzSlZMM2p7");
  get.addUser(username, password);
  get.send();
  //println("Reponse Content: " + get.getContent());
  String content = get.getContent();  

  JSONObject response = parseJSONObject(content);

  // Declare some global variables
  String brushstroke; 
 
  // Get the array of items from the JSON object
    // Get the array of items from the JSON object
  JSONObject hits = response.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  JSONObject firstHit = hitArray.getJSONObject(0);
  JSONObject source = firstHit.getJSONObject("_source");
  
  // Get the first item in the JSON array
  JSONArray path = source.getJSONArray("path");

  int numberOfPoints = path.size();

for (int i=0; i<numberOfPoints; i++) {
    // Get a JSON Object with a list of details about the first item
    JSONArray point = path.getJSONArray(i);
    Float x = point.getFloat(0);
    Float y = point.getFloat(1);
    println(" "+x+" : "+y+" ");
  }

  return path;

}

JSONObject getElasticonDots() {
 
//URL: https://a988764591d47d22b828dbd6616886fe.eu-west-1.aws.found.io:9243
//user: pindar
//pwd: c1dp@1ntrgh78
  
  //ap_info docs
  //https://a988764591d47d22b828dbd6616886fe.eu-west-1.aws.found.io:9243/snmp-*/ap_info/_search?pretty=true&q=*:*
  //String theurl = new String("https://a988764591d47d22b828dbd6616886fe.eu-west-1.aws.found.io:9243/snmp-2017-03-07/ap_info/_search?source={\"sort\":[{\"@timestamp\":{\"order\":\"desc\"}}]}"); 
 String theurl = new String("https://a988764591d47d22b828dbd6616886fe.eu-west-1.aws.found.io:9243/snmp-2017-03-09/ap_info/_search?pretty=true&size=37&source=%7b%22sort%22:%5b%7b%22@timestamp%22:%7b%22order%22:%22desc%22%7d%7d%5d%7d");
 
 String str = theurl;
byte[] utf8 = null;
byte[] conv = new byte[1];
try
{
  utf8 = str.getBytes("UTF-8");
} catch (Exception e) {}
StringBuffer sb = new StringBuffer();
for (int i = 0; i < utf8.length; i++)
{
  if (utf8[i] < 0) // Beyond Ascii: high bit is set, hence negative byte
  {
    sb.append("%" + Integer.toString(256 + (int)utf8[i], 16));
  }
  else
  {
    conv[0] = utf8[i];
    try
    {
  sb.append(new String(conv, "ASCII")); // Convert back to Ascii
    } catch (Exception e) {}
  }
}
println(sb);
 
  String theurlutf8 = sb.toString();

  println(theurlutf8);
  //GetRequest get = new GetRequest("https://a988764591d47d22b828dbd6616886fe.eu-west-1.aws.found.io:9243/snmp-2017-03-07/ap_info/_search?pretty=true&size=37&source={"sort\":[{\"@timestamp\":{\"order\":\"desc\"}}]}");
  GetRequest get = new GetRequest(theurlutf8);
  //GetRequest get = new GetRequest("https://a988764591d47d22b828dbd6616886fe.eu-west-1.aws.found.io:9243/snmp-*/ap_info/_search?pretty=true&q=*:*&size=16");
  get.addUser("pindar", "c1dp@1ntrgh78");
  get.send();
  println("Reponse Content: " + get.getContent());
  String content = get.getContent();  
  JSONObject response = parseJSONObject(content);
  return response;
}

void parseElasticonDots(JSONObject apInfoObjects) {
 
  // Get the array of items from the JSON object
    // Get the array of items from the JSON object
  JSONObject hits = apInfoObjects.getJSONObject("hits");
  JSONArray hitArray = hits.getJSONArray("hits");
  for (int i=0; i<hitArray.size();i++) {
    JSONObject hit = hitArray.getJSONObject(i);
    JSONObject source = hit.getJSONObject("_source");
    // Get the first item in the JSON array
    //String num  = ""+source.getFloat("number");
    String macAddress  = source.getString("mac_address");
    float connections = float(source.getString("num_auth_clients"));
    if (connections == 0) {
      connections = 1 ;
    }
    connectionsPerAccessPoint[i] = connections;

    System.out.println(macAddress+" : "+connections);
    float latty = getLatFromMacAddress(macAddress);
    float lonny = getLonFromMacAddress(macAddress);
    float latPercentage = getLatPositionPercentage(latty);
    float lonPercentage = getLonPositionPercentage(lonny);
    //System.out.println("Location : "+num);
    goToStartPose();
    //smoothStrokeElastic(0.1, 0.9, 0.9, 0.9, threeBrushVec56, 0);
    System.out.println(""+ connections + " points at "+ lonPercentage+", " +latPercentage);
    //smoothStrokeElastic(lonPercentage, latPercentage, lonPercentage, latPercentage, threeBrushVec56, 90, false, true, false);
    //smoothStrokeElastic(lonPercentage, latPercentage, lonPercentage, latPercentage, threeBrushVec56, 90, true, false, false);
    //smoothStrokeElastic(lonPercentage, latPercentage, lonPercentage, latPercentage, threeBrushVec56, 90, false, false, true);  
}
  
  
}