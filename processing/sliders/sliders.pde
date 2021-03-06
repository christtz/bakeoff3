import java.util.ArrayList;
import java.util.Collections;

int index = 0;

//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

float xOffset = 0.0;  //used to get offset from target to mouse
float yOffset = 0.0; 

int trialCount = 10; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0;
int errorCount = 0;  
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

final int screenPPI = 445; //what is the DPI of the screen you are using
//Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

int phoneWidth = 900; // need to compute and then set size.x to this manually
int phoneHeight = 1558;

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

// these should change according to screen size
float sliderHeight = 20; 
float sliderWidth = inchesToPixels(1.6f);
float scaleSliderHeight = inchesToPixels(1f);
float scaleSliderWidth = 20;
float sliderBarWidth = inchesToPixels(0.4f);
float sliderBarHeight = inchesToPixels(0.5f);

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
  boolean dragged = false;
  boolean locked = false;
  
  public boolean containsMouse()
  {
    /*
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    translate(t.x, t.y); //center the drawing coordinates to the center of the screen
    translate(screenTransX, screenTransY);
    */
    // correct for translations
    float xmin = width/2 + this.x + screenTransX - this.z/2;
    float xmax = width/2 + this.x + screenTransX + this.z/2;
    float ymin = height/2 + this.y + screenTransY - this.z/2;
    float ymax = height/2 + this.y + screenTransY + this.z/2;
    
    boolean value = (mouseX >= xmin && mouseX <= xmax && mouseY >= ymin && mouseY <= ymax);
    return value;
  }
}

private class ScaleSlider
{
  boolean target;
  int x;
  int y;
  
  ScaleSlider(boolean target)
  {
    this.target = target;
  }
  
  public void draw()
  {
    noStroke();
    fill(255,200);
    if (this.target) this.x = int(width/2 - width/7);
    else this.x = int(width/2 + width/7);
    this.y = int(height/3.6 + sliderBarWidth);
    // acceptable zone
    if (abs(currentTarget.z - screenZ)<inchesToPixels(0.05f)) fill(0,255,0,200);
    rect(this.x, this.y, scaleSliderWidth, scaleSliderHeight);
  }
}

private class ScaleSliderBar
{
  boolean target;
  boolean dragged = false;
  boolean locked = false;
  int x;
  int y;
  
  ScaleSliderBar(boolean target)
  {
    this.target = target;
  }
  
  private void findScaleHeight()
  {
    float delta;
    float range = (scaleSliderHeight - sliderBarWidth);
    if (this.target) delta = screenZ / inchesToPixels(2.85f);
    else delta = currentTarget.z / inchesToPixels(2.85f);
    int value = int(currentScaleSlider.y - range/2 + delta * range);
    this.y = value;
  }
  
  public void draw()
  {
    noStroke();
    if (this.target) fill(255, 200);
    else fill(255,0,0,200);
    // within acceptable zone
    if (this.target) println("current TARGET.Z: " + currentTarget.z);
    if (abs(currentTarget.z - screenZ)<inchesToPixels(0.05f)) fill(0,255,0,200);
    if (this.target) this.x = targetScaleSlider.x;
    else this.x = currentScaleSlider.x;
    if (!this.dragged) this.findScaleHeight();
    rect(this.x, this.y, sliderBarHeight, sliderBarWidth);
    //sop(this.y);
  }
  
  public boolean containsMouse()
  {
    return (mouseX >= this.x - sliderBarHeight/2 && mouseX <= this.x + sliderBarHeight/2 &&
       mouseY >= this.y - sliderBarWidth/2 && mouseY <= this.y + sliderBarWidth/2);
  }
} 


private class RotationSlider
{
  int x = 0;
  int y = 0;
  
  public void draw()
  {
    noStroke();
    fill(255,200);
    if (calculateDifferenceBetweenAngles(currentTarget.rotation,screenRotation)<=5) fill(0,255,0,200);
    this.x = width/2;
    this.y = height/7;    
    rect(this.x, this.y, sliderWidth, sliderHeight);
    // draw the little slide markers
    rect(this.x - sliderWidth/2 + 5/2, this.y, 5, sliderBarHeight);
    rect(this.x + sliderWidth/2 - 5/2, this.y, 5, sliderBarHeight);
  }
  
