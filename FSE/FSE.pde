/*ICS2O Final Summative Evaluation
By Gordon Lin and Daniel Weng
*/

int currentScene = 0;

PFont[] regular = new PFont[3];
PFont[] light = new PFont[3];
PFont[] xLight = new PFont[3];
PFont[] thin = new PFont[3];

String[] saveData = {};

float loadError = 0;

float time = 0;

PImage square;
PImage back;

int JUMPPOWER=-10;
float gravity=0.5;

float pos[] = {0.0, 0.0};

float vy=0;
float angle=0;

boolean moveLeft=false;
boolean moveRight=false;

ArrayList<ArrayList<Float>> trail = new ArrayList<ArrayList<Float>>();

void movePlayer(){
  if(moveRight){
    pos[0]+=10;;
  }
  if(moveLeft){
    pos[0]-=10;;
  }
  pos[1]+=vy;//moving the player up/down
  if (pos[1]>565-square.height){
    pos[1]=565-square.height;//keep the player on the ground
    vy=0;//stop falling
  }
  
  vy+=gravity;//apply gravity
}


void initFont(){
  for (int i = 0; i < regular.length; i++){
    regular[i] = createFont("Font/Montserrat-Regular.ttf", (i+1)*48);
    light[i] = createFont("Font/Montserrat-Light.ttf", (i+1)*48);
    xLight[i] = createFont("Font/Montserrat-LightItalic.ttf", (i+1)*48);
    thin[i] = createFont("Font/Montserrat-Thin.ttf", (i+1)*48);
  }
}

void setup(){
  size(1280, 720);
  initFont();
  square=loadImage("Imgs/white-small-square_25ab.png");
  back=loadImage("Imgs/Wiki-background.png");
  if (loadStrings("saveGame.txt") != null){
    saveData = loadStrings("saveGame.txt");
  }
}

void mainMenu(){
  background(0);
  fill(255);
  textFont(regular[1], 96);
  textAlign(CENTER, CENTER);
  text("Ultimate Dash", width/2, 100);
  
  textFont(light[0], 48);
  rectMode(CENTER);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2-60 && mouseY < height/2+20){
    fill(0);
    if (mousePressed) currentScene = 2;
  }
  else{
    fill(255);
  }
  rect(width/2, height/2-20, 300, 80);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2-60 && mouseY < height/2+20){
    fill(255);
  }
  else{
    fill(0);
  }
  text("Play Game", width/2, height/2-25);
  
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+40 && mouseY < height/2+120){
    fill(0);
  }
  else{
    fill(255);
  }
  rect(width/2, height/2+80, 300, 80);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+40 && mouseY < height/2+120){
    fill(255);
    if (mousePressed) currentScene = 1;
  }
  else{
    fill(0);
  }
  text("Credits", width/2, height/2+75);
  
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+140 && mouseY < height/2+220){
    fill(0);
    if (mousePressed) exit();
  }
  else{
    fill(255);
  }
  rect(width/2, height/2+180, 300, 80);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+140 && mouseY < height/2+220){
    fill(255);
  }
  else{
    fill(0);
  }
  text("Exit", width/2, height/2+175);
  
}

void keyPressed(){
  if (key==32 && pos[1]==565-square.height){//only jump if on ground
    vy=JUMPPOWER;//jumping power
  }
}//end keyPressed

void addTrail(){
  tint(255,100);
  ArrayList<Float> newTrail = new ArrayList<Float>();
  newTrail.add(200.0);
  newTrail.add(pos[1]);
  trail.add(newTrail);
  time = millis();
}

void updateTrail(){
  tint(255, 100);
  for(int i = 0; i < trail.size(); i++){
    image(square, trail.get(i).get(0), trail.get(i).get(1));
    if (trail.get(i).get(0)+square.width < 0){
      trail.remove(i);
    }
    trail.get(i).set(0, trail.get(i).get(0)-1);
  }
}

int gameFrame = 0;

void game(){
  movePlayer();
  for(int i=0;i<99999;i+=600){
    tint(255,255);
    rotate(angle);
    //angle+=0.1;
    image(back,pos[0]+i,0);
    
  }
  rect(0,565,width,565);
  if (trail.size() == 0 || trail.get(trail.size()-1).get(0) <= 200-square.width/1.25 || trail.get(trail.size()-1).get(1) > pos[1]+square.height/1.25 || trail.get(trail.size()-1).get(1)+square.height/1.25 < pos[1]) addTrail();
  updateTrail();
  pos[0]-=10;
  tint(255, 255);
  image(square,200,pos[1]);
  fill(0,255,0);
}

void credits(){
}

void draw(){
  if (currentScene == 0) mainMenu();
  else if (currentScene == 1) credits();
  else if (currentScene == 2) game();
}
