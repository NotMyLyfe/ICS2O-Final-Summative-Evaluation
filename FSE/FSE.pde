/*ICS2O Final Summative Evaluation
By Gordon Lin and Daniel Weng
*/

int currentScene = 0;

PFont[] regular = new PFont[3];
PFont[] light = new PFont[3];
PFont[] xLight = new PFont[3];
PFont[] thin = new PFont[3];

PImage square;
PImage back;

int JUMPPOWER=-10;
float gravity=0.5;

float px=0.0;
float py=0.0;
float vy=0;
float angle=0;

boolean moveLeft=false;
boolean moveRight=false;

void movePlayer(){
  if(moveRight){
    px+=10;;
  }
  if(moveLeft){
    px-=10;;
  }
  py+=vy;//moving the player up/down
  if (py>450){
    py=450;//keep the player on the ground
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
  }
  else{
    fill(0);
  }
  text("Load Game", width/2, height/2+75);
  
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+140 && mouseY < height/2+220){
    fill(0);
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
  text("Credits", width/2, height/2+175);
  
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+240 && mouseY < height/2+320){
    fill(0);
  }
  else{
    fill(255);
  }
  rect(width/2, height/2+280, 300, 80);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+240 && mouseY < height/2+320){
    fill(255);
  }
  else{
    fill(0);
  }
  text("Exit", width/2, height/2+275);
  
}

void keyPressed(){
  if (key==32 && py==450){//only jump if on ground
    vy=JUMPPOWER;//jumping power
  }
}//end keyPressed


void game(){
  movePlayer();
  for(int i=0;i<99999;i+=600){
    //rotate(angle);
    // angle+=0.1;
    image(back,px+i,0);
    rect(0,565,800,565);
  }
  px-=10;
  image(square,200,py);
  fill(0,255,0);
}

void draw(){
  if (currentScene == 0) mainMenu();
  else if (currentScene == 3) game();
}
