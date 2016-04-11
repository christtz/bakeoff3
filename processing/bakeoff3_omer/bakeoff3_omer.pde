import java.util.ArrayList;
import java.util.Collections;
import java.lang.Math;

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

final float root2 = (float) Math.sqrt(2);
float xOffset = 0.0;  //used to get offset from target to mouse
float yOffset = 0.0; 
float prevRotation = 0.0; 
float curRotation = 0.0;
float rotationDiff = 0.0;
boolean closeEnough = false;

float circleDiameter = 50.0;
float circleRadius = circleDiameter / 2;
Corners corners;

ArrayList<Target> targets = new ArrayList<Target>();
Target currentTarget;

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;

  public boolean containsMouse()
  {
    // correct for translations
    float xmin = width/2 + this.x + screenTransX - this.z/2;
    float xmax = width/2 + this.x + screenTransX + this.z/2;
    float ymin = height/2 + this.y + screenTransY - this.z/2;
    float ymax = height/2 + this.y + screenTransY + this.z/2;
    
    boolean value = (mouseX >= xmin && mouseX <= xmax && mouseY >= ymin && mouseY <= ymax);
    return value;
  }
}

private class Corners
{
  Target ct;
  float cx;
  float cy;
  float chypotenuse;

  boolean onTopRight = false;
  boolean onTopLeft = false;
  boolean onBotLeft = false;
  boolean onBotRight = false;

  public float getOppCornerX() {
    if (onTopRight)
      return cx + chypotenuse * cos(radians(ct.rotation) + 3*PI/4);
    else if (onTopLeft)
      return cx + chypotenuse * cos(radians(ct.rotation) + PI/4);
    else if (onBotLeft)
      return cx + chypotenuse * cos(radians(ct.rotation) - PI/4);
    else
      return cx + chypotenuse * cos(radians(ct.rotation) - 3*PI/4);
  }

  public float getOppCornerY() {
    if (onTopRight)
      return cy + chypotenuse * sin(radians(ct.rotation) + 3*PI/4);
    else if (onTopLeft)
      return cy + chypotenuse * sin(radians(ct.rotation) + PI/4);
    else if (onBotLeft)
      return cy + chypotenuse * sin(radians(ct.rotation) - PI/4);
    else
      return cy + chypotenuse * sin(radians(ct.rotation) - 3*PI/4);
  }

  public boolean rotationActive()
  {
    return (onTopRight || onTopLeft || onBotLeft || onBotRight);
  }

  private void clearRotation()
  {
    onTopRight = false;
    onTopLeft = false;
    onBotLeft = false;
    onBotRight = false;
  }

  public void setIfMouseOnCorner() {
    // set target and center
    ct = currentTarget;
    cx = width/2 + ct.x + screenTransX;
    cy = height/2 + ct.y + screenTransY; 
    chypotenuse = dist(cx, cy, cx + ct.z/2, cy + ct.z/2);

    mouseInTopRight();
    mouseInTopLeft();
    mouseInBotLeft();
    mouseInBotRight();
  }

  public void mouseInTopRight()
  { 
    float resx = cx + chypotenuse * cos(radians(ct.rotation) - PI/4);
    float resy = cy + chypotenuse * sin(radians(ct.rotation) - PI/4);
    if (dist(resx, resy, mouseX, mouseY) < circleRadius)
      onTopRight = true;
  }

  public void mouseInTopLeft()
  { 
    float resx = cx + chypotenuse * cos(radians(ct.rotation) - 3*PI/4);
    float resy = cy + chypotenuse * sin(radians(ct.rotation) - 3*PI/4);
    if (dist(resx, resy, mouseX, mouseY) < circleRadius)
      onTopLeft = true;
  }

  public void mouseInBotLeft()
  {   
    float resx = cx + chypotenuse * cos(radians(ct.rotation) + 3*PI/4);
    float resy = cy + chypotenuse * sin(radians(ct.rotation) + 3*PI/4);
    if (dist(resx, resy, mouseX, mouseY) < circleRadius)
      onBotLeft = true;
  }

  public void mouseInBotRight()
  {  
    float resx = cx + chypotenuse * cos(radians(ct.rotation) + PI/4);
    float resy = cy + chypotenuse * sin(radians(ct.rotation) + PI/4);
    if (dist(resx, resy, mouseX, mouseY) < circleRadius)
      onBotRight = true;
  }

