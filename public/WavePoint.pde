import processing.opengl.*;

int circleRadius = 100;
float inByte = 0;
float inByte2 = 0;
float[] audioArray = new float[720];
float[] audioArray2 = new float[720];
boolean up = false;
int counter = 0;
float delta;
float cGo;
float widthGo;
int radius;
boolean overlap;
boolean threeD;
boolean twoWaves;
boolean showBase1;
boolean showBase;
boolean showDetail;
boolean backToWhite = true;
float pointSpeed = 0.3;
//array variables for the data CSV files
var input1;
String[] input2;
String[] input3;
String[] input4;
String[] input5;
String[] input6;
//ArrayLists for two point/line visuals
ArrayList wpoints;
WavePoint wp;
WavePoint wp3;
WavePoint wp2;
WavePoint wp4;

//JAVASCRIPT variables
var waveToggle1 = false;
var waveToggle2 = false;
var clickCount = 0;
var inputAtr1;
var inputAtr2;
var allInputs;
var filler1;
var filler2;

 
void setup(){  
  size(screen.width, screen.height, OPENGL);
  smooth();
  background(0);
  textFont(createFont("Miso",32));
  
  widthGo = width/2;
  
  // Load the CSV
  input1 = loadStrings("2011-10-19-twominutes.csv");
  input2 = loadStrings("2011-10-20-twominutes.csv");
  input3 = loadStrings("2011-10-21-twominutes.csv");
  input4 = loadStrings("2011-10-22-twominutes.csv");
  input5 = loadStrings("2011-10-23-twominutes.csv");
  input6 = loadStrings("2011-10-24-twominutes.csv");
  
  //allInputs to be used in the website UI to select visible day
  allInputs = [input1, input2, input3, input4, input5, input6];
  
  //set baseline values for the two data arrays
  wpoints = new ArrayList();
  for (int i=0; i < audioArray.length; i++){
    audioArray[i]=inByte;
    audioArray2[i]=inByte;
    wpoints.add(new WavePoint());
  }  

  //set spacing for the objects based on their quantity
  delta = TWO_PI / (audioArray.length-1);
}

void draw(){
  background(0);
  waveDisplay();
}

void waveDisplay(){
  pushMatrix();
  if (showDetail == true){
    //widthGo += (width-widthGo)*(0.3);
    translate(width-100, height*0.4);
    float mapY = map(mouseY, 0, height, 420, 0);
    rotate(radians(mapY));
    circleRadius = 400;
  } else {
    //widthGo += ((width/2)-widthGo)*(0.3);
    translate(width/2, height*0.4);
    circleRadius = 100;
    rotate(0);
  }
  stroke(20);
  makeBase();//function to draw the guide
  cGo += (circleRadius-cGo)*(0.07);
  for (int i = 0; i < wpoints.size(); i++ ) {
     wp = (WavePoint) wpoints.get(i);
     stroke(50,40,50);
     strokeWeight(1);
     if(i+1 == wpoints.size()){
       wp2 = (WavePoint) wpoints.get(i);
     } else {
       wp2 = (WavePoint) wpoints.get(i+1);
     }
     /////////second day////////////
     if (twoWaves == true){
       wp3 = (WavePoint) wpoints.get(i);
       if(i+1 == wpoints.size()){
         wp4 = (WavePoint) wpoints.get(i);
       } else {
         wp4 = (WavePoint) wpoints.get(i+1);
       }
       line(wp3.xoff2,wp3.yoff2,wp4.xoff2,wp4.yoff2);
     }
     
     line(wp.xoff,wp.yoff,wp2.xoff,wp2.yoff);
     wp.display(i);
     wp.update1(i);
  } 
  popMatrix();
}