  // deprecated
  public boolean containsMouse() // padded out to sliderBarHeight
  {
    return (mouseX >= this.x + sliderBarWidth/2 - sliderWidth/2 && mouseX <= this.x + sliderWidth/2 - sliderBarWidth/2 &&
       mouseY >= this.y - sliderHeight/2 - sliderBarHeight/2 && mouseY <= this.y + sliderHeight/2 + sliderBarHeight/2);
  }
}

// Find a reasonable currentTarget.rotation value
float normalizedRotation() // it's here because I don't want to scroll down to it
{
  float range = (sliderWidth - sliderBarWidth);
  float delta = (mouseX - rotationSlider.x + range/2) / range;
  return (delta * 90);
}

private class RotationSliderBar
{
  int x = 0;
  int y = 0;
  boolean target;
  boolean dragged = false;
  boolean locked = false;
  
  RotationSliderBar(boolean target)
  {
    this.target = target;
    this.x = phoneWidth/2; // width and height are currently undefined
    //this.x = this.findTargetLocation();
  }
  
  private void normalizedRotationLocation()
  {
    currentTarget.rotation %= 90;
    float range = (sliderWidth - sliderBarWidth);
    float delta = currentTarget.rotation / 90.0;
    float loc = rotationSlider.x - range/2 + delta * range;
    this.x = int(loc);
  }
  
  private int findScaleHeight()
  {
    float delta;
    float range = (scaleSliderHeight - sliderBarWidth);
    if (this.target) delta = screenZ / inchesToPixels(2.85f);
    else delta = currentTarget.z / inchesToPixels(2.85f);
    int value = int(currentScaleSlider.y - range/2 + delta * range);
    return value;
  }
  
  public void draw()
  {
    noStroke();
    if (this.target) fill(255, 200);
    else fill(255,0,0,200);
    if (!this.target && !this.dragged) this.normalizedRotationLocation();
    //if (this.target) this.findTargetLocation();
    if (calculateDifferenceBetweenAngles(currentTarget.rotation,screenRotation)<=5) 
    {
      fill(0,255,0,200);
      //this.locked = true; // need to set it on mouse release
    }
    this.y = height/7;
    rect(this.x, this.y, sliderBarWidth, sliderBarHeight);
  }
  
  public boolean containsMouse() // don't need this; covered by SliderBar area + padding
  {
    return (mouseX >= this.x - sliderBarWidth/2 && mouseX <= this.x + sliderBarWidth/2 &&
       mouseY >= this.y - sliderBarHeight/2 && mouseY <= this.y + sliderBarHeight/2);
  }
    
}

RotationSlider    rotationSlider  = new RotationSlider();
RotationSliderBar rotationCurrent = new RotationSliderBar(false);
ScaleSlider targetScaleSlider = new ScaleSlider(true);
ScaleSlider currentScaleSlider = new ScaleSlider(false);
ScaleSliderBar targetScaleSliderBar = new ScaleSliderBar(true);
ScaleSliderBar currentScaleSliderBar = new ScaleSliderBar(false);

//https://amnonp5.wordpress.com/2012/01/28/25-life-saving-tips-for-processing/
// ^ #17 shows math to find if mouse is over a circle

ArrayList<Target> targets = new ArrayList<Target>();
Target currentTarget;
float originalRotation = -1000; // arbitrary number to check against

void setup() {
  //size does not let you use variables, so you have to manually compute this
  size(900, 1558); //set this, based on your sceen's PPI to be a 2x3.5" area.

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
  currentTarget = t;
  // set rotation targetting
  if (originalRotation == -1000) originalRotation = t.rotation;
  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height*3/4); //center the drawing coordinates to the center of the screen (actually a bit lower)
  rotate(radians(screenRotation));

  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen

  fill(255, 128); //set color to semi translucent
  rect(0, 0, screenZ, screenZ);

  popMatrix();

  fill(255);
  rotationSlider.draw();
  targetScaleSlider.draw();
  currentScaleSlider.draw();
  targetScaleSliderBar.draw();
  currentScaleSliderBar.draw();
  //rotationTarget.draw();
  rotationCurrent.draw();
  fill(255);  
  
  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
  rotate(radians(t.rotation));
  if (dist(t.x,t.y,-screenTransX,-screenTransY + height/4)<inchesToPixels(0.05f)) fill(0,255,0,200);
  else fill(255, 0, 0); //set color to semi translucent
  rect(0, 0, t.z, t.z);
  popMatrix();
  
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.25f));
}

void sop(String stuff) { System.out.println(stuff); }
void sop(int stuff) { System.out.println(stuff); }
void sop(float stuff) { System.out.println(stuff); }