  void drawCornerCircles() {
    // draw four corner starting from upper right clockwise
    // if (closeEnough) stroke(0, 255, 0);
    Target t = currentTarget;
    stroke(255, 255, 255);

    if (onTopLeft) fill(255, 255, 0);
    else fill(0, 255, 255);
    ellipse(-t.z/2, -t.z/2, circleDiameter, circleDiameter); // top right

    if (onTopRight) fill(255, 255, 0);
    else fill(0, 255, 255);
    ellipse(t.z/2, -t.z/2, circleDiameter, circleDiameter); // top right

    if (onBotLeft) fill(255, 255, 0);
    else fill(0, 255, 255);
    ellipse(-t.z/2, t.z/2, circleDiameter, circleDiameter); // top right

    if (onBotRight) fill(255, 255, 0);
    else fill(0, 255, 255);
    ellipse(t.z/2, t.z/2, circleDiameter, circleDiameter); // top right

  }
}

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

  // custom setup work

  Target t = targets.get(trialIndex);
  corners = new Corners();
  // initialize rotations
  prevRotation = t.rotation;
  curRotation = t.rotation;
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

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));

  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen

  // if (closeEnough) stroke(0, 255, 0);
  // else stroke(255, 255, 255);
  // noFill();
  // ellipse(0, 0, root2*screenZ, root2*screenZ);
  noStroke();
  fill(255, 128); //set color to semi translucent
  rect(0, 0, screenZ, screenZ);
  

  popMatrix();

  //===========DRAW TARGET SQUARE=================
  pushMatrix();

  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
  noStroke();
  fill(255, 0, 0); //set color to semi translucent
  rotate(radians(t.rotation));

  // if (corners.rotationActive()) {
  //   if (corners.onTopRight) {
  //     holdCornerAndDraw(-t.z/2, t.z/2);
  //   }
  //   else if (corners.onTopLeft) 
  //     rotateFromCorner(t.z/2, t.z/2);
  //   else if (corners.onBotLeft) 
  //     rotateFromCorner(t.z/2, -t.z/2);
  //   else 
  //     rotateFromCorner(-t.z/2, -t.z/2);
  // } else {
  //   rect(0, 0, t.z, t.z);
  // }

  rect(0, 0, t.z, t.z);
  corners.drawCornerCircles();
  // if (closeEnough) stroke(0, 255, 0);
  // else stroke(255, 255, 255);
  // noFill();
  // ellipse(0, 0, root2*t.z, root2*t.z);


  popMatrix();

  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

void holdCornerAndDraw(float dx, float dy) {
  translate(dx, dy);
  rect(-dx, -dy, currentTarget.z, currentTarget.z);
}

void mousePressed(){
  xOffset = mouseX-screenTransX; 
  yOffset = mouseY-screenTransY; 

  // keep track of rotation difference to keep refernce of where we drag from
  corners.setIfMouseOnCorner();
  if (corners.rotationActive())
  {
    curRotation = normalizedRotation();
    rotationDiff = curRotation - prevRotation;
    // println("mousePressed! curRotation is: "+ curRotation);
    // println("prevRotation: "+prevRotation);
    // println("rotationDiff: "+rotationDiff);
    // println(" ");
  }  
}

void mouseReleased(MouseEvent event)
{
  if (corners.rotationActive())
  {
      // save current rotation as previous
      prevRotation = curRotation;
      // println("End -> set prevRotation as: "+prevRotation);
      // println(" ");
  }
  corners.clearRotation();

  check();
  
  //check to see if user clicked middle of screen
  if (event.getClickCount() == 2 &&
      dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    //and move on to next trial
    trialIndex++;
    closeEnough = false;

    screenTransX = 0;
    screenTransY = 0;

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

void mouseDragged() {
    mouseHandling();
}

void mouseHandling()
{
  // give the square preference as it may overlap sliders
  if (corners.rotationActive())
  {
    curRotation = normalizedRotation() - rotationDiff;
    // println("prevRotation: "+prevRotation);
    // println("curRotation: "+curRotation);
    // println("rotationDiff: "+rotationDiff);
    currentTarget.rotation = curRotation;
  } else if (currentTarget.containsMouse())
  {
    screenTransX = mouseX - xOffset;
    screenTransY = mouseY - yOffset;
  }
}

// Find a reasonable currentTarget.rotation value
float normalizedRotation()
{
  float curX = width/2 + currentTarget.x + screenTransX;
  float curY = height/2 + currentTarget.y + screenTransY;
  // float curX = corners.getOppCornerX();
  // float curY = corners.getOppCornerY();

  float angle = atan((mouseY - curY) / (mouseX - curX));
  float rotation = angle * 180 / PI;

  return rotation;
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

public void check() 
{
  Target t = targets.get(trialIndex);  
  boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be withi  
 
  closeEnough = closeDist && closeRotation && closeZ;  
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