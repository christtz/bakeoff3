import java.util.ArrayList;
import java.util.Collections;

int index = 0;

//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

int trialCount = 20; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0;
int errorCount = 0;  
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

final int screenPPI = 120; //what is the DPI of the screen you are using
//Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

int phoneWidth = 400; // these may change
int phoneHeight = 700;

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

int sliderHeight = 10; // these should change according to screen size
int sliderWidth = 200;
int sliderBarWidth = 10;
int sliderBarHeight = 50;

private class Slider
{
  //int translateX;
  //int translateY; 
  int x;
  int y;
  String attribute;
  
  Slider(String attribute)
  {
    //this.translateX = x;
    //this.translateY = y;
    this.attribute = attribute;
  }
  
  public void drawSlider()
  {
    pushMatrix();
    if (this.attribute == "rotation")
    {
      translate(width/2, height/7); // magic numbers
      this.x = width/2 - sliderWidth/2;
      this.y = height/7 - sliderHeight/2;
    }
    else 
    {
      translate(width/2, height/4);
      this.x = width/2 - sliderWidth/2;
      this.y = height/4 - sliderHeight/2;
    }
    //translate(this.translateX, this.translateY); // it's dumb that this doesn't work properly
    noStroke();
    fill(255,128);
    rect(0, 0, sliderWidth, sliderHeight);
    popMatrix();
  }
}

private class SliderBar
{
  int x = 0;
  int y = 0;
  String attribute;
  boolean target;
  
  SliderBar(String attribute, boolean target)
  {
    this.attribute = attribute;
    this.target = target;
  }
  
  SliderBar(String attribute, boolean target, int x) // perhaps won't use this constructor
  {
    this.attribute = attribute;
    this.target = target;
    this.x = x;
  }
  
  public void drawSliderBar()
  {
    pushMatrix();
    if (this.attribute == "rotation")
    {
      translate(width/2, height/7); // magic numbers
      this.x = width/2 - sliderBarWidth/2;
      this.y = height/7 - sliderBarHeight/2;
    }
    else 
    {
      translate(width/2, height/4);
      this.x = width/2 - sliderBarWidth/2;
      this.y = height/4 - sliderBarHeight/2;
    }
    noStroke();
    if (this.target) fill(255, 128);
    else fill(255,0,0,128);
    rect(this.x, this.y, sliderBarWidth, sliderBarHeight);
    popMatrix();
  }
    
}

Slider rotationSlider = new Slider("rotation");
SliderBar rotationTarget = new SliderBar("rotation", true);
SliderBar rotationCurrent = new SliderBar("rotation", false);
Slider scaleSlider = new Slider("scale");
SliderBar scaleTarget = new SliderBar("scale", true);
SliderBar scaleCurrent = new SliderBar("rotation", false);


//private class TargetCircle
//{
//  float x = width/4;
//  float y = 0;
//  float diameter = 30;
//  float rotation;
  
//  public void drawCircle(float rotation)
//  {
//    this.x = width/4*cos(rotation);
//    this.y = width/4*sin(rotation);
//    this.rotation = rotation;
    
//    fill(255,0,0, 200);
//    ellipse(this.x, this.y, diameter, diameter);
//    rotate(this.rotation);
//    rect(this.x, this.y, diameter/2, diameter*2);
    
//  }
//}

//https://amnonp5.wordpress.com/2012/01/28/25-life-saving-tips-for-processing/
// ^ #17 shows math to find if mouse is over a circle

//TargetCircle targetCircle = new TargetCircle();

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  //size does not let you use variables, so you have to manually compute this
  size(400, 700); //set this, based on your sceen's PPI to be a 2x3.5" area.

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.15f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    t.z = ((i%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0"
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {

  background(60); //background is dark grey
  fill(200);
  noStroke();

  if (startTime == 0)
    startTime = millis();

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);

    return;
  }
  
  Target t = targets.get(trialIndex);

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));

  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen

  fill(255, 128); //set color to semi translucent
  rect(0, 0, screenZ, screenZ);

  popMatrix();
  
  //============DRAW ROTATION GUIDE=================
  //pushMatrix();
  //translate(width/2, height/2);
  //strokeWeight(3);
  //stroke(255, 128);
  //noFill();
  //ellipse(0, 0, width/2, width/2);
  
  //// draw targetting circle
  //noStroke();
  //fill(0,255,0, 200);
  //ellipse(width/4, 0, 30, 30);
  
  //// draw target circle
  ////fill(255,0,0, 200);
  ////targetCircle.drawCircle(t.rotation);
  
  //popMatrix();
  
  //============DRAW ROTATION LINE==============
  rotationSlider.drawSlider();
  scaleSlider.drawSlider();
  rotationTarget.drawSliderBar();
  //rotationCurrent
  scaleTarget.drawSliderBar();
  System.out.println(rotationSlider.x);
  
  
  //===========DRAW TARGET SQUARE================= (do last so it doesn't get overlapped)
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
  rotate(radians(t.rotation));
  fill(255, 0, 0); //set color to semi translucent
  rect(0, 0, t.z, t.z);
  popMatrix();
  

  scaffoldControlLogic(); //you are going to want to replace this!

  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

void scaffoldControlLogic()
{
  fill(255);
  //upper left corner, rotate counterclockwise
  //text("CCW", inchesToPixels(.2f), inchesToPixels(.2f));
  //if (mousePressed && dist(0, 0, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenRotation--;

  ////upper right corner, rotate clockwise
  //text("CW", width-inchesToPixels(.2f), inchesToPixels(.2f));
  //if (mousePressed && dist(width, 0, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenRotation++;

  ////lower left corner, decrease Z
  //text("-", inchesToPixels(.2f), height-inchesToPixels(.2f));
  //if (mousePressed && dist(0, height, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenZ-=inchesToPixels(.02f);

  ////lower right corner, increase Z
  //text("+", width-inchesToPixels(.2f), height-inchesToPixels(.2f));
  //if (mousePressed && dist(width, height, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenZ+=inchesToPixels(.02f);

  ////left middle, move left
  //text("left", inchesToPixels(.2f), height/2);
  //if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenTransX-=inchesToPixels(.02f);
  //;

  //text("right", width-inchesToPixels(.2f), height/2);
  //if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenTransX+=inchesToPixels(.02f);
  //;

  //text("up", width/2, inchesToPixels(.2f));
  //if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenTransY-=inchesToPixels(.02f);
  //;

  //text("down", width/2, height-inchesToPixels(.2f));
  //if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchesToPixels(.5f))
  //  screenTransY+=inchesToPixels(.02f);
  //;
}

void mouseReleased()
{
  //check to see if user clicked middle of screen
  if (dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    //and move on to next trial
    trialIndex++;

    screenTransX = 0;
    screenTransY = 0;

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
    boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
	boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"	
	println("Close Enough Distance: " + closeDist);
    println("Close Enough Rotation: " + closeRotation + "(dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
	println("Close Enough Z: " + closeZ);
	
	return closeDist && closeRotation && closeZ;	
}

double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }