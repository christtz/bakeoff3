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

int phoneWidth = 400; // need to compute and then set size.x to this manually
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
int sliderBarWidth = 20;
int sliderBarHeight = 50;

private class Slider
{
  //int translateX;
  //int translateY; 
  int x = 0;
  int y = 0;
  String attribute;
  //boolean hovered;
  //boolean selected;
  
  Slider(String attribute)
  {
    this.attribute = attribute;
  }
  
  public void drawSlider()
  {
    //pushMatrix();
    //translate(0,0);
    //translate(this.translateX, this.translateY); // it's dumb that this doesn't work properly
    noStroke();
    fill(255,200);
    this.x = width/2;
    if (this.attribute == "rotation") this.y = height/7;
    else this.y = height/4;
    
    rect(this.x, this.y, sliderWidth, sliderHeight);
    //popMatrix();
  }
  
  // I have no idea why this.x references the CENTER of the rectangle
  public boolean containsMouse() // padded out to sliderBarHeight
  {
    return (mouseX >= this.x + sliderBarWidth/2 - sliderWidth/2 && mouseX <= this.x + sliderWidth/2 - sliderBarWidth/2 &&
       mouseY >= this.y - sliderHeight/2 - sliderBarHeight/2 && mouseY <= this.y + sliderHeight/2 + sliderBarHeight/2);
  }
}

private class SliderBar
{
  int x = 0;
  int y = 0;
  //int translatedX = 0;
  //int translatedY = 0;
  String attribute;
  boolean target;
  //boolean hovered = false;
  //boolean selected = false;
  boolean dragged = false;
  
  SliderBar(String attribute, boolean target)
  {
    this.attribute = attribute;
    this.target = target;
    this.x = phoneWidth/2; // width and height are currently undefined
    // width and height go to a default if referenced before size() is called in setup
    // that's the case here because I create my objects before setup gets called (I guess?)
    if (this.attribute == "rotation") this.y = height/7;
    else this.y = height/4;
  }
  
  //SliderBar(String attribute, boolean target, int x) // perhaps won't use this constructor
  //{
  //  this.attribute = attribute;
  //  this.target = target;
  //  this.x = x;
  //}
  
  public void drawSliderBar()
  {
    //pushMatrix();
    noStroke();
    if (this.target) fill(255, 200);
    else fill(255,0,0,200);
    //System.out.println(this.x + " " +  this.y);
    if (this.attribute == "rotation") this.y = height/7; // I shouldn't need to define these again, but I do...
    else this.y = height/4;
    rect(this.x, this.y, sliderBarWidth, sliderBarHeight);
    //popMatrix();
  }
  
  public boolean containsMouse() // don't need this; covered by SliderBar area + padding
  {
    return (mouseX >= this.x - sliderBarWidth/2 && mouseX <= this.x + sliderBarWidth/2 &&
       mouseY >= this.y - sliderBarHeight/2 && mouseY <= this.y + sliderBarHeight/2);
  }
    
}

Slider rotationSlider = new Slider("rotation");
SliderBar rotationTarget = new SliderBar("rotation", true);
SliderBar rotationCurrent = new SliderBar("rotation", false);
Slider scaleSlider = new Slider("scale");
SliderBar scaleTarget = new SliderBar("scale", true);
SliderBar scaleCurrent = new SliderBar("scale", false);


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
Target currentTarget;

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
  
  //System.out.println(mouseX);
  //System.out.println(mouseY);

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
  currentTarget = t;

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
  fill(255);
  rotationSlider.drawSlider();
  scaleSlider.drawSlider();
  rotationTarget.drawSliderBar();
  
  // If it has been dragged, we don't want to reset it to its previous position
  if (!rotationCurrent.dragged) rotationCurrent.x = normalizedLocation(t.rotation);
  //System.out.println("rotation: " + t.rotation);
  rotationCurrent.drawSliderBar();
  scaleTarget.drawSliderBar();
  scaleCurrent.drawSliderBar();
  fill(255);
  //rect(rotationCurrent.x, rotationCurrent.y, 50,50);
  
  
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

// Finds a reasonable rotationCurrent.x value
int normalizedLocation(float rotation)
{
  float delta = (rotation - 180) / 180;
  return int(rotationTarget.x + delta * sliderWidth / 2);
}

// Find a reasonable currentTarget.rotation value
float normalizedRotation()
{
  float delta = mouseX - rotationTarget.x;
  return delta / (sliderWidth / 2) * 180 + 180;
  
}

void mousePressed()
{

}

void mouseDragged()
{

  int difference = mouseX - pmouseX;
  if (rotationSlider.containsMouse()) 
  {
    rotationCurrent.dragged = true;
    rotationCurrent.x = mouseX;
    currentTarget.rotation = normalizedRotation();
    // if moving left, increase angle
    //if (difference < 0) currentTarget.rotation++;
    //else currentTarget.rotation--;
    
    //rotationCurrent.x += difference;
    //System.out.println("yay" + mouseX);
  }
  //if (scaleSlider.selected) scaleSlider.x += difference;
  //if (rotationTarget.selected) rotationTarget.x += difference;
  //if (rotationCurrent.selected) rotationCurrent.x += difference;
  //if (scaleTarget.selected) scaleTarget.x += difference;
  //if (scaleCurrent.selected) scaleCurrent.x += difference;
  
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
  // deselect everything
  //rotationSlider.selected = false;
  //scaleSlider.selected = false;
  //rotationTarget.selected = false;
  //rotationCurrent.selected = false;
  //scaleTarget.selected = false;
  //scaleCurrent.selected = false;
  
  
  //check to see if user clicked middle of screen
  if (dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(.5f))
  {
    // reset slider drag values
    rotationCurrent.dragged = false;
    scaleCurrent.dragged = false;
    
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