void makeBase(){
  if (showBase1 == true){
    stroke(20);
    strokeWeight(2);
    ellipse(0, 0, cGo*2, cGo*2 );
  }
  if (showBase == true){
    if (showDetail == true){ //should something get bigger/heavier when we zoom?
      
    } else {
      
    } 
      textSize(26);
      fill(60);
      textAlign(CENTER);
      text("NOON", 5, ((circleRadius*2)/2)+140);
      text("MIDNIGHT", 10, -((circleRadius*2)/2)-140);
      text("6PM", -((circleRadius*2)/2)-140, 0);
      text("6AM",((circleRadius*2)/2)+140 , 0);
      pushMatrix();
        rotate(radians(45));
        textSize(18);
        fill(60);
        text("0", circleRadius , 0);
        text("140" ,((circleRadius*2)/2)+138 , 0);
        text("280" ,((circleRadius*2)/2)+260 , 0);
        text("0", -circleRadius , 0);
        text("140", -((circleRadius*2)/2)-130 , 0);
        text("280", -((circleRadius*2)/2)-260 , 0);
        text("0", 0 , -circleRadius);
        text("140", 0, -((circleRadius*2)/2)-136);
        text("280", 0, -((circleRadius*2)/2)-260);
        text("0", 0 , circleRadius);
        text("140", 0, ((circleRadius*2)/2)+130);
        text("280", 0, ((circleRadius*2)/2)+260);
        noFill();
        stroke(20);
        strokeWeight(2);
        line(0, ((-circleRadius*2)/2)-260, 0, ((circleRadius*2)/2)+260);
        line(((-circleRadius*2)/2)-260, 0, ((circleRadius*2)/2)+260, 0);  
      popMatrix();
    ellipse(0, 0, cGo*2, cGo*2 );
    ellipse(0, 0, (cGo*2)+240, (cGo*2)+240 );
    ellipse(0, 0, (cGo*2)+500, (cGo*2)+500 );
    line(0, ((-circleRadius*2)/2)-260, 0, ((circleRadius*2)/2)+260);
    line(((-circleRadius*2)/2)-260, 0, ((circleRadius*2)/2)+260, 0);  
  }
}

void fillArrayZero(int whichArray){
    pointSpeed = 0.5;
    //backToWhite = true;
    overlap = false;
    showBase = false;
   for (int i = 0; i < audioArray.length; i++) {
    if (overlap == false){
      if(whichArray == 1){
        audioArray[counter]=0;
      } else if(whichArray == 2) {
        audioArray2[counter]=0;
      }
    }
    if (counter >= audioArray.length-1) {
     counter = 0;
     overlap = true;
    } else {
     counter+= 1;
    }
   }
}

void fillArrayValues(int[] date1){  
    pointSpeed = 0.5;
    //backToWhite = true;
    overlap = false;
    showBase = false;  
   for (int i = 0; i < audioArray.length; i++) {
    String[] splits = date1[i].split(",");
    audioArray[i]= float(splits[1]);
    if (counter >= audioArray.length-1) {
     counter = 0;
     overlap = true;
    } else {
     counter+= 1;
    }
  }
}

void fillArrayValues2(int[] date2){ 
    pointSpeed = 0.3;
    overlap = false;
    backToWhite = false;
    twoWaves = true;
    showBase1 = true;  
   for (int i = 0; i < audioArray2.length; i++) {
    String[] splits = date2[i].split(",");
    audioArray2[i]= float(splits[1]);
    if (counter >= audioArray2.length-1) {
     counter = 0;
     overlap = true;
    } else {
     counter+= 1;
    }
  }
}


class WavePoint {
  float rot;
  int count;
  float x;
  float xGo;
  float y;
  float yGo;
  float z;
  float zGo;
  float xoff = 0;
  float yoff = 0;
  float x2;
  float x2Go;
  float y2;
  float y2Go;
  float xoff2 = 0;
  float yoff2 = 0;

  WavePoint() { // "the constructor"
  }
 