void mousePressed() // for testing purposes
{

  xOffset = mouseX-screenTransX; 
  yOffset = mouseY-screenTransY; 
  //mouseHandling();
  //if (dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(.5f))
  //{
  //  // reset slider drag values
  //  rotationCurrent.dragged = false;
  //  targetScaleSliderBar.dragged = false;
  //  currentScaleSliderBar.dragged = false;
  //  originalRotation = -1000;
  //  rotationCurrent.locked = false;
    
  //  if (userDone==false && !checkForSuccess())
  //    errorCount++;

  //  //and move on to next trial
  //  trialIndex++;

  //  screenTransX = 0;
  //  screenTransY = 0;

  //  if (trialIndex==trialCount && userDone==false)
  //  {
  //    userDone = true;
  //    finishTime = millis();
  //  }
  //}
  
}

float normalizedScale()
{
  float range = (scaleSliderHeight - sliderBarWidth);
  float delta = (dist(mouseY, 0, targetScaleSlider.y - range/2, 0)) / range;
  return delta * inchesToPixels(2.85f);
}

void mouseDragged()
{
  mouseHandling();
}

void mouseHandling()
{
  // give the square preference as it may overlap sliders
  if (currentTarget.containsMouse() && !currentTarget.locked)
  {
    //float xmin = width/2 + this.x + screenTransX - this.z/2;
    //float xmax = width/2 + this.x + screenTransX + this.z/2;
    //float ymin = height/2 + this.y + screenTransY - this.z/2;
    //float ymax = height/2 + this.y + screenTransY + this.z/2;
    currentTarget.dragged = true;
    screenTransX = mouseX - xOffset;
    screenTransY = mouseY - yOffset;
  }
  else if (rotationCurrent.containsMouse() && withinSliderRange(rotationSlider) && !rotationCurrent.locked) 
  {
    rotationCurrent.dragged = true;
    rotationCurrent.x += (mouseX - pmouseX);
    currentTarget.rotation = normalizedRotation();
  }
  else if (currentScaleSliderBar.containsMouse() && withinSliderRange(currentScaleSlider) && !currentScaleSliderBar.locked)
  {
    currentScaleSliderBar.dragged = true;
    currentScaleSliderBar.y = mouseY+2; // this is the only place addressing the pixel issue works. ugh
    println("CURRENT TARGET Y normalizing:" + currentScaleSliderBar.y);
    currentTarget.z = normalizedScale(); 
    sop("target: "+targetScaleSliderBar.y+", current: "+currentScaleSliderBar.y);
  } 
  else if (targetScaleSliderBar.containsMouse() && withinSliderRange(targetScaleSlider) && !targetScaleSliderBar.locked) 
  {
   //System.out.println("target z: "+screenZ);
   targetScaleSliderBar.dragged = true;
   targetScaleSliderBar.y = mouseY;
   
   screenZ = normalizedScale();
  }
}

boolean withinSliderRange(RotationSlider slider)
{
  return (mouseX >= slider.x - (sliderWidth - sliderBarWidth)/2 && mouseX <= slider.x + (sliderWidth - sliderBarWidth)/2);
}

boolean withinSliderRange(ScaleSlider slider)
{
  return (mouseY >= slider.y - (scaleSliderHeight - sliderBarWidth)/2 && mouseY <= slider.y + (scaleSliderHeight - sliderBarWidth)/2);
}

void mouseReleased()
{
  
  // locking
  if (calculateDifferenceBetweenAngles(currentTarget.rotation,screenRotation)<=5) rotationCurrent.locked = true;
  if (dist(currentTarget.x,currentTarget.y,-screenTransX,-screenTransY + height/4)<inchesToPixels(0.05f)) currentTarget.locked = true;
  if (abs(currentTarget.z - screenZ)<inchesToPixels(0.05f))
  {
    targetScaleSliderBar.locked = true;
    currentScaleSliderBar.locked = true;
  }
  
  // separate if than locking
  if (checkForSuccess())
  {
    // reset slider drag values
    rotationCurrent.dragged = false;
    targetScaleSliderBar.dragged = false;
    currentScaleSliderBar.dragged = false;
    originalRotation = -1000;
    rotationCurrent.locked = false;
    currentTarget.locked = false;
    targetScaleSliderBar.locked = false;
    currentScaleSliderBar.locked = false;
    
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
    boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY + height/4)<inchesToPixels(.05f); //has to be within .1" // add height to support translation
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