/*ICS2O Final Summative Evaluation
By Gordon Lin and Daniel Weng
*/

int currentScene = 2;

PFont[] regular = new PFont[3];
PFont[] light = new PFont[3];
PFont[] xLight = new PFont[3];
PFont[] thin = new PFont[3];

String[] saveData = {};

float loadError = 0;

float time = 0;

PImage square;
PImage back;
PImage[] character = new PImage[3];

int JUMPPOWER=-10;
float gravity=0.5;

float pos[] = {0.0, 0.0};

float vy=0;
float angle=0;

boolean moveLeft=false;
boolean moveRight=false;

int[] platx=new int[35];
int[] platy=new int[35];

ArrayList<ArrayList<Float>> trail = new ArrayList<ArrayList<Float>>();

void movePlayer(){
  if(moveRight){
    pos[0]+=10;;
  }
  if(moveLeft){
    pos[0]-=10;;
  }
  pos[1]+=vy;//moving the player up/down
  if (pos[1]>700-character[0].height){
    pos[1]=700-character[0].height;//keep the player on the ground
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

void initImgs(){
  character[0] = loadImage("Imgs/Character Body.png");
  character[1] = loadImage("Imgs/Character Arm.png");
  character[2] = loadImage("Imgs/Character Leg.png");
  for (int i = 0; i < 3; i++){
    character[i].resize(character[i].width*3/4, character[i].height*3/4);
  }
  character[1].resize(character[1].width*3/4, character[1].height*3/4);
}

void setup(){
  size(1280, 720);
  initFont();
  initImgs();
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
  if (key==32 && pos[1]==700-character[0].height){//only jump if on ground
    vy=JUMPPOWER;//jumping power
  }
}//end keyPressed

void platform(){
  for(int i=0;i<platx.length;i++){
    platx[i]=int(random(300,3750));
    platy[i]=int(random(400,500));
  }
}

float rotation = 0;
float vR = radians(8.5);


void addTrail(){

  tint(255,100);
  ArrayList<Float> newTrail = new ArrayList<Float>();
  newTrail.add(180.0);
  newTrail.add(pos[1]);
  newTrail.add(rotation);
  trail.add(newTrail);
}

void updateTrail(){
  for(int i = 0; i < trail.size(); i++){
    tint(255, trail.get(i).get(0));
    pushMatrix();
    translate(trail.get(i).get(0),trail.get(i).get(1)+character[0].height/3);
    rotate(trail.get(i).get(2));
    image(character[2], 0, character[1].height/2);
    rotate(-trail.get(i).get(2)*2);
    image(character[2], 0, character[1].height/2);
    popMatrix();
    image(character[0], trail.get(i).get(0), trail.get(i).get(1));
    if (trail.get(i).get(0)+square.width < 0){
      trail.remove(i);
    }
    trail.get(i).set(0, trail.get(i).get(0)-10);
  }
}

void drawArms(){
  rectMode(CENTER);
  pushMatrix();
  translate(200, pos[1]);
  if (mousePressed) rotate(-PI/2);
  else rotate(rotation);
  image(character[1], 0, character[1].height/2);
  rectMode(CENTER);
  rect(0, character[1].height, 20, 30); //placeholder for gun
  popMatrix();
}

void drawChar(){
  for (int i=0;i<platx.length;i++){
    rect(platx[i],platy[i],60,10); 
  }
  if (trail.size() == 0 || trail.get(trail.size()-1).get(0) <= 200-square.width/1.25 || trail.get(trail.size()-1).get(1) > pos[1]+square.height/1.25 || trail.get(trail.size()-1).get(1)+square.height/1.25 < pos[1]) addTrail();
  imageMode(CENTER);
  updateTrail();
  pos[0]-=3;
  tint(255, 255);
  fill(0,255,0);
  platform();
  if (rotation >= PI/4 || rotation <= -PI/4) vR*=-1;
  rotation+=vR;
  pushMatrix();
  translate(200,pos[1]+character[0].height/3);
  rotate(rotation);
  image(character[2], 0, character[1].height/2);
  rotate(-rotation*2);
  image(character[2], 0, character[1].height/2);
  popMatrix();
  image(character[0],200,pos[1]);
  drawArms();
}

void game(){
  movePlayer();
  for(int i=0;i<99999;i+=600){
    imageMode(CORNER);
    tint(255,255);
    image(back,pos[0]+i,0);
  }
   rectMode(CORNER);
  rect(0,565,width,565);
  drawChar();
}

void credits(){
}

void draw(){
  if (currentScene == 0) mainMenu();
  else if (currentScene == 1) credits();
  else if (currentScene == 2) game();
}