  void update1(int qount){
     x = cos((qount+540) * delta) * (cGo + (int)audioArray[qount]);
     xGo += (x-xGo)*(pointSpeed);
     y = sin((qount+540) * delta) * (cGo + (int)audioArray[qount]);
     yGo += (y-yGo)*(pointSpeed);
     z = (int)audioArray[qount];
     zGo += (z-zGo)*(pointSpeed);
     //println("xGo = " + xGo + ", yGo = " + yGo);
     
     x2 = cos((qount+540) * delta) * (circleRadius + (int)audioArray2[qount]);
     x2Go += (x2-x2Go)*(pointSpeed);
     y2 = sin((qount+540) * delta) * (circleRadius + (int)audioArray2[qount]);
     y2Go += (y2-y2Go)*(pointSpeed);
     
     rot = delta * qount;
//     xFlat = qount-screen.width/2;
//     xf += (xFlat-xf)*(pointSpeed);
//     yFlat = -audioArray[qount];
//     yf += (yFlat-yf)*(pointSpeed);
  }

  void display(int kount) {
    noFill();
    strokeWeight(2);
    pushMatrix();
      translate(screen.width / 2, height / 2);
      xoff = 0;
      yoff = 0;
      xoff2 = 0;
      yoff2 = 0;
      if (threeD == true){
//        rotateX(radians(map(mouseX, 0, screen.width, 0, 360)));
//        rotateY(radians(map(mouseY, 0, height, 0, 360)));
//        translate(xGo, yGo, zGo);
        //translate(xf, yf);
      } else {
       translate(xGo, yGo);
       xoff+=xGo;
       yoff+=yGo;
       
       xoff2+=x2Go;
       yoff2+=y2Go;
       
       rotate(rot);
      }
      //fill(255,255,255,40);
      //noStroke();
      //rect(0, 0, 0-audioArray[kount], 2);
//      point(0, 0, 0);     
    popMatrix();
    
     if (backToWhite == true){
       stroke(200);
     } else 
     {
       //colorMode(HSB);
       float culrr = map(audioArray[kount], 0, max(audioArray), 80, 200); 
       stroke(culrr, culrr*0.6, culrr*0.5);
     }
    strokeWeight(3);
    point(xoff,yoff);
    if (twoWaves == true){
       float kulrr = map(audioArray2[kount], 0, max(audioArray2), 80, 300); 
       stroke(kulrr*0.5, kulrr*0.6, kulrr);
      point(xoff2,yoff2);
    }
  }
  
  
} // END: WavePoint class //




//////////////// START JQUERY FUNCTIONS ////////////////



$(document).ready(function(){
  $('.action2').click(function(){
    pointSpeed = 0.3;
    overlap = false;
    backToWhite = false;
    showBase1 = true;
    if (clickCount == 0) {
      inputAtr1 = $(this).attr('input');
          console.log("inputAtr1 = "+inputAtr1);
      int[] num = int(split(inputAtr1, ' '));
          console.log("num = "+num);
      filler1 = allInputs[num];
      fillArrayValues(filler1);
      clickCount ++;
    } else if (clickCount == 1 && $(this).attr('input') != inputAtr1) {
      inputAtr2 = $(this).attr('input');
      int[] num2 = int(split(inputAtr2, ' '));
      console.log("nun2 = "+num2);
      filler2 = allInputs[num2];
      fillArrayValues2(filler2);
      clickCount ++;
    } else if (clickCount > 3 && $(this).attr('input') != inputAtr1 || $(this).attr('input') != inputAtr2) {
      inputAtr1 = $(this).attr('input');
      int[] num3 = int(split(inputAtr1, ' '));
      filler1 = allInputs[num3];
      fillArrayValues(filler1);
      clickCount = 1;
    }
  });

   $('#dayo').click(function(){
     showDetail =! showDetail;
     showBase =! showBase;
     showBase1 =! showBase1;
   });
   $('#base').click(function(){
     showBase =! showBase;
     showBase1 =! showBase1;
   });
});